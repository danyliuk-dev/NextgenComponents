import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets('selection and removal are independent controlled requests', (
    t,
  ) async {
    var items = const [
      NgOption('a', 'Alpha'),
      NgOption('b', 'Beta'),
      NgOption('c', 'Locked', disabled: true),
    ];
    var value = <String>['a'];
    var changes = 0;
    var removes = 0;
    var accept = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => NgChipList(
              items: items,
              value: value,
              multiple: true,
              onChanged: (v) => setState(() {
                value = v;
                changes++;
              }),
              onRemove: (id) => setState(() {
                removes++;
                if (accept) {
                  items = items.where((x) => x.value != id).toList();
                  value = value.where((x) => x != id).toList();
                }
              }),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Beta'));
    await t.pumpAndSettle();
    expect(value, ['a', 'b']);
    expect(changes, 1);
    await t.tap(find.byTooltip('Remove Alpha'));
    await t.pumpAndSettle();
    expect(removes, 1);
    expect(value, ['a', 'b']);
    expect(find.text('Alpha'), findsOneWidget);
    accept = true;
    await t.tap(find.byTooltip('Remove Alpha'));
    await t.pumpAndSettle();
    expect(value, ['b']);
    expect(changes, 1);
    expect(find.text('Alpha'), findsNothing);
    await t.tap(find.text('Locked'));
    await t.pumpAndSettle();
    expect(value, ['b']);
    expect(find.byTooltip('Remove Locked'), findsNothing);
  });
  testWidgets('toggle retains keyboard focus across state changes', (t) async {
    bool value = false;
    int changes = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => NgChip(
              label: 'Favourite',
              value: value,
              onChanged: (v) => setState(() {
                value = v;
                changes++;
              }),
            ),
          ),
        ),
      ),
    );
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pumpAndSettle();
    expect(value, true);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pumpAndSettle();
    expect(value, false);
    expect(changes, 2);
  });
  testWidgets('disabled actions, nonselectable removal, empty state', (
    t,
  ) async {
    int selected = 0, removed = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgChip(
            label: 'Disabled',
            disabled: true,
            onChanged: (_) => selected++,
            onRemove: () => removed++,
          ),
        ),
      ),
    );
    await t.tap(find.text('Disabled'));
    await t.pump();
    expect(selected, 0);
    expect(removed, 0);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgChip(
            label: 'Static',
            selectable: false,
            onChanged: (_) => selected++,
            onRemove: () => removed++,
          ),
        ),
      ),
    );
    await t.tap(find.text('Static'));
    await t.pump();
    expect(selected, 0);
    await t.tap(find.byTooltip('Remove Static'));
    await t.pump();
    expect(removed, 1);
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NgChipList(items: [])),
      ),
    );
    expect(find.text('No tags'), findsOneWidget);
  });
}
