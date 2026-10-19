import 'text_editor.dart';
import 'package:flutter/material.dart';

class NgOption {
  final String value;
  final String label;
  final bool disabled;
  const NgOption(this.value, this.label, {this.disabled = false});
}

class NgButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool primary;
  const NgButton({
    super.key,
    required this.child,
    this.onPressed,
    this.primary = false,
  });
  @override
  Widget build(BuildContext context) => primary
      ? FilledButton(onPressed: onPressed, child: child)
      : OutlinedButton(onPressed: onPressed, child: child);
}

class NgTextBox extends StatelessWidget {
  final String label;
  final String counterMode;
  final String Function(int current, int? maximum)? counterText;
  final int debounceDelay;
  final ValueChanged<String>? onDebouncedChange;
  final String size, fillMode, rounded;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled, readOnly, showClearButton, password, showPasswordToggle;
  final FocusNode? focusNode;
  final String? helperText;
  final Widget? prefix, suffix;
  final ValueChanged<String>? onSubmitted;
  final String? placeholder;
  final int? maxLength;
  const NgTextBox({
    super.key,
    required this.label,
    this.counterMode = 'native',
    this.counterText,
    this.size = 'medium',
    this.fillMode = 'theme',
    this.rounded = 'theme',
    this.debounceDelay = 300,
    this.onDebouncedChange,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.showClearButton = false,
    this.password = false,
    this.showPasswordToggle = false,
    this.focusNode,
    this.helperText,
    this.prefix,
    this.suffix,
    this.onSubmitted,
    this.placeholder,
    this.maxLength,
  });
  @override
  Widget build(BuildContext context) {
    if (maxLength != null && maxLength! <= 0)
      throw ArgumentError('maxLength must be positive.');
    if (controller != null && initialValue != null)
      throw ArgumentError('Use controller or initialValue, not both.');
    return NextgenTextEditor(
      label: label,
      counterMode: counterMode,
      counterText: counterText,
      debounceDelay: debounceDelay,
      onDebouncedChange: onDebouncedChange,
      size: size,
      fillMode: fillMode,
      rounded: rounded,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      placeholder: placeholder,
      helperText: helperText,
      prefix: prefix,
      suffix: suffix,
      showClearButton: showClearButton,
      password: password,
      showPasswordToggle: showPasswordToggle,
    );
  }
}

/// Controlled nullable number. Invalid drafts are retained until corrected;
/// they never replace the last valid value. Form.validate reports the error.
class NgNumericTextBox extends StatefulWidget {
  final String label;
  final double? value;
  final double? min;
  final double? max;
  final ValueChanged<double?>? onChanged;
  final bool enabled, required, readOnly, showSpinButtons;
  final double step;
  final String? helperText;
  const NgNumericTextBox({
    super.key,
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.showSpinButtons = true,
    this.step = 1,
    this.helperText,
  });
  @override
  State<NgNumericTextBox> createState() => _NgNumericTextBoxState();
}

