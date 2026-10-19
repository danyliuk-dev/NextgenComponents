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
    if (!value.isFinite || !min.isFinite || !max.isFinite || max <= min)
      throw ArgumentError('Gauge requires finite values and Min < Max.');
    if (value <= min) return 0;
    if (value >= max) return 1;
    final span = max - min;
    return span.isFinite
        ? (value - min) / span
        : (value / 2 - min / 2) / (max / 2 - min / 2);
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
  final String title, emptyText;
  final Set<int>? hiddenSeries;
  final ValueChanged<Set<int>>? onHiddenSeriesChanged;
  final bool legendReadOnly, selectionReadOnly;
  final String Function(NgChartSelection)? pointLabel;
  final NgChartKind kind;
  final List<String> categories;
  final List<NgChartSeries> series;
  final ValueChanged<NgChartSelection>? onPointSelected;
  const NgChart({
    super.key,
    this.title = 'Chart',
    this.emptyText = 'No chart data.',
    this.hiddenSeries,
    this.onHiddenSeriesChanged,
    this.legendReadOnly = false,
    this.selectionReadOnly = false,
    this.pointLabel,
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
  Set<int> get effectiveHidden => widget.hiddenSeries ?? hidden;
  String pointText(NgChartSelection p) => widget.pointLabel?.call(p) ?? p.label;
  bool same(NgChartSelection? a, NgChartSelection b) =>
      a != null &&
      a.seriesIndex == b.seriesIndex &&
      a.categoryIndex == b.categoryIndex &&
      a.series == b.series &&
      a.category == b.category &&
      a.value == b.value;
  NgChartScene currentScene() => NgChartMath.build(
    widget.kind,
    widget.categories,
    widget.series,
    hidden: effectiveHidden,
  );
  bool contains(NgChartScene scene, NgChartSelection? point) =>
      point != null &&
      scene.marks.any((m) => m.point != null && same(m.point, point));
  void toggle(int index) {
    if (!mounted ||
        widget.legendReadOnly ||
        index < 0 ||
        index >= widget.series.length ||
        (widget.hiddenSeries != null && widget.onHiddenSeriesChanged == null))
      return;
    final next = {...effectiveHidden};
    if (!next.add(index)) next.remove(index);
    if (widget.hiddenSeries == null)
      setState(() {
        hidden
          ..clear()
          ..addAll(next);
      });
    widget.onHiddenSeriesChanged?.call(next);
  }

  void select(NgChartSelection p) {
    if (!mounted || widget.selectionReadOnly) return;
    try {
      if (!contains(currentScene(), p)) return;
    } on ArgumentError {
      return;
    }
    setState(() => selected = p);
    widget.onPointSelected?.call(p);
  }

  @override
  Widget build(BuildContext context) {
    hidden.removeWhere((i) => i < 0 || i >= widget.series.length);
    NgChartScene scene;
    try {
      scene = NgChartMath.build(
        widget.kind,
        widget.categories,
        widget.series,
        hidden: effectiveHidden,
      );
      if (!contains(scene, selected)) selected = null;
      if (!contains(scene, hover)) hover = null;
    } on ArgumentError catch (e) {
      selected = null;
      hover = null;
      return Semantics(
        liveRegion: true,
        child: Text(
          e.message.toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
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
                selected: !effectiveHidden.contains(i),
                onSelected:
                    widget.legendReadOnly ||
                        (widget.hiddenSeries != null &&
                            widget.onHiddenSeriesChanged == null)
                    ? null
                    : (_) => toggle(i),
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
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(widget.emptyText),
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
                                  pointText(hover!),
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
                  NgButton(
                    onPressed: widget.selectionReadOnly
                        ? null
                        : () => select(p),
                    child: Text(pointText(p)),
                  ),
              ],
            ),
        ],
        if (selected != null)
          Semantics(
            liveRegion: true,
            child: Text(
              pointText(selected!),
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

class NgGaugeRange {
  final double from, to;
  final String color, label;
  const NgGaugeRange(this.from, this.to, this.color, this.label);
}

abstract final class NgGaugeRules {
  static List<NgGaugeRange> validate(
    List<NgGaugeRange> ranges,
    double min,
    double max,
  ) {
    NgChartMath.fraction(min, min, max);
    final ordered = [...ranges]..sort((a, b) => a.from.compareTo(b.from));
    var end = min;
    for (final range in ordered) {
      if (!range.from.isFinite ||
          !range.to.isFinite ||
          range.from < min ||
          range.to > max ||
          range.from >= range.to ||
          range.from < end)
        throw ArgumentError(
          'Gauge ranges must be finite, nonoverlapping and inside Min/Max with From < To.',
        );
      if (range.label.trim().isEmpty ||
          !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(range.color))
        throw ArgumentError(
          'Gauge ranges need a label and a six-digit hex color (#RRGGBB).',
        );
      end = range.to;
    }
    return ordered;
  }

  static NgGaugeRange? active(
    List<NgGaugeRange> ranges,
    double value,
    double min,
    double max,
  ) {
    final clamped = value.clamp(min, max);
    return ranges
        .where(
          (r) =>
              clamped >= r.from &&
              (clamped < r.to || clamped == max && r.to == max),
        )
        .firstOrNull;
  }

  static String status(
    NgGaugeRange? active,
    double value,
    double min,
    double max,
  ) => [
    if (active != null) active.label,
    if (value < min) 'Below minimum',
    if (value > max) 'Above maximum',
  ].join(' · ');
  static Color color(NgGaugeRange range) =>
      Color(0xff000000 | int.parse(range.color.substring(1), radix: 16));
  static String number(double value) {
    final parts = value.toStringAsPrecision(6).split('e');
    if (parts[0].contains('.')) {
      parts[0] = parts[0]
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return parts.join('e');
  }
}

class NgLinearGauge extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  final List<NgGaugeRange> ranges;
  final String Function(double)? valueFormatter;
  const NgLinearGauge({
    super.key,
    this.label = 'Progress',
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '%',
    this.ranges = const [],
    this.valueFormatter,
  });
  @override
  Widget build(BuildContext context) => _GaugeBody(
    label: label,
    unit: unit,
    value: value,
    min: min,
    max: max,
    ranges: ranges,
    valueFormatter: valueFormatter,
    arc: false,
  );
}

class NgArcGauge extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  final List<NgGaugeRange> ranges;
  final String Function(double)? valueFormatter;
  const NgArcGauge({
    super.key,
    this.label = 'Progress',
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '%',
    this.ranges = const [],
    this.valueFormatter,
  });
  @override
  Widget build(BuildContext context) => _GaugeBody(
    label: label,
    unit: unit,
    value: value,
    min: min,
    max: max,
    ranges: ranges,
    valueFormatter: valueFormatter,
    arc: true,
  );
}

class _GaugeBody extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  final List<NgGaugeRange> ranges;
  final String Function(double)? valueFormatter;
  final bool arc;
  const _GaugeBody({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.ranges,
    required this.valueFormatter,
    required this.arc,
  });
  @override
  Widget build(BuildContext context) {
    final fraction = NgChartMath.fraction(value, min, max);
    final ordered = NgGaugeRules.validate(ranges, min, max);
    final active = NgGaugeRules.active(ordered, value, min, max);
    final status = NgGaugeRules.status(active, value, min, max);
    String format(double v) =>
        valueFormatter?.call(v) ?? NgGaugeRules.number(v);
    final valueLabel = [
      format(value),
      if (unit.trim().isNotEmpty) unit,
    ].join(' ');
    final colors = Theme.of(context).colorScheme;
    final fill = active == null ? colors.primary : NgGaugeRules.color(active);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: label,
          value: [valueLabel, if (status.isNotEmpty) status].join(' · '),
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(arc ? label : '$label · $valueLabel'),
              if (arc)
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _ArcPainter(
                      fraction,
                      colors,
                      fill,
                      ordered,
                      min,
                      max,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 45, 30, 0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            valueLabel,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: fraction,
                  color: fill,
                  minHeight: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                if (ordered.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 5,
                    child: LayoutBuilder(
                      builder: (c, b) => Stack(
                        children: [
                          for (final r in ordered)
                            Positioned(
                              left:
                                  NgChartMath.fraction(r.from, min, max) *
                                  b.maxWidth,
                              width:
                                  (NgChartMath.fraction(r.to, min, max) -
                                      NgChartMath.fraction(r.from, min, max)) *
                                  b.maxWidth,
                              top: 0,
                              bottom: 0,
                              child: ColoredBox(color: NgGaugeRules.color(r)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(format(min))),
                  Flexible(child: Text(format(max))),
                ],
              ),
              if (status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        if (ordered.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final r in ordered)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.square,
                          size: 10,
                          color: NgGaugeRules.color(r),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${r.label}: ${format(r.from)}–${format(r.to)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double fraction, min, max;
  final ColorScheme colors;
  final Color fill;
  final List<NgGaugeRange> ranges;
  _ArcPainter(
    this.fraction,
    this.colors,
    this.fill,
    this.ranges,
    this.min,
    this.max,
  );
  @override
  void paint(Canvas c, Size s) {
    final radius = math.max(0.0, math.min(s.width / 2 - 18, s.height - 35));
    final center = Offset(s.width / 2, s.height - 20);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = colors.outline;
    c.drawArc(rect, math.pi, math.pi, false, p);
    if (fraction > 0) {
      p.color = fill;
      c.drawArc(rect, math.pi, math.pi * fraction, false, p);
    }
    p
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt;
    for (final r in ranges) {
      final from = NgChartMath.fraction(r.from, min, max),
          to = NgChartMath.fraction(r.to, min, max);
      p.color = NgGaugeRules.color(r);
      c.drawArc(
        Rect.fromCircle(center: center, radius: radius + 10),
        math.pi * (1 + from),
        math.pi * (to - from),
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => true;
}

enum NgScheduleView { week, day }

class NgScheduleEvent {
  final String id, title;
  final DateTime start, end;
  const NgScheduleEvent(this.id, this.title, this.start, this.end);
}

abstract final class NgScheduleRules {
  static DateTime weekStart(DateTime d, [int firstDayOfWeek = 1]) {
    if (firstDayOfWeek < 1 || firstDayOfWeek > 7)
      throw ArgumentError('First day must be 1–7.');
    return DateTime(
      d.year,
      d.month,
      d.day - (d.weekday - firstDayOfWeek + 7) % 7,
    );
  }

  static DateTime displayStart(
    DateTime d,
    NgScheduleView view,
    int firstDayOfWeek,
  ) => view == NgScheduleView.day
      ? DateTime(d.year, d.month, d.day)
      : weekStart(d, firstDayOfWeek);
  static bool canDisplay(DateTime d, NgScheduleView view, int firstDayOfWeek) {
    if (d.year < 2 || d.year > 9998 || firstDayOfWeek < 1 || firstDayOfWeek > 7)
      return false;
    final start = displayStart(d, view, firstDayOfWeek);
    final end = DateTime(
      start.year,
      start.month,
      start.day + (view == NgScheduleView.day ? 0 : 6),
    );
    return start.year >= 2 && end.year <= 9998;
  }

  static String? validate(NgScheduleEvent e) => e.id.trim().isEmpty
      ? 'ID is required.'
      : e.title.trim().isEmpty
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

class NgScheduler extends StatefulWidget {
  final String label;
  final DateTime date;
  final List<NgScheduleEvent> items;
  final ValueChanged<DateTime>? onDateChanged, onCreate;
  final ValueChanged<NgScheduleEvent>? onEdit;
  final NgScheduleView view;
  final ValueChanged<NgScheduleView>? onViewChanged;
  final int firstDayOfWeek;
  final bool readOnly, navigationReadOnly;
  final String emptyText;
  final String Function(NgScheduleEvent)? eventLabel;
  const NgScheduler({
    super.key,
    this.label = 'Schedule',
    required this.date,
    required this.items,
    this.onDateChanged,
    this.onCreate,
    this.onEdit,
    this.view = NgScheduleView.week,
    this.onViewChanged,
    this.firstDayOfWeek = 1,
    this.readOnly = false,
    this.navigationReadOnly = false,
    this.emptyText = 'No events',
    this.eventLabel,
  });
  static String dayText(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String stamp(DateTime d) =>
      '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  @override
  State<NgScheduler> createState() => _NgSchedulerState();
}

class _NgSchedulerState extends State<NgScheduler> {
  bool current(NgScheduler source) =>
      mounted &&
      widget.date == source.date &&
      widget.view == source.view &&
      widget.firstDayOfWeek == source.firstDayOfWeek;
  bool canNavigate(DateTime target) =>
      !widget.navigationReadOnly &&
      widget.onDateChanged != null &&
      NgScheduleRules.canDisplay(target, widget.view, widget.firstDayOfWeek);
  void navigate(NgScheduler source, DateTime target) {
    if (current(source) && canNavigate(target))
      widget.onDateChanged?.call(
        DateTime(target.year, target.month, target.day),
      );
  }

  void changeView(NgScheduler source, NgScheduleView view) {
    if (current(source) &&
        !widget.navigationReadOnly &&
        NgScheduleRules.canDisplay(widget.date, view, widget.firstDayOfWeek))
      widget.onViewChanged?.call(view);
  }

  void create(NgScheduler source, DateTime day) {
    if (current(source) && !widget.readOnly) widget.onCreate?.call(day);
  }

  void edit(NgScheduler source, NgScheduleEvent event) {
    if (!current(source) || widget.readOnly) return;
    if (widget.items.any(
      (e) =>
          e.id == event.id &&
          e.title == event.title &&
          e.start == event.start &&
          e.end == event.end,
    ))
      widget.onEdit?.call(event);
  }

  @override
  Widget build(BuildContext context) {
    final source = widget;
    final date = widget.date, items = widget.items;
    if (!NgScheduleRules.canDisplay(date, widget.view, widget.firstDayOfWeek) ||
        items.map((e) => e.id).toSet().length != items.length ||
        items.any((e) => NgScheduleRules.validate(e) != null))
      throw ArgumentError(
        'Events require unique nonblank IDs, a title and End > Start; display years 2–9998 and first day 1–7.',
      );
    final week = NgScheduleRules.displayStart(
      date,
      widget.view,
      widget.firstDayOfWeek,
    );
    final count = widget.view == NgScheduleView.day ? 1 : 7;
    final period = widget.view == NgScheduleView.day ? 'day' : 'week';
    final previous = DateTime(week.year, week.month, week.day - count);
    final next = DateTime(week.year, week.month, week.day + count);
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
              '${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1]} ${day.day}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Tooltip(
              message: 'Add event ${NgScheduler.dayText(day)}',
              child: NgButton(
                onPressed: widget.readOnly || widget.onCreate == null
                    ? null
                    : () => create(source, day),
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
                  onPressed: widget.readOnly || widget.onEdit == null
                      ? null
                      : () => edit(source, e),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.eventLabel?.call(e) ?? e.title),
                      Text(
                        '${NgScheduler.stamp(e.start)} – ${NgScheduler.stamp(e.end)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  widget.emptyText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NgButton(
              onPressed: canNavigate(previous)
                  ? () => navigate(source, previous)
                  : null,
              child: Text('Previous $period'),
            ),
            Text(
              count == 1
                  ? NgScheduler.dayText(week)
                  : '${NgScheduler.dayText(week)} – ${NgScheduler.dayText(DateTime(week.year, week.month, week.day + count - 1))}',
            ),
            NgButton(
              onPressed: canNavigate(next)
                  ? () => navigate(source, next)
                  : null,
              child: Text('Next $period'),
            ),
            NgButton(
              onPressed: canNavigate(DateTime.now())
                  ? () => navigate(source, DateTime.now())
                  : null,
              child: const Text('Today'),
            ),
            for (final view in NgScheduleView.values)
              Semantics(
                selected: widget.view == view,
                child: NgButton(
                  primary: widget.view == view,
                  onPressed:
                      widget.navigationReadOnly ||
                          widget.onViewChanged == null ||
                          !NgScheduleRules.canDisplay(
                            date,
                            view,
                            widget.firstDayOfWeek,
                          )
                      ? null
                      : () => changeView(source, view),
                  child: Text(view == NgScheduleView.day ? 'Day' : 'Week'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => count == 1 || c.maxWidth < 600
              ? Column(
                  children: [
                    for (var i = 0; i < count; i++)
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
                      for (var i = 0; i < count; i++)
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
