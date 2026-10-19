import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final list in [false, true]) {
    testWidgets(
      '${list ? 'TreeList' : 'TreeView'} bulk checks are loaded-only, protected and controlled',
      (t) async {
        var items = [
          const NgTreeNode(
            'root',
            'Root',
            children: [
              NgTreeNode('a', 'Alpha'),
              NgTreeNode(
                'locked',
                'Locked',
                disabled: true,
                children: [NgTreeNode('hidden', 'Hidden')],
              ),
              NgTreeNode(
                'protected',
                'Protected',
                children: [NgTreeNode('child', 'Child')],
              ),
            ],
          ),
          const NgTreeNode('lazy', 'Lazy', hasChildren: true),
        ];
        final input = {'unknown', 'locked', 'child'};
        Set<String> checked = input, expanded = {};
        Set<String>? proposed;
        var accept = false, readOnly = false, show = true, calls = 0, loads = 0;
        late StateSetter update;
        Future<List<NgTreeNode<String>>> load(NgTreeNode<String> node) async {
          loads++;
          return [const NgTreeNode('new', 'New')];
        }

        void changed(Set<String> v) {
          calls++;
          proposed = v;
          if (accept) update(() => checked = v);
        }

        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (c, set) {
                  update = set;
                  return SingleChildScrollView(
                    child: list
                        ? NgTreeList<String>(
                            items: items,
                            columns: [NgDataColumn('name', 'Name', (s) => s)],
                            loadChildren: load,
                            expandedIds: expanded,
                            onExpandedChanged: (v) =>
                                update(() => expanded = v),
                            checkboxes: true,
                            showCheckActions: show,
                            checkedIds: checked,
                            onCheckedChanged: changed,
                            checkingReadOnly: readOnly,
                            canCheck: (n) => n.id != 'protected',
                          )
                        : NgTreeView<String>(
                            items: items,
                            text: (s) => s,
                            loadChildren: load,
                            expandedIds: expanded,
                            onExpandedChanged: (v) =>
                                update(() => expanded = v),
                            checkboxes: true,
                            showCheckActions: show,
                            checkedIds: checked,
                            onCheckedChanged: changed,
                            checkingReadOnly: readOnly,
                            canCheck: (n) => n.id != 'protected',
                          ),
                  );
                },
              ),
            ),
          ),
        );
        Finder button(String label) => find.widgetWithText(TextButton, label);
        VoidCallback? action(String label) =>
            t.widget<TextButton>(button(label)).onPressed;
        expect(action('Clear loaded checks'), isNull);
        await t.tap(button('Check loaded nodes'));
        await t.pump();
        expect(calls, 1);
        expect(loads, 0);
        expect(input, {'unknown', 'locked', 'child'});
        expect(proposed, {'unknown', 'locked', 'child', 'root', 'a', 'lazy'});
        update(() => accept = true);
        await t.pump();
        await t.tap(button('Check loaded nodes'));
        await t.pump();
        expect(action('Check loaded nodes'), isNull);
        expect(calls, 2);
        await t.tap(find.byTooltip('Expand Lazy'));
        await t.pumpAndSettle();
        expect(loads, 1);
        expect(checked.contains('new'), false);
        expect(action('Check loaded nodes'), isNotNull);
        await t.enterText(find.byType(TextField), 'Alpha');
        await t.pump();
        await t.tap(button('Check loaded nodes'));
        await t.pump();
        expect(checked.contains('new'), true);
        expect(calls, 3);
        final stale = action('Clear loaded checks')!;
        update(() => readOnly = true);
        await t.pump();
        stale();
        expect(calls, 3);
        update(() => readOnly = false);
        await t.pump();
        stale();
        await t.pump();
        expect(checked, input);
        expect(calls, 4);
        update(() => show = false);
        await t.pump();
        stale();
        expect(calls, 4);
        expect(button('Clear loaded checks'), findsNothing);
        update(() {
          show = true;
          items = [];
        });
        await t.pump();
        stale();
        expect(calls, 4);
        expect(action('Check loaded nodes'), isNull);
        await t.pumpWidget(const SizedBox());
        stale();
        expect(calls, 4);
      },
    );
  }
}
