import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    Widget keyboard(Widget child) => Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) {
        if (HardwareKeyboard.instance.isAltPressed ||
            HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)
          return KeyEventResult.ignored;
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.delete ||
                event.logicalKey == LogicalKeyboardKey.backspace) &&
            remove != null) {
          remove();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
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
      return keyboard(
        Opacity(
          opacity: disabled ? .5 : 1,
          child: remove == null
              ? Semantics(label: label, excludeSemantics: true, child: chip)
              : chip,
        ),
      );
    }
    final interactive = keyboard(
      InputChip(
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
        onPressed: !disabled && !selectable && onClick != null
            ? activate
            : null,
        onDeleted: remove,
        deleteIcon: removeIcon,
        deleteIconColor: foreground,
        deleteButtonTooltipMessage: 'Remove $label',
      ),
    );
    return !selectable && onRemove == null
        ? Semantics(
            label: label,
            button: true,
            enabled: !disabled,
            onTap: disabled ? null : activate,
            excludeSemantics: true,
            child: interactive,
          )
        : interactive;
  }
}

class NgChipList extends StatefulWidget {
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
  State<NgChipList> createState() => _NgChipListState();
}

class _NgChipListState extends State<NgChipList> {
  final Map<String, FocusNode> nodes = {};
  String? entryId;
  final FocusScopeNode scope = FocusScopeNode(
    debugLabel: 'Chip list scope',
    traversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
  );
  final FocusNode fallback = FocusNode(
    debugLabel: 'Empty chip list',
    skipTraversal: true,
  );
  bool enabled(NgOption item) =>
      !widget.disabled &&
      !item.disabled &&
      ((widget.selectable && widget.onChanged != null) ||
          widget.onClick != null ||
          (widget.onRemove != null && (widget.canRemove?.call(item) ?? true)));
  FocusNode node(String id) =>
      nodes.putIfAbsent(id, () => FocusNode(debugLabel: 'Chip $id'));
  void activateItem(NgOption item) {
    if (!enabled(item)) return;
    if (widget.selectable && widget.onChanged != null) {
      final next = NgSelectionRules.toggle(
        widget.items,
        widget.value,
        item.value,
        widget.multiple,
        widget.allowEmpty,
      );
      if (!listEquals(next, widget.value)) widget.onChanged!(next);
    }
    widget.onClick?.call(item.value);
  }

  void remove(NgOption item) {
    if (enabled(item) && (widget.canRemove?.call(item) ?? true)) {
      node(item.value).requestFocus();
      widget.onRemove?.call(item.value);
    }
  }

  KeyEventResult key(NgOption item, KeyEvent event) {
    final k = event.logicalKey;
    if (HardwareKeyboard.instance.isAltPressed ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed)
      return KeyEventResult.ignored;
    final keys = [
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.home,
      LogicalKeyboardKey.end,
      LogicalKeyboardKey.delete,
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.space,
    ];
    if (!keys.contains(k)) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    if (k == LogicalKeyboardKey.delete || k == LogicalKeyboardKey.backspace) {
      remove(item);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
      activateItem(item);
      return KeyEventResult.handled;
    }
    final all = widget.items.where(enabled).toList();
    if (all.isEmpty) return KeyEventResult.handled;
    final index = all.indexWhere((x) => x.value == item.value);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final next = k == LogicalKeyboardKey.home
        ? 0
        : k == LogicalKeyboardKey.end
        ? all.length - 1
        : index + ((k == LogicalKeyboardKey.arrowRight) != rtl ? 1 : -1);
    node(all[next.clamp(0, all.length - 1)].value).requestFocus();
    return KeyEventResult.handled;
  }

