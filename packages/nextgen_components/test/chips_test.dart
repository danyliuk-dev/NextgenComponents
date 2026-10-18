import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test(
    'uncapped selection validates large collections without weakening ID rules',
    () {
      final items = List.generate(
        5000,
        (i) => NgOption('tag$i', 'Topic $i', disabled: i == 4999),
      );
      final selected = items.take(4999).map((x) => x.value).toList();
      NgSelectionRules.validate(items, selected, true, maxItems: null);
      expect(
        NgSelectionRules.toggle(
          items,
          selected,
          'tag4998',
          true,
          true,
          maxItems: null,
        ).length,
        4998,
      );
      expect(
        NgSelectionRules.toggle(
          items,
          selected,
          'tag4999',
          true,
          true,
          maxItems: null,
        ),
        selected,
      );
      expect(
        () => NgSelectionRules.validate(items, [], true),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate(
          [...items, items.first],
          [],
          true,
          maxItems: null,
        ),
        throwsArgumentError,
      );
      expect(
        () =>
            NgSelectionRules.validate(items, ['missing'], true, maxItems: null),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate(
          items,
          ['tag0', 'tag0'],
          true,
          maxItems: null,
        ),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate(
          [const NgOption('bad id', 'Topic')],
          [],
          true,
          maxItems: null,
        ),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    '500 chips retain End Home selection removal and scroll into view',
    (t) async {
      var items = List.generate(
        500,
        (i) => NgOption('tag$i', 'Topic $i', disabled: i == 499),
      );
      var selected = <String>[];
      final controller = NgChipListController();
      final scroll = ScrollController();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scroll,
              child: StatefulBuilder(
                builder: (context, update) => NgChipList(
                  items: items,
                  value: selected,
                  multiple: true,
                  focusController: controller,
                  onChanged: (v) => update(() => selected = v),
                  onRemove: (id) => update(() {
                    items = items.where((x) => x.value != id).toList();
                    selected = selected.where((x) => x != id).toList();
                  }),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(NgChip), findsNWidgets(500));
      expect(controller.focus(), isTrue);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.end);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip tag498');
      expect(scroll.offset, greaterThan(0));
      final last = t.getRect(find.text('Topic 498'));
      expect(last.top, greaterThanOrEqualTo(0));
      expect(last.bottom, lessThanOrEqualTo(600));
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect(selected, ['tag498']);
      await t.sendKeyEvent(LogicalKeyboardKey.delete);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip tag497');
      expect(selected, isEmpty);
      expect(items.length, 499);
      await t.sendKeyEvent(LogicalKeyboardKey.home);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip tag0');
      expect(t.getRect(find.text('Topic 0')).top, greaterThanOrEqualTo(0));
      expect(scroll.offset, lessThan(20));
      await t.pumpWidget(const SizedBox());
      controller.dispose();
      scroll.dispose();
    },
  );

  testWidgets(
    'public focus controller targets IDs, swaps and detaches safely',
    (t) async {
      final first = NgChipListController();
      final second = NgChipListController();
      expect(first.isAttached, isFalse);
      expect(first.focus(), isFalse);
      var controller = first;
      var items = const [
        NgOption('a', 'Alpha'),
        NgOption('b', 'Beta'),
        NgOption('locked', 'Locked', disabled: true),
      ];
      late StateSetter update;
      var changes = 0;
      await t.pumpWidget(
        MaterialApp(
          builder: (context, child) => Material(child: child),
          home: StatefulBuilder(
            builder: (context, set) {
              update = set;
              return NgChipList(
                focusController: controller,
                items: items,
                onChanged: (_) => changes++,
              );
            },
          ),
        ),
      );
      expect(first.isAttached, isTrue);
      expect(first.focus(itemId: 'b'), isTrue);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
      expect(first.focus(itemId: 'locked'), isFalse);
      expect(first.focus(itemId: 'missing'), isFalse);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
      expect(changes, 0);
      update(() => controller = second);
      await t.pumpAndSettle();
      expect(first.isAttached, isFalse);
      expect(first.focus(), isFalse);
      expect(second.focus(), isTrue);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip a');
      update(() => items = []);
      await t.pumpAndSettle();
      expect(second.focus(), isTrue);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Empty chip list');
      final outline = t
          .widgetList<Container>(
            find.descendant(
              of: find.byType(NgChipList),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      final border = (outline.decoration! as BoxDecoration).border! as Border;
      expect(border.top.color.a, greaterThan(0));
      await t.pumpWidget(const SizedBox());
      expect(second.isAttached, isFalse);
      expect(second.focus(), isFalse);
      first.dispose();
      second.dispose();
      expect(second.focus(), isFalse);
    },
  );

  testWidgets(
    'controller cannot attach to two lists or be reused after disposal',
    (t) async {
      final controller = NgChipListController();
      await t.pumpWidget(
        MaterialApp(
          builder: (context, child) => Material(child: child),
          home: Column(
            children: [
              Expanded(
                child: NgChipList(items: const [], focusController: controller),
              ),
              Expanded(
                child: NgChipList(items: const [], focusController: controller),
              ),
            ],
          ),
        ),
      );
      expect(t.takeException(), isStateError);
      await t.pumpWidget(const SizedBox());
      controller.dispose();
      await t.pumpWidget(
        MaterialApp(
          builder: (context, child) => Material(child: child),
          home: NgChipList(items: const [], focusController: controller),
        ),
      );
      expect(t.takeException(), isStateError);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets('custom remove labels and empty text follow parent updates', (
    t,
  ) async {
    var custom = false;
    var items = const [NgOption('a', 'Alpha')];
    late StateSetter update;
    var removals = 0;
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => Material(child: child),
        home: StatefulBuilder(
          builder: (context, set) {
            update = set;
            return NgChipList(
              items: items,
              emptyText: 'No topics available',
              removeLabelBuilder: custom
                  ? (item) => 'Dismiss ${item.label}'
                  : null,
              onRemove: (_) => removals++,
            );
          },
        ),
      ),
    );
    expect(find.byTooltip('Remove Alpha'), findsOneWidget);
    update(() => custom = true);
    await t.pumpAndSettle();
    expect(find.byTooltip('Remove Alpha'), findsNothing);
    await t.tap(find.byTooltip('Dismiss Alpha'));
    await t.pumpAndSettle();
    expect(removals, 1);
    expect(
      find.text('Alpha'),
      findsOneWidget,
    ); // Request was rejected by parent.
    update(() => items = []);
    await t.pumpAndSettle();
    expect(find.text('No topics available'), findsOneWidget);
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => Material(child: child),
        home: NgChip(label: 'Alpha', removeLabel: ' '),
      ),
    );
    expect(t.takeException(), isArgumentError);
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => Material(child: child),
        home: NgChipList(items: [], emptyText: ' '),
      ),
    );
    expect(t.takeException(), isArgumentError);
  });

  testWidgets(
    'Tab enters selected chip, exits list and returns to remembered chip',
    (t) async {
      final before = FocusNode(debugLabel: 'Before');
      final after = FocusNode(debugLabel: 'After');
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextButton(
                  focusNode: before,
                  onPressed: () {},
                  child: const Text('Before'),
                ),
                NgChipList(
                  items: const [
                    NgOption('a', 'Alpha'),
                    NgOption('b', 'Beta'),
                    NgOption('c', 'Gamma'),
                  ],
                  value: const ['b'],
                  onChanged: (_) {},
                  onRemove: (_) {},
                ),
                TextButton(
                  focusNode: after,
                  onPressed: () {},
                  child: const Text('After'),
                ),
              ],
            ),
          ),
        ),
      );
      before.requestFocus();
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(after.hasFocus, isTrue);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(before.hasFocus, isTrue);
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await t.pumpWidget(const SizedBox());
      before.dispose();
      after.dispose();
    },
  );

  testWidgets('semantic activation callback also establishes keyboard focus', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgChipList(
            items: const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    // Web semantics can invoke the action without a raw pointer-down event.
    t.widget<NgChip>(find.byType(NgChip).first).onChanged!(true);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip a');
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
  });

  testWidgets(
    'arrows skip disabled, deletion moves next then previous then empty',
    (t) async {
      var items = const [
        NgOption('a', 'Alpha'),
        NgOption('locked', 'Locked', disabled: true),
        NgOption('b', 'Beta'),
        NgOption('c', 'Gamma'),
      ];
      var value = <String>[];
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => NgChipList(
                items: items,
                value: value,
                multiple: true,
                onChanged: (v) => update(() => value = v),
                onRemove: (id) => update(() {
                  items = items.where((x) => x.value != id).toList();
                  value = value.where((x) => x != id).toList();
                }),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Alpha'));
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
      await t.sendKeyEvent(LogicalKeyboardKey.delete);
      await t.pumpAndSettle();
      expect(find.text('Beta'), findsNothing);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.sendKeyEvent(LogicalKeyboardKey.backspace);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip a');
      await t.sendKeyEvent(LogicalKeyboardKey.delete);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Empty chip list');
    },
  );
  testWidgets(
    'rejected removal retains focus; delayed removal never steals outside focus',
    (t) async {
      var items = const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')];
      late StateSetter update;
      var requests = 0;
      final outside = FocusNode(debugLabel: 'Outside');
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return Column(
                  children: [
                    NgChipList(
                      items: items,
                      onChanged: (_) {},
                      onRemove: (_) => requests++,
                    ),
                    TextButton(
                      focusNode: outside,
                      onPressed: () {},
                      child: const Text('After'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Alpha'));
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.delete);
      await t.pumpAndSettle();
      expect(requests, 1);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip a');
      outside.requestFocus();
      await t.pumpAndSettle();
      update(() => items = items.skip(1).toList());
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, outside);
      await t.pumpWidget(const SizedBox());
      outside.dispose();
    },
  );
  testWidgets('Home End and RTL arrows focus without changing selection', (
    t,
  ) async {
    var changes = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: NgChipList(
              items: const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')],
              onChanged: (_) => changes++,
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Alpha'));
    await t.pumpAndSettle();
    expect(changes, 1);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
    expect(changes, 1);
    await t.sendKeyEvent(LogicalKeyboardKey.home);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip a');
    await t.sendKeyEvent(LogicalKeyboardKey.end);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip b');
  });

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
