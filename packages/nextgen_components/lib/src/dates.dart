import 'package:flutter/material.dart';

/// Dates are local calendar values, without implicit UTC conversion.
abstract final class NgDateRules {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static String dateText(DateTime? d) => d == null
      ? ''
      : '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String timeText(TimeOfDay? t) => t == null
      ? ''
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  static DateTime? parseDate(String text) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return null;
    final p = text.split('-').map(int.parse).toList();
    if (p[0] < 1 || p[0] > 9999) return null;
    final d = DateTime(p[0], p[1], p[2]);
    return d.year == p[0] && d.month == p[1] && d.day == p[2] ? d : null;
  }

  static TimeOfDay? parseTime(String text) {
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(text)) return null;
    final p = text.split(':').map(int.parse).toList();
    return p[0] < 24 && p[1] < 60 ? TimeOfDay(hour: p[0], minute: p[1]) : null;
  }

  static DateTime? parseDateTime(String text) {
    final parts = text.split(' ');
    if (parts.length != 2) return null;
    final d = parseDate(parts[0]), t = parseTime(parts[1]);
    return d == null || t == null
        ? null
        : DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  static bool allowed(
    DateTime d, {
    DateTime? min,
    DateTime? max,
    bool Function(DateTime)? disabledDate,
  }) {
    final date = dateOnly(d);
    return (min == null || !date.isBefore(dateOnly(min))) &&
        (max == null || !date.isAfter(dateOnly(max))) &&
        !(disabledDate?.call(date) ?? false);
  }

  static void checkBounds(DateTime? min, DateTime? max) {
    if ((min != null && (min.year < 1 || min.year > 9999)) ||
        (max != null && (max.year < 1 || max.year > 9999)) ||
        (min != null && max != null && dateOnly(min).isAfter(dateOnly(max)))) {
      throw ArgumentError(
        'Dates must be within years 1–9999 and Min must not exceed Max',
      );
    }
  }

  static String? rangeError(NgDateRange? range) {
    if (range == null || (range.start == null && range.end == null))
      return null;
    if (range.start == null || range.end == null)
      return 'Enter both start and end dates.';
    return dateOnly(range.end!).isBefore(dateOnly(range.start!))
        ? 'End date must not precede start date.'
        : null;
  }
}

class NgDateRange {
  final DateTime? start, end;
  const NgDateRange(this.start, this.end);
  @override
  bool operator ==(Object other) =>
      other is NgDateRange && start == other.start && end == other.end;
  @override
  int get hashCode => Object.hash(start, end);
}

