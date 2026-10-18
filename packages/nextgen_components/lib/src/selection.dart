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

class NgButtonAppearance {
  final String? size, rounded, fillMode, themeColor;
  const NgButtonAppearance({
    this.size,
    this.rounded,
    this.fillMode,
    this.themeColor,
  });
}

abstract final class NgButtonRules {
  static void validate(
    String size,
    String rounded,
    String fillMode,
    String themeColor,
  ) {
    if (!['sm', 'md', 'lg'].contains(size) ||
        !['sm', 'md', 'lg', 'full'].contains(rounded) ||
        !['solid', 'outline', 'flat', 'link', 'clear'].contains(fillMode) ||
        ![
          'base',
          'primary',
          'secondary',
          'tertiary',
          'info',
          'success',
          'warning',
          'error',
          'dark',
          'light',
          'inverse',
        ].contains(themeColor))
      throw ArgumentError('Invalid button appearance. Use documented values.');
  }

  static ButtonStyle style(
    BuildContext context,
    String size,
    String rounded,
    String fillMode,
    String themeColor,
    bool selected,
  ) {
    validate(size, rounded, fillMode, themeColor);
    final scheme = Theme.of(context).colorScheme,
        dark = Theme.of(context).brightness == Brightness.dark;
    final tone = switch (themeColor) {
      'primary' => scheme.primary,
      'secondary' => Color(dark ? 0xffc1cede : 0xff536176),
      'tertiary' => Color(dark ? 0xffdcc2ff : 0xff7040a0),
      'info' => Color(dark ? 0xffb8d5ff : 0xff174b9a),
      'success' => Color(dark ? 0xffa5e6c0 : 0xff165c38),
      'warning' => Color(dark ? 0xffffe0a0 : 0xff805000),
      'error' => Color(dark ? 0xffffc1c1 : 0xff982727),
      'dark' => Color(dark ? 0xffe5e7eb : 0xff202938),
      'light' => Color(dark ? 0xffe8edf5 : 0xff475569),
      _ => scheme.onSurface,
    };
    final filled = selected || fillMode == 'solid';
    final onTone = themeColor == 'primary'
        ? scheme.onPrimary
        : tone.computeLuminance() > .4
        ? const Color(0xff202938)
        : Colors.white;
    final foreground = filled
        ? onTone
        : fillMode == 'clear'
        ? scheme.onSurface
        : tone;
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      backgroundColor: filled ? tone : Colors.transparent,
      disabledForegroundColor: scheme.onSurface.withValues(alpha: .5),
      disabledBackgroundColor: scheme.onSurface.withValues(alpha: .08),
      side: BorderSide(
        color: filled || fillMode == 'outline' ? tone : Colors.transparent,
        width: selected ? 2 : 1,
      ),
      minimumSize: Size(0, {'sm': 28.0, 'md': 36.0, 'lg': 44.0}[size]!),
      padding: EdgeInsets.symmetric(
        horizontal: {'sm': 8.0, 'md': 12.0, 'lg': 16.0}[size]!,
        vertical: {'sm': 3.0, 'md': 6.0, 'lg': 10.0}[size]!,
      ),
      textStyle: TextStyle(
        fontSize: {'sm': 12.0, 'md': 14.0, 'lg': 16.0}[size]!,
        decoration: fillMode == 'link' ? TextDecoration.underline : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          {'sm': 4.0, 'md': 6.0, 'lg': 12.0, 'full': 999.0}[rounded]!,
        ),
      ),
    );
  }
}

Widget _buttonContent(
  String label,
  String? semanticLabel,
  Widget? leading,
  Widget? child, {
  bool selected = false,
}) => Semantics(
  label: semanticLabel ?? label,
  excludeSemantics: true,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (selected) ...[
        const Icon(Icons.check, size: 16),
        const SizedBox(width: 8),
      ],
      if (leading != null) ...[leading, const SizedBox(width: 8)],
      child ?? Text(label),
    ],
  ),
);

