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
  final bool Function(DateTime)? disabledDate;
  const NgCalendar({
    super.key,
    this.value,
    this.min,
    this.max,
    this.onChanged,
    this.disabledDate,
  });
  @override
  Widget build(BuildContext context) {
    final first = NgDateRules.dateOnly(min ?? DateTime(1900));
    final last = NgDateRules.dateOnly(max ?? DateTime(2100, 12, 31));
    assert(!last.isBefore(first), 'Min must not exceed Max');
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
        absorbing: onChanged == null,
        child: Opacity(
          opacity: onChanged == null ? 0.5 : 1,
          child: CalendarDatePicker(
            key: ValueKey(
              '${NgDateRules.dateText(value)}:${NgDateRules.dateText(first)}:${NgDateRules.dateText(last)}',
            ),
            initialDate: initial,
            firstDate: first,
            lastDate: last,
            selectableDayPredicate: (d) => !(disabledDate?.call(d) ?? false),
            onDateChanged: (d) => onChanged?.call(d),
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
  final bool required, enabled;
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
    this.suffixBuilder,
  });
  @override
  State<NgTemporalField<T>> createState() => _NgTemporalFieldState<T>();
}

class _NgTemporalFieldState<T> extends State<NgTemporalField<T>> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.format(widget.value));
  }

  @override
  void didUpdateWidget(covariant NgTemporalField<T> old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value &&
        widget.parse(controller.text) != widget.value)
      controller.text = widget.format(widget.value);
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
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: widget.enabled,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      suffixIcon: widget.suffixBuilder?.call((value) {
        controller.text = widget.format(value);
        widget.onChanged?.call(value);
      }),
    ),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validate,
    onChanged: (text) {
      if (validate(text) == null)
        widget.onChanged?.call(text.isEmpty ? null : widget.parse(text));
    },
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class NgDateInput extends StatelessWidget {
  final String label;
  final DateTime? value, min, max;
  final bool required, enabled;
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
    this.disabledDate,
  });
  @override
  Widget build(BuildContext context) => NgTemporalField<DateTime>(
    label: label,
    hint: 'yyyy-mm-dd',
    value: value,
    onChanged: onChanged,
    format: NgDateRules.dateText,
    parse: NgDateRules.parseDate,
    required: required,
    enabled: enabled,
    validateValue: (d) =>
        NgDateRules.allowed(d, min: min, max: max, disabledDate: disabledDate)
        ? null
        : 'This date is not available.',
  );
}

class NgDatePicker extends StatelessWidget {
  final String label;
  final DateTime? value, min, max;
  final bool required, enabled;
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
    this.disabledDate,
  });
  @override
  Widget build(BuildContext context) => NgTemporalField<DateTime>(
    label: label,
    hint: 'yyyy-mm-dd',
    value: value,
    onChanged: onChanged,
    format: NgDateRules.dateText,
    parse: NgDateRules.parseDate,
    required: required,
    enabled: enabled,
    validateValue: (d) =>
        NgDateRules.allowed(d, min: min, max: max, disabledDate: disabledDate)
        ? null
        : 'This date is not available.',
    suffixBuilder: (apply) => IconButton(
      tooltip: 'Choose $label',
      icon: const Icon(Icons.calendar_month),
      onPressed: !enabled
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

class NgTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? value, min, max;
  final bool required, enabled;
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
  });
  static int minutes(TimeOfDay t) => t.hour * 60 + t.minute;
  String? validate(TimeOfDay t) =>
      (min != null && minutes(t) < minutes(min!)) ||
          (max != null && minutes(t) > minutes(max!))
      ? 'Time is outside the allowed range.'
      : null;
  @override
  Widget build(BuildContext context) => NgTemporalField<TimeOfDay>(
    label: label,
    hint: 'hh:mm',
    value: value,
    onChanged: onChanged,
    format: NgDateRules.timeText,
    parse: NgDateRules.parseTime,
    required: required,
    enabled: enabled,
    validateValue: validate,
    suffixBuilder: (apply) => IconButton(
      tooltip: 'Choose $label',
      icon: const Icon(Icons.schedule),
      onPressed: !enabled
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

class NgDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? value, min, max;
  final bool required, enabled;
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
  });
  String? validate(DateTime d) =>
      (min != null && d.isBefore(min!)) || (max != null && d.isAfter(max!))
      ? 'Value is outside the allowed range.'
      : null;
  @override
  Widget build(BuildContext context) => NgTemporalField<DateTime>(
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
    validateValue: validate,
    suffixBuilder: (apply) => IconButton(
      tooltip: 'Choose $label',
      icon: const Icon(Icons.event),
      onPressed: !enabled
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

class NgDateRangePicker extends StatelessWidget {
  final String label;
  final NgDateRange? value;
  final DateTime? min, max;
  final bool enabled, required;
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
  });
  @override
  Widget build(BuildContext context) => FormField<NgDateRange>(
    initialValue: value,
    enabled: enabled,
    validator: (current) =>
        required &&
            (current == null || (current.start == null && current.end == null))
        ? '$label is required'
        : NgDateRules.rangeError(current),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (field) {
      void update(NgDateRange next) {
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
                  width: c.maxWidth > 550 ? (c.maxWidth - 16) / 2 : c.maxWidth,
                  child: NgDatePicker(
                    label: 'Start date',
                    value: value?.start,
                    min: min,
                    max: max,
                    enabled: enabled,
                    onChanged: (d) => update(NgDateRange(d, value?.end)),
                  ),
                ),
                SizedBox(
                  width: c.maxWidth > 550 ? (c.maxWidth - 16) / 2 : c.maxWidth,
                  child: NgDatePicker(
                    label: 'End date',
                    value: value?.end,
                    min: min,
                    max: max,
                    enabled: enabled,
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
