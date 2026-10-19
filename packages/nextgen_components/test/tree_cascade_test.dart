import 'dart:ui' show CheckedState;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final list in [false, true]) {
    testWidgets(
      '${list ? 'TreeList' : 'TreeView'} cascade is atomic, scoped and controlled',
      (t) async {
        final semantics = t.ensureSemantics();
        final items = [
          const NgTreeNode(
            'root',
            'Root',
            children: [
              NgTreeNode('a', 'Alpha'),
              NgTreeNode('group', 'Group', children: [NgTreeNode('b', 'Beta')]),
              NgTreeNode(
                'locked',
                'Locked',
                disabled: true,
                children: [NgTreeNode('locked-child', 'Locked child')],
              ),
              NgTreeNode(
                'protected',
                'Protected',
                children: [NgTreeNode('protected-child', 'Protected child')],
              ),
              NgTreeNode('lazy', 'Lazy', hasChildren: true),
            ],
          ),
        ];
        final initial = {'unknown', 'locked', 'protected-child'};
        Set<String> checked = initial, expanded = {};
        Set<String>? proposed;
        var accept = false, cascade = true, locked = false, calls = 0;
        late StateSetter update;
        void change(Set<String> next) {
          calls++;
          proposed = next;
          if (accept) update(() => checked = next);
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
                            expandedIds: expanded,
                            onExpandedChanged: (v) =>
                                update(() => expanded = v),
                            checkboxes: true,
                            checkChildren: cascade,
                            checkingReadOnly: locked,
                            checkedIds: checked,
                            onCheckedChanged: change,
                            canCheck: (n) => n.id != 'protected',
                          )
                        : NgTreeView<String>(
                            items: items,
                            text: (s) => s,
                            expandedIds: expanded,
                            onExpandedChanged: (v) =>
                                update(() => expanded = v),
                            checkboxes: true,
                            checkChildren: cascade,
                            checkingReadOnly: locked,
                            checkedIds: checked,
                            onCheckedChanged: change,
                            canCheck: (n) => n.id != 'protected',
                          ),
                  );
                },
              ),
            ),
          ),
        );
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(calls, 1);
        expect(initial, {'unknown', 'locked', 'protected-child'});
        expect(proposed, {
          'unknown',
          'locked',
          'protected-child',
          'root',
          'a',
          'group',
          'b',
          'lazy',
        });
        expect(t.widget<Checkbox>(find.byType(Checkbox).first).value, false);
        update(() => accept = true);
        await t.pump();
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(calls, 2);
        expect(t.widget<Checkbox>(find.byType(Checkbox).first).value, true);
        update(() => checked = {...checked}..remove('b'));
        await t.pump();
        expect(t.widget<Checkbox>(find.byType(Checkbox).first).value, isNull);
        expect(
          t
              .getSemantics(find.bySemanticsLabel('Check Root'))
              .getSemanticsData()
              .flagsCollection
              .isChecked,
          CheckedState.mixed,
        );
        expect(
          t
              .getSemantics(find.bySemanticsLabel('Check Root'))
              .getSemanticsData()
              .value,
          'Partially checked',
        );
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(checked.contains('b'), true);
        expect(calls, 3);
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(checked, initial);
        expect(calls, 4);
        final stale = t
            .widget<Checkbox>(find.byType(Checkbox).first)
            .onChanged!;
        update(() => locked = true);
        await t.pump();
        stale(true);
        expect(calls, 4);
        update(() {
          locked = false;
          cascade = false;
        });
        await t.pump();
        stale(true);
        await t.pump();
        expect(checked, {...initial, 'root'});
        update(() => cascade = true);
        await t.pump();
        expect(t.widget<Checkbox>(find.byType(Checkbox).first).value, isNull);
        await t.tap(find.byTooltip('Expand Root'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), 'Alpha');
        await t.pump();
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(
          checked.contains('b'),
          true,
        ); // Filtering does not trim the cascade.
        expect(checked.contains('locked-child'), false);
        expect(checked.contains('protected-child'), true);
        semantics.dispose();
      },
    );
    testWidgets(
      '${list ? 'TreeList' : 'TreeView'} newly loaded children do not inherit checks',
      (t) async {
        final items = [const NgTreeNode('root', 'Root', hasChildren: true)];
        Set<String> checked = {}, expanded = {};
        var loads = 0, calls = 0;
        Future<List<NgTreeNode<String>>> load(NgTreeNode<String> node) async {
          loads++;
          return [const NgTreeNode('a', 'Alpha')];
        }

        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (c, set) {
                  void change(Set<String> next) {
                    calls++;
                    set(() => checked = next);
                  }

                  return list
                      ? NgTreeList<String>(
                          items: items,
                          columns: [NgDataColumn('name', 'Name', (s) => s)],
                          loadChildren: load,
                          expandedIds: expanded,
                          onExpandedChanged: (v) => set(() => expanded = v),
                          checkboxes: true,
                          checkChildren: true,
                          checkedIds: checked,
                          onCheckedChanged: change,
                        )
                      : NgTreeView<String>(
                          items: items,
                          text: (s) => s,
                          loadChildren: load,
                          expandedIds: expanded,
                          onExpandedChanged: (v) => set(() => expanded = v),
                          checkboxes: true,
                          checkChildren: true,
                          checkedIds: checked,
                          onCheckedChanged: change,
                        );
                },
              ),
            ),
          ),
        );
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(checked, {'root'});
        expect(loads, 0);
        await t.tap(find.byTooltip('Expand Root'));
        await t.pumpAndSettle();
        expect(loads, 1);
        expect(calls, 1);
        expect(checked, {'root'});
        expect(t.widget<Checkbox>(find.byType(Checkbox).first).value, isNull);
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(checked, {'root', 'a'});
        expect(calls, 2);
      },
    );
  }
}
