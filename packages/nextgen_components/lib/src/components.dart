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
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled, readOnly;
  final FocusNode? focusNode;
  final String? helperText;
  final Widget? prefix, suffix;
  final ValueChanged<String>? onSubmitted;
  final String? placeholder;
  final int? maxLength;
  const NgTextBox({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
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
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      onFieldSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        helperText: helperText,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
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
  final bool enabled, required;
  const NgNumericTextBox({
    super.key,
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.onChanged,
    this.enabled = true,
    this.required = false,
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
    final value = double.tryParse(input);
    if (value == null || !value.isFinite) return 'Enter a valid number';
    if (widget.min != null && value < widget.min!)
      return 'Minimum: ${widget.min}';
    if (widget.max != null && value > widget.max!)
      return 'Maximum: ${widget.max}';
    return null;
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: widget.enabled,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    decoration: InputDecoration(labelText: widget.label),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validate,
    onChanged: (text) {
      if (validate(text) == null)
        widget.onChanged?.call(text.isEmpty ? null : double.parse(text));
    },
  );
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

class NgDropDownList extends StatelessWidget {
  final String label;
  final String? value;
  final List<NgOption> items;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  const NgDropDownList({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey(value),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    validator: validator,
    items: items
        .map(
          (item) => DropdownMenuItem(
            value: item.value,
            enabled: !item.disabled,
            child: Text(item.label),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
}

class NgRadioGroup extends StatelessWidget {
  final String label;
  final String? value;
  final List<NgOption> items;
  final ValueChanged<String?>? onChanged;
  const NgRadioGroup({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      RadioGroup<String>(
        groupValue: value,
        onChanged: (v) => onChanged?.call(v),
        child: Wrap(
          spacing: 12,
          children: items
              .map(
                (item) => MergeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: item.value,
                        enabled: onChanged != null && !item.disabled,
                      ),
                      GestureDetector(
                        onTap: onChanged == null || item.disabled
                            ? null
                            : () => onChanged!(item.value),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
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
