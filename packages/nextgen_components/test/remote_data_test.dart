import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test('multi-sort preserves ties and descriptor order', () {
    final values = [
      (id: 'a', group: 1, value: 2),
      (id: 'b', group: 0, value: 5),
      (id: 'c', group: 1, value: 3),
      (id: 'd', group: 1, value: 3),
    ];
    final columns = [
      NgDataColumn('g', 'Group', (dynamic r) => r.group),
      NgDataColumn('v', 'Value', (dynamic r) => r.value),
    ];
    final result = NgDataOperations.queryMany(values, columns, '', [
      const NgSortDescriptor('g'),
      const NgSortDescriptor('v', descending: true),
    ]);
    expect(result.map((r) => r.id), ['b', 'c', 'd', 'a']);
  });
  testWidgets(
    'grid discards late responses, exposes retry, sends page and ordered sorts',
    (t) async {
      final requests = <NgDataRequest>[];
      final pending = <Completer<NgDataResult<String>>>[];
      Future<NgDataResult<String>> read(NgDataRequest r) {
        requests.add(r);
        final c = Completer<NgDataResult<String>>();
        pending.add(c);
        return c.future;
      }

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgDataGrid<String>(
              readData: read,
              multiSort: true,
              rowId: (s) => s,
              columns: [
                NgDataColumn('id', 'ID', (s) => s),
                NgDataColumn('length', 'Length', (s) => s.length),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Loading records…'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'new');
      await t.pump();
      expect(requests.last.search, 'new');
      pending[1].complete(NgDataResult(['newest'], 12));
      await t.pumpAndSettle();
      pending[0].complete(NgDataResult(['obsolete'], 1));
      await t.pumpAndSettle();
      expect(find.text('newest'), findsOneWidget);
      expect(find.text('obsolete'), findsNothing);
      await t.tap(find.text('ID'));
      await t.pump();
      pending.last.complete(NgDataResult(['sorted'], 12));
      await t.pumpAndSettle();
      await t.tap(find.text('Length'));
      await t.pump();
      expect(requests.last.sorts.map((s) => s.key), ['id', 'length']);
      pending.last.completeError(StateError('private service failure'));
      await t.pumpAndSettle();
      expect(find.text('Unable to load records.'), findsOneWidget);
      expect(find.textContaining('private service'), findsNothing);
      await t.tap(find.text('Retry'));
      await t.pump();
      pending.last.complete(NgDataResult(['recovered'], 12));
      await t.pumpAndSettle();
      expect(find.text('recovered'), findsOneWidget);
    },
  );
  testWidgets(
    'grid source version invalidates requests and shrinking total refetches page',
    (t) async {
      var version = 0;
      late StateSetter update;
      final requests = <NgDataRequest>[];
      final pending = <Completer<NgDataResult<String>>>[];
      Future<NgDataResult<String>> read(NgDataRequest r) {
        requests.add(r);
        final c = Completer<NgDataResult<String>>();
        pending.add(c);
        return c.future;
      }

      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgDataGrid<String>(
                  readData: read,
                  dataVersion: version,
                  rowId: (s) => s,
                  columns: [NgDataColumn('id', 'ID', (s) => s)],
                );
              },
            ),
          ),
        ),
      );
      update(() => version++);
      await t.pump();
      pending[0].completeError(StateError('old'));
      await t.pump();
      expect(find.text('Unable to load records.'), findsNothing);
      pending[1].complete(NgDataResult(['a'], 12));
      await t.pumpAndSettle();
      // Pager semantics expose a stable Next page tooltip.
      final pager = t.widget<NgPager>(find.byType(NgPager));
      pager.onPageChanged(3);
      await t.pump();
      expect(requests.last.page, 3);
      pending.last.complete(NgDataResult([], 1));
      await t.pump();
      expect(requests.last.page, 1);
      pending.last.complete(NgDataResult(['remaining'], 1));
      await t.pumpAndSettle();
      expect(find.text('remaining'), findsOneWidget);
    },
  );
  for (final treeList in [false, true]) {
    testWidgets(
      '${treeList ? 'TreeList' : 'TreeView'} lazy cache, failure retry, empty leaf, stale reset and expansion lock',
      (t) async {
        final roots = [const NgTreeNode('root', 'Root', hasChildren: true)];
        var expanded = <String>{};
        var locked = false;
        var version = 0;
        late StateSetter update;
        final pending = <Completer<List<NgTreeNode<String>>>>[];
        Future<List<NgTreeNode<String>>> load(NgTreeNode<String> node) {
          final c = Completer<List<NgTreeNode<String>>>();
          pending.add(c);
          return c.future;
        }

        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (c, set) {
                  update = set;
                  return treeList
                      ? NgTreeList<String>(
                          items: roots,
                          columns: [NgDataColumn('name', 'Name', (s) => s)],
                          loadChildren: load,
                          dataVersion: version,
                          expandedIds: expanded,
                          expansionReadOnly: locked,
                          onExpandedChanged: (v) => set(() => expanded = v),
                        )
                      : NgTreeView<String>(
                          items: roots,
                          text: (s) => s,
                          loadChildren: load,
                          dataVersion: version,
                          expandedIds: expanded,
                          expansionReadOnly: locked,
                          onExpandedChanged: (v) => set(() => expanded = v),
                        );
                },
              ),
            ),
          ),
        );
        await t.tap(find.byTooltip('Expand Root'));
        await t.pump();
        expect(pending.length, 1);
        pending.last.completeError(StateError('private'));
        await t.pumpAndSettle();
        expect(
          find.text('Unable to load children. Expand to retry.'),
          findsOneWidget,
        );
        await t.tap(find.byTooltip('Expand Root'));
        await t.pump();
        pending.last.complete([const NgTreeNode('child', 'Child')]);
        await t.pumpAndSettle();
        expect(find.text('Child'), findsOneWidget);
        await t.tap(find.byTooltip('Collapse Root'));
        await t.pumpAndSettle();
        await t.tap(find.byTooltip('Expand Root'));
        await t.pumpAndSettle();
        expect(pending.length, 2);
        update(() {
          version++;
          expanded = {};
        });
        await t.pump();
        await t.tap(find.byTooltip('Expand Root'));
        await t.pump();
        update(() => locked = true);
        await t.pump();
        pending.last.complete([
          const NgTreeNode('locked-child', 'Locked child'),
        ]);
        await t.pumpAndSettle();
        expect(expanded, isEmpty);
        update(() {
          locked = false;
          version++;
        });
        await t.pump();
        await t.tap(find.byTooltip('Expand Root'));
        await t.pump();
        final old = pending.last;
        update(() => version++);
        await t.pump();
        old.complete([const NgTreeNode('stale', 'Stale')]);
        await t.pumpAndSettle();
        expect(find.text('Stale'), findsNothing);
        expect(expanded, isEmpty);
        await t.tap(find.byTooltip('Expand Root'));
        await t.pump();
        pending.last.complete([]);
        await t.pumpAndSettle();
        expect(find.byTooltip('Expand Root'), findsNothing);
        expect(find.byTooltip('Collapse Root'), findsNothing);
      },
    );
    testWidgets(
      '${treeList ? 'TreeList' : 'TreeView'} rejects child IDs colliding with ancestors',
      (t) async {
        Future<List<NgTreeNode<String>>> load(NgTreeNode<String> n) async => [
          const NgTreeNode('root', 'Collision'),
        ];
        final roots = [const NgTreeNode('root', 'Root', hasChildren: true)];
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: treeList
                  ? NgTreeList<String>(
                      items: roots,
                      columns: [NgDataColumn('name', 'Name', (s) => s)],
                      loadChildren: load,
                      expandedIds: {},
                      onExpandedChanged: (_) {},
                    )
                  : NgTreeView<String>(
                      items: roots,
                      text: (s) => s,
                      loadChildren: load,
                      expandedIds: {},
                      onExpandedChanged: (_) {},
                    ),
            ),
          ),
        );
        await t.tap(find.byTooltip('Expand Root'));
        await t.pumpAndSettle();
        expect(
          find.text('Unable to load children. Expand to retry.'),
          findsOneWidget,
        );
        expect(find.text('Collision'), findsNothing);
      },
    );
  }
}
