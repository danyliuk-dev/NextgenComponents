import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

const tree = [
  NgTreeNode(
    'root',
    'Projects',
    children: [NgTreeNode('a', 'Design'), NgTreeNode('b', 'Engineering')],
  ),
];
void main() {
  for (final list in [false, true]) {
    testWidgets(
      '${list ? "TreeList" : "TreeView"} guards state, stale expansion and search without mutating caller sets',
      (t) async {
        var items = tree;
        var expanded = <String>{'unknown'};
        final original = expanded;
        String? selected;
        var lockSelection = true, lockExpansion = false, accept = true;
        late StateSetter update;
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (c, set) {
                  update = set;
                  void expand(Set<String> v) {
                    if (accept) set(() => expanded = v);
                  }

                  void select(String v) {
                    set(() => selected = v);
                  }

                  return list
                      ? NgTreeList<String>(
                          items: items,
                          columns: [
                            NgDataColumn(
                              'name',
                              'Name',
                              (s) => s,
                              cellBuilder: (c, s) => Text('Team $s'),
                            ),
                          ],
                          expandedIds: expanded,
                          onExpandedChanged: expand,
                          selectedId: selected,
                          onSelected: select,
                          selectionReadOnly: lockSelection,
                          expansionReadOnly: lockExpansion,
                          emptyText: 'Nothing found',
                        )
                      : NgTreeView<String>(
                          items: items,
                          text: (s) => s,
                          itemBuilder: (c, s) => Text('Team $s'),
                          expandedIds: expanded,
                          onExpandedChanged: expand,
                          selectedId: selected,
                          onSelected: select,
                          selectionReadOnly: lockSelection,
                          expansionReadOnly: lockExpansion,
                          emptyText: 'Nothing found',
                        );
                },
              ),
            ),
          ),
        );
        final staleExpand = t
            .widget<IconButton>(find.byType(IconButton).first)
            .onPressed!;
        await t.tap(find.byTooltip('Expand Projects'));
        await t.pump();
        expect(expanded, {'unknown', 'root'});
        expect(original, {'unknown'});
        await t.tap(find.text('Team Design'));
        await t.pump();
        expect(selected, isNull);
        update(() {
          lockSelection = false;
          lockExpansion = true;
        });
        await t.pump();
        await t.tap(find.text('Team Design'));
        await t.pump();
        expect(selected, 'a');
        staleExpand();
        await t.pump();
        expect(expanded, {'unknown', 'root'});
        update(() {
          lockExpansion = false;
          accept = false;
        });
        await t.pump();
        await t.tap(find.byTooltip('Collapse Projects'));
        await t.pump();
        expect(find.text('Team Design'), findsOneWidget);
        update(() {
          accept = true;
          expanded = {'unknown'};
        });
        await t.pump();
        await t.enterText(find.byType(TextField), 'Engineering');
        await t.pump();
        expect(find.text('Team Engineering'), findsOneWidget);
        expect(expanded, {'unknown'});
        staleExpand();
        await t.pump();
        expect(expanded, {'unknown'});
        await t.enterText(find.byType(TextField), '   ');
        await t.pump();
        expect(find.text('Team Engineering'), findsNothing);
        await t.tap(find.byTooltip('Expand Projects'));
        await t.pump();
        expect(expanded, {'unknown', 'root'});
        update(() => items = []);
        await t.pump();
        staleExpand();
        await t.pump();
        expect(expanded, {'unknown', 'root'});
        expect(find.text('Nothing found'), findsOneWidget);
      },
    );
  }
  testWidgets(
    'TreeView ArrowRight on a leaf stays put even with stale expansion ID',
    (t) async {
      String? selected;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgTreeView<String>(
              items: tree,
              text: (s) => s,
              expandedIds: const {'root', 'a'},
              onExpandedChanged: (_) {},
              onSelected: (v) => selected = v,
            ),
          ),
        ),
      );
      await t.tap(find.text('Design'));
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, 'a');
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selected, 'b');
    },
  );
  test('blank IDs rejected and leaf expansion ignored', () {
    expect(
      () => NgDataOperations.flatten(
        [const NgTreeNode(' ', 'Bad')],
        {},
        (s) => s,
      ),
      throwsArgumentError,
    );
    expect(
      NgDataOperations.flatten(tree, {
        'root',
        'a',
      }, (s) => s).firstWhere((r) => r.node.id == 'a').expanded,
      isFalse,
    );
  });
}
