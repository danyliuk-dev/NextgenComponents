import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class FormsGallery extends StatefulWidget {
  final bool dark, compact;
  final ValueChanged<bool> onDark, onCompact;
  final VoidCallback onBack;
  const FormsGallery({
    super.key,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
    required this.onBack,
  });
  @override
  State<FormsGallery> createState() => _FormsGalleryState();
}

class _FormsGalleryState extends State<FormsGallery> {
  String name = 'Design workshop',
      city = 'Kyiv',
      notes = 'Bring the latest design proposals.';
  String? person = 'alex', saved;
  DateTime? deadline = DateTime(2026, 10, 20),
      date = DateTime(2026, 10, 22),
      reminder = DateTime(2026, 10, 21, 9);
  TimeOfDay? time = const TimeOfDay(hour: 9, minute: 30);
  NgDateRange? range = NgDateRange(
    DateTime(2026, 10, 22),
    DateTime(2026, 10, 23),
  );
  List<String> services = ['room'];
  int revision = 0;
  bool readOnly = false, fail = false, choicesReadOnly = false;
  String filterMode = "contains";
  final min = DateTime(2026), max = DateTime(2026, 12, 31);
  static const people = [
    NgOption('alex', 'Alex Morgan'),
    NgOption('jamie', 'Jamie Chen'),
    NgOption('sam', 'Sam Rivera'),
    NgOption('unavailable', 'Unavailable facilitator', disabled: true),
  ];
  static const serviceOptions = [
    NgOption('room', 'Meeting room'),
    NgOption('coffee', 'Coffee'),
    NgOption('video', 'Video recording'),
    NgOption('lunch', 'Lunch'),
    NgOption('travel', 'Travel (unavailable)', disabled: true),
  ];
  void reset() => setState(() {
    revision++;
    name = 'Design workshop';
    city = 'Kyiv';
    notes = 'Bring the latest design proposals.';
    person = 'alex';
    saved = null;
    deadline = DateTime(2026, 10, 20);
    date = DateTime(2026, 10, 22);
    reminder = DateTime(2026, 10, 21, 9);
    time = const TimeOfDay(hour: 9, minute: 30);
    range = NgDateRange(date, DateTime(2026, 10, 23));
    services = ['room'];
  });
  Widget fields(List<Widget> children) => LayoutBuilder(
    builder: (context, c) {
      final width = c.maxWidth > 640 ? (c.maxWidth - 24) / 2 : c.maxWidth;
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: children
            .map((w) => SizedBox(width: width, child: w))
            .toList(),
      );
    },
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'N / NEXTGEN COMPONENTS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Foundation'),
                  ),
                  NgSwitch(
                    label: 'Dark theme',
                    value: widget.dark,
                    onChanged: widget.onDark,
                  ),
                  NgCheckBox(
                    label: 'Compact',
                    value: widget.compact,
                    onChanged: widget.onCompact,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'FLUTTER / FORMS AND DATES 0.53',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Every detail.\nIn the right place.',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Plan a team workshop. Dates use yyyy-mm-dd; Sundays are unavailable for the workshop.',
              ),
              const SizedBox(height: 28),
              Wrap(
                children: [
                  NgCheckBox(
                    label: 'Read only text and dates',
                    value: readOnly,
                    onChanged: (v) => setState(() => readOnly = v),
                  ),
                  NgCheckBox(
                    label: 'Simulate save failure',
                    value: fail,
                    onChanged: (v) => setState(() => fail = v),
                  ),
                ],
              ),
              Wrap(
                spacing: 16,
                children: [
                  NgCheckBox(
                    label: 'Read only choices',
                    value: choicesReadOnly,
                    onChanged: (v) => setState(() => choicesReadOnly = v),
                  ),
                  SizedBox(
                    width: 200,
                    child: NgDropDownList(
                      label: 'Search mode',
                      value: filterMode,
                      items: const [
                        NgOption('contains', 'Contains'),
                        NgOption('startsWith', 'Starts with'),
                        NgOption('endsWith', 'Ends with'),
                      ],
                      onChanged: (v) => setState(() => filterMode = v!),
                    ),
                  ),
                ],
              ),
              if (saved != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      'Workshop saved\n$saved',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: NgForm(
                  key: ValueKey(revision),
                  submitLabel: 'Save workshop',
                  onValidSubmit: () async {
                    final version = revision, denied = fail;
                    final snapshot =
                        '$name · $city · $person · ${NgDateRules.dateText(date)} ${NgDateRules.timeText(time)} · ${NgDateRules.dateText(range?.start)} – ${NgDateRules.dateText(range?.end)} · ${services.join(', ')}';
                    await Future<void>.delayed(
                      const Duration(milliseconds: 1200),
                    );
                    if (denied) throw StateError('Demo failure');
                    if (mounted && version == revision)
                      setState(() => saved = snapshot);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workshop booking',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      fields([
                        NgTextBox(
                          label: 'Workshop name',
                          readOnly: readOnly,
                          maxLength: 80,
                          helperText: 'Required. Use a descriptive name.',
                          prefix: const Icon(Icons.edit_outlined),
                          initialValue: name,
                          onChanged: (v) => name = v,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Workshop name is required'
                              : null,
                        ),
                        NgAutoComplete(
                          label: 'City',
                          filterMode: filterMode,
                          minLength: 2,
                          readOnly: choicesReadOnly,
                          placeholder: 'Type two letters',
                          initialValue: city,
                          items: const [
                            'Kyiv',
                            'London',
                            'Lisbon',
                            'Berlin',
                            'Paris',
                          ],
                          onChanged: (v) => city = v,
                        ),
                        NgComboBox(
                          label: 'Facilitator',
                          filterMode: filterMode,
                          readOnly: choicesReadOnly,
                          showClearButton: true,
                          itemBuilder: (_, o) =>
                              Text('${o.label} · Facilitator'),
                          value: person,
                          items: people,
                          required: true,
                          onChanged: (v) => setState(() => person = v),
                        ),
                        NgDateInput(
                          label: 'Registration deadline',
                          readOnly: readOnly,
                          value: deadline,
                          min: min,
                          max: max,
                          required: true,
                          onChanged: (v) => setState(() => deadline = v),
                        ),
                        NgDatePicker(
                          label: 'Workshop date',
                          readOnly: readOnly,
                          value: date,
                          min: min,
                          max: max,
                          required: true,
                          disabledDate: (d) => d.weekday == DateTime.sunday,
                          onChanged: (v) => setState(() => date = v),
                        ),
                        NgTimePicker(
                          minuteStep: 15,
                          label: 'Start time',
                          value: time,
                          min: const TimeOfDay(hour: 8, minute: 0),
                          max: const TimeOfDay(hour: 18, minute: 0),
                          required: true,
                          onChanged: (v) => setState(() => time = v),
                        ),
                        NgDateTimePicker(
                          minuteStep: 15,
                          label: 'Reminder',
                          value: reminder,
                          min: min,
                          max: DateTime(2026, 12, 31, 23, 59),
                          onChanged: (v) => setState(() => reminder = v),
                        ),
                        NgDateInput(
                          label: 'Locked date',
                          value: min,
                          enabled: false,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      NgDateRangePicker(
                        label: 'Room reservation',
                        readOnly: readOnly,
                        disabledDate: (d) => d.weekday == DateTime.sunday,
                        value: range,
                        min: min,
                        max: max,
                        onChanged: (v) => setState(() => range = v),
                      ),
                      const SizedBox(height: 24),
                      fields([
                        NgMultiSelect(
                          label: 'Services',
                          filterMode: filterMode,
                          readOnly: choicesReadOnly,
                          showActions: true,
                          itemBuilder: (_, o) => Text(o.label),
                          tagBuilder: (_, o) => Text('✓ ${o.label}'),
                          value: services,
                          items: serviceOptions,
                          maxSelected: 3,
                          required: true,
                          onChanged: (v) => setState(() => services = v),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: NgCalendar(
                            readOnly: readOnly,                            value: date,
                            min: min,
                            max: max,
                            disabledDate: (d) => d.weekday == DateTime.sunday,
                            onChanged: (v) => setState(() => date = v),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      NgTextArea(
                        label: 'Notes',
                        readOnly: readOnly,
                        helperText: 'Share preparation details with the team.',
                        initialValue: notes,
                        maxLength: 500,
                        onChanged: (v) => notes = v,
                      ),
                      const SizedBox(height: 16),
                      NgButton(
                        onPressed: reset,
                        child: const Text('Reset example'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('47 COMPONENTS · WEB FIRST / BLAZOR + FLUTTER'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
