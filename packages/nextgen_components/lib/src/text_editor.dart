import 'package:flutter/material.dart';

// Internal shared implementation; TextBox and TextArea retain their public APIs.
class NextgenTextEditor extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue, placeholder, helperText;
  final ValueChanged<String>? onChanged, onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled, readOnly, showClearButton, password, showPasswordToggle;
  final int? maxLength;
  final int rows;
  final bool multiline;
  final FocusNode? focusNode;
  final Widget? prefix, suffix;
  const NextgenTextEditor({
    super.key,
    required this.label,
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
  bool revealed = false;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(changed);
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant NextgenTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    revision++;
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
    widget.controller?.removeListener(changed);
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
    field.currentState?.didChange('');
    widget.controller?.clear();
    inputFocus.requestFocus();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
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
        maxLines: widget.multiline ? widget.rows : 1,
        obscureText: widget.password && !revealed,
        enableSuggestions: !widget.password,
        autocorrect: !widget.password,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
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