class NgCalendar extends StatelessWidget {
  final DateTime? value, min, max;
  final ValueChanged<DateTime>? onChanged;
  final bool enabled, readOnly;
  final bool Function(DateTime)? disabledDate;
  const NgCalendar({
    super.key,
    this.value,
    this.min,
    this.max,
    this.onChanged,
    this.disabledDate,
    this.enabled = true,
    this.readOnly = false,
  });
  @override
  Widget build(BuildContext context) {
    NgDateRules.checkBounds(min, max);
    final first = NgDateRules.dateOnly(min ?? DateTime(1900));
    final last = NgDateRules.dateOnly(max ?? DateTime(2100, 12, 31));
    NgDateRules.checkBounds(first, last);

    // A disabled selected value must never trigger CalendarDatePicker's assertion.
    var initial = NgDateRules.dateOnly(value ?? DateTime.now());
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    if (disabledDate?.call(initial) ?? false) {
      DateTime? available;
      for (
        var d = first;
        !d.isAfter(last);
        d = DateTime(d.year, d.month, d.day + 1)
      ) {
        if (!(disabledDate?.call(d) ?? false)) {
          available = d;
          break;
        }
      }
      if (available == null)
        return const SizedBox(
          height: 80,
          child: Center(child: Text('No dates available')),
        );
      initial = available;
    }
    return SizedBox(
      width: 300,
      height: 320,
      child: AbsorbPointer(
        absorbing: onChanged == null || !enabled || readOnly,
        child: ExcludeFocus(
          excluding: onChanged == null || !enabled || readOnly,
          child: Opacity(
            opacity: !enabled || onChanged == null ? 0.5 : 1,
            child: CalendarDatePicker(
              key: ValueKey(
                '${NgDateRules.dateText(value)}:${NgDateRules.dateText(first)}:${NgDateRules.dateText(last)}:${NgDateRules.dateText(initial)}',
              ),
              initialDate: initial,
              firstDate: first,
              lastDate: last,
              selectableDayPredicate: (d) => !(disabledDate?.call(d) ?? false),
              onDateChanged: (d) {
                if (enabled &&
                    !readOnly &&
                    NgDateRules.allowed(
                      d,
                      min: min,
                      max: max,
                      disabledDate: disabledDate,
                    ))
                  onChanged?.call(d);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared controlled text draft. Invalid edits remain visible without overwriting
/// the last valid value; Form.validate still rejects the invalid draft.
class NgTemporalField<T> extends StatefulWidget {
  final String label, hint;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T?) format;
  final T? Function(String) parse;
  final String? Function(T)? validateValue;
  final bool required, enabled, readOnly;
  final Widget Function(ValueChanged<T>)? suffixBuilder;
  const NgTemporalField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.format,
    required this.parse,
    this.onChanged,
    this.validateValue,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.suffixBuilder,
  });
  @override
  State<NgTemporalField<T>> createState() => _NgTemporalFieldState<T>();
}

class _NgTemporalFieldState<T> extends State<NgTemporalField<T>> {
  late final TextEditingController controller;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.format(widget.value));
  }

  @override
  void didUpdateWidget(covariant NgTemporalField<T> old) {
    super.didUpdateWidget(old);
    revision++;
    if (old.value != widget.value &&
        widget.parse(controller.text) != widget.value) {
      final generation = revision;
      // Controller listeners notify FormState; defer until its build completes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == revision) {
          controller.text = widget.format(widget.value);
        }
      });
    }
  }

