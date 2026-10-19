import 'text_editor.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'components.dart';

class NgTextArea extends StatelessWidget {
  final String label;
  final int debounceDelay;
  final ValueChanged<String>? onDebouncedChange;
  final String size, fillMode, rounded;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int rows, maxRows;
  final bool autoSize;
  final String? placeholder;
  final int? maxLength;
  final bool enabled, readOnly, showClearButton;
  final FocusNode? focusNode;
  final String? helperText;
  final Widget? prefix, suffix;
  final ValueChanged<String>? onSubmitted;
  const NgTextArea({
    super.key,
    this.label = 'Notes',
    this.size = 'medium',
    this.fillMode = 'theme',
    this.rounded = 'theme',
    this.debounceDelay = 300,
    this.onDebouncedChange,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.rows = 4,
    this.autoSize = false,
    this.maxRows = 12,
    this.placeholder,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.showClearButton = false,
    this.focusNode,
    this.helperText,
    this.prefix,
    this.suffix,
    this.onSubmitted,
  });
  @override
  Widget build(BuildContext context) {
    if (maxLength != null && maxLength! <= 0)
      throw ArgumentError('maxLength must be positive.');
    if (controller != null && initialValue != null)
      throw ArgumentError('Use controller or initialValue, not both.');
    if (rows < 1 || rows > 30) throw ArgumentError('Use 1–30 rows.');
    if (maxRows < 1 || maxRows > 30 || (autoSize && maxRows < rows))
      throw ArgumentError(
        'Use 1–30 maximum rows, at least rows when autoSize is enabled.',
      );
    return NextgenTextEditor(
      label: label,
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
      rows: rows,
      autoSize: autoSize,
      maxRows: maxRows,
      multiline: true,
    );
  }
}

class NgFilterRules {
  static void validate(String mode, int minLength) {
    if (!['contains', 'startsWith', 'endsWith'].contains(mode) || minLength < 0)
      throw ArgumentError(
        'Use contains/startsWith/endsWith and a nonnegative minimum length.',
      );
  }

  static bool matches(String label, String query, String mode, int minLength) {
    if (query.length < minLength) return false;
    final l = label.toLowerCase(), q = query.toLowerCase();
    return mode == 'startsWith'
        ? l.startsWith(q)
        : mode == 'endsWith'
        ? l.endsWith(q)
        : l.contains(q);
  }

  static void validateItems(List<NgOption> items) {
    if (items.any((o) => o.value.trim().isEmpty || o.label.trim().isEmpty) ||
        items.map((o) => o.value).toSet().length != items.length)
      throw ArgumentError(
        'Options need unique nonempty values and nonempty labels.',
      );
  }
}

class NgAutoComplete extends StatefulWidget {
  final String label, initialValue, filterMode;
  final String? placeholder;
  final List<String> items;
  final ValueChanged<String>? onChanged;
  final bool enabled, readOnly;
  final int minLength;
  const NgAutoComplete({
    super.key,
    this.label = 'Search',
    required this.items,
    this.initialValue = '',
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.filterMode = 'contains',
    this.minLength = 1,
    this.placeholder,
  });
  @override
  State<NgAutoComplete> createState() => _NgAutoCompleteState();
}

class _NgAutoCompleteState extends State<NgAutoComplete> {
  late final controller = TextEditingController(text: widget.initialValue);
  final focus = FocusNode();
  @override
  void didUpdateWidget(covariant NgAutoComplete old) {
    super.didUpdateWidget(old);
    if (widget.readOnly || !widget.enabled) focus.unfocus();
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NgFilterRules.validate(widget.filterMode, widget.minLength);
    return Autocomplete<String>(
      textEditingController: controller,
      focusNode: focus,
      optionsBuilder: (v) => !widget.enabled || widget.readOnly
          ? const Iterable<String>.empty()
          : widget.items.where(
              (s) => NgFilterRules.matches(
                s,
                v.text,
                widget.filterMode,
                widget.minLength,
              ),
            ),
      onSelected: (v) {
        if (widget.enabled && !widget.readOnly) widget.onChanged?.call(v);
      },
      fieldViewBuilder: (context, controller, focus, onSubmitted) =>
          TextFormField(
            controller: controller,
            focusNode: focus,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            onChanged: widget.onChanged,
            onFieldSubmitted: (_) {
              if (!widget.readOnly) onSubmitted();
            },
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.placeholder,
            ),
          ),
    );
  }
}

