import 'dart:ui' show CheckedState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final list in [false, true]) {
    testWidgets(
      '${list ? 'TreeList' : 'TreeView'} controlled checks preserve hidden IDs and independent state',
      (t) async {
        final input = <String>{'hidden'};
        Set<String> checked = input, expanded = {'root'};
        Set<String>? proposal;
        var readOnly = false, protect = true, show = true, accept = false;
        var selections = 0, loads = 0;
        final roots = [const NgTreeNode('root', 'Root', hasChildren: true)];
        Future<List<NgTreeNode<String>>> load(NgTreeNode<String> n) async {
          loads++;
          return [
            const NgTreeNode('a', 'Alpha'),
            const NgTreeNode('b', 'Beta', disabled: true),
          ];
        }

        // Start collapsed: checking a lazy parent must not trigger loading.
        expanded = {};
        late StateSetter update;
        Widget tree() => list
            ? NgTreeList<String>(
                items: roots,
                columns: [NgDataColumn('name', 'Name', (s) => s)],
                loadChildren: load,
                expandedIds: expanded,
                onExpandedChanged: (v) => update(() => expanded = v),
                onSelected: (_) => selections++,
                checkboxes: show,
                checkedIds: checked,
                checkingReadOnly: readOnly,
                canCheck: (n) => !protect || n.id != 'a',
                onCheckedChanged: (v) {
                  proposal = v;
                  if (accept) update(() => checked = v);
                },
              )
            : NgTreeView<String>(
                items: roots,
                text: (s) => s,
                loadChildren: load,
                expandedIds: expanded,
                onExpandedChanged: (v) => update(() => expanded = v),
                onSelected: (_) => selections++,
                checkboxes: show,
                checkedIds: checked,
                checkingReadOnly: readOnly,
                canCheck: (n) => !protect || n.id != 'a',
                onCheckedChanged: (v) {
                  proposal = v;
                  if (accept) update(() => checked = v);
                },
              );
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (c, set) {
                  update = set;
                  return SingleChildScrollView(child: tree());
                },
              ),
            ),
          ),
        );
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(proposal, {'hidden', 'root'});
        expect(input, {'hidden'});
        expect(loads, 0);
        expect(selections, 0);
        expect(t.widget<Checkbox>(find.byType(Checkbox).first).value, false);
        update(() => accept = true);
        await t.pump();
        await t.tap(find.byType(Checkbox).first);
        await t.pump();
        expect(checked, {'hidden', 'root'});
        await t.tap(find.byTooltip('Expand Root'));
        await t.pumpAndSettle();
        expect(loads, 1);
        expect(find.byType(Checkbox), findsNWidgets(3));
        expect(
          t.widget<Checkbox>(find.byType(Checkbox).at(1)).onChanged,
          isNull,
        );
        expect(
          t.widget<Checkbox>(find.byType(Checkbox).at(2)).onChanged,
          isNull,
        );
        update(() => protect = false);
        await t.pump();
        final stale = t
            .widget<Checkbox>(find.byType(Checkbox).at(1))
            .onChanged!;
        update(() => readOnly = true);
        await t.pump();
        stale(true);
        expect(checked, {'hidden', 'root'});
        update(() => readOnly = false);
        await t.pump();
        await t.tap(find.byType(Checkbox).at(1));
        await t.pump();
        expect(checked, {'hidden', 'root', 'a'});
        expect(selections, 0);
        await t.tap(find.byTooltip('Collapse Root'));
        await t.pump();
        stale(false);
        expect(checked, {'hidden', 'root', 'a'});
        await t.tap(find.byTooltip('Expand Root'));
        await t.pumpAndSettle();
        expect(loads, 1);
        update(() => show = false);
        await t.pump();
        stale(false);
        expect(checked, {'hidden', 'root', 'a'});
        expect(find.byType(Checkbox), findsNothing);
        await t.pumpWidget(const SizedBox());
        stale(false);
        expect(checked, {'hidden', 'root', 'a'});
      },
    );
    testWidgets(
      '${list ? 'TreeList' : 'TreeView'} checkbox Space does not select row',
      (t) async {
        final semantics = t.ensureSemantics();

        Set<String> checked = {};
        var selections = 0;
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (c, set) {
                  final items = [const NgTreeNode('a', 'Alpha')];
                  return list
                      ? NgTreeList<String>(
                          items: items,
                          columns: [NgDataColumn('name', 'Name', (s) => s)],
                          expandedIds: {},
                          onExpandedChanged: (_) {},
                          onSelected: (_) => selections++,
                          checkboxes: true,
                          checkedIds: checked,
                          onCheckedChanged: (v) => set(() => checked = v),
                        )
                      : NgTreeView<String>(
                          items: items,
                          text: (s) => s,
                          expandedIds: {},
                          onExpandedChanged: (_) {},
                          onSelected: (_) => selections++,
                          checkboxes: true,
                          checkedIds: checked,
                          onCheckedChanged: (v) => set(() => checked = v),
                        );
                },
              ),
            ),
          ),
        );
        await t.tap(find.byType(Checkbox));
        await t.pump();
        expect(find.bySemanticsLabel('Check Alpha'), findsOneWidget);
        final node = t.getSemantics(find.bySemanticsLabel('Check Alpha'));

        expect(
          node.getSemanticsData().flagsCollection.isChecked,
          CheckedState.isTrue,
        );
        final before = Set<String>.from(checked);
        Focus.of(
          t.element(
            find
                .descendant(
                  of: find.byType(Checkbox),
                  matching: find.byType(CustomPaint),
                )
                .first,
          ),
        ).requestFocus();
        await t.pump();
        await t.sendKeyEvent(LogicalKeyboardKey.space);
        await t.pump();
        expect(selections, 0);
        expect(checked, isNot(before));
        semantics.dispose();
      },
    );
  }
}
