import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  testWidgets(
    'controlled legend proposals are immutable, rejectable and independently locked',
    (t) async {
      var hidden = <int>{99};
      final original = hidden;
      Set<int>? proposed;
      var accept = false, locked = false, pointLocked = true;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) {
              update = set;
              return NgChart(
                categories: const ['A'],
                series: const [
                  NgChartSeries('Orders', [10]),
                ],
                hiddenSeries: hidden,
                onHiddenSeriesChanged: (v) {
                  proposed = v;
                  if (accept) set(() => hidden = v);
                },
                legendReadOnly: locked,
                selectionReadOnly: pointLocked,
                emptyText: 'Nothing visible',
              );
            },
          ),
        ),
      );
      final stale = t.widget<FilterChip>(find.byType(FilterChip)).onSelected!;
      await t.tap(find.byType(FilterChip));
      await t.pump();
      expect(proposed, {99, 0});
      expect(hidden, {99});
      expect(original, {99});
      expect(find.text('Nothing visible'), findsNothing);
      update(() => accept = true);
      await t.pump();
      await t.tap(find.byType(FilterChip));
      await t.pump();
      expect(find.text('Nothing visible'), findsOneWidget);
      update(() {
        locked = true;
        hidden = {99};
      });
      await t.pump();
      stale(false);
      await t.pump();
      expect(hidden, {99});
      expect(t.widget<FilterChip>(find.byType(FilterChip)).onSelected, isNull);
    },
  );
  for (final kind in NgChartKind.values) {
    testWidgets(
      '$kind reconciles selection and rejects stale or locked point actions',
      (t) async {
        var value = 10.0, invalid = false, locked = false;
        var calls = 0;
        late StateSetter update;
        await t.pumpWidget(
          host(
            StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgChart(
                  kind: kind,
                  categories: const ['A'],
                  series: [
                    NgChartSeries('Orders', invalid ? [] : [value]),
                  ],
                  selectionReadOnly: locked,
                  pointLabel: (p) => 'Amount ${p.value.toInt()} units',
                  onPointSelected: (_) => calls++,
                );
              },
            ),
          ),
        );
        await t.tap(find.text('Chart data'));
        await t.pump();
        final point = find.widgetWithText(NgButton, 'Amount 10 units');
        await t.ensureVisible(point);
        final stale = t.widget<NgButton>(point).onPressed!;
        await t.tap(point);
        await t.pump();
        expect(calls, 1);
        expect(find.text('Amount 10 units'), findsNWidgets(2));
        update(() {});
        await t.pump();
        expect(find.text('Amount 10 units'), findsNWidgets(2));
        update(() => locked = true);
        await t.pump();
        stale();
        await t.pump();
        expect(calls, 1);
        update(() {
          locked = false;
          value = 20;
        });
        await t.pump();
        stale();
        await t.pump();
        expect(calls, 1);
        expect(find.text('Amount 10 units'), findsNothing);
        expect(find.text('Amount 20 units'), findsOneWidget);
        await t.ensureVisible(find.widgetWithText(NgButton, 'Amount 20 units'));
        await t.tap(find.widgetWithText(NgButton, 'Amount 20 units'));
        await t.pump();
        expect(calls, 2);
        update(() => invalid = true);
        await t.pump();
        stale();
        expect(calls, 2);
        update(() => invalid = false);
        await t.pump();
        expect(find.text('Amount 20 units'), findsOneWidget);
      },
    );
  }
}
