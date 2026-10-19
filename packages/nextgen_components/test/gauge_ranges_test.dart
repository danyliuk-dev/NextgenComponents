import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  const ranges = [
    NgGaugeRange(60, 100, '#b42318', 'High'),
    NgGaugeRange(0, 60, '#187444', 'Normal'),
  ];
  test('range ordering, endpoints and gaps preserve input', () {
    final ordered = NgGaugeRules.validate(ranges, 0, 100);
    expect(ordered.first.label, 'Normal');
    expect(ranges.first.label, 'High');
    for (final v in [60.0, 100.0, 125.0]) {
      expect(NgGaugeRules.active(ordered, v, 0, 100)?.label, 'High');
    }
    expect(NgGaugeRules.active(ordered, -10, 0, 100)?.label, 'Normal');
    expect(NgGaugeRules.active([ranges.first], 30, 0, 100), isNull);
  });
  test('invalid ranges fail before drawing', () {
    for (final bad in [
      [const NgGaugeRange(50, 70, '#123456', 'Overlap'), ...ranges],
      [const NgGaugeRange(-1, 50, '#123456', 'Outside')],
      [const NgGaugeRange(10, 10, '#123456', 'Empty')],
      [const NgGaugeRange(0, double.infinity, '#123456', 'Infinite')],
      [const NgGaugeRange(0, 50, 'red', 'Color')],
      [const NgGaugeRange(0, 50, '#123456', ' ')],
    ]) {
      expect(() => NgGaugeRules.validate(bad, 0, 100), throwsArgumentError);
    }
  });
  test('extreme finite bounds and default precision', () {
    expect(NgChartMath.fraction(0, -1.7e308, 1.7e308), 0.5);
    expect(
      NgChartMath.fraction(1e308, -1.7e308, 1.7e308),
      closeTo(0.794117647, 1e-9),
    );
    expect(NgGaugeRules.number(100000), '100000');
    expect(NgGaugeRules.number(72.5), '72.5');
    expect(NgGaugeRules.number(0), '0');
    expect(NgGaugeRules.number(0.000125), '0.000125');
  });
  for (final arc in [false, true]) {
    testWidgets(
      '${arc ? "arc" : "linear"} updates readings, status and ranges at narrow width',
      (t) async {
        Widget gauge(double v, List<NgGaugeRange> r) => MaterialApp(
          theme: NgTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: arc
                    ? NgArcGauge(
                        label: 'Load',
                        value: v,
                        ranges: r,
                        valueFormatter: (v) => v.toStringAsFixed(1),
                      )
                    : NgLinearGauge(
                        label: 'Load',
                        value: v,
                        ranges: r,
                        valueFormatter: (v) => v.toStringAsFixed(1),
                      ),
              ),
            ),
          ),
        );
        await t.pumpWidget(gauge(72.5, ranges));
        expect(find.textContaining('72.5 %'), findsWidgets);
        expect(find.text('High'), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(gauge(125, ranges));
        expect(find.textContaining('125.0 %'), findsWidgets);
        expect(find.text('High · Above maximum'), findsOneWidget);
        await t.pumpWidget(gauge(-10, ranges));
        expect(find.text('Normal · Below minimum'), findsOneWidget);
        await t.pumpWidget(gauge(42.5, []));
        expect(find.text('High'), findsNothing);
        expect(find.textContaining('42.5 %'), findsWidgets);
        expect(t.takeException(), isNull);
      },
    );
  }
}
