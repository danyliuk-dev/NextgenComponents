import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    '10k grid builds bounded cells, scrolls to last and preserves selected IDs',
    (t) async {
      var built = 0;
      var selected = <String>{'hidden'};
      late StateSetter update;
      var count = 10000;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgDataGrid<int>(
                  virtualize: true,
                  viewportHeight: 192,
                  items: List.generate(count, (i) => i),
                  rowId: (i) => '$i',
                  columns: [
                    NgDataColumn(
                      'n',
                      'Number',
                      (i) => i,
                      cellBuilder: (c, i) {
                        built++;
                        return Text('row $i');
                      },
                    ),
                  ],
                  selectedIds: selected,
                  onSelectionChanged: (v) => set(() => selected = v),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(built, lessThan(30));
      expect(find.text('row 9999'), findsNothing);
      await t.tap(find.byType(Checkbox).at(1));
      await t.pump();
      expect(selected, {'hidden', '0'});
      final scroll = t.state<ScrollableState>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await t.pumpAndSettle();
      expect(find.text('row 9999'), findsOneWidget);
      expect(find.text('row 0'), findsNothing);
      expect(selected, {'hidden', '0'});
      update(() => count = 3);
      await t.pumpAndSettle();
      expect(find.text('row 2'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'virtual tree End crosses unbuilt rows and Enter selects last node',
    (t) async {
      String? selected;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgTreeView<int>(
              virtualize: true,
              viewportHeight: 192,
              items: List.generate(10000, (i) => NgTreeNode('$i', i)),
              text: (i) => 'node $i',
              selectedId: selected,
              onSelected: (v) => selected = v,
              expandedIds: const {},
              onExpandedChanged: (_) {},
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('node 9999'), findsNothing);
      await t.tap(find.text('node 0'));
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.end);
      await t.pumpAndSettle();
      expect(find.text('node 9999'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pump();
      expect(selected, '9999');
      await t.sendKeyEvent(LogicalKeyboardKey.home);
      await t.pumpAndSettle();
      expect(find.text('node 0'), findsOneWidget);
    },
  );

  testWidgets('virtual tree list constructs only visible cell templates', (
    t,
  ) async {
    var built = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgTreeList<int>(
            virtualize: true,
            viewportHeight: 192,
            items: List.generate(10000, (i) => NgTreeNode('$i', i)),
            columns: [
              NgDataColumn(
                'n',
                'Number',
                (i) => i,
                cellBuilder: (c, i) {
                  built++;
                  return Text('node $i');
                },
              ),
            ],
            expandedIds: const {},
            onExpandedChanged: (_) {},
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(built, lessThan(30));
    final scroll = t.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    scroll.position.jumpTo(scroll.position.maxScrollExtent);
    await t.pumpAndSettle();
    expect(find.text('node 9999'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'virtual server page scrolling does not fetch or fabricate other pages',
    (t) async {
      var reads = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NgDataGrid<int>(
                virtualize: true,
                viewportHeight: 192,
                initialPageSize: 100,
                pageSizes: const [100],
                rowId: (i) => '$i',
                columns: [NgDataColumn('n', 'Number', (i) => i)],
                readData: (r) async {
                  reads++;
                  return NgDataResult(
                    List.generate(100, (i) => (r.page - 1) * 100 + i),
                    10000,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(reads, 1);
      final scroll = t.state<ScrollableState>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await t.pumpAndSettle();
      expect(find.text('99'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(ListView), matching: find.text('100')),
        findsNothing,
      );
      expect(reads, 1);
    },
  );
  testWidgets(
    'virtual grouping scopes selection and export to expanded logical records',
    (t) async {
      var selected = <String>{'hidden'};
      var locked = false;
      late StateSetter update;
      NgGridExportFile? output;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (c, set) {
                  update = set;
                  return NgDataGrid<int>(
                    virtualize: true,
                    viewportHeight: 192,
                    items: List.generate(1000, (i) => i),
                    rowId: (i) => '$i',
                    columns: [NgDataColumn('n', 'Number', (i) => i)],
                    groupBy: (i) => i < 500 ? 'closed' : 'open',
                    collapsibleGroups: true,
                    collapsedGroups: {
                      ngGroupId(['closed']),
                    },
                    onCollapsedGroupsChanged: (_) {},
                    selectedIds: selected,
                    selectionReadOnly: locked,
                    canSelect: (i) => i != 999,
                    onSelectionChanged: (v) => set(() => selected = v),
                    export: NgGridExport(
                      onExport: (file) async {
                        output = file;
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final header = t.widget<Checkbox>(find.byType(Checkbox).first).onChanged!;
      header(true);
      await t.pumpAndSettle();
      expect(
        selected.length,
        500,
      ); // 499 eligible rows plus an unknown retained ID.
      expect(selected.contains('0'), isFalse);
      expect(selected.contains('999'), isFalse);
      await t.tap(find.text('Prepare export'));
      await t.pumpAndSettle();
      expect(
        output!.rowCount,
        500,
      ); // All expanded records, including offscreen/protected rows.
      update(() => locked = true);
      await t.pumpAndSettle();
      header(false);
      await t.pump();
      expect(selected.length, 500);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('virtual table keyboard end reaches final row', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgDataGrid<int>(
            virtualize: true,
            viewportHeight: 192,
            items: List.generate(10000, (i) => i),
            rowId: (i) => '$i',
            columns: [NgDataColumn('n', 'Number', (i) => 'row $i')],
            onSelectionChanged: (_) {},
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final checkbox = t.widget<Checkbox>(find.byType(Checkbox).at(1));
    expect(checkbox.onChanged, isNotNull);
    await t.tap(find.byType(Checkbox).at(1));
    await t.pump();
    Focus.of(t.element(find.byType(Checkbox).at(1))).requestFocus();
    await t.pump();
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.end);
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await t.pumpAndSettle();
    expect(find.text('row 9999'), findsOneWidget);
  });
}