class _NgNumericTextBoxState extends State<NgNumericTextBox> {
  late final TextEditingController controller;
  String format(double? value) =>
      value == null ? '' : value.toString().replaceFirst(RegExp(r'\.0$'), '');
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: format(widget.value));
  }

  @override
  void didUpdateWidget(covariant NgNumericTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        double.tryParse(controller.text) != widget.value) {
      controller.text = format(widget.value);
    }
  }

  String? validate(String? input) {
    if (input == null || input.isEmpty)
      return widget.required ? '${widget.label} is required' : null;
    final value =
        RegExp(r'^[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$').hasMatch(input)
        ? double.tryParse(input)
        : null;
    if (value == null || !value.isFinite) return 'Enter a valid number';
    if (widget.min != null && value < widget.min!)
      return 'Minimum: ${widget.min}';
    if (widget.max != null && value > widget.max!)
      return 'Maximum: ${widget.max}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.step.isFinite ||
        widget.step <= 0 ||
        (widget.min != null && !widget.min!.isFinite) ||
        (widget.max != null && !widget.max!.isFinite) ||
        (widget.min != null &&
            widget.max != null &&
            widget.min! > widget.max!)) {
      throw ArgumentError(
        'Step must be positive and finite; bounds must be finite and ordered',
      );
    }
    return TextFormField(
      controller: controller,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        suffixIcon: widget.showSpinButtons
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Decrease ${widget.label}',
                    onPressed: canSpin ? () => spin(-1) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    tooltip: 'Increase ${widget.label}',
                    onPressed: canSpin ? () => spin(1) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              )
            : null,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validate,
      onChanged: (text) {
        if (widget.enabled && !widget.readOnly && validate(text) == null)
          widget.onChanged?.call(text.isEmpty ? null : double.parse(text));
      },
    );
  }

  bool get canSpin =>
      widget.enabled && !widget.readOnly && widget.onChanged != null;
  void spin(int direction) {
    if (!canSpin) return;
    var next = (widget.value ?? 0) + direction * widget.step;
    if (!next.isFinite)
      next = direction > 0 ? double.maxFinite : -double.maxFinite;
    if (widget.min != null && next < widget.min!) next = widget.min!;
    if (widget.max != null && next > widget.max!) next = widget.max!;
    controller.text = format(next);
    widget.onChanged?.call(next);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class NgCheckBox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const NgCheckBox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged == null ? null : (v) => onChanged!(v!),
        ),
        Flexible(
          child: GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(!value),
            child: Text(label),
          ),
        ),
      ],
    ),
  );
}

class NgSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const NgSwitch({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        const SizedBox(width: 8),
        Flexible(
          child: GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(!value),
            child: Text(label),
          ),
        ),
      ],
    ),
  );
}

void _validateChoiceItems(List<NgOption> items) {
  final ids = <String>{};
  for (final item in items) {
    if (item.value.trim().isEmpty ||
        item.label.trim().isEmpty ||
        !ids.add(item.value)) {
      throw ArgumentError(
        'Options need unique nonempty values and nonempty labels.',
      );
    }
  }
}

class NgDropDownList extends StatefulWidget {
  final String label;
  final String? value, placeholder, helperText;
  final List<NgOption> items;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled, readOnly;
  const NgDropDownList({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.placeholder,
    this.helperText,
    this.enabled = true,
    this.readOnly = false,
  });
  @override
  State<NgDropDownList> createState() => _NgDropDownListState();
}

class _NgDropDownListState extends State<NgDropDownList> {
  int revision = 0;
  @override
  void didUpdateWidget(covariant NgDropDownList oldWidget) {
    super.didUpdateWidget(oldWidget);
    revision++;
  }

  @override
  Widget build(BuildContext context) {
    _validateChoiceItems(widget.items);
    final generation = revision;
    return FormField<String>(
      key: ValueKey(widget.value),
      initialValue: widget.value,
      validator: (v) => v != null && !widget.items.any((o) => o.value == v)
          ? 'Choose an available option.'
          : widget.validator?.call(v),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final missing =
            field.value != null &&
            !widget.items.any((o) => o.value == field.value);
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helperText,
            errorText: field.errorText,
            enabled: widget.enabled && !widget.readOnly,
          ),
          isEmpty: field.value == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: field.value,
              isExpanded: true,
              isDense: true,
              hint: widget.placeholder == null
                  ? null
                  : Text(widget.placeholder!),
              items: [
                if (missing)
                  DropdownMenuItem(
                    value: field.value,
                    enabled: false,
                    child: Text('Unavailable selection: ${field.value}'),
                  ),
                ...widget.items.map(
                  (o) => DropdownMenuItem(
                    value: o.value,
                    enabled: !o.disabled,
                    child: Text(o.label),
                  ),
                ),
              ],
              onChanged:
                  !widget.enabled || widget.readOnly || widget.onChanged == null
                  ? null
                  : (v) {
                      if (!mounted ||
                          generation != revision ||
                          !widget.enabled ||
                          widget.readOnly ||
                          !widget.items.any((o) => o.value == v && !o.disabled))
                        return;
                      field.didChange(v);
                      widget.onChanged?.call(v);
                    },
            ),
          ),
        );
      },
    );
  }
}

