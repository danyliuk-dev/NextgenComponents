import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

NgGroupedDataResult<String> pageResult(
  List<String> values, {
  int total = 40,
  int levels = 2,
}) => NgGroupedDataResult(
  values
      .map((v) => NgGroupedItem(v, levels == 2 ? ['A', 'x'] : ['A']))
      .toList(),
  total,
  values.isEmpty
      ? []
      : [
          NgRemoteGroup(['A'], total, [const NgGroupSummary('Sum', 800)]),
          if (levels == 2)
            NgRemoteGroup(
              ['A', 'x'],
              total,
              [const NgGroupSummary('Sum', 800)],
            ),
        ],
);
void main() {
  test(
    'grouped protocol validates boundaries, paths, complete metadata and snapshots',
    () {
      final request = NgGroupedDataRequest(1, 2, '', [], ['name', 'kind']);
      final valid = pageResult(['a', 'b']);
      final tree = NgGroupedData.validate(valid, request, (v) => v);
      expect(tree.single.count, 40);
      expect(tree.single.items.length, 2);
      expect(tree.single.summaries.single.value, 800);
      expect(() => request.groupKeys.add('new'), throwsUnsupportedError);
      expect(() => tree.single.summaries.clear(), throwsUnsupportedError);
      final invalid = <NgGroupedDataResult<String>>[
        pageResult(['a', 'a']),
        pageResult(['a']),
        NgGroupedDataResult(valid.items, -1, valid.groups),
        NgGroupedDataResult(valid.items, 40, []),
        NgGroupedDataResult(valid.items, 40, [
          ...valid.groups,
          valid.groups.first,
        ]),
        NgGroupedDataResult(valid.items, 40, [
          NgRemoteGroup(['A'], 1, []),
          valid.groups.last,
        ]),
        NgGroupedDataResult(valid.items, 40, [
          NgRemoteGroup(['A'], 30, []),
          valid.groups.last,
        ]),
        NgGroupedDataResult(valid.items, 40, [
          NgRemoteGroup(['A'], 40, [NgGroupSummary('bad', double.nan)]),
          valid.groups.last,
        ]),
        NgGroupedDataResult(valid.items, 40, [
          NgRemoteGroup(
            ['A'],
            40,
            [const NgGroupSummary('s', 1), const NgGroupSummary('s', 2)],
          ),
          valid.groups.last,
        ]),
        NgGroupedDataResult(
          [
            NgGroupedItem('a', ['A']),
            NgGroupedItem('b', ['A']),
          ],
          40,
          valid.groups,
        ),
        NgGroupedDataResult(valid.items, 40, [
          ...valid.groups,
          NgRemoteGroup(['unused'], 1, []),
        ]),
      ];
      for (final response in invalid) {
        expect(
          () => NgGroupedData.validate(response, request, (v) => v),
          throwsArgumentError,
        );
      }
      final interleaved = NgGroupedDataResult(
        [
          NgGroupedItem('a', ['A']),
          NgGroupedItem('b', ['B']),
          NgGroupedItem('c', ['A']),
        ],
        3,
        [
          NgRemoteGroup(['A'], 2, []),
          NgRemoteGroup(['B'], 1, []),
        ],
      );
      expect(
        () => NgGroupedData.validate(
          interleaved,
          NgGroupedDataRequest(1, 3, '', [], ['name']),
          (v) => v,
        ),
        throwsArgumentError,
      );
      for (final keys in <List<String>>[
        [],
        ['name', 'name'],
        [' '],
        List.generate(9, (n) => '$n'),
      ]) {
        expect(() => NgGroupedData.validateKeys(keys), throwsArgumentError);
      }
      final mutable = ['a'];
      final snapshot = NgGroupedItem('value', mutable);
      mutable[0] = 'b';
      expect(snapshot.path, ['a']);
      final decoded = NgGroupedDataResult<String>.fromJson({
        'items': [
          {
            'item': {'id': 'a'},
            'path': ['A'],
          },
        ],
        'total': 1,
        'groups': [
          {
            'path': ['A'],
            'count': 1,
            'summaries': [
              {'title': 'Sum', 'value': null},
            ],
          },
        ],
      }, (row) => row['id'] as String);
      expect(
        NgGroupedData.validate(
          decoded,
          NgGroupedDataRequest(1, 2, '', [], ['name']),
          (v) => v,
        ).single.summaries.single.value,
        isNull,
      );
    },
  );
  test(
    'reference adapter groups before paging and computes full weighted summaries',
    () {
      final values = ['A/x/2', 'B/x/9', 'A/y/10', 'A/x/6'];
      final result = NgGroupedData.page<String>(
        values,
        [(s) => s.split('/')[0], (s) => s.split('/')[1]],
        [
          NgGroupAggregate(
            'Mean',
            (s) => double.parse(s.split('/')[2]),
            operation: 'average',
          ),
        ],
        1,
        2,
      );
      expect(result.items.map((r) => r.item), ['A/x/2', 'A/x/6']);
      expect(result.groups.first.count, 3);
      expect(result.groups.first.summaries.single.value, 6);
      expect(result.groups.last.summaries.single.value, 4);
      expect(
        NgGroupedData.validate(
          result,
          NgGroupedDataRequest(1, 2, '', [], ['a', 'b']),
          (v) => v,
        ).single.items.length,
        2,
      );
      final beyond = NgGroupedData.page<String>(
        values,
        [(s) => s.split('/')[0]],
        <NgGroupAggregate<String>>[],
        9,
        2,
      );
      expect(beyond.items, isEmpty);
      expect(beyond.groups, isEmpty);
    },
  );
  testWidgets(
    'remote grouped lifecycle discards stale data; collapse stays local; retry and shrinking pages recover',
    (t) async {
      final requests = <NgGroupedDataRequest>[];
      final pending = <Completer<NgGroupedDataResult<String>>>[];
      Future<NgGroupedDataResult<String>> read(NgGroupedDataRequest request) {
        requests.add(request);
        final c = Completer<NgGroupedDataResult<String>>();
        pending.add(c);
        return c.future;
      }

      var keys = ['name', 'kind'];
      var collapsed = <String>{'unknown'};
      var selected = <String>{'off-page'};
      var version = 0;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgDataGrid<String>(
                  label: 'Remote',
                  readGroupedData: read,
                  remoteGroupKeys: keys,
                  dataVersion: version,
                  columns: [NgDataColumn('id', 'ID', (s) => s)],
                  rowId: (s) => s,
                  initialPageSize: 2,
                  pageSizes: const [2, 4],
                  collapsibleGroups: true,
                  collapsedGroups: collapsed,
                  onCollapsedGroupsChanged: (v) => set(() => collapsed = v),
                  selectedIds: selected,
                  onSelectionChanged: (v) => set(() => selected = v),
                );
              },
            ),
          ),
        ),
      );
      expect(requests.single.groupKeys, ['name', 'kind']);
      await t.enterText(find.byType(TextField), 'new');
      await t.pump();
      pending[1].complete(pageResult(['new1', 'new2']));
      await t.pumpAndSettle();
      pending[0].completeError(StateError('private obsolete error'));
      await t.pumpAndSettle();
      expect(find.text('new1'), findsOneWidget);
      expect(find.text('Unable to load records.'), findsNothing);
      expect(find.text('▾ A (40)'), findsOneWidget);
      expect(find.text(' · Sum: 800'), findsNWidgets(2));
      await t.tap(find.byType(Checkbox).first);
      await t.pump();
      expect(selected, {'off-page', 'new1', 'new2'});
      final before = requests.length;
      await t.tap(find.widgetWithText(TextButton, 'Collapse page groups'));
      await t.pump();
      expect(requests.length, before);
      expect(collapsed, {
        'unknown',
        ngGroupId(['A']),
        ngGroupId(['A', 'x']),
      });
      expect(find.text('new1'), findsNothing);
      expect(find.text('1–2 of 40'), findsOneWidget);
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      expect(requests.last.page, 2);
      expect(find.text('▸ A (40)'), findsNothing);
      pending.last.complete(
        NgGroupedDataResult(
          [
            NgGroupedItem('bad1', ['A', 'x']),
            NgGroupedItem('bad2', ['A', 'x']),
          ],
          40,
          [],
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Unable to load records.'), findsOneWidget);
      expect(find.text('bad1'), findsNothing);
      await t.tap(find.text('Retry'));
      await t.pump();
      pending.last.complete(pageResult(['next1', 'next2']));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(TextButton, 'Expand page groups'));
      await t.pump();
      expect(find.text('next1'), findsOneWidget);
      expect(selected, contains('new1'));
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      pending.last.complete(pageResult([], total: 1));
      await t.pumpAndSettle();
      expect(requests.last.page, 1);
      pending.last.complete(pageResult(['only'], total: 1));
      await t.pumpAndSettle();
      expect(find.text('1–1 of 1'), findsOneWidget);
      update(() => version++);
      await t.pump();
      final obsolete = pending.last;
      update(() => keys = ['name']);
      await t.pump();
      expect(requests.last.groupKeys, ['name']);
      pending.last.complete(pageResult(['current1', 'current2'], levels: 1));
      await t.pumpAndSettle();
      obsolete.complete(pageResult(['obsolete1', 'obsolete2']));
      await t.pumpAndSettle();
      expect(find.text('current1'), findsOneWidget);
      expect(find.text('obsolete1'), findsNothing);
      await t.tap(find.text('ID'));
      await t.pump();
      expect(requests.last.sorts.single.key, 'id');
      final afterDispose = pending.last;
      await t.pumpWidget(const SizedBox());
      afterDispose.complete(pageResult(['late1', 'late2'], levels: 1));
      await t.pump();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'invalid mixed remote/local configuration never starts a request',
    (t) async {
      var calls = 0;
      await t.pumpWidget(
        MaterialApp(
          home: NgDataGrid<String>(
            readGroupedData: (r) async {
              calls++;
              return pageResult([]);
            },
            remoteGroupKeys: const ['name'],
            groupBy: (s) => s,
            columns: [NgDataColumn('id', 'ID', (s) => s)],
            rowId: (s) => s,
          ),
        ),
      );
      expect(t.takeException(), isArgumentError);
      expect(calls, 0);
    },
  );
}
