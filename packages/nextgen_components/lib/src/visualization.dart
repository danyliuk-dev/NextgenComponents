import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'components.dart';

enum NgChartKind { column, bar, line, area, pie, donut }

class NgChartSeries {
  final String name;
  final List<double?> values;
  const NgChartSeries(this.name, this.values);
}

class NgChartSelection {
  final int seriesIndex, categoryIndex;
  final String series, category;
  final double value;
  const NgChartSelection(
    this.seriesIndex,
    this.categoryIndex,
    this.series,
    this.category,
    this.value,
  );
  String get label =>
      '$series · $category: ${value.toString().replaceFirst(RegExp(r"\.0$"), "")}';
}

class NgChartMark {
  final String kind;
  final List<double> coordinates;
  final int colorIndex;
  final NgChartSelection? point;
  const NgChartMark(this.kind, this.coordinates, this.colorIndex, [this.point]);
}

class NgChartText {
  final double x, y;
  final String text;
  const NgChartText(this.x, this.y, this.text);
}

class NgChartScene {
  final List<NgChartMark> marks;
  final List<NgChartText> labels;
  const NgChartScene(this.marks, this.labels);
}

abstract final class NgChartMath {
  static const colors = [
    Color(0xffc73e32),
    Color(0xff2878b8),
    Color(0xff218468),
    Color(0xff8b5bb6),
    Color(0xffb66d16),
    Color(0xff55717d),
  ];
  static double fraction(double value, double min, double max) {
    if (!value.isFinite ||
        !min.isFinite ||
        !max.isFinite ||
        max <= min ||
        !(max - min).isFinite)
      throw ArgumentError('Gauge requires finite values and Min < Max.');
    return ((value - min) / (max - min)).clamp(0, 1);
  }

