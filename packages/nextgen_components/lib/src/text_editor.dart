import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_composition_stub.dart'
    if (dart.library.js_interop) 'text_composition_web.dart';

// Internal shared implementation; TextBox and TextArea retain their public APIs.
class NextgenTextEditor extends StatefulWidget {
  final String label;
  final int debounceDelay;
  final ValueChanged<String>? onDebouncedChange;
  final String size, fillMode, rounded;
  final TextEditingController? controller;
  final String? initialValue, placeholder, helperText;
  final ValueChanged<String>? onChanged, onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled, readOnly, showClearButton, password, showPasswordToggle;
  final int? maxLength;
  final int rows, maxRows;
  final bool autoSize;
  final bool multiline;
  final FocusNode? focusNode;
  final Widget? prefix, suffix;
  const NextgenTextEditor({
    super.key,
    required this.label,
    this.size = 'medium',
    this.fillMode = 'theme',
    this.rounded = 'theme',
    this.debounceDelay = 300,
    this.onDebouncedChange,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.helperText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.showClearButton = false,
    this.password = false,
    this.showPasswordToggle = false,
    this.maxLength,
    this.rows = 1,
    this.autoSize = false,
    this.maxRows = 12,
    this.multiline = false,
    this.focusNode,
    this.prefix,
    this.suffix,
  });
  @override
  State<NextgenTextEditor> createState() => _NextgenTextEditorState();
}

class _NextgenTextEditorState extends State<NextgenTextEditor> {
  final field = GlobalKey<FormFieldState<String>>();
  final ownedFocus = FocusNode();
  FocusNode get inputFocus => widget.focusNode ?? ownedFocus;
  String get text =>
      widget.controller?.text ??
      field.currentState?.value ??
      widget.initialValue ??
      '';
  // Read the framework-owned controller without taking ownership: supplying a
  // replacement controller would change TextFormField.initialValue/reset behavior.
  TextEditingValue? get editingValue {
    if (widget.controller != null) return widget.controller!.value;
    TextEditingValue? result;
    void visit(Element element) {
      if (element.widget case EditableText editor) {
        result = editor.controller.value;
      } else if (result == null) {
        element.visitChildElements(visit);
      }
    }

    field.currentContext?.visitChildElements(visit);
    return result;
  }

  late final TextCompositionObserver nativeComposition;
  bool get composing {
    if (nativeComposition.active) return true;
    final range = editingValue?.composing;
    return range != null && range.isValid && !range.isCollapsed;
  }

  int notificationEpoch = 0;
  TextEditingValue observeEdit(
    TextEditingValue oldValue,
    TextEditingValue value,
  ) {
    cancelDebounce();
    if (!value.composing.isCollapsed && value.composing.isValid) return value;
    // IME may commit without changing text, so onChanged alone is insufficient.
    if (!oldValue.composing.isCollapsed && oldValue.composing.isValid) {
      final epoch = notificationEpoch;
      scheduleMicrotask(() {
        if (mounted && epoch == notificationEpoch && text == value.text) {
          scheduleDebounce(value.text);
        }
      });
    }
    return value;
  }

  Timer? debounce;
  String? pendingValue;
  void cancelDebounce() {
    notificationEpoch++;
    debounce?.cancel();
    debounce = null;
    pendingValue = null;
  }

  void scheduleDebounce(String value) {
    cancelDebounce();
    if (!mounted ||
        !widget.enabled ||
        widget.readOnly ||
        widget.onDebouncedChange == null ||
        composing ||
        text != value)
      return;
    pendingValue = value;
    debounce = Timer(Duration(milliseconds: widget.debounceDelay), () {
      if (!mounted ||
          !widget.enabled ||
          widget.readOnly ||
          composing ||
          text != value)
        return;
      cancelDebounce();
      widget.onDebouncedChange?.call(value);
    });
  }