  String? validate(String? text) {
    if (text == null || text.isEmpty)
      return widget.required ? '${widget.label} is required' : null;
    final parsed = widget.parse(text);
    return parsed == null
        ? 'Enter a valid value (${widget.hint}).'
        : widget.validateValue?.call(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final generation = revision;
    return TextFormField(
      controller: controller,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: widget.suffixBuilder?.call((value) {
          if (!mounted ||
              generation != revision ||
              !widget.enabled ||
              widget.readOnly)
            return;
          setState(() => revision++);
          controller.text = widget.format(value);
          if (validate(controller.text) != null) return;
          widget.onChanged?.call(value);
        }),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validate,
      onChanged: (text) {
        setState(() => revision++);
        if (widget.enabled && !widget.readOnly && validate(text) == null)
          widget.onChanged?.call(text.isEmpty ? null : widget.parse(text));
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class NgDateInput extends StatelessWidget {
  final String label;
  final DateTime? value, min, max;
  final bool required, enabled, readOnly;
  final bool Function(DateTime)? disabledDate;
  final ValueChanged<DateTime?>? onChanged;
  const NgDateInput({
    super.key,
    this.label = 'Date',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.disabledDate,
  });
  @override
  Widget build(BuildContext context) {
    NgDateRules.checkBounds(min, max);
    return NgTemporalField<DateTime>(
      label: label,
      hint: 'yyyy-mm-dd',
      value: value,
      onChanged: onChanged,
      format: NgDateRules.dateText,
      parse: NgDateRules.parseDate,
      required: required,
      enabled: enabled,
      readOnly: readOnly,
      validateValue: (d) =>
          NgDateRules.allowed(d, min: min, max: max, disabledDate: disabledDate)
          ? null
          : 'This date is not available.',
    );
  }
}

class NgDatePicker extends StatelessWidget {
  final String label;
  final DateTime? value, min, max;
  final bool required, enabled, readOnly;
  final bool Function(DateTime)? disabledDate;
  final ValueChanged<DateTime?>? onChanged;
  const NgDatePicker({
    super.key,
    this.label = 'Date',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.disabledDate,
  });
  @override
  Widget build(BuildContext context) {
    NgDateRules.checkBounds(min, max);
    return NgTemporalField<DateTime>(
      label: label,
      hint: 'yyyy-mm-dd',
      value: value,
      onChanged: onChanged,
      format: NgDateRules.dateText,
      parse: NgDateRules.parseDate,
      required: required,
      enabled: enabled,
      readOnly: readOnly,
      validateValue: (d) =>
          NgDateRules.allowed(d, min: min, max: max, disabledDate: disabledDate)
          ? null
          : 'This date is not available.',
      suffixBuilder: (apply) => IconButton(
        tooltip: 'Choose $label',
        icon: const Icon(Icons.calendar_month),
        onPressed: !enabled || readOnly || onChanged == null
            ? null
            : () async {
                final result = await showDialog<DateTime>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Choose $label'),
                    content: SizedBox(
                      width: 300,
                      height: 320,
                      child: NgCalendar(
                        value: value,
                        min: min,
                        max: max,
                        disabledDate: disabledDate,
                        onChanged: (d) => Navigator.pop(ctx, d),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
                if (result != null) apply(result);
              },
      ),
    );
  }
}

class NgTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? value, min, max;
  final bool required, enabled, readOnly;
  final int minuteStep;
  final ValueChanged<TimeOfDay?>? onChanged;
  const NgTimePicker({
    super.key,
    this.label = 'Time',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.minuteStep = 1,
  });
  static int minutes(TimeOfDay t) => t.hour * 60 + t.minute;
  String? validate(TimeOfDay t) =>
      (min != null && minutes(t) < minutes(min!)) ||
          (max != null && minutes(t) > minutes(max!))
      ? 'Time is outside the allowed range.'
      : t.minute % minuteStep != 0
      ? 'Choose a time in $minuteStep-minute intervals.'
      : null;
  @override
  Widget build(BuildContext context) {
    if (minuteStep < 1 ||
        minuteStep > 60 ||
        60 % minuteStep != 0 ||
        (min != null && max != null && minutes(min!) > minutes(max!)))
      throw ArgumentError(
        'MinuteStep must divide 60 and Min must not exceed Max',
      );
    return NgTemporalField<TimeOfDay>(
      label: label,
      hint: 'hh:mm',
      value: value,
      onChanged: onChanged,
      format: NgDateRules.timeText,
      parse: NgDateRules.parseTime,
      required: required,
      enabled: enabled,
      readOnly: readOnly,
      validateValue: validate,
      suffixBuilder: (apply) => IconButton(
        tooltip: 'Choose $label',
        icon: const Icon(Icons.schedule),
        onPressed: !enabled || readOnly || onChanged == null
            ? null
            : () async {
                final result = await showTimePicker(
                  context: context,
                  initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
                );
                if (result != null) {
                  if (validate(result) == null)
                    apply(result);
                  else if (context.mounted)
                    ScaffoldMessenger.maybeOf(
                      context,
                    )?.showSnackBar(SnackBar(content: Text(validate(result)!)));
                }
              },
      ),
    );
  }
}

class NgDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? value, min, max;
  final bool required, enabled, readOnly;
  final int minuteStep;
  final ValueChanged<DateTime?>? onChanged;
  const NgDateTimePicker({
    super.key,
    this.label = 'Date and time',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.minuteStep = 1,
  });
  String? validate(DateTime d) =>
      (min != null && d.isBefore(min!)) || (max != null && d.isAfter(max!))
      ? 'Value is outside the allowed range.'
      : d.minute % minuteStep != 0
      ? 'Choose a time in $minuteStep-minute intervals.'
      : null;
  @override
  Widget build(BuildContext context) {
    if (minuteStep < 1 ||
        minuteStep > 60 ||
        60 % minuteStep != 0 ||
        (min != null && max != null && min!.isAfter(max!)))
      throw ArgumentError(
        'MinuteStep must divide 60 and Min must not exceed Max',
      );
    return NgTemporalField<DateTime>(
      label: label,
      hint: 'yyyy-mm-dd hh:mm',
      value: value,
      onChanged: onChanged,
      format: (d) => d == null
          ? ''
          : '${NgDateRules.dateText(d)} ${NgDateRules.timeText(TimeOfDay.fromDateTime(d))}',
      parse: NgDateRules.parseDateTime,
      required: required,
      enabled: enabled,
      readOnly: readOnly,
      validateValue: validate,
      suffixBuilder: (apply) => IconButton(
        tooltip: 'Choose $label',
        icon: const Icon(Icons.event),
        onPressed: !enabled || readOnly || onChanged == null
            ? null
            : () async {
                final first = NgDateRules.dateOnly(min ?? DateTime(1900)),
                    last = NgDateRules.dateOnly(max ?? DateTime(2100, 12, 31));
                var initial = NgDateRules.dateOnly(value ?? DateTime.now());
                if (initial.isBefore(first)) initial = first;
                if (initial.isAfter(last)) initial = last;
                final date = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: first,
                  lastDate: last,
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: value == null
                      ? const TimeOfDay(hour: 9, minute: 0)
                      : TimeOfDay.fromDateTime(value!),
                );
                if (time == null) return;
                final result = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
                if (validate(result) == null)
                  apply(result);
                else if (context.mounted)
                  ScaffoldMessenger.maybeOf(
                    context,
                  )?.showSnackBar(SnackBar(content: Text(validate(result)!)));
              },
      ),
    );
  }
}

// Synchronize external replacements without losing an edit before parent rebuild.
class _NgRangeField extends FormField<NgDateRange> {
  final NgDateRange? controlledValue;
  _NgRangeField({
    required this.controlledValue,
    required super.enabled,
    required super.validator,
    required super.builder,
  }) : super(
         initialValue: controlledValue,
         autovalidateMode: AutovalidateMode.onUserInteraction,
       );
  @override
  FormFieldState<NgDateRange> createState() => _NgRangeFieldState();
}

class _NgRangeFieldState extends FormFieldState<NgDateRange> {
  @override
  void didUpdateWidget(covariant _NgRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget as _NgRangeField;
    if (oldWidget.controlledValue != current.controlledValue) {
      setValue(current.controlledValue);
    }
  }
}

class NgDateRangePicker extends StatelessWidget {
  final String label;
  final NgDateRange? value;
  final DateTime? min, max;
  final bool enabled, required, readOnly;
  final bool Function(DateTime)? disabledDate;
  final ValueChanged<NgDateRange?>? onChanged;
  const NgDateRangePicker({
    super.key,
    this.label = 'Date range',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.disabledDate,
  });
  @override
  Widget build(BuildContext context) {
    NgDateRules.checkBounds(min, max);
    return _NgRangeField(
      controlledValue: value,
      enabled: enabled,
      validator: (current) =>
          required &&
              (current == null ||
                  (current.start == null && current.end == null))
          ? '$label is required'
          : NgDateRules.rangeError(current) ??
                ([current?.start, current?.end].whereType<DateTime>().any(
                      (d) => !NgDateRules.allowed(
                        d,
                        min: min,
                        max: max,
                        disabledDate: disabledDate,
                      ),
                    )
                    ? "This date is not available."
                    : null),
      builder: (field) {
        void update(NgDateRange next) {
          if (!enabled || readOnly || onChanged == null) return;
          field.didChange(next);
          onChanged?.call(next);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: c.maxWidth > 550
                        ? (c.maxWidth - 16) / 2
                        : c.maxWidth,
                    child: NgDatePicker(
                      label: 'Start date',
                      value: value?.start,
                      min: min,
                      max: max,
                      enabled: enabled,
                      readOnly: readOnly,
                      disabledDate: disabledDate,
                      onChanged: (d) => update(NgDateRange(d, value?.end)),
                    ),
                  ),
                  SizedBox(
                    width: c.maxWidth > 550
                        ? (c.maxWidth - 16) / 2
                        : c.maxWidth,
                    child: NgDatePicker(
                      label: 'End date',
                      value: value?.end,
                      min: min,
                      max: max,
                      enabled: enabled,
                      readOnly: readOnly,
                      disabledDate: disabledDate,
                      onChanged: (d) => update(NgDateRange(value?.start, d)),
                    ),
                  ),
                ],
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
