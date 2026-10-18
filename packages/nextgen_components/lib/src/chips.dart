import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'components.dart';
import 'selection.dart';

class NgChipAppearance {
  final String? size, rounded, fillMode, themeColor;
  const NgChipAppearance({
    this.size,
    this.rounded,
    this.fillMode,
    this.themeColor,
  });
}

abstract final class NgChipRules {
  static void validate(
    String size,
    String rounded,
    String fillMode,
    String themeColor,
  ) {
    if (!['sm', 'md', 'lg'].contains(size) ||
        !['sm', 'md', 'lg', 'full'].contains(rounded) ||
        !['solid', 'outline'].contains(fillMode) ||
        !['base', 'info', 'success', 'warning', 'error'].contains(themeColor)) {
      throw ArgumentError(
        'Invalid chip appearance. Use documented size, rounded, fill mode and theme color values.',
      );
    }
  }
}

class NgChip extends StatelessWidget {
  final String label;
  final bool value, selectable, disabled;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onRemove, onClick;
  final String size, rounded, fillMode, themeColor;
  final Widget? leading, child, removeIcon;
  const NgChip({
    super.key,
    required this.label,
    this.value = false,
    this.selectable = true,
    this.disabled = false,
    this.onChanged,
    this.onRemove,
    this.onClick,
    this.size = 'md',
    this.rounded = 'full',
    this.fillMode = 'outline',
    this.themeColor = 'base',
    this.leading,
    this.child,
    this.removeIcon,
  });
  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty || label.length > 120) {
      throw ArgumentError('Use a nonblank label of at most 120 characters.');
    }
    NgChipRules.validate(size, rounded, fillMode, themeColor);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final palette = <String, List<Color>>{
      'base': [
        theme.colorScheme.onSurface,
        theme.colorScheme.surfaceContainerHighest,
      ],
      'info': [
        Color(dark ? 0xffb8d5ff : 0xff174b9a),
        Color(dark ? 0xff183861 : 0xffe4efff),
      ],
      'success': [
        Color(dark ? 0xffa5e6c0 : 0xff165c38),
        Color(dark ? 0xff19442e : 0xffdef5e8),
      ],
      'warning': [
        Color(dark ? 0xffffe0a0 : 0xff694200),
        Color(dark ? 0xff503916 : 0xfffff0cb),
      ],
      'error': [
        Color(dark ? 0xffffc1c1 : 0xff982727),
        Color(dark ? 0xff592828 : 0xffffe6e6),
      ],
    }[themeColor]!;
    final foreground = palette[0];
    final background = fillMode == 'solid' || value
        ? palette[1]
        : theme.colorScheme.surface;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        {'sm': 4.0, 'md': 8.0, 'lg': 14.0, 'full': 999.0}[rounded]!,
      ),
    );
    final text = Semantics(
      label: label,
      excludeSemantics: true,
      child: child ?? Text(label),
    );
    final decoration = leading == null
        ? null
        : ExcludeSemantics(child: leading!);
    final padding = EdgeInsets.symmetric(
      horizontal: size == 'sm'
          ? 6
          : size == 'lg'
          ? 12
          : 8,
      vertical: size == 'sm'
          ? 0
          : size == 'lg'
          ? 8
          : 4,
    );
    final textStyle = TextStyle(
      color: foreground,
      fontSize: size == 'sm'
          ? 12
          : size == 'lg'
          ? 16
          : 14,
    );
    final remove = disabled ? null : onRemove;
    void activate() {
      if (disabled) return;
      if (selectable) onChanged?.call(!value);
      onClick?.call();
    }

    if (!selectable && onClick == null) {
      final chip = Chip(
        label: text,
        avatar: decoration,
        shape: shape,
        backgroundColor: background,
        labelStyle: textStyle,
        padding: padding,
        side: BorderSide(color: foreground),
        onDeleted: remove,
        deleteIcon: removeIcon,
        deleteIconColor: foreground,
        deleteButtonTooltipMessage: 'Remove $label',
      );
      return Opacity(
        opacity: disabled ? .5 : 1,
        child: remove == null
            ? Semantics(label: label, excludeSemantics: true, child: chip)
            : chip,
      );
    }
    return InputChip(
      label: text,
      avatar: decoration,
      shape: shape,
      backgroundColor: background,
      selectedColor: palette[1],
      labelStyle: textStyle,
      padding: padding,
      side: BorderSide(color: foreground, width: value ? 2 : 1),
      checkmarkColor: foreground,
      selected: value,
      isEnabled: !disabled,
      onSelected:
          !disabled && selectable && (onChanged != null || onClick != null)
          ? (_) => activate()
          : null,
      onPressed: !disabled && !selectable && onClick != null ? activate : null,
      onDeleted: remove,
      deleteIcon: removeIcon,
      deleteIconColor: foreground,
      deleteButtonTooltipMessage: 'Remove $label',
    );
  }
}

class NgChipList extends StatelessWidget {
  final String label;
  final List<NgOption> items;
  final List<String> value;
  final ValueChanged<List<String>>? onChanged;
  final ValueChanged<String>? onRemove, onClick;
  final String size, rounded, fillMode, themeColor;
  final NgChipAppearance Function(NgOption)? itemAppearance;
  final bool Function(NgOption)? canRemove;
  final Widget Function(NgOption)? itemBuilder, leadingBuilder;
  final Widget? removeIcon;
  final bool selectable, multiple, allowEmpty, disabled;
  const NgChipList({
    super.key,
    this.label = 'Tags',
    this.onClick,
    this.size = 'md',
    this.rounded = 'full',
    this.fillMode = 'outline',
    this.themeColor = 'base',
    this.itemAppearance,
    this.canRemove,
    this.itemBuilder,
    this.leadingBuilder,
    this.removeIcon,
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
    NgChipRules.validate(size, rounded, fillMode, themeColor);
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
                  Builder(
                    key: ValueKey(item.value),
                    builder: (context) {
                      final appearance = itemAppearance?.call(item);
                      return NgChip(
                        key: ValueKey(item.value),
                        size: appearance?.size ?? size,
                        rounded: appearance?.rounded ?? rounded,
                        fillMode: appearance?.fillMode ?? fillMode,
                        themeColor: appearance?.themeColor ?? themeColor,
                        child: itemBuilder?.call(item),
                        leading: leadingBuilder?.call(item),
                        removeIcon: removeIcon,
                        onClick: onClick == null
                            ? null
                            : () => onClick!(item.value),
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
                        onRemove:
                            onRemove == null || !(canRemove?.call(item) ?? true)
                            ? null
                            : () => onRemove!(item.value),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