  static NgChartScene build(
    NgChartKind kind,
    List<String> categories,
    List<NgChartSeries> series, {
    Set<int> hidden = const {},
  }) {
    if (series.any(
      (s) =>
          s.values.length != categories.length ||
          s.values.any((v) => v != null && !v.isFinite),
    ))
      throw ArgumentError(
        'Series must match categories and contain finite values or null.',
      );
    final active = List.generate(
      series.length,
      (i) => i,
    ).where((i) => !hidden.contains(i)).toList();
    final marks = <NgChartMark>[], labels = <NgChartText>[];
    if (categories.isEmpty || active.isEmpty)
      return NgChartScene(marks, labels);
    if (kind == NgChartKind.pie || kind == NgChartKind.donut) {
      if (series.length > 1)
        throw ArgumentError('Pie and donut currently accept one series.');
      final s = active.first;
      if (series[s].values.any((v) => (v ?? 0) < 0))
        throw ArgumentError('Pie and donut require nonnegative values.');
      final total = series[s].values.fold(0.0, (sum, v) => sum + (v ?? 0));
      if (!total.isFinite)
        throw ArgumentError('Chart total exceeds supported range.');
      if (total == 0) return NgChartScene(marks, labels);
      var angle = -math.pi / 2;
      for (var i = 0; i < categories.length; i++) {
        final value = series[s].values[i] ?? 0;
        if (value <= 0) continue;
        final sweep = value / total * math.pi * 2;
        final steps = math.max(2, (sweep * 32).ceil());
        final poly = <double>[];
        void add(double a, double r) {
          poly.addAll([320 + math.cos(a) * r, 145 + math.sin(a) * r]);
        }

        for (var k = 0; k <= steps; k++) {
          add(angle + sweep * k / steps, 120);
        }
        if (kind == NgChartKind.donut) {
          for (var k = steps; k >= 0; k--) {
            add(angle + sweep * k / steps, 64);
          }
        } else {
          poly.addAll([320, 145]);
        }
        marks.add(
          NgChartMark(
            'polygon',
            poly,
            i,
            NgChartSelection(s, i, series[s].name, categories[i], value),
          ),
        );
        angle += sweep;
      }
      return NgChartScene(marks, labels);
    }
    final values = active
        .expand((i) => series[i].values)
        .whereType<double>()
        .toList();
    if (values.isEmpty) return NgChartScene(marks, labels);
    final min = math.min(0.0, values.reduce(math.min));
    var max = math.max(0.0, values.reduce(math.max));
    if (min == max) max = min + 1;
    final span = max - min;
    if (!span.isFinite)
      throw ArgumentError('Chart range exceeds supported values.');
    double y(double v) => 260 - (v - min) / span * 230;
    double x(double v) => 100 + (v - min) / span * 510;
    for (var t = 0; t <= 4; t++) {
      final value = min + span * (t / 4);
      if (kind == NgChartKind.bar) {
        marks.add(NgChartMark('line', [x(value), 20, x(value), 260], -1));
        labels.add(NgChartText(x(value), 286, value.toStringAsPrecision(3)));
      } else {
        marks.add(NgChartMark('line', [55, y(value), 620, y(value)], -1));
        labels.add(NgChartText(27, y(value) + 4, value.toStringAsPrecision(3)));
      }
    }
    for (var c = 0; c < categories.length; c++) {
      labels.add(
        kind == NgChartKind.bar
            ? NgChartText(
                47,
                30 + (c + .5) * 230 / categories.length,
                categories[c],
              )
            : NgChartText(
                55 + (c + .5) * 565 / categories.length,
                286,
                categories[c],
              ),
      );
    }
    for (var si = 0; si < active.length; si++) {
      final s = active[si];
      final segment = <double>[];
      void flush() {
        if (segment.length >= 4) {
          if (kind == NgChartKind.area) {
            marks.add(
              NgChartMark('area', [
                segment.first,
                y(0),
                ...segment,
                segment[segment.length - 2],
                y(0),
              ], s),
            );
          }
          marks.add(NgChartMark('line', [...segment], s));
        }
        segment.clear();
      }

      for (var c = 0; c < categories.length; c++) {
        final value = series[s].values[c];
        if (value == null) {
          flush();
          continue;
        }
        final point = NgChartSelection(
          s,
          c,
          series[s].name,
          categories[c],
          value,
        );
        final px = 55 + (c + .5) * 565 / categories.length, py = y(value);
        if (kind == NgChartKind.column) {
          final band = 565 / categories.length,
              width = band * .72 / active.length;
          marks.add(
            NgChartMark(
              'rect',
              [
                55 + c * band + band * .14 + si * width,
                math.min(py, y(0)),
                width * .92,
                math.max(1, (py - y(0)).abs()),
              ],
              s,
              point,
            ),
          );
        } else if (kind == NgChartKind.bar) {
          final band = 230 / categories.length,
              height = band * .72 / active.length;
          marks.add(
            NgChartMark(
              'rect',
              [
                math.min(x(value), x(0)),
                30 + c * band + band * .14 + si * height,
                math.max(1, (x(value) - x(0)).abs()),
                height * .92,
              ],
              s,
              point,
            ),
          );
        } else {
          segment.addAll([px, py]);
          marks.add(NgChartMark('dot', [px, py, 5], s, point));
        }
      }
      flush();
    }
    return NgChartScene([
      ...marks.where((m) => m.point == null),
      ...marks.where((m) => m.point != null),
    ], labels);
  }

  static Path path(NgChartMark mark) {
    final p = mark.coordinates;
    final path = Path()..moveTo(p[0], p[1]);
    for (var i = 2; i < p.length; i += 2) {
      path.lineTo(p[i], p[i + 1]);
    }
    if (mark.kind != 'line') path.close();
    return path;
  }

  static NgChartSelection? hit(NgChartScene scene, Offset position) {
    for (final mark in scene.marks.reversed) {
      if (mark.point == null) continue;
      final p = mark.coordinates;
      final hit = mark.kind == 'rect'
          ? Rect.fromLTWH(p[0], p[1], p[2], p[3]).contains(position)
          : mark.kind == 'dot'
          ? (position - Offset(p[0], p[1])).distance <= 12
          : path(mark).contains(position);
      if (hit) return mark.point;
    }
    return null;
  }
}

class NgChart extends StatefulWidget {
  final String title;
  final NgChartKind kind;
  final List<String> categories;
  final List<NgChartSeries> series;
  final ValueChanged<NgChartSelection>? onPointSelected;
  const NgChart({
    super.key,
    this.title = 'Chart',
    this.kind = NgChartKind.column,
    required this.categories,
    required this.series,
    this.onPointSelected,
  });
  @override
  State<NgChart> createState() => _NgChartState();
}

class _NgChartState extends State<NgChart> {
  final hidden = <int>{};
  NgChartSelection? selected, hover;
  bool showData = false;
  @override
  void didUpdateWidget(covariant NgChart old) {
    super.didUpdateWidget(old);
    hidden.removeWhere((i) => i >= widget.series.length);
    if (old.kind != widget.kind ||
        old.series != widget.series ||
        old.categories != widget.categories) {
      selected = null;
      hover = null;
    }
  }

