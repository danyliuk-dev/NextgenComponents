import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test(
    'appearance validation accepts all combinations and rejects invalid values',
    () {
      for (final size in ['sm', 'md', 'lg'])
        for (final rounded in ['sm', 'md', 'lg', 'full'])
          for (final fill in ['solid', 'outline'])
            for (final tone in [
              'base',
              'info',
              'success',
              'warning',
              'error',
            ]) {
              NgChipRules.validate(size, rounded, fill, tone);
            }
      for (final values in [
        ['xl', 'full', 'solid', 'base'],
        ['md', 'bad', 'solid', 'base'],
        ['md', 'full', 'bad', 'base'],
        ['md', 'full', 'solid', 'bad'],
      ]) {
        expect(
          () =>
              NgChipRules.validate(values[0], values[1], values[2], values[3]),
          throwsArgumentError,
        );
      }
    },
  );
  testWidgets(
    'templates retain name; click follows selection; removal is independent',
    (t) async {
      final events = <String>[];
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgChip(
              label: 'Accessible',
              child: const Text('Custom'),
              leading: const Icon(Icons.star),
              removeIcon: const Icon(Icons.remove),
              size: 'lg',
              rounded: 'sm',
              fillMode: 'solid',
              themeColor: 'success',
              onChanged: (v) => events.add('selection:$v'),
              onClick: () => events.add('click'),
              onRemove: () => events.add('remove'),
            ),
          ),
        ),
      );
      final semantics = t.ensureSemantics();
      expect(find.bySemanticsLabel('Accessible'), findsWidgets);
      await t.tap(find.text('Custom'));
      await t.pumpAndSettle();
      expect(events, ['selection:true', 'click']);
      await t.tap(find.byTooltip('Remove Accessible'));
      await t.pumpAndSettle();
      expect(events, ['selection:true', 'click', 'remove']);
      expect(
        t.widget<InputChip>(find.byType(InputChip)).labelStyle!.fontSize,
        16,
      );
      semantics.dispose();
    },
  );
  testWidgets('command-only chip and per-item overrides', (t) async {
    int clicks = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgChipList(
            items: const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')],
            selectable: false,
            onClick: (_) => clicks++,
            onRemove: (_) {},
            canRemove: (item) => item.value == 'a',
            itemAppearance: (item) => NgChipAppearance(
              size: item.value == 'a' ? 'sm' : 'lg',
              themeColor: 'info',
            ),
            itemBuilder: (item) => Text('Custom ${item.label}'),
          ),
        ),
      ),
    );
    await t.tap(find.text('Custom Beta'));
    await t.pumpAndSettle();
    expect(clicks, 1);
    expect(find.byTooltip('Remove Alpha'), findsOneWidget);
    expect(find.byTooltip('Remove Beta'), findsNothing);
    final chips = t.widgetList<InputChip>(find.byType(InputChip)).toList();
    expect(chips[0].labelStyle!.fontSize, 12);
    expect(chips[1].labelStyle!.fontSize, 16);
  });

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
