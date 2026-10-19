import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(
  theme: NgTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  final records = [
    NgPivotRecord('a', {'Team': 'A', 'Quarter': 'Q1'}, 10),
    NgPivotRecord('b', {'Team': 'A', 'Quarter': 'Q1'}, 30),
    NgPivotRecord('c', {'Team': 'B', 'Quarter': 'Q2'}, 90),
    NgPivotRecord('d', {'Team': '', 'Quarter': 'Q1'}, null),
  ];
  String format(double? v) =>
      v == null ? 'No value' : '${v.toStringAsFixed(1)} credits';
  test('weighted totals, null count and nonblank IDs', () {
    expect(
      NgPivotMath.aggregate(records, NgAggregate.average),
      closeTo(130 / 3, 1e-10),
    );
    expect(NgPivotMath.aggregate(records, NgAggregate.count), 4);
    expect(
      () => NgPivotMath.validate([NgPivotRecord(' ', {}, 1)]),
      throwsArgumentError,
    );
  });
  testWidgets('total visibility combinations retain correct table shape', (
    t,
  ) async {
    for (final rowTotals in [true, false])
      for (final colTotals in [true, false]) {
        await t.pumpWidget(
          app(
            NgPivotGrid(
              items: records,
              showRowTotals: rowTotals,
              showColumnTotals: colTotals,
              onCellSelected: (_) {},
            ),
          ),
        );
        expect(
          find.byType(TextButton),
          findsNWidgets((3 + (colTotals ? 1 : 0)) * (2 + (rowTotals ? 1 : 0))),
        );
        expect(t.takeException(), isNull);
      }
  });
  testWidgets(
    'formatted labels preserve raw keys and original records in readonly payload',
    (t) async {
      NgPivotSelection? selected;
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        app(
          NgPivotGrid(
            items: records,
            rowLabel: (v) => v.isEmpty ? 'Unassigned' : 'Team $v',
            columnLabel: (v) => 'Period $v',
            valueFormatter: format,
            totalText: 'All',
            onCellSelected: (v) => selected = v,
          ),
        ),
      );
      await t.tap(find.bySemanticsLabel('Team A / Period Q1: 40.0 credits'));
      expect(selected?.row, 'A');
      expect(selected?.column, 'Q1');
      expect(selected?.records.length, 2);
      expect(identical(selected!.records.first, records.first), isTrue);
      expect(() => selected!.records.clear(), throwsUnsupportedError);
      await t.ensureVisible(
        find.bySemanticsLabel('Unassigned / Period Q1: No value'),
      );
      await t.tap(find.bySemanticsLabel('Unassigned / Period Q1: No value'));
      expect(selected?.row, '');
      expect(selected?.records.single.id, 'd');
      await t.ensureVisible(find.bySemanticsLabel('All / All: 130.0 credits'));
      await t.tap(find.bySemanticsLabel('All / All: 130.0 credits'));
      expect(selected?.row, isNull);
      expect(selected?.column, isNull);
      expect(selected?.records.length, 4);
      semantics.dispose();
    },
  );
  testWidgets('selection locks and missing callbacks retain readable values', (
    t,
  ) async {
    int calls = 0;
    for (final callback in [false, true]) {
      await t.pumpWidget(
        app(
          NgPivotGrid(
            items: records,
            selectionReadOnly: callback,
            onCellSelected: callback ? (_) => calls++ : null,
          ),
        ),
      );
      expect(
        t
            .widgetList<TextButton>(find.byType(TextButton))
            .every((b) => b.onPressed == null),
        isTrue,
      );
      expect(find.text('130'), findsOneWidget);
      expect(calls, 0);
    }
  });
  testWidgets(
    'stale callbacks reject replacement, aggregation, lock, hidden totals and disposal',
    (t) async {
      int calls = 0;
      Widget pivot({
        List<NgPivotRecord>? items,
        NgAggregate aggregate = NgAggregate.sum,
        bool locked = false,
        bool totals = true,
      }) => app(
        NgPivotGrid(
          items: items ?? records,
          aggregate: aggregate,
          selectionReadOnly: locked,
          showRowTotals: totals,
          onCellSelected: (_) => calls++,
        ),
      );
      Future<VoidCallback> capture() async {
        await t.pumpWidget(pivot());
        return t
            .widget<TextButton>(find.widgetWithText(TextButton, '130'))
            .onPressed!;
      }

      var action = await capture();
      await t.pumpWidget(
        pivot(
          items: [
            NgPivotRecord('new', {'Team': 'A', 'Quarter': 'Q1'}, 999),
          ],
        ),
      );
      action();
      expect(calls, 0);
      action = await capture();
      await t.pumpWidget(pivot(aggregate: NgAggregate.average));
      action();
      expect(calls, 0);
      action = await capture();
      await t.pumpWidget(pivot(locked: true));
      action();
      expect(calls, 0);
      action = await capture();
      await t.pumpWidget(pivot(totals: false));
      action();
      expect(calls, 0);
      action = await capture();
      await t.pumpWidget(const SizedBox());
      action();
      expect(calls, 0);
    },
  );
  testWidgets('custom empty text and missing-value formatter', (t) async {
    await t.pumpWidget(
      app(const NgPivotGrid(items: [], emptyText: 'No matching records')),
    );
    expect(find.text('No matching records'), findsOneWidget);
    await t.pumpWidget(
      app(NgPivotGrid(items: records, valueFormatter: format)),
    );
    expect(find.text('No value'), findsWidgets);
  });
}