class NgComboBox extends StatefulWidget {
  final String label;
  final String? value;
  final List<NgOption> items;
  final ValueChanged<String?>? onChanged;
  final bool enabled, required, readOnly, showClearButton;
  final String filterMode;
  final String? placeholder;
  final int minLength;
  final Widget Function(BuildContext, NgOption)? itemBuilder;
  const NgComboBox({
    super.key,
    this.label = 'Choose an option',
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.showClearButton = false,
    this.filterMode = 'contains',
    this.minLength = 0,
    this.placeholder,
    this.itemBuilder,
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
    if (widget.readOnly || !widget.enabled) focus.unfocus();
    final before = old.items.where((o) => o.value == old.value).firstOrNull;
    final after = widget.items
        .where((o) => o.value == widget.value)
        .firstOrNull;
    if ((old.value != widget.value || before?.label != after?.label) &&
        controller.text != textFor(widget.value))
      controller.text = textFor(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    NgFilterRules.validate(widget.filterMode, widget.minLength);
    NgFilterRules.validateItems(widget.items);
    return RawAutocomplete<NgOption>(
      textEditingController: controller,
      focusNode: focus,
      displayStringForOption: (o) => o.label,
      optionsBuilder: (v) => widget.items.where(
        (o) =>
            widget.enabled &&
            !widget.readOnly &&
            !o.disabled &&
            NgFilterRules.matches(
              o.label,
              v.text,
              widget.filterMode,
              widget.minLength,
            ),
      ),
      onSelected: (o) {
        if (widget.enabled &&
            !widget.readOnly &&
            widget.items.any(
              (current) =>
                  current.value == o.value &&
                  current.label == o.label &&
                  !current.disabled,
            ))
          widget.onChanged?.call(o.value);
      },
      fieldViewBuilder: (context, controller, focus, onSubmitted) =>
          TextFormField(
            controller: controller,
            focusNode: focus,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) {
              if (text == null || text.isEmpty)
                return widget.required ? '${widget.label} is required' : null;
              return widget.items.any(
                    (o) =>
                        !o.disabled &&
                        o.label.toLowerCase() == text.toLowerCase(),
                  )
                  ? null
                  : 'Choose an option from the list.';
            },
            onFieldSubmitted: (_) => onSubmitted(),
            onChanged: (text) {
              final match = widget.items
                  .where(
                    (o) =>
                        !o.disabled &&
                        o.label.toLowerCase() == text.toLowerCase(),
                  )
                  .firstOrNull;
              if (match != null || text.isEmpty)
                widget.onChanged?.call(match?.value);
            },
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.placeholder,
              suffixIcon: widget.showClearButton
                  ? IconButton(
                      tooltip: 'Clear ${widget.label}',
                      onPressed: widget.enabled && !widget.readOnly
                          ? () {
                              controller.clear();
                              widget.onChanged?.call(null);
                            }
                          : null,
                      icon: const Icon(Icons.clear),
                    )
                  : const Icon(Icons.expand_more),
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
                      selected:
                          options.toList().indexOf(o) ==
                          AutocompleteHighlightedOption.of(context),
                      title: Semantics(
                        label: o.label,
                        excludeSemantics: true,
                        child:
                            widget.itemBuilder?.call(context, o) ??
                            Text(o.label),
                      ),
                      onTap: () => onSelected(o),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

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
  final bool enabled, required, readOnly, showActions;
  final String filterMode, placeholder, emptyText;
  final int minLength;
  final Widget Function(BuildContext, NgOption)? itemBuilder, tagBuilder;
  const NgMultiSelect({
    super.key,
    this.label = 'Options',
    required this.value,
    required this.items,
    this.onChanged,
    this.maxSelected,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.showActions = false,
    this.filterMode = 'contains',
    this.minLength = 0,
    this.placeholder = 'Filter options…',
    this.emptyText = 'No matches',
    this.itemBuilder,
    this.tagBuilder,
  });
  @override
  State<NgMultiSelect> createState() => _NgMultiSelectState();
}

class _NgMultiSelectState extends State<NgMultiSelect> {
  final fieldKey = GlobalKey<FormFieldState<List<String>>>();
  String query = '';
  String? error;
  void toggle(String value) {
    if (!widget.enabled || widget.readOnly || !canRemove(value)) return;
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

  bool canToggle(NgOption o) =>
      widget.enabled &&
      !widget.readOnly &&
      !o.disabled &&
      (widget.value.contains(o.value) ||
          widget.maxSelected == null ||
          widget.value.length < widget.maxSelected!);
  bool canRemove(String value) =>
      widget.items.where((o) => o.value == value).firstOrNull?.disabled != true;
  List<NgOption> get filtered => widget.items
      .where(
        (o) => NgFilterRules.matches(
          o.label,
          query,
          widget.filterMode,
          widget.minLength,
        ),
      )
      .toList();
  void publish(List<String> next) {
    if (!widget.enabled || widget.readOnly) return;
    setState(() => error = null);
    fieldKey.currentState?.didChange([...next]);
    widget.onChanged?.call([...next]);
  }

  void selectFiltered() {
    if (!widget.enabled || widget.readOnly) return;
    final next = {
      ...widget.value,
      ...filtered.where((o) => !o.disabled).map((o) => o.value),
    }.toList();
    if (widget.maxSelected != null && next.length > widget.maxSelected!) {
      setState(() => error = 'Select at most ${widget.maxSelected} options.');
      return;
    }
    publish(next);
  }

  @override
  Widget build(BuildContext context) {
    NgFilterRules.validate(widget.filterMode, widget.minLength);
    NgFilterRules.validateItems(widget.items);
    if (widget.maxSelected != null && widget.maxSelected! <= 0)
      throw ArgumentError('maxSelected must be positive.');
    return FormField<List<String>>(
      key: fieldKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: widget.value,
      enabled: widget.enabled,
      validator: (current) => widget.required && widget.value.isEmpty
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
                      label: Builder(
                        builder: (context) {
                          final option = widget.items
                              .where((o) => o.value == v)
                              .firstOrNull;
                          return Semantics(
                            label: option?.label ?? v,
                            excludeSemantics: true,
                            child: option != null
                                ? (widget.tagBuilder?.call(context, option) ??
                                      Text(option.label))
                                : Text(v),
                          );
                        },
                      ),
                      onDeleted:
                          widget.enabled && !widget.readOnly && canRemove(v)
                          ? () => toggle(v)
                          : null,
                    ),
                  )
                  .toList(),
            ),
            TextField(
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                labelText: 'Filter ${widget.label}',
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            if (widget.showActions)
              Wrap(
                spacing: 8,
                children: [
                  NgButton(
                    onPressed:
                        widget.enabled &&
                            !widget.readOnly &&
                            filtered.any(
                              (o) =>
                                  !o.disabled &&
                                  !widget.value.contains(o.value),
                            )
                        ? selectFiltered
                        : null,
                    child: const Text('Select filtered'),
                  ),
                  NgButton(
                    onPressed:
                        widget.enabled &&
                            !widget.readOnly &&
                            widget.value.any(canRemove)
                        ? () => publish(
                            widget.value.where((v) => !canRemove(v)).toList(),
                          )
                        : null,
                    child: const Text('Clear selection'),
                  ),
                ],
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  children: filtered
                      .map(
                        (o) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              semanticLabel: o.label,
                              value: widget.value.contains(o.value),
                              onChanged:
                                  !widget.enabled ||
                                      widget.readOnly ||
                                      o.disabled ||
                                      (widget.maxSelected != null &&
                                          widget.value.length >=
                                              widget.maxSelected! &&
                                          !widget.value.contains(o.value))
                                  ? null
                                  : (_) => toggle(o.value),
                            ),
                            Flexible(
                              child: ExcludeSemantics(
                                child: GestureDetector(
                                  onTap: canToggle(o)
                                      ? () => toggle(o.value)
                                      : null,
                                  child:
                                      widget.itemBuilder?.call(context, o) ??
                                      Text(o.label),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            if (filtered.isEmpty) Text(widget.emptyText),
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
}

class NgForm extends StatefulWidget {
  final Widget? child;
  final List<Widget>? fields;
  final List<NgFormSection>? sections;
  final List<int>? fieldSpans;
  final int columns, minColumnWidth, gap;
  final Widget Function(BuildContext, VoidCallback?)? actionsBuilder;
  final FutureOr<void> Function() onValidSubmit;
  final VoidCallback? onInvalidSubmit;
  final bool enabled, showSummary;
  final String busyText, errorText;
  final String summaryTitle;
  final Widget Function(BuildContext, List<String>)? summaryBuilder;
  final String submitLabel;
  final GlobalKey<FormState>? formKey;
  const NgForm({
    super.key,
    this.child,
    this.fields,
    this.sections,
    this.fieldSpans,
    this.columns = 1,
    this.minColumnWidth = 240,
    this.gap = 16,
    this.actionsBuilder,
    required this.onValidSubmit,
    this.submitLabel = 'Save',
    this.onInvalidSubmit,
    this.enabled = true,
    this.showSummary = true,
    this.summaryTitle = 'Please correct the highlighted fields.',
    this.summaryBuilder,
    this.busyText = 'Saving…',
    this.errorText = 'Unable to save. Try again.',
    this.formKey,
  });
  @override
  State<NgForm> createState() => _NgFormState();
}

class _NgFormState extends State<NgForm> {
  final internalKey = GlobalKey<FormState>();
  bool busy = false, error = false, attempted = false, refreshQueued = false;
  List<String> messages = const [];
  List<String> collectErrors(FormState form) => List.unmodifiable(
    form.validateGranularly().map((field) => field.errorText ?? ''),
  );
  void queueSummaryRefresh() {
    if (!attempted || refreshQueued) return;
    refreshQueued = true;
    final key = widget.formKey ?? internalKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshQueued = false;
      if (!mounted ||
          !attempted ||
          key != (widget.formKey ?? internalKey) ||
          key.currentState == null)
        return;
      final next = collectErrors(key.currentState!);
      setState(() => messages = next);
    });
  }

  @override
  void didUpdateWidget(covariant NgForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formKey != widget.formKey) {
      attempted = false;
      messages = const [];
    }
  }

  Future<void> submit() async {
    if (!mounted || busy || !widget.enabled) return;
    final next = collectErrors((widget.formKey ?? internalKey).currentState!);
    final valid = next.isEmpty;
    setState(() {
      attempted = true;
      messages = next;
      error = false;
    });
    if (!valid) {
      widget.onInvalidSubmit?.call();
      return;
    }
    setState(() => busy = true);
    try {
      await widget.onValidSubmit();
    } catch (_) {
      if (mounted) setState(() => error = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if ([
          widget.child,
          widget.fields,
          widget.sections,
        ].where((value) => value != null).length !=
        1)
      throw ArgumentError('Supply exactly one of child, fields or sections.');
    if (widget.sections != null) {
      if (widget.sections!.map((section) => section.id).toSet().length !=
          widget.sections!.length)
        throw ArgumentError('Section IDs must be unique.');
      for (final section in widget.sections!) {
        section.validate();
      }
    }
    if (widget.fieldSpans != null &&
        (widget.fields == null ||
            widget.fieldSpans!.length != widget.fields!.length ||
            widget.fieldSpans!.any((span) => span < 0 || span > 4)))
      throw ArgumentError(
        'Supply one span (0–4) per field; zero fills the row.',
      );
    if (widget.columns < 1 || widget.columns > 4)
      throw ArgumentError('Use 1–4 columns.');
    if (widget.minColumnWidth < 120 || widget.minColumnWidth > 1200)
      throw ArgumentError('Use a minimum column width of 120–1200.');
    if (widget.gap < 0 || widget.gap > 64)
      throw ArgumentError('Use a gap of 0–64.');
    return Form(
      key: widget.formKey ?? internalKey,
      onChanged: queueSummaryRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (messages.isNotEmpty && widget.showSummary)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Semantics(
                liveRegion: true,
                child:
                    widget.summaryBuilder?.call(context, messages) ??
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.summaryTitle),
                          for (final message in messages) Text('• $message'),
                        ],
                      ),
                    ),
              ),
            ),
          AbsorbPointer(
            key: const ValueKey('ng-form-content'),
            absorbing: busy || !widget.enabled,
            child: ExcludeFocus(
              excluding: busy || !widget.enabled,
              child: widget.sections != null
                  ? _FormSections(
                      sections: widget.sections!,
                      enabled: !busy && widget.enabled,
                    )
                  : widget.fields == null
                  ? widget.child!
                  : _FormFields(
                      fields: widget.fields!,
                      fieldSpans: widget.fieldSpans,
                      columns: widget.columns,
                      minColumnWidth: widget.minColumnWidth,
                      gap: widget.gap,
                    ),
            ),
          ),
          if (busy) Semantics(liveRegion: true, child: Text(widget.busyText)),
          if (error)
            Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          if (widget.actionsBuilder != null)
            AbsorbPointer(
              absorbing: busy || !widget.enabled,
              child: ExcludeFocus(
                excluding: busy || !widget.enabled,
                child: widget.actionsBuilder!(
                  context,
                  busy || !widget.enabled ? null : submit,
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: NgButton(
                primary: true,
                onPressed: busy || !widget.enabled ? null : submit,
                child: Text(widget.submitLabel),
              ),
            ),
        ],
      ),
    );
  }
}

/// Explicit section data; all sections share the containing NgForm.
class NgFormSection {
  final String id, title;
  final bool expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final String? description;
  final List<Widget>? fields;
  final List<NgFormSection>? sections;
  final List<int>? fieldSpans;
  final int columns, minColumnWidth, gap;
  const NgFormSection({
    required this.id,
    required this.title,
    this.fields,
    this.sections,
    this.expanded = true,
    this.onExpandedChanged,
    this.description,
    this.fieldSpans,
    this.columns = 1,
    this.minColumnWidth = 240,
    this.gap = 16,
  });
  void validate([int depth = 1]) {
    if (depth > 8)
      throw ArgumentError(
        "Sections must be acyclic and at most eight levels deep.",
      );
    if ((fields == null) == (sections == null))
      throw ArgumentError("Supply either fields or sections for each section.");
    if (id.trim().isEmpty || title.trim().isEmpty)
      throw ArgumentError('A section needs a nonempty ID and title.');
    if (columns < 1 ||
        columns > 4 ||
        minColumnWidth < 120 ||
        minColumnWidth > 1200 ||
        gap < 0 ||
        gap > 64)
      throw ArgumentError('Invalid section layout limits.');
    if (fieldSpans != null &&
        (fields == null ||
            fieldSpans!.length != fields!.length ||
            fieldSpans!.any((span) => span < 0 || span > 4)))
      throw ArgumentError('Supply one span (0–4) per section field.');
    if (sections != null) {
      if (sections!.map((section) => section.id).toSet().length !=
          sections!.length)
        throw ArgumentError('Sibling sections need unique IDs.');
      for (final section in sections!) {
        section.validate(depth + 1);
      }
    }
  }
}

class _FormFields extends StatelessWidget {
  final List<Widget> fields;
  final List<int>? fieldSpans;
  final int columns, minColumnWidth, gap;
  const _FormFields({
    required this.fields,
    this.fieldSpans,
    required this.columns,
    required this.minColumnWidth,
    required this.gap,
  });
  int effectiveSpan(int index, int columns) {
    final span = fieldSpans?[index] ?? 1;
    return span == 0 ? columns : span.clamp(1, columns);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Keep the same Wrap/SizedBox tree across column changes so fields retain state.
      final width = constraints.maxWidth;
      final count = !width.isFinite
          ? 1
          : ((width + gap) / (minColumnWidth + gap))
                .floor()
                .clamp(1, columns)
                .clamp(
                  1,
                  fields.isEmpty
                      ? 1
                      : List.generate(
                          fields.length,
                          (i) => fieldSpans?[i] ?? 1,
                        ).fold<int>(
                          0,
                          (sum, span) => sum + (span == 0 ? columns : span),
                        ),
                );
      final cellWidth = width.isFinite
          ? ((width - (count - 1) * gap) / count).clamp(0.0, double.infinity)
          : minColumnWidth.toDouble();
      return Wrap(
        spacing: gap.toDouble(),
        runSpacing: gap.toDouble(),
        children: [
          for (var i = 0; i < fields.length; i++)
            SizedBox(
              key: fields[i].key == null ? null : ValueKey(fields[i].key),
              width:
                  cellWidth * effectiveSpan(i, count) +
                  gap * (effectiveSpan(i, count) - 1),
              child: fields[i],
            ),
        ],
      );
    },
  );
}

class _FormSections extends StatelessWidget {
  final List<NgFormSection> sections;
  final int depth;
  final bool enabled;
  const _FormSections({
    required this.sections,
    this.depth = 1,
    this.enabled = true,
  });
  void toggle(BuildContext context, NgFormSection section) {
    if (!context.mounted) return;
    final current = context.widget as _FormSections;
    if (!current.enabled ||
        !current.sections.any((candidate) => identical(candidate, section)))
      return;
    section.onExpandedChanged?.call(!section.expanded);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final section in sections)
        Padding(
          key: ValueKey(section.id),
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            padding: EdgeInsets.all(depth == 1 ? 16 : 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  expanded: section.onExpandedChanged == null
                      ? null
                      : section.expanded,
                  child: section.onExpandedChanged == null
                      ? Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : TextButton(
                          onPressed: enabled
                              ? () => toggle(context, section)
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                section.expanded
                                    ? Icons.expand_more
                                    : Icons.chevron_right,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(section.title)),
                            ],
                          ),
                        ),
                ),
                Offstage(
                  offstage: !section.expanded,
                  child: ExcludeFocus(
                    excluding: !section.expanded,
                    child: TickerMode(
                      enabled: section.expanded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (section.description?.trim().isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(section.description!),
                            ),
                          const SizedBox(height: 16),
                          if (section.fields != null)
                            _FormFields(
                              fields: section.fields!,
                              fieldSpans: section.fieldSpans,
                              columns: section.columns,
                              minColumnWidth: section.minColumnWidth,
                              gap: section.gap,
                            )
                          else
                            _FormSections(
                              sections: section.sections!,
                              depth: depth + 1,
                              enabled: enabled && section.expanded,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
