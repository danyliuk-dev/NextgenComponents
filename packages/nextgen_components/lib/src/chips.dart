import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'components.dart';
import 'selection.dart';

class NgChip extends StatelessWidget {
  final String label;
  final bool value, selectable, disabled;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onRemove;
  const NgChip({
    super.key,
    required this.label,
    this.value = false,
    this.selectable = true,
    this.disabled = false,
    this.onChanged,
    this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty || label.length > 120) {
      throw ArgumentError('Use a nonblank label of at most 120 characters.');
    }
    if (!selectable) {
      return Opacity(
        opacity: disabled ? .5 : 1,
        child: Chip(
          label: Text(label),
          shape: const StadiumBorder(),
          backgroundColor: value
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          onDeleted: disabled ? null : onRemove,
          deleteButtonTooltipMessage: 'Remove $label',
        ),
      );
    }
    return InputChip(
      shape: const StadiumBorder(),
      label: Text(label),
      selected: value,
      isEnabled: !disabled,
      onSelected: disabled || !selectable ? null : onChanged,
      onDeleted: disabled ? null : onRemove,
      deleteButtonTooltipMessage: 'Remove $label',
    );
  }
}

class NgChipList extends StatelessWidget {
  final String label;
  final List<NgOption> items;
  final List<String> value;
  final ValueChanged<List<String>>? onChanged;
  final ValueChanged<String>? onRemove;
  final bool selectable, multiple, allowEmpty, disabled;
  const NgChipList({
    super.key,
    this.label = 'Tags',
    required this.items,
    this.value = const [],
    this.onChanged,
    this.onRemove,
    this.selectable = true,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
  });
  @override
  Widget build(BuildContext context) {
    NgSelectionRules.validate(items, value, multiple);
    return Semantics(
      label: label,
      container: true,
      explicitChildNodes: true,
      child: items.isEmpty
          ? const Text('No tags')
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in items)
                  NgChip(
                    key: ValueKey(item.value),
                    label: item.label,
                    value: value.contains(item.value),
                    selectable: selectable,
                    disabled: disabled || item.disabled,
                    onChanged: onChanged == null
                        ? null
                        : (_) {
                            final next = NgSelectionRules.toggle(
                              items,
                              value,
                              item.value,
                              multiple,
                              allowEmpty,
                            );
                            if (!listEquals(next, value)) onChanged!(next);
                          },
                    onRemove: onRemove == null
                        ? null
                        : () => onRemove!(item.value),
                  ),
              ],
            ),
    );
  }
}
