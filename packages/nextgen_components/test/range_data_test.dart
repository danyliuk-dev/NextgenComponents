import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

final columns = [NgDataColumn<int>('id', 'Record', (i) => 'row $i')];
NgDataRangeResult<int> result(NgDataRangeRequest q, [int total = 100000]) =>
    NgDataRangeResult(
      q.startIndex,
      List.generate(
        (total - q.startIndex).clamp(0, q.count),
        (i) => q.startIndex + i,
      ),
      total,
    );
Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
ScrollableState scroller(WidgetTester t) => t.state<ScrollableState>(
  find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)),
);
Future<void> scrollEnd(WidgetTester t) async {
  final s = scroller(t);
  s.position.jumpTo(s.position.maxScrollExtent);
  await t.pump();
  await t.pump(const Duration(milliseconds: 80));
  await t.pumpAndSettle();
}

void main() {
  test(
    'range contract snapshots and validates exact offsets, counts, IDs and limits',
    () {
      final sorts = <NgSortDescriptor>[const NgSortDescriptor('id')];
      final q = NgDataRangeRequest(10, 5, '', sorts);
      sorts.clear();
      expect(q.sorts.length, 1);
      expect(NgDataRange.validate(result(q, 13), q, (i) => '$i'), [10, 11, 12]);
      for (final bad in [
        NgDataRangeResult(11, [10, 11, 12], 13),
        NgDataRangeResult(10, [10, 11], 13),
        NgDataRangeResult(10, [10, 10, 12], 13),
        NgDataRangeResult(10, [10, 11, 12], 100001),
        NgDataRangeResult<int>(10, [], -1),
      ]) {
        expect(
          () => NgDataRange.validate(bad, q, (i) => '$i'),
          throwsArgumentError,
        );
      }
      for (final bad in [
        NgDataRangeRequest(-1, 5, '', []),
        NgDataRangeRequest(0, 513, '', []),
        NgDataRangeRequest(0, 0, '', []),
      ]) {
        expect(() => NgDataRange.validateRequest(bad), throwsArgumentError);
      }
    },
  );
  testWidgets(
    '100k result jumps to end with bounded reads and retains selection',
    (t) async {
      final requests = <NgDataRangeRequest>[];
      var selected = <String>{'hidden'};
      Future<NgDataRangeResult<int>> read(NgDataRangeRequest q) async {
        requests.add(q);
        return result(q);
      }

      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => NgDataGrid<int>(
              readRange: read,
              virtualize: true,
              viewportHeight: 192,
              columns: columns,
              rowId: (i) => '$i',
              selectedIds: selected,
              onSelectionChanged: (v) => set(() => selected = v),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(requests.length, 1);
      expect(requests.first.count, lessThanOrEqualTo(512));
      await t.tap(find.byType(Checkbox).at(1));
      await t.pumpAndSettle();
      expect(selected, {'hidden', '0'});
      await scrollEnd(t);
      expect(find.text('row 99999'), findsOneWidget);
      expect(find.text('row 0'), findsNothing);
      expect(requests.length, lessThanOrEqualTo(3));
      expect(requests.last.startIndex, greaterThan(99000));
      expect(selected, {'hidden', '0'});
      expect(find.byType(NgPager), findsNothing);
      expect(find.byType(Checkbox).evaluate().length, lessThan(30));
    },
  );
  testWidgets(
    'failed and malformed windows clear rows and retry at the same position',
    (t) async {
      var fail = false, malformed = false;
      final requests = <NgDataRangeRequest>[];
      Future<NgDataRangeResult<int>> read(NgDataRangeRequest q) async {
        requests.add(q);
        if (fail) throw StateError('private transport details');
        final r = result(q);
        return malformed
            ? NgDataRangeResult(q.startIndex + 1, r.items, r.total)
            : r;
      }

      await t.pumpWidget(
        host(
          NgDataGrid<int>(
            readRange: read,
            virtualize: true,
            viewportHeight: 192,
            columns: columns,
            rowId: (i) => '$i',
          ),
        ),
      );
      await t.pumpAndSettle();
      fail = true;
      await scrollEnd(t);
      expect(find.text('row 99999'), findsNothing);
      expect(find.text('private transport details'), findsNothing);
      final start = requests.last.startIndex;
      fail = false;
      malformed = true;
      await t.tap(find.text('Retry'));
      await t.pumpAndSettle();
      expect(requests.last.startIndex, start);
      expect(find.text('row 99999'), findsNothing);
      malformed = false;
      await t.tap(find.text('Retry'));
      await t.pumpAndSettle();
      expect(find.text('row 99999'), findsOneWidget);
    },
  );
  testWidgets('new query discards obsolete successful and failed responses', (
    t,
  ) async {
    final pending =
        <
          ({NgDataRangeRequest request, Completer<NgDataRangeResult<int>> done})
        >[];
    Future<NgDataRangeResult<int>> read(NgDataRangeRequest q) {
      final done = Completer<NgDataRangeResult<int>>();
      pending.add((request: q, done: done));
      return done.future;
    }

    await t.pumpWidget(
      host(
        NgDataGrid<int>(
          readRange: read,
          virtualize: true,
          viewportHeight: 192,
          columns: columns,
          rowId: (i) => '$i',
        ),
      ),
    );
    await t.pump();
    expect(pending.length, 1);
    await t.enterText(find.byType(TextField), 'new');
    await t.pump();
    expect(pending.length, 2);
    pending[1].done.complete(result(pending[1].request, 12));
    await t.pumpAndSettle();
    pending[0].done.completeError(StateError('obsolete'));
    await t.pumpAndSettle();
    expect(find.text('row 0'), findsOneWidget);
    expect(find.textContaining('/ 12'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    await t.enterText(find.byType(TextField), 'next');
    await t.pump();
    await t.enterText(find.byType(TextField), 'last');
    await t.pump();
    pending[3].done.complete(result(pending[3].request, 3));
    await t.pumpAndSettle();
    pending[2].done.complete(result(pending[2].request));
    await t.pumpAndSettle();
    expect(find.text('row 2'), findsOneWidget);
    expect(find.text('row 11'), findsNothing);
  });
  testWidgets('live shrinking server result corrects an out-of-range window', (
    t,
  ) async {
    var total = 100000;
    Future<NgDataRangeResult<int>> read(NgDataRangeRequest q) async =>
        result(q, total);
    await t.pumpWidget(
      host(
        NgDataGrid<int>(
          readRange: read,
          virtualize: true,
          viewportHeight: 192,
          columns: columns,
          rowId: (i) => '$i',
        ),
      ),
    );
    await t.pumpAndSettle();
    total = 12;
    await scrollEnd(t);
    expect(find.text('row 11'), findsOneWidget);
    expect(find.textContaining('/ 12'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'window export and header selection never imply the entire result',
    (t) async {
      NgGridExportFile? output;
      var selected = <String>{};
      final requests = <NgDataRangeRequest>[];
      Future<NgDataRangeResult<int>> read(NgDataRangeRequest q) async {
        requests.add(q);
        return result(q);
      }

      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => NgDataGrid<int>(
              readRange: read,
              virtualize: true,
              viewportHeight: 192,
              columns: columns,
              rowId: (i) => '$i',
              selectedIds: selected,
              onSelectionChanged: (v) => set(() => selected = v),
              export: NgGridExport(
                onExport: (file) async {
                  output = file;
                },
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.byType(Checkbox).first);
      await t.pumpAndSettle();
      expect(selected.length, requests.last.count);
      expect(selected.length, lessThan(100000));
      await t.tap(find.text('Prepare export'));
      await t.pumpAndSettle();
      expect(output!.rowCount, requests.last.count);
    },
  );
}