  bool revealed = false;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    nativeComposition = TextCompositionObserver(
      () => mounted && inputFocus.hasFocus,
      (active, value) {
        cancelDebounce();
        if (!active) {
          final epoch = notificationEpoch;
          scheduleMicrotask(() {
            if (mounted && epoch == notificationEpoch && text == value)
              scheduleDebounce(value);
          });
        }
      },
    );
    widget.controller?.addListener(changed);
  }

  void changed() {
    if (pendingValue != null && widget.controller?.text != pendingValue)
      cancelDebounce();
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant NextgenTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    revision++;
    if (oldWidget.controller != widget.controller ||
        oldWidget.debounceDelay != widget.debounceDelay ||
        !widget.enabled ||
        widget.readOnly ||
        widget.onDebouncedChange == null)
      cancelDebounce();
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(changed);
      widget.controller?.addListener(changed);
      revealed = false;
    }
    if (!widget.password ||
        !widget.showPasswordToggle ||
        !widget.enabled ||
        widget.readOnly)
      revealed = false;
  }

  @override
  void dispose() {
    cancelDebounce();
    widget.controller?.removeListener(changed);
    nativeComposition.dispose();
    ownedFocus.dispose();
    super.dispose();
  }

  void clear(int captured) {
    if (!mounted ||
        captured != revision ||
        !widget.enabled ||
        widget.readOnly ||
        !widget.showClearButton ||
        text.isEmpty)
      return;
    setState(() => revealed = false);
    nativeComposition.reset();
    field.currentState?.didChange('');
    widget.controller?.clear();
    inputFocus.requestFocus();
    widget.onChanged?.call('');
    scheduleDebounce('');
  }

  @override
  Widget build(BuildContext context) {
    if (!['small', 'medium', 'large'].contains(widget.size)) {
      throw ArgumentError('Use small, medium or large.');
    }
    if (!['theme', 'outline', 'filled', 'flat'].contains(widget.fillMode)) {
      throw ArgumentError('Use theme, outline, filled or flat.');
    }
    if (widget.debounceDelay < 0 || widget.debounceDelay > 60000)
      throw ArgumentError('Use a debounce delay of 0–60000 milliseconds.');
    if (![
      'theme',
      'none',
      'small',
      'medium',
      'large',
      'full',
    ].contains(widget.rounded)) {
      throw ArgumentError('Use theme, none, small, medium, large or full.');
    }
    final decorationTheme = Theme.of(context).inputDecorationTheme;
    final radius = BorderRadius.circular(switch (widget.rounded) {
      'none' => 0,
      'small' => 4,
      'medium' => 8,
      'large' => 16,
      'full' => 9999,
      _ => 0,
    });
    InputBorder? shaped(InputBorder? border) {
      if (widget.rounded == 'theme') return border;
      if (border is UnderlineInputBorder)
        return border.copyWith(borderRadius: radius);
      if (border == InputBorder.none) return border;
      return (border is OutlineInputBorder
              ? border
              : const OutlineInputBorder())
          .copyWith(borderRadius: radius);
    }

    final flat = widget.fillMode == 'flat';
    final baseBorder = shaped(decorationTheme.border);
    final current = revision;
    final actions = <Widget>[
      if (widget.password && widget.showPasswordToggle)
        IconButton(
          tooltip: revealed ? 'Hide password' : 'Show password',
          isSelected: revealed,
          icon: Icon(revealed ? Icons.visibility_off : Icons.visibility),
          onPressed: !widget.enabled || widget.readOnly
              ? null
              : () {
                  if (!mounted ||
                      current != revision ||
                      !widget.enabled ||
                      widget.readOnly ||
                      !widget.password ||
                      !widget.showPasswordToggle)
                    return;
                  setState(() => revealed = !revealed);
                },
        ),
      if (widget.showClearButton)
        IconButton(
          tooltip: 'Clear ${widget.label}',
          icon: const Icon(Icons.clear),
          onPressed: !widget.enabled || widget.readOnly || text.isEmpty
              ? null
              : () => clear(current),
        ),
      if (widget.suffix != null) widget.suffix!,
    ];
    return Focus(
      onFocusChange: (focused) {
        if (!focused && revealed && mounted) setState(() => revealed = false);
      },
      child: TextFormField(
        key: field,
        inputFormatters: [TextInputFormatter.withFunction(observeEdit)],
        style: widget.size == 'medium'
            ? null
            : TextStyle(fontSize: widget.size == 'small' ? 13 : 18),
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: inputFocus,
        onChanged: (value) {
          if (mounted &&
              current == revision &&
              widget.enabled &&
              !widget.readOnly) {
            setState(() {});
            widget.onChanged?.call(value);
            scheduleDebounce(value);
          }
        },
        onFieldSubmitted: (value) {
          if (mounted &&
              current == revision &&
              widget.enabled &&
              !widget.readOnly)
            widget.onSubmitted?.call(value);
        },
        validator: widget.validator,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        minLines: widget.multiline ? widget.rows : null,
        maxLines: widget.multiline
            ? (widget.autoSize ? widget.maxRows : widget.rows)
            : 1,
        obscureText: widget.password && !revealed,
        enableSuggestions: !widget.password,
        autocorrect: !widget.password,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: baseBorder,
          enabledBorder: flat
              ? (shaped(
                          decorationTheme.enabledBorder ??
                              decorationTheme.border,
                        ) ??
                        const UnderlineInputBorder())
                    .copyWith(borderSide: BorderSide.none)
              : decorationTheme.enabledBorder == null
              ? null
              : shaped(decorationTheme.enabledBorder),
          disabledBorder: flat
              ? (shaped(
                          decorationTheme.disabledBorder ??
                              decorationTheme.border,
                        ) ??
                        const UnderlineInputBorder())
                    .copyWith(borderSide: BorderSide.none)
              : decorationTheme.disabledBorder == null
              ? null
              : shaped(decorationTheme.disabledBorder),
          focusedBorder: decorationTheme.focusedBorder == null
              ? null
              : shaped(decorationTheme.focusedBorder),
          errorBorder: decorationTheme.errorBorder == null
              ? null
              : shaped(decorationTheme.errorBorder),
          focusedErrorBorder: decorationTheme.focusedErrorBorder == null
              ? null
              : shaped(decorationTheme.focusedErrorBorder),
          filled: widget.fillMode == 'theme'
              ? null
              : (widget.fillMode == 'filled' || flat),
          fillColor: (widget.fillMode == 'filled' || flat)
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : null,
          contentPadding: widget.size == 'medium'
              ? null
              : EdgeInsets.symmetric(
                  horizontal: widget.size == 'small' ? 8 : 16,
                  vertical: widget.size == 'small' ? 8 : 20,
                ),
          labelText: widget.label,
          hintText: widget.placeholder,
          helperText: widget.helperText,
          prefixIcon: widget.prefix,
          suffixIcon: actions.isEmpty
              ? null
              : Row(mainAxisSize: MainAxisSize.min, children: actions),
          alignLabelWithHint: widget.multiline,
        ),
      ),
    );
  }
}
