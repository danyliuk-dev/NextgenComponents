import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'page selection preserves protected and hidden IDs; readonly guards stale handlers',
    (t) async {
      var selected = <String>{'locked', 'hidden'};
      final original = selected;
      var readOnly = false;
      var protectAll = false;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgDataGrid<String>(
                  items: const ['a', 'locked', 'b'],
                  columns: [NgDataColumn('id', 'ID', (s) => s)],
                  rowId: (s) => s,
                  selectedIds: selected,
                  selectionReadOnly: readOnly,
                  canSelect: (s) => !protectAll && s != 'locked',
                  pageSizes: const [2, 3],
                  initialPageSize: 2,
                  emptyBuilder: const Text('Try a different query'),
                  onSelectionChanged: (v) => set(() => selected = v),
                );
              },
            ),
          ),
        ),
      );
      final header = find.byType(Checkbox).first;
      await t.tap(header);
      await t.pump();
      expect(selected, {'a', 'locked', 'hidden'});
      expect(original, {'locked', 'hidden'});
      expect(t.widget<Checkbox>(find.byType(Checkbox).at(2)).onChanged, isNull);
      await t.tap(header);
      await t.pump();
      expect(selected, {'locked', 'hidden'});
      final staleHeader = t.widget<Checkbox>(header).onChanged!;
      final staleRow = t
          .widget<Checkbox>(find.byType(Checkbox).at(1))
          .onChanged!;
      update(() => readOnly = true);
      await t.pump();
      expect(
        t
            .widgetList<Checkbox>(find.byType(Checkbox))
            .every((c) => c.onChanged == null),
        isTrue,
      );
      staleHeader(true);
      staleRow(true);
      await t.pump();
      expect(selected, {'locked', 'hidden'});
      update(() {
        readOnly = false;
        protectAll = true;
      });
      await t.pump();
      staleHeader(true);
      staleRow(true);
      await t.pump();
      expect(selected, {'locked', 'hidden'});
      expect(t.widget<Checkbox>(header).onChanged, isNull);
      await t.enterText(find.byType(TextField), 'missing');
      await t.pump();
      expect(find.text('Try a different query'), findsOneWidget);
      expect(find.text('0–0 of 0'), findsOneWidget);
    },
  );
  testWidgets('selection remains caller owned when callback declines update', (
    t,
  ) async {
    var calls = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgDataGrid<String>(
            items: const ['a', 'b'],
            columns: [NgDataColumn('id', 'ID', (s) => s)],
            rowId: (s) => s,
            onSelectionChanged: (_) => calls++,
          ),
        ),
      ),
    );
    await t.tap(find.byType(Checkbox).at(1));
    await t.pump();
    expect(calls, 1);
    expect(t.widget<Checkbox>(find.byType(Checkbox).at(1)).value, false);
  });
}