  void select(NgChartSelection p) {
    setState(() => selected = p);
    widget.onPointSelected?.call(p);
  }

  @override
  Widget build(BuildContext context) {
    NgChartScene scene;
    try {
      scene = NgChartMath.build(
        widget.kind,
        widget.categories,
        widget.series,
        hidden: hidden,
      );
    } on ArgumentError catch (e) {
      return Text(
        e.message.toString(),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < widget.series.length; i++)
              FilterChip(
                label: Text(widget.series[i].name),
                avatar: CircleAvatar(
                  backgroundColor: NgChartMath.colors[i % 6],
                  radius: 5,
                ),
                selected: !hidden.contains(i),
                onSelected: (v) => setState(() {
                  if (v) {
                    hidden.remove(i);
                  } else {
                    hidden.add(i);
                  }
                  selected = null;
                  hover = null;
                }),
              ),
          ],
        ),
        if (widget.kind == NgChartKind.pie || widget.kind == NgChartKind.donut)
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (var i = 0; i < widget.categories.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: NgChartMath.colors[i % 6],
                    ),
                    const SizedBox(width: 5),
                    Text(widget.categories[i]),
                  ],
                ),
            ],
          ),
        if (scene.marks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Text('No chart data.'),
          )
        else ...[
          LayoutBuilder(
            builder: (context, c) {
              final width = c.maxWidth;
              final height = width * 310 / 640;
              Offset map(Offset p) =>
                  Offset(p.dx * 640 / width, p.dy * 640 / width);
              return MouseRegion(
                onExit: (_) => setState(() => hover = null),
                onHover: (e) {
                  final point = NgChartMath.hit(scene, map(e.localPosition));
                  if (point?.label != hover?.label)
                    setState(() => hover = point);
                },
                child: GestureDetector(
                  // Point-level accessible actions live in Chart data. A synthetic
                  // semantics tap has no canvas coordinates and would mask pointer taps.
                  excludeFromSemantics: true,
                  onTapUp: (e) {
                    final p = NgChartMath.hit(scene, map(e.localPosition));
                    if (p != null) select(p);
                  },
                  child: SizedBox(
                    height: height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ChartPainter(
                              scene,
                              Theme.of(context).colorScheme,
                            ),
                          ),
                        ),
                        if (hover != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                color: Theme.of(context).colorScheme.surface,
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  hover!.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () => setState(() => showData = !showData),
            child: Text(showData ? 'Hide chart data' : 'Chart data'),
          ),
          if (showData)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p
                    in scene.marks
                        .where((m) => m.point != null)
                        .map((m) => m.point!))
                  NgButton(onPressed: () => select(p), child: Text(p.label)),
              ],
            ),
        ],
        if (selected != null)
          Semantics(
            liveRegion: true,
            child: Text(
              selected!.label,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final NgChartScene scene;
  final ColorScheme colors;
  _ChartPainter(this.scene, this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 640, size.height / 310);
    for (final m in scene.marks) {
      final p = m.coordinates;
      final color = m.colorIndex < 0
          ? colors.outline
          : NgChartMath.colors[m.colorIndex % 6];
      final paint = Paint()
        ..color = m.kind == 'area' ? color.withValues(alpha: .22) : color
        ..style = m.kind == 'line' ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = m.colorIndex < 0 ? 1 : 2;
      if (m.kind == 'rect') {
        canvas.drawRect(Rect.fromLTWH(p[0], p[1], p[2], p[3]), paint);
      } else if (m.kind == 'dot') {
        canvas.drawCircle(Offset(p[0], p[1]), 5, paint);
      } else {
        canvas.drawPath(NgChartMath.path(m), paint);
      }
    }
    for (final label in scene.labels) {
      final text = TextPainter(
        text: TextSpan(
          text: label.text,
          style: TextStyle(color: colors.onSurface, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 90);
      text.paint(canvas, Offset(label.x - text.width / 2, label.y - 12));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => true;
}

class NgLinearGauge extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  const NgLinearGauge({
    super.key,
    this.label = 'Progress',
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '%',
  });
  @override
  Widget build(BuildContext context) {
    final fraction = NgChartMath.fraction(value, min, max);
    return Semantics(
      label: label,
      value: '$value $unit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$label · ${value.toStringAsFixed(0)} $unit'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: fraction,
            minHeight: 16,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('$min'), Text('$max')],
          ),
        ],
      ),
    );
  }
}

