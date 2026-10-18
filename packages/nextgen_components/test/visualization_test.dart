import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(
  theme: NgTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  const categories = ['A', 'B', 'C'];
  const signed = [
    NgChartSeries('Values', [-10, 0, 20]),
  ];
  test('signed bars, zeros, gaps and hidden series', () {
    final bars = NgChartMath.build(
      NgChartKind.column,
      categories,
      signed,
    ).marks.where((m) => m.point != null).toList();
    expect(bars.length, 3);
    expect(bars.every((m) => m.coordinates.every((v) => v.isFinite)), isTrue);
    expect(bars.first.coordinates[1], greaterThan(bars.last.coordinates[1]));
    final gap = NgChartMath.build(NgChartKind.line, categories, [
      const NgChartSeries('Gap', [1, null, 3]),
    ]);
    expect(gap.marks.where((m) => m.kind == 'dot').length, 2);
    expect(
      gap.marks.where((m) => m.kind == 'line' && m.colorIndex >= 0),
      isEmpty,
    );
    expect(
      NgChartMath.build(
        NgChartKind.area,
        categories,
        signed,
        hidden: {0},
      ).marks,
      isEmpty,
    );
  });
  test('large finite ticks stay finite', () {
    expect(
      NgChartMath.build(
        NgChartKind.line,
        ['A', 'B'],
        [
          const NgChartSeries('Large', [0, 1e308]),
        ],
      ).marks.every((m) => m.coordinates.every((v) => v.isFinite)),
      isTrue,
    );
  });
  test('all six modes accept a single point; donut hole is not a target', () {
    for (final kind in NgChartKind.values) {
      final scene = NgChartMath.build(
        kind,
        ['Only'],
        [
          const NgChartSeries('One', [1]),
        ],
      );
      expect(scene.marks.any((m) => m.point != null), isTrue);
      if (kind == NgChartKind.donut) {
        expect(NgChartMath.hit(scene, const Offset(320, 145)), isNull);
        expect(NgChartMath.hit(scene, const Offset(420, 145))?.value, 1);
      }
    }
  });
  test('invalid data and ranges rejected, gauge clamps', () {
    expect(
      () => NgChartMath.build(
        NgChartKind.pie,
        ['A'],
        [
          const NgChartSeries('Bad', [-1]),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => NgChartMath.build(
        NgChartKind.line,
        ['A'],
        [
          const NgChartSeries('Bad', [double.nan]),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => NgChartMath.build(NgChartKind.line, ['A'], signed),
      throwsArgumentError,
    );
    expect(NgChartMath.fraction(-1, 0, 100), 0);
    expect(NgChartMath.fraction(150, 0, 100), 1);
    expect(() => NgChartMath.fraction(1, 1, 1), throwsArgumentError);
    expect(
      const NgChartSelection(0, 0, 'S', 'C', 100000).label,
      'S · C: 100000',
    );
  });
  test('calendar intersection uses half-open day boundaries across years', () {
    final event = NgScheduleEvent(
      'x',
      'Overnight',
      DateTime(2026, 12, 31, 23),
      DateTime(2027, 1, 1, 1),
    );
    expect(NgScheduleRules.forDay([event], DateTime(2026, 12, 31)), [event]);
    expect(NgScheduleRules.forDay([event], DateTime(2027, 1, 1)), [event]);
    expect(
      NgScheduleRules.forDay([
        NgScheduleEvent('x', 'Midnight', event.start, DateTime(2027, 1, 1)),
      ], DateTime(2027, 1, 1)),
      isEmpty,
    );
    expect(
      NgScheduleRules.weekStart(DateTime(2027, 1, 3)),
      DateTime(2026, 12, 28),
    );
    expect(
      NgScheduleRules.validate(
        NgScheduleEvent('x', 'Bad', event.start, event.start),
      ),
      isNotNull,
    );
  });
  testWidgets('legend hides data and accessible point selection calls back', (
    t,
  ) async {
    NgChartSelection? selected;
    await t.pumpWidget(
      app(
        NgChart(
          categories: categories,
          series: signed,
          onPointSelected: (p) => selected = p,
        ),
      ),
    );
    await t.tap(find.text('Chart data'));
    await t.pump();
    await t.ensureVisible(find.text('Values · A: -10'));
    await t.tap(find.text('Values · A: -10'));
    await t.pump();
    expect(selected?.value, -10);
    await t.ensureVisible(find.byType(FilterChip));
    await t.tap(find.byType(FilterChip));
    await t.pump();
    expect(find.text('No chart data.'), findsOneWidget);
  });
  testWidgets('scheduler dispatches date, create and edit callbacks', (
    t,
  ) async {
    DateTime? date, created;
    NgScheduleEvent? edited;
    final event = NgScheduleEvent(
      'x',
      'Review',
      DateTime(2026, 10, 19, 10),
      DateTime(2026, 10, 19, 11),
    );
    await t.pumpWidget(
      app(
        NgScheduler(
          date: DateTime(2026, 10, 19),
          items: [event],
          onDateChanged: (d) => date = d,
          onCreate: (d) => created = d,
          onEdit: (e) => edited = e,
        ),
      ),
    );
    await t.tap(find.text('Next week'));
    await t.pump();
    expect(date, DateTime(2026, 10, 26));
    await t.ensureVisible(find.text('Review'));
    await t.tap(find.text('Review'));
    expect(edited, event);
    await t.ensureVisible(find.text('+ Add').first);
    await t.tap(find.text('+ Add').first);
    expect(created, DateTime(2026, 10, 19));
  });
}