class NgRadioGroup extends StatelessWidget {
  final String label, orientation;
  final String? value, helperText;
  final List<NgOption> items;
  final ValueChanged<String?>? onChanged;
  final Widget Function(BuildContext, NgOption)? itemBuilder;
  final bool enabled, readOnly;
  const NgRadioGroup({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.helperText,
    this.itemBuilder,
    this.orientation = 'horizontal',
    this.enabled = true,
    this.readOnly = false,
  });
  @override
  Widget build(BuildContext context) {
    _validateChoiceItems(items);
    if (orientation != 'horizontal' && orientation != 'vertical')
      throw ArgumentError('Orientation must be horizontal or vertical.');
    final interactive = enabled && !readOnly && onChanged != null;
    final children = items
        .map(
          (item) => MergeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: item.value,
                  enabled: interactive && !item.disabled,
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: !interactive || item.disabled
                        ? null
                        : () => onChanged!(item.value),
                    child: Semantics(
                      label: item.label,
                      excludeSemantics: true,
                      child:
                          itemBuilder?.call(context, item) ?? Text(item.label),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        RadioGroup<String>(
          groupValue: value,
          onChanged: (v) {
            if (interactive && items.any((o) => o.value == v && !o.disabled))
              onChanged!(v);
          },
          child: orientation == 'vertical'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                )
              : Wrap(spacing: 12, runSpacing: 8, children: children),
        ),
        if (helperText != null)
          Text(helperText!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class NgTab {
  final String label;
  final Widget child;
  const NgTab(this.label, this.child);
}

class NgTabs extends StatefulWidget {
  final List<NgTab> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  const NgTabs({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onChanged,
  });
  @override
  State<NgTabs> createState() => _NgTabsState();
}

class _NgTabsState extends State<NgTabs> with SingleTickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    createController();
  }

  void createController() {
    controller = TabController(
      length: widget.items.length,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );
    controller.addListener(changed);
  }

  void changed() {
    if (controller.index != widget.selectedIndex)
      widget.onChanged?.call(controller.index);
  }

  @override
  void didUpdateWidget(covariant NgTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      controller.dispose();
      createController();
    } else if (controller.index != widget.selectedIndex) {
      controller.index = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: widget.items.map((t) => Tab(text: t.label)).toList(),
      ),
      if (widget.items.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: widget.items[widget.selectedIndex].child,
        ),
    ],
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class NgDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  const NgDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget> actions = const [],
  }) => showDialog<T>(
    context: context,
    builder: (_) => NgDialog(title: title, actions: actions, child: child),
  );
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: [
        Expanded(child: Text(title)),
        IconButton(
          tooltip: 'Close dialog',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    content: child,
    actions: actions,
  );
}

class NgTooltip extends StatelessWidget {
  final String text;
  final Widget child;
  const NgTooltip({super.key, required this.text, required this.child});
  @override
  Widget build(BuildContext context) => Tooltip(message: text, child: child);
}

class NgNotification extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final bool error;
  const NgNotification({
    super.key,
    required this.message,
    this.onDismiss,
    this.error = false,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: error
                ? colors.error
                : (colors.brightness == Brightness.dark
                      ? const Color(0xff75d6a1)
                      : const Color(0xff187444)),
          ),
        ),
        child: Row(
          children: [
            Icon(error ? Icons.error_outline : Icons.check_circle_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            if (onDismiss != null)
              IconButton(
                tooltip: 'Dismiss notification',
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
  }
}
