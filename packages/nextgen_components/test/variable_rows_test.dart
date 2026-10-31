import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets('measured rows: bounded jump, resize, selection and shrink', (
    t,
  ) async {
    var built = 0, count = 10000;
    var extra = false;
    var selected = <String>{'hidden'};
    late StateSetter update;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, set) {
              update = set;
              return NgDataGrid<int>(
                virtualize: true,
                variableRowHeight: true,
                viewportHeight: 192,
                items: List.generate(count, (i) => i),
                rowId: (i) => '$i',
                selectedIds: selected,
                onSelectionChanged: (v) => set(() => selected = v),
                columns: [
                  NgDataColumn(
                    'n',
                    'Number',
                    (i) => i,
                    cellBuilder: (context, i) {
                      built++;
                      return SizedBox(
                        height: (i % 3 + 1) * 55.0 + (extra ? 80 : 0),
                        child: Text('row $i'),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(built, lessThan(80));
    expect(t.getSize(find.text('row 0').first).height, 55);
    expect(t.getSize(find.text('row 1').first).height, 110);
    await t.tap(find.byType(Checkbox).at(1));
    await t.pumpAndSettle();
    expect(selected, {'hidden', '0'});
    final scroll = t.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    built = 0;
    scroll.position.jumpTo(scroll.position.maxScrollExtent);
    await t.pumpAndSettle();
    expect(find.text('row 9999'), findsOneWidget);
    expect(built, lessThan(120));
    expect(selected, {'hidden', '0'});
    update(() => extra = true);
    await t.pumpAndSettle();
    expect(find.text('row 9999'), findsOneWidget);
    update(() => count = 3);
    await t.pumpAndSettle();
    expect(find.text('row 0'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('variable rows reject continuous range adapters', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: NgDataGrid<int>(
          virtualize: true,
          variableRowHeight: true,
          readRange: (request) async =>
              NgDataRangeResult(request.startIndex, [], 0),
          rowId: (i) => '$i',
          columns: [NgDataColumn('n', 'Number', (i) => i)],
        ),
      ),
    );
    expect(t.takeException(), isArgumentError);
  });
  testWidgets(
    'measured server page scrolling does not fetch or fabricate other pages',
    (t) async {
      var reads = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NgDataGrid<int>(
                virtualize: true,
                variableRowHeight: true,
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
    'measured grouping scopes selection and export to expanded logical records',
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
                    variableRowHeight: true,
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

  testWidgets('measured table keyboard end reaches final row', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgDataGrid<int>(
            virtualize: true,
            variableRowHeight: true,
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