class NgArcGauge extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  const NgArcGauge({
    super.key,
    this.label = 'Progress',
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '%',
  });
  @override
  Widget build(BuildContext context) {
    final fraction = NgChartMath.fraction(value, min, max);
    return Semantics(
      label: label,
      value: '$value $unit',
      child: Column(
        children: [
          Text(label),
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(240, 150),
              painter: _ArcPainter(fraction, Theme.of(context).colorScheme),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Text(
                    '${value.toStringAsFixed(0)} $unit',
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('$min'), Text('$max')],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double fraction;
  final ColorScheme colors;
  _ArcPainter(this.fraction, this.colors);
  @override
  void paint(Canvas c, Size s) {
    final rect = Rect.fromCircle(
      center: Offset(s.width / 2, s.height - 20),
      radius: math.min(s.width / 2 - 10, s.height - 30),
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = colors.outline;
    c.drawArc(rect, math.pi, math.pi, false, p);
    if (fraction > 0) {
      p.color = colors.primary;
      c.drawArc(rect, math.pi, math.pi * fraction, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.fraction != fraction || old.colors != colors;
}

class NgScheduleEvent {
  final String id, title;
  final DateTime start, end;
  const NgScheduleEvent(this.id, this.title, this.start, this.end);
}

abstract final class NgScheduleRules {
  static DateTime weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - 1));
  static String? validate(NgScheduleEvent e) => e.title.trim().isEmpty
      ? 'Title is required.'
      : !e.end.isAfter(e.start)
      ? 'End must be after start.'
      : null;
  static List<NgScheduleEvent> forDay(
    List<NgScheduleEvent> events,
    DateTime date,
  ) {
    final day = DateTime(date.year, date.month, date.day),
        next = DateTime(date.year, date.month, date.day + 1);
    return events
        .where((e) => e.start.isBefore(next) && e.end.isAfter(day))
        .toList()
      ..sort((a, b) {
        final order = a.start.compareTo(b.start);
        return order == 0 ? a.id.compareTo(b.id) : order;
      });
  }
}

class NgScheduler extends StatelessWidget {
  final String label;
  final DateTime date;
  final List<NgScheduleEvent> items;
  final ValueChanged<DateTime> onDateChanged, onCreate;
  final ValueChanged<NgScheduleEvent> onEdit;
  const NgScheduler({
    super.key,
    this.label = 'Schedule',
    required this.date,
    required this.items,
    required this.onDateChanged,
    required this.onCreate,
    required this.onEdit,
  });
  static String dayText(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String stamp(DateTime d) =>
      '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    final week = NgScheduleRules.weekStart(date);
    if (week.year <= 1 ||
        week.year >= 9999 ||
        items.map((e) => e.id).toSet().length != items.length ||
        items.any((e) => NgScheduleRules.validate(e) != null))
      throw ArgumentError(
        'Events require unique IDs, a title and End > Start; supported years 2–9998.',
      );
    Widget day(int i) {
      final day = DateTime(week.year, week.month, week.day + i);
      final events = NgScheduleRules.forDay(items, day);
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i]} ${day.day}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Tooltip(
              message: 'Add event ${dayText(day)}',
              child: NgButton(
                onPressed: () => onCreate(day),
                child: const Text('+ Add'),
              ),
            ),
            for (final e in events)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .1),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () => onEdit(e),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title),
                      Text(
                        '${stamp(e.start)} – ${stamp(e.end)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('No events', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NgButton(
              onPressed: () =>
                  onDateChanged(DateTime(week.year, week.month, week.day - 7)),
              child: const Text('Previous week'),
            ),
            Text(
              '${dayText(week)} – ${dayText(DateTime(week.year, week.month, week.day + 6))}',
            ),
            NgButton(
              onPressed: () =>
                  onDateChanged(DateTime(week.year, week.month, week.day + 7)),
              child: const Text('Next week'),
            ),
            NgButton(
              onPressed: () => onDateChanged(DateTime.now()),
              child: const Text('Today'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth < 600
              ? Column(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: day(i),
                      ),
                  ],
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: math.max(140, (c.maxWidth - 56) / 7),
                            child: day(i),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
