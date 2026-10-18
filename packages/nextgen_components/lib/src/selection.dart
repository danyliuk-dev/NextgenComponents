import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'components.dart';

abstract final class NgSelectionRules {
  static final _idPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');
  static void validate(
    List<NgOption> items,
    List<String> value,
    bool multiple, {
    int? maxItems = 50,
  }) {
    if (maxItems != null && (maxItems < 0 || items.length > maxItems)) {
      throw ArgumentError('Option count exceeds the configured limit.');
    }
    final ids = <String>{};
    for (final item in items) {
      if (!_idPattern.hasMatch(item.value) ||
          item.label.trim().isEmpty ||
          item.label.length > 120 ||
          !ids.add(item.value)) {
        throw ArgumentError(
          'Options require unique IDs and nonblank labels of at most 120 characters.',
        );
      }
    }
    if ((!multiple && value.length > 1) ||
        value.toSet().length != value.length ||
        value.any((id) => !ids.contains(id))) {
      throw ArgumentError(
        'Use unique known selected IDs; single selection accepts at most one ID.',
      );
    }
  }

  static List<String> toggle(
    List<NgOption> items,
    List<String> value,
    String id,
    bool multiple,
    bool allowEmpty, {
    int? maxItems = 50,
  }) {
    validate(items, value, multiple, maxItems: maxItems);
    if (!items.any((item) => item.value == id && !item.disabled))
      return List.unmodifiable(value);
    final selected = value.toSet();
    if (selected.contains(id)) {
      if (!allowEmpty && selected.length == 1) return List.unmodifiable(value);
      selected.remove(id);
    } else {
      if (!multiple) selected.clear();
      selected.add(id);
    }
    return List.unmodifiable(
      items
          .where((item) => selected.contains(item.value))
          .map((item) => item.value),
    );
  }
}

class NgToggleButton extends StatelessWidget {
  final String label;
  final bool value, disabled;
  final ValueChanged<bool>? onChanged;
  const NgToggleButton({
    super.key,
    required this.label,
    this.value = false,
    this.onChanged,
    this.disabled = false,
  });
  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty || label.length > 120)
      throw ArgumentError('Use a nonblank label of at most 120 characters.');
    return MergeSemantics(
      child: Semantics(
        checked: value,
        enabled: !disabled && onChanged != null,
        child: OutlinedButton(
          style: value
              ? ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) =>
                        Theme.of(context).colorScheme.primary.withValues(
                          alpha: states.contains(WidgetState.disabled)
                              ? .25
                              : 1,
                        ),
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: .5)
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                )
              : null,
          onPressed: disabled || onChanged == null
              ? null
              : () => onChanged!(!value),
          child: Text(label),
        ),
      ),
    );
  }
}

class NgButtonGroup extends StatelessWidget {
  final String label;
  final List<NgOption> items;
  final List<String> value;
  final ValueChanged<List<String>>? onChanged;
  final bool multiple, allowEmpty, disabled, vertical;
  const NgButtonGroup({
    super.key,
    this.label = 'Options',
    required this.items,
    this.value = const [],
    this.onChanged,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
    this.vertical = false,
  });
  @override
  Widget build(BuildContext context) {
    NgSelectionRules.validate(items, value, multiple);
    final buttons = items
        .map(
          (item) => NgToggleButton(
            key: ValueKey(item.value),
            label: item.label,
            value: value.contains(item.value),
            disabled: disabled || item.disabled || onChanged == null,
            onChanged: (_) {
              final next = NgSelectionRules.toggle(
                items,
                value,
                item.value,
                multiple,
                allowEmpty,
              );
              if (!listEquals(next, value)) onChanged?.call(next);
            },
          ),
        )
        .toList();
    return Semantics(
      label: label,
      container: true,
      explicitChildNodes: true,
      child: items.isEmpty
          ? const Text('No options')
          : vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final button in buttons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: button,
                  ),
              ],
            )
          : Wrap(spacing: 4, runSpacing: 4, children: buttons),
    );
  }
}
