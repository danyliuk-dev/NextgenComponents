import 'package:flutter/material.dart';
import 'components.dart';

class NgTextArea extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int rows;
  final int? maxLength;
  final bool enabled;
  const NgTextArea({
    super.key,
    this.label = 'Notes',
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.rows = 4,
    this.maxLength,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    initialValue: initialValue,
    onChanged: onChanged,
    validator: validator,
    minLines: rows,
    maxLines: rows,
    maxLength: maxLength,
    enabled: enabled,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
  );
}

class NgAutoComplete extends StatelessWidget {
  final String label;
  final List<String> items;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  const NgAutoComplete({
    super.key,
    this.label = 'Search',
    required this.items,
    this.initialValue = '',
    this.onChanged,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => Autocomplete<String>(
    initialValue: TextEditingValue(text: initialValue),
    optionsBuilder: (v) => v.text.isEmpty
        ? const Iterable<String>.empty()
        : items.where((s) => s.toLowerCase().contains(v.text.toLowerCase())),
    onSelected: onChanged,
    fieldViewBuilder: (context, controller, focus, onSubmitted) =>
        TextFormField(
          controller: controller,
          focusNode: focus,
          enabled: enabled,
          onChanged: onChanged,
          onFieldSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(labelText: label),
        ),
  );
}

class NgComboBox extends StatefulWidget {
  final String label;
  final String? value;
  final List<NgOption> items;
  final ValueChanged<String?>? onChanged;
  final bool enabled, required;
  const NgComboBox({
    super.key,
    this.label = 'Choose an option',
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.required = false,
  });
  @override
  State<NgComboBox> createState() => _NgComboBoxState();
}

class _NgComboBoxState extends State<NgComboBox> {
  late final TextEditingController controller;
  String textFor(String? value) =>
      widget.items.where((o) => o.value == value).firstOrNull?.label ?? '';
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: textFor(widget.value));
  }

  @override
  void didUpdateWidget(covariant NgComboBox old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && controller.text != textFor(widget.value))
      controller.text = textFor(widget.value);
  }

  @override
  Widget build(BuildContext context) => RawAutocomplete<NgOption>(
    textEditingController: controller,
    focusNode: focus,
    displayStringForOption: (o) => o.label,
    optionsBuilder: (v) => widget.items.where(
      (o) =>
          !o.disabled && o.label.toLowerCase().contains(v.text.toLowerCase()),
    ),
    onSelected: (o) => widget.onChanged?.call(o.value),
    fieldViewBuilder: (context, controller, focus, onSubmitted) =>
        TextFormField(
          controller: controller,
          focusNode: focus,
          enabled: widget.enabled,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (text) {
            if (text == null || text.isEmpty)
              return widget.required ? '${widget.label} is required' : null;
            return widget.items.any((o) => !o.disabled && o.label == text)
                ? null
                : 'Choose an option from the list.';
          },
          onFieldSubmitted: (_) => onSubmitted(),
          onChanged: (text) {
            final match = widget.items
                .where((o) => !o.disabled && o.label == text)
                .firstOrNull;
            if (match != null || text.isEmpty)
              widget.onChanged?.call(match?.value);
          },
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: const Icon(Icons.expand_more),
          ),
        ),
    optionsViewBuilder: (context, onSelected, options) => Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220, maxWidth: 300),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: options
                .map(
                  (o) => ListTile(
                    title: Text(o.label),
                    onTap: () => onSelected(o),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
  );
  final FocusNode focus = FocusNode();
  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }
}

class NgMultiSelect extends StatefulWidget {
  final String label;
  final List<String> value;
  final List<NgOption> items;
  final ValueChanged<List<String>>? onChanged;
  final int? maxSelected;
  final bool enabled, required;
  const NgMultiSelect({
    super.key,
    this.label = 'Options',
    required this.value,
    required this.items,
    this.onChanged,
    this.maxSelected,
    this.enabled = true,
    this.required = false,
  });
  @override
  State<NgMultiSelect> createState() => _NgMultiSelectState();
}

class _NgMultiSelectState extends State<NgMultiSelect> {
  final fieldKey = GlobalKey<FormFieldState<List<String>>>();
  String query = '';
  String? error;
  void toggle(String value) {
    if (!widget.enabled) return;
    final next = [...widget.value];
    error = null;
    if (!next.remove(value)) {
      if (widget.items.where((o) => o.value == value).firstOrNull?.disabled ??
          false)
        return;
      if (widget.maxSelected != null && next.length >= widget.maxSelected!) {
        setState(() => error = 'Select at most ${widget.maxSelected} options.');
        return;
      }
      next.add(value);
    }
    setState(() => error = null);
    fieldKey.currentState?.didChange(next.toSet().toList());
    widget.onChanged?.call(next.toSet().toList());
  }

  @override
  Widget build(BuildContext context) => FormField<List<String>>(
    key: fieldKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    initialValue: widget.value,
    enabled: widget.enabled,
    validator: (current) => widget.required && (current ?? []).isEmpty
        ? '${widget.label} is required'
        : null,
    builder: (field) => InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: error ?? field.errorText,
        enabled: widget.enabled,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.value
                .map(
                  (v) => InputChip(
                    label: Text(
                      widget.items
                              .where((o) => o.value == v)
                              .firstOrNull
                              ?.label ??
                          v,
                    ),
                    onDeleted: widget.enabled ? () => toggle(v) : null,
                  ),
                )
                .toList(),
          ),
          TextField(
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: 'Filter options…',
              labelText: 'Filter ${widget.label}',
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                children: widget.items
                    .where(
                      (o) =>
                          o.label.toLowerCase().contains(query.toLowerCase()),
                    )
                    .map(
                      (o) => NgCheckBox(
                        label: o.label,
                        value: widget.value.contains(o.value),
                        onChanged: !widget.enabled || o.disabled
                            ? null
                            : (_) {
                                toggle(o.value);
                              },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          if (!widget.items.any(
            (o) => o.label.toLowerCase().contains(query.toLowerCase()),
          ))
            const Text('No matches'),
          if (widget.maxSelected != null)
            Text(
              '${widget.value.length} / ${widget.maxSelected} selected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    ),
  );
}

class NgForm extends StatefulWidget {
  final Widget child;
  final VoidCallback onValidSubmit;
  final String submitLabel;
  final GlobalKey<FormState>? formKey;
  const NgForm({
    super.key,
    required this.child,
    required this.onValidSubmit,
    this.submitLabel = 'Save',
    this.formKey,
  });
  @override
  State<NgForm> createState() => _NgFormState();
}

class _NgFormState extends State<NgForm> {
  final internalKey = GlobalKey<FormState>();
  bool invalid = false;
  @override
  Widget build(BuildContext context) => Form(
    key: widget.formKey ?? internalKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (invalid)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                'Please correct the highlighted fields.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        widget.child,
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: NgButton(
            primary: true,
            onPressed: () {
              final valid = (widget.formKey ?? internalKey).currentState!
                  .validate();
              setState(() => invalid = !valid);
              if (valid) widget.onValidSubmit();
            },
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    ),
  );
}
