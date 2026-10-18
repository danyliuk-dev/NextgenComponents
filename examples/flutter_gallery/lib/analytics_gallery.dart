import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class AnalyticsGallery extends StatefulWidget {
  final bool dark, compact;
  final ValueChanged<bool> onDark, onCompact;
  final VoidCallback onBack;
  const AnalyticsGallery({
    super.key,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
    required this.onBack,
  });
  @override
  State<AnalyticsGallery> createState() => _AnalyticsGalleryState();
}

class _AnalyticsGalleryState extends State<AnalyticsGallery> {
  NgChartKind kind = NgChartKind.column;
  bool empty = false;
  String? selected, message;
  DateTime week = DateTime(2026, 10, 19);
  List<NgScheduleEvent> events = [
    NgScheduleEvent(
      'review',
      'Design review',
      DateTime(2026, 10, 19, 10),
      DateTime(2026, 10, 19, 11),
    ),
    NgScheduleEvent(
      'release',
      'Release window',
      DateTime(2026, 10, 21, 23),
      DateTime(2026, 10, 22, 1),
    ),
    NgScheduleEvent(
      'retro',
      'Team retrospective',
      DateTime(2026, 10, 23, 15),
      DateTime(2026, 10, 23, 16),
    ),
  ];
  static const categories = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  List<NgChartSeries> get series => empty
      ? []
      : (kind == NgChartKind.pie || kind == NgChartKind.donut)
      ? const [
          NgChartSeries('Completed', [35, 55, 40, 70, 60]),
        ]
      : const [
          NgChartSeries('Completed', [35, 55, null, 70, 60]),
          NgChartSeries('Variance', [-12, 8, 18, -6, 24]),
        ];
  Future<void> edit(NgScheduleEvent original, {bool creating = false}) async {
    var title = original.title;
    DateTime? start = original.start, end = original.end;
    String? error;
    final result = await showDialog<Object>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Event details'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, set) => NgForm(
                submitLabel: 'Save event',
                onValidSubmit: () {
                  if (start == null || end == null) {
                    set(() => error = 'Start and end are required.');
                    return;
                  }
                  final item = NgScheduleEvent(
                    original.id,
                    title,
                    start!,
                    end!,
                  );
                  final problem = NgScheduleRules.validate(item);
                  if (problem != null) {
                    set(() => error = problem);
                    return;
                  }
                  Navigator.pop(ctx, item);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NgTextBox(
                      label: 'Event title',
                      initialValue: title,
                      onChanged: (v) => title = v,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    NgDateTimePicker(
                      label: 'Starts',
                      value: start,
                      required: true,
                      onChanged: (v) => set(() => start = v),
                    ),
                    const SizedBox(height: 16),
                    NgDateTimePicker(
                      label: 'Ends',
                      value: end,
                      required: true,
                      onChanged: (v) => set(() => end = v),
                    ),
                    if (error != null)
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: [
                        NgButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        if (!creating)
                          NgButton(
                            onPressed: () => Navigator.pop(ctx, 'delete'),
                            child: const Text('Delete event'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result == 'delete') {
        events = events.where((e) => e.id != original.id).toList();
        message = 'Deleted ${original.title}';
      } else {
        final item = result as NgScheduleEvent;
        events = [...events.where((e) => e.id != item.id), item];
        message = 'Saved ${item.title}';
      }
    });
  }

  Widget panel(Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(6),
    ),
    child: child,
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
                'FLUTTER / ANALYTICS AND SCHEDULE 0.4',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'See the trend.\nPlan what comes next.',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                "Compare delivery results, inspect individual values and manage the team's weekly schedule.",
              ),
              const SizedBox(height: 28),
              panel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 230,
                          child: NgDropDownList(
                            label: 'Chart type',
                            value: kind.name,
                            items: NgChartKind.values
                                .map((k) => NgOption(k.name, k.name))
                                .toList(),
                            onChanged: (v) => setState(() {
                              kind = NgChartKind.values.byName(v!);
                              selected = null;
                            }),
                          ),
                        ),
                        NgCheckBox(
                          label: 'Show empty data',
                          value: empty,
                          onChanged: (v) => setState(() => empty = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    NgChart(
                      title: 'Delivery overview',
                      kind: kind,
                      categories: empty ? [] : categories,
                      series: series,
                      onPointSelected: (v) =>
                          setState(() => selected = v.label),
                    ),
                    Text('Selected data: ${selected ?? 'none'}'),
                  ],
                ),
              ),
              LayoutBuilder(
                builder: (context, c) => Wrap(
                  spacing: 20,
                  children: [
                    SizedBox(
                      width: c.maxWidth > 650
                          ? (c.maxWidth - 20) / 2
                          : c.maxWidth,
                      child: panel(
                        const NgLinearGauge(
                          label: 'Delivery target',
                          value: 72,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: c.maxWidth > 650
                          ? (c.maxWidth - 20) / 2
                          : c.maxWidth,
                      child: panel(
                        const NgArcGauge(label: 'Team capacity', value: 84),
                      ),
                    ),
                  ],
                ),
              ),
              panel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NgScheduler(
                      label: 'Team schedule',
                      date: week,
                      items: events,
                      onDateChanged: (v) => setState(() => week = v),
                      onCreate: (day) => edit(
                        NgScheduleEvent(
                          'new-${DateTime.now().microsecondsSinceEpoch}',
                          'New event',
                          DateTime(day.year, day.month, day.day, 9),
                          DateTime(day.year, day.month, day.day, 10),
                        ),
                        creating: true,
                      ),
                      onEdit: (e) => edit(e),
                    ),
                    if (message != null)
                      Semantics(liveRegion: true, child: Text(message!)),
                  ],
                ),
              ),
              const Text('31 CONTROLS / 37 CATALOGUE ENTRIES · WEB FIRST'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
