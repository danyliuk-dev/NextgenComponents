import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'skipped list retains application focus, selection and dynamic gap',
    (t) async {
      final before = FocusNode(), after = FocusNode();
      final controller = NgChipListController();
      var skip = true, gap = 'sm';
      var selected = <String>[];
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return Column(
                  children: [
                    TextButton(
                      focusNode: before,
                      onPressed: () {},
                      child: const Text('Before'),
                    ),
                    NgChipList(
                      gap: gap,
                      tabIndex: skip ? -1 : 0,
                      focusController: controller,
                      items: const [
                        NgOption('a', 'Alpha'),
                        NgOption('b', 'Beta', disabled: true),
                        NgOption('c', 'Gamma'),
                      ],
                      value: selected,
                      onChanged: (v) => setState(() => selected = v),
                    ),
                    TextButton(
                      focusNode: after,
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
      final wrap = find.descendant(
        of: find.byType(NgChipList),
        matching: find.byType(Wrap),
      );
      expect(t.widget<Wrap>(wrap).spacing, 4);
      expect(t.widget<Wrap>(wrap).runSpacing, 4);
      before.requestFocus();
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(after.hasFocus, isTrue);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(before.hasFocus, isTrue);
      expect(controller.focus(), isTrue);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip a');
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect(selected, ['c']);
      update(() {
        skip = false;
        gap = 'lg';
      });
      await t.pumpAndSettle();
      expect(t.widget<Wrap>(wrap).spacing, 12);
      expect(t.widget<Wrap>(wrap).runSpacing, 12);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(after.hasFocus, isTrue);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.pumpWidget(const SizedBox());
      controller.dispose();
      before.dispose();
      after.dispose();
    },
  );
  testWidgets('standalone skipped chip stays clickable and removable', (
    t,
  ) async {
    final before = FocusNode(), after = FocusNode();
    var clicked = 0, removed = 0;
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
              NgChip(
                label: 'Alpha',
                tabIndex: -1,
                selectable: false,
                onClick: () => clicked++,
                onRemove: () => removed++,
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
    expect(after.hasFocus, isTrue);
    await t.tap(find.text('Alpha'));
    await t.pumpAndSettle();
    expect(clicked, 1);
    await t.tap(find.byTooltip('Remove Alpha'));
    await t.pumpAndSettle();
    expect(removed, 1);
    await t.pumpWidget(const SizedBox());
    before.dispose();
    after.dispose();
  });
  testWidgets('empty and fully disabled lists do not create a Tab stop', (
    t,
  ) async {
    for (final items in <List<NgOption>>[
      [],
      [const NgOption('a', 'Alpha', disabled: true)],
    ]) {
      final before = FocusNode(), after = FocusNode();
      final controller = NgChipListController();
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
                  items: items,
                  onChanged: (_) {},
                  focusController: controller,
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
      expect(after.hasFocus, isTrue);
      expect(controller.focus(), isTrue);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Empty chip list');
      await t.pumpWidget(const SizedBox());
      before.dispose();
      after.dispose();
      controller.dispose();
    }
  });
  test('gap and traversal settings reject unsupported values', () {
    expect(NgChipRules.gapPixels('md'), 8);
    expect(() => NgChipRules.gapPixels('xl'), throwsArgumentError);
    expect(() => NgChipRules.validateTabIndex(1), throwsArgumentError);
    expect(() => NgChipRules.validateTabIndex(-2), throwsArgumentError);
  });
}
