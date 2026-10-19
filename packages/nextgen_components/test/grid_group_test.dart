import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'groups precede paging; counts, sorting, search and selection compose',
    (t) async {
      var items = ['b1', 'a1', 'b2', 'a2', 'b3'];
      var grouped = true;
      var selected = <String>{'hidden'};
      var version = 0;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgDataGrid<String>(
                  items: items,
                  columns: [NgDataColumn('id', 'ID', (s) => s)],
                  rowId: (s) => s,
                  groupBy: grouped ? (s) => s[0] : null,
                  groupText: (key, count) => '$key: $count records',
                  initialPageSize: 2,
                  pageSizes: const [2, 5],
                  dataVersion: version,
                  selectedIds: selected,
                  canSelect: (s) => s != 'b2',
                  onSelectionChanged: (v) => set(() => selected = v),
                );
              },
            ),
          ),
        ),
      );
      DataTable table() => t.widget<DataTable>(find.byType(DataTable));
      expect(find.text('b: 3 records'), findsOneWidget);
      expect(table().rows.length, 3);
      expect(table().rows.first.onSelectChanged, isNull);
      expect(find.text('a1'), findsNothing);
      await t.tap(find.byType(Checkbox).first);
      await t.pump();
      expect(selected, {'hidden', 'b1'});
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      expect(find.text('b: 3 records'), findsOneWidget);
      expect(find.text('a: 2 records'), findsOneWidget);
      expect(table().rows.length, 4);
      await t.tap(find.byType(Checkbox).first);
      await t.pump();
      expect(selected, {'hidden', 'b1', 'b3', 'a1'});
      await t.enterText(find.byType(TextField), '2');
      await t.pump();
      expect(find.text('b: 1 records'), findsOneWidget);
      expect(find.text('a: 1 records'), findsOneWidget);
      await t.enterText(find.byType(TextField), '');
      await t.pump();
      table().columns[1].onSort!(0, true);
      await t.pump();
      expect(find.text('a: 2 records'), findsOneWidget);
      expect(find.text('a1'), findsOneWidget);
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      update(() => grouped = false);
      await t.pump();
      expect(find.text('1–2 of 5'), findsOneWidget);
      expect(table().rows.length, 2);
      update(() => grouped = true);
      await t.pump();
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      update(() => version++);
      await t.pump();
      expect(find.text('1–2 of 5'), findsOneWidget);
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      update(() => items = ['a1']);
      await t.pump();
      expect(find.text('1–1 of 1'), findsOneWidget);
      expect(find.text('a: 1 records'), findsOneWidget);
      expect(selected, contains('b3'));
      await t.enterText(find.byType(TextField), 'missing');
      await t.pump();
      expect(find.text('No matching records.'), findsOneWidget);
    },
  );
  testWidgets('local grouping rejects remote adapter before requesting data', (
    t,
  ) async {
    var calls = 0;
    await t.pumpWidget(
      MaterialApp(
        home: NgDataGrid<String>(
          columns: [NgDataColumn('id', 'ID', (s) => s)],
          rowId: (s) => s,
          groupBy: (s) => s,
          readData: (r) async {
            calls++;
            return NgDataResult([], 0);
          },
        ),
      ),
    );
    expect(t.takeException(), isArgumentError);
    expect(calls, 0);
  });
}
