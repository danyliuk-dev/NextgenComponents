import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  final columns = [
    NgDataColumn<String>('name', 'Name', (r) => r),
    NgDataColumn<String>('length', 'Length', (r) => r.length),
  ];
  test('CSV Unicode, quotes, CRLF, formulas, columns, formatting and BOM', () {
    final file = NgGridCsv.create(
      ['a,"b"\nc', 'Україна', '=SUM(A1)', '  +cmd', '-1', '@x', '\tdata'],
      columns,
      NgGridExport<String>(onExport: (_) async {}, columnKeys: ['name']),
    );
    expect(
      file.content,
      '\uFEFF"Name"\r\n"a,""b""\nc"\r\n"Україна"\r\n"\'=SUM(A1)"\r\n"\'  +cmd"\r\n"\'-1"\r\n"\'@x"\r\n"\'\tdata"\r\n',
    );
    expect(file.rowCount, 7);
    expect(file.columnKeys, ['name']);
    expect(file.bytes.take(3), [239, 187, 191]);
    final tsv = NgGridCsv.create(
      ['é'],
      columns,
      NgGridExport<String>(
        onExport: (_) async {},
        columnKeys: ['length', 'name'],
        includeHeaders: false,
        includeBom: false,
        delimiter: '\t',
        format: (key, r) => key == 'length' ? 'one' : r,
      ),
    );
    expect(tsv.content, '"one"\t"é"\r\n');
    expect(tsv.mimeType, 'text/tab-separated-values;charset=utf-8');
    expect(NgGridCsv.cell('=header'), '"\'=header"');
  });
  test(
    'empty output, limits and invalid descriptors fail without truncating',
    () {
      final empty = NgGridCsv.create(
        <String>[],
        columns,
        NgGridExport<String>(onExport: (_) async {}),
      );
      expect(empty.content, '\uFEFF"Name","Length"\r\n');
      for (final option in [
        NgGridExport<String>(onExport: (_) async {}, maxRows: 1),
        NgGridExport<String>(onExport: (_) async {}, maxCharacters: 4),
        NgGridExport<String>(onExport: (_) async {}, delimiter: '|'),
        NgGridExport<String>(onExport: (_) async {}, columnKeys: ['missing']),
        NgGridExport<String>(
          onExport: (_) async {},
          columnKeys: ['name', 'name'],
        ),
        NgGridExport<String>(onExport: (_) async {}, fileName: '../x.csv'),
      ]) {
        expect(
          () => NgGridCsv.create(['a', 'b'], columns, option),
          throwsArgumentError,
        );
      }
    },
  );
  testWidgets(
    'page versus full filtered versus selected, collapse and ordered columns',
    (t) async {
      NgGridExportFile? output;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NgDataGrid<String>(
                items: ['A', 'B', 'C', 'D'],
                columns: columns,
                rowId: (r) => r,
                initialPageSize: 2,
                selectedIds: {'B', 'C', 'missing'},
                groupBy: (r) => r == 'A' ? 'hidden' : 'shown',
                collapsibleGroups: true,
                collapsedGroups: {
                  ngGroupId(['hidden']),
                },
                onCollapsedGroupsChanged: (_) {},
                export: NgGridExport(
                  onExport: (f) async {
                    output = f;
                  },
                  columnKeys: ['length', 'name'],
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> prepare() async {
        final f = find.text('Prepare export');
        await t.ensureVisible(f);
        await t.tap(f);
        await t.pumpAndSettle();
      }

      Future<void> scope(String name) async {
        await t.tap(find.byType(DropdownButton<NgGridExportScope>));
        await t.pumpAndSettle();
        await t.tap(find.text(name).last);
        await t.pumpAndSettle();
      }

      await prepare();
      expect(output!.rowCount, 1);
      expect(output!.content.contains('"B"'), true);
      expect(output!.columnKeys, ['length', 'name']);
      await scope('Filtered records');
      await prepare();
      expect(output!.rowCount, 4);
      await scope('Selected filtered records');
      await prepare();
      expect(output!.rowCount, 2);
      await t.enterText(find.byType(TextField).first, 'C');
      await t.pumpAndSettle();
      await prepare();
      expect(output!.rowCount, 1);
      expect(output!.content.contains('"C"'), true);
    },
  );
  testWidgets(
    'remote adapter snapshot, duplicate guard, failure, retry, cancel and invalidation',
    (t) async {
      var pending = Completer<List<String>>();
      var calls = 0, version = 0;
      var locked = false;
      late StateSetter update;
      NgGridExportRequest? request;
      final outputs = <NgGridExportFile>[];
      Future<NgDataResult<String>> read(NgDataRequest r) async =>
          NgDataResult(['A'], 3);
      Future<List<String>> export(NgGridExportRequest r) {
        calls++;
        request = r;
        return pending.future;
      }

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return NgDataGrid<String>(
                  readData: read,
                  dataVersion: version,
                  columns: columns,
                  rowId: (r) => r,
                  selectedIds: {'A', 'C'},
                  export: NgGridExport(
                    readExportData: export,
                    readOnly: locked,
                    onExport: (f) async {
                      outputs.add(f);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.byType(DropdownButton<NgGridExportScope>));
      await t.pumpAndSettle();
      await t.tap(find.text('Selected filtered records').last);
      await t.pumpAndSettle();
      Future<void> start() async {
        await t.tap(find.text('Prepare export'));
        await t.pump();
      }

      await start();
      expect(calls, 1);
      expect(request!.selectedIds, ['A', 'C']);
      expect(() => request!.selectedIds.add('B'), throwsUnsupportedError);
      expect(
        t
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Prepare export'),
            )
            .onPressed,
        isNull,
      );
      pending.complete(['A', 'B']);
      await t.pumpAndSettle();
      expect(outputs, isEmpty);
      expect(
        find.text('Unable to export records. Check limits and retry.'),
        findsOneWidget,
      );
      pending = Completer();
      await start();
      pending.complete(['A', 'A']);
      await t.pumpAndSettle();
      expect(outputs, isEmpty);
      pending = Completer();
      await start();
      pending.completeError(StateError('PRIVATE'));
      await t.pumpAndSettle();
      expect(find.textContaining('PRIVATE'), findsNothing);
      pending = Completer();
      await start();
      await t.tap(find.text('Cancel export'));
      await t.pump();
      pending.complete(['A']);
      await t.pumpAndSettle();
      expect(outputs, isEmpty);
      pending = Completer();
      await start();
      update(() => version++);
      await t.pumpAndSettle();
      pending.complete(['A']);
      await t.pumpAndSettle();
      expect(outputs, isEmpty);
      pending = Completer();
      await start();
      update(() => locked = true);
      await t.pump();
      pending.complete(['A']);
      await t.pumpAndSettle();
      expect(outputs, isEmpty);
      update(() => locked = false);
      await t.pump();
      pending = Completer();
      await start();
      pending.complete(['A', 'C']);
      await t.pumpAndSettle();
      expect(outputs.single.rowCount, 2);
      expect(find.text('Export ready.'), findsOneWidget);
    },
  );
  testWidgets(
    'remote page export works without full adapter; filtered export unavailable',
    (t) async {
      NgGridExportFile? output;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgDataGrid<String>(
              readData: (_) async => NgDataResult(['A'], 40),
              columns: columns,
              rowId: (r) => r,
              export: NgGridExport(
                onExport: (f) async {
                  output = f;
                },
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Prepare export'));
      await t.pumpAndSettle();
      expect(output!.rowCount, 1);
      final dropdown = t.widget<DropdownButton<NgGridExportScope>>(
        find.byType(DropdownButton<NgGridExportScope>),
      );
      expect(
        dropdown.items!
            .where((i) => i.value != NgGridExportScope.page)
            .every((i) => !i.enabled),
        true,
      );
    },
  );
}