class NgToggleButton extends StatelessWidget {
  final String label;
  final bool value, disabled, visible;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onClick;
  final String size, rounded, fillMode, themeColor;
  final String? semanticLabel, semanticIdentifier, semanticHint;
  final Widget? leading, child;
  final FocusNode? focusNode;
  final int tabIndex;
  const NgToggleButton({
    super.key,
    required this.label,
    this.value = false,
    this.onChanged,
    this.onClick,
    this.disabled = false,
    this.visible = true,
    this.size = 'md',
    this.rounded = 'md',
    this.fillMode = 'outline',
    this.themeColor = 'primary',
    this.semanticLabel,
    this.semanticIdentifier,
    this.semanticHint,
    this.leading,
    this.child,
    this.focusNode,
    this.tabIndex = 0,
  });
  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty || label.length > 120)
      throw ArgumentError('Use a nonblank label of at most 120 characters.');
    for (final name in [semanticLabel, semanticIdentifier, semanticHint]) {
      if (name != null && name.trim().isEmpty)
        throw ArgumentError('Semantic metadata must be nonblank.');
    }
    if (tabIndex != -1 && tabIndex != 0)
      throw ArgumentError('tabIndex supports only -1 or 0.');
    final style = NgButtonRules.style(
      context,
      size,
      rounded,
      fillMode,
      themeColor,
      value,
    );
    if (!visible) return const SizedBox.shrink();
    final enabled = !disabled && (onChanged != null || onClick != null);
    return ExcludeFocusTraversal(
      excluding: tabIndex == -1,
      child: MergeSemantics(
        child: Semantics(
          identifier: semanticIdentifier,
          hint: semanticHint,
          checked: value,
          enabled: enabled,
          child: OutlinedButton(
            focusNode: focusNode,
            style: style,
            onPressed: !enabled
                ? null
                : () {
                    onChanged?.call(!value);
                    onClick?.call();
                  },
            child: _buttonContent(
              label,
              semanticLabel,
              leading,
              child,
              selected: value,
            ),
          ),
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
  final ValueChanged<String>? onClick;
  final bool Function(NgOption)? isCommand;
  final bool multiple, allowEmpty, disabled, vertical;
  final String size, rounded, fillMode, themeColor;
  final String? semanticIdentifier, semanticHint;
  final NgButtonAppearance Function(NgOption)? itemAppearance;
  final bool Function(NgOption)? isVisible;
  final Widget Function(NgOption)? itemBuilder, leadingBuilder;
  const NgButtonGroup({
    super.key,
    this.label = 'Options',
    this.size = 'md',
    this.rounded = 'md',
    this.fillMode = 'outline',
    this.themeColor = 'primary',
    this.semanticIdentifier,
    this.semanticHint,
    this.itemAppearance,
    this.isVisible,
    this.itemBuilder,
    this.leadingBuilder,
    required this.items,
    this.value = const [],
    this.onClick,
    this.isCommand,
    this.onChanged,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
    this.vertical = false,
  });
  @override
  Widget build(BuildContext context) {
    NgSelectionRules.validate(items, value, multiple);
    NgButtonRules.validate(size, rounded, fillMode, themeColor);
    for (final name in [label, semanticIdentifier, semanticHint]) {
      if (name != null && name.trim().isEmpty)
        throw ArgumentError('Group semantic metadata must be nonblank.');
    }
    final commandIds = items
        .where((item) => isCommand?.call(item) ?? false)
        .map((item) => item.value)
        .toSet();
    if (value.any(commandIds.contains))
      throw ArgumentError('Command IDs cannot be selected.');
    final buttons = items
        .where((item) => isVisible?.call(item) ?? true)
        .map<Widget>((item) {
          final a = itemAppearance?.call(item) ?? const NgButtonAppearance();
          final itemSize = a.size ?? size,
              itemRounded = a.rounded ?? rounded,
              itemFill = a.fillMode ?? fillMode,
              itemTone = a.themeColor ?? themeColor;
          final blocked = disabled || item.disabled;
          if (commandIds.contains(item.value)) {
            return OutlinedButton(
              style: NgButtonRules.style(
                context,
                itemSize,
                itemRounded,
                itemFill,
                itemTone,
                false,
              ),
              key: ValueKey(item.value),
              onPressed: blocked || onClick == null
                  ? null
                  : () => onClick!(item.value),
              child: _buttonContent(
                item.label,
                null,
                leadingBuilder?.call(item),
                itemBuilder?.call(item),
              ),
            );
          }
          return NgToggleButton(
            size: itemSize,
            rounded: itemRounded,
            fillMode: itemFill,
            themeColor: itemTone,
            leading: leadingBuilder?.call(item),
            child: itemBuilder?.call(item),
            key: ValueKey(item.value),
            label: item.label,
            value: value.contains(item.value),
            disabled: blocked,
            onClick: onClick == null ? null : () => onClick!(item.value),
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
          );
        })
        .toList();
    return Semantics(
      label: label,
      identifier: semanticIdentifier,
      hint: semanticHint,
      container: true,
      explicitChildNodes: true,
      child: buttons.isEmpty
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