  @override
  void didUpdateWidget(covariant NgChipList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focused = nodes.entries.where((e) => e.value.hasFocus).firstOrNull;
    final previous = FocusManager.instance.primaryFocus;
    String? nextId;
    bool restore = false;
    if (focused != null &&
        !widget.items.any((x) => x.value == focused.key && enabled(x))) {
      restore = true;
      final index = oldWidget.items
          .indexWhere((x) => x.value == focused.key)
          .clamp(0, widget.items.length);
      final candidates = [
        ...widget.items.skip(index),
        ...widget.items.take(index).toList().reversed,
      ];
      nextId = candidates.where(enabled).firstOrNull?.value;
    }
    final removed = nodes.keys
        .where((id) => !widget.items.any((x) => x.value == id))
        .toList();
    final retired = [for (final id in removed) nodes.remove(id)!];
    if (restore || retired.isNotEmpty)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && restore) {
          final current = FocusManager.instance.primaryFocus;
          if (current == previous || current == scope || current == null) {
            (nextId == null ? fallback : node(nextId)).requestFocus();
          }
        }
        for (final n in retired) n.dispose();
      });
  }

  @override
  void dispose() {
    for (final n in nodes.values) n.dispose();
    scope.dispose();
    fallback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NgSelectionRules.validate(widget.items, widget.value, widget.multiple);
    NgChipRules.validate(
      widget.size,
      widget.rounded,
      widget.fillMode,
      widget.themeColor,
    );
    final available = widget.items.where(enabled).toList();
    if (!available.any((item) => item.value == entryId)) {
      entryId =
          (available
                      .where((item) => widget.value.contains(item.value))
                      .firstOrNull ??
                  available.firstOrNull)
              ?.value;
    }
    return FocusScope(
      node: scope,
      child: Focus(
        focusNode: fallback,
        child: Semantics(
          label: widget.label,
          container: true,
          explicitChildNodes: true,
          child: widget.items.isEmpty
              ? const Text('No tags')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in widget.items)
                      Builder(
                        key: ValueKey(item.value),
                        builder: (context) {
                          final appearance = widget.itemAppearance?.call(item);
                          final focus = node(item.value);
                          return Focus(
                            focusNode: focus,
                            canRequestFocus: enabled(item),
                            skipTraversal: item.value != entryId,
                            onFocusChange: (focused) {
                              if (mounted)
                                setState(() {
                                  if (focused) entryId = item.value;
                                });
                            },
                            onKeyEvent: (_, e) => key(item, e),
                            child: Listener(
                              onPointerDown: (_) {
                                if (enabled(item)) focus.requestFocus();
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: focus.hasFocus
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: ExcludeFocus(
                                    child: NgChip(
                                      label: item.label,
                                      value: widget.value.contains(item.value),
                                      selectable: widget.selectable,
                                      disabled:
                                          widget.disabled || item.disabled,
                                      size: appearance?.size ?? widget.size,
                                      rounded:
                                          appearance?.rounded ?? widget.rounded,
                                      fillMode:
                                          appearance?.fillMode ??
                                          widget.fillMode,
                                      themeColor:
                                          appearance?.themeColor ??
                                          widget.themeColor,
                                      child: widget.itemBuilder?.call(item),
                                      leading: widget.leadingBuilder?.call(
                                        item,
                                      ),
                                      removeIcon: widget.removeIcon,
                                      onClick: widget.onClick == null
                                          ? null
                                          : () {
                                              focus.requestFocus();
                                              widget.onClick!(item.value);
                                            },
                                      onChanged: widget.onChanged == null
                                          ? null
                                          : (_) {
                                              focus.requestFocus();
                                              final next =
                                                  NgSelectionRules.toggle(
                                                    widget.items,
                                                    widget.value,
                                                    item.value,
                                                    widget.multiple,
                                                    widget.allowEmpty,
                                                  );
                                              if (!listEquals(
                                                next,
                                                widget.value,
                                              ))
                                                widget.onChanged!(next);
                                            },
                                      onRemove:
                                          widget.onRemove == null ||
                                              !(widget.canRemove?.call(item) ??
                                                  true)
                                          ? null
                                          : () => remove(item),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
