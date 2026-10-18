import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'accessible chip name updates independently of text and removal',
    (t) async {
      final handle = t.ensureSemantics();
      String? name = 'CI — Continuous integration';
      var selected = false, removed = false;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return NgChip(
                  label: 'CI',
                  semanticLabel: name,
                  value: selected,
                  onChanged: (v) => setState(() => selected = v),
                  onRemove: () => removed = true,
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('CI'), findsOneWidget);
      expect(find.text('CI — Continuous integration'), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp('CI — Continuous integration')),
        findsWidgets,
      );
      await t.tap(find.text('CI'));
      await t.pumpAndSettle();
      expect(selected, isTrue);
      update(() => name = 'CI — Build completed');
      await t.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('CI — Build completed')),
        findsWidgets,
      );
      expect(selected, isTrue);
      expect(find.byTooltip('Remove CI'), findsOneWidget);
      await t.tap(find.byTooltip('Remove CI'));
      await t.pumpAndSettle();
      expect(removed, isTrue);
      expect(selected, isTrue);
      update(() => name = null);
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('^CI')), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('Build completed')), findsNothing);
      handle.dispose();
    },
  );
  testWidgets(
    'static, command and disabled chips retain accessible name override',
    (t) async {
      final handle = t.ensureSemantics();
      for (final mode in ['static', 'command', 'disabled']) {
        var clicked = false;
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NgChip(
                label: 'CI',
                semanticLabel: 'CI status',
                selectable: false,
                disabled: mode == 'disabled',
                onClick: mode == 'static' ? null : () => clicked = true,
              ),
            ),
          ),
        );
        expect(find.bySemanticsLabel('CI status'), findsWidgets);
        await t.tap(find.text('CI'));
        await t.pumpAndSettle();
        expect(clicked, mode == 'command');
      }
      handle.dispose();
    },
  );
  testWidgets('blank accessible chip name is rejected', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: NgChip(label: 'CI', semanticLabel: '  '),
      ),
    );
    expect(t.takeException(), isArgumentError);
  });

  testWidgets('list identity and hint update without replacing named actions', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    var updated = false;
    late StateSetter update;
    var selected = <String>[];
    var removed = '';
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return NgChipList(
                semanticIdentifier: 'topics',
                semanticHint: updated ? 'New help' : 'Choose topics',
                label: updated ? 'Assigned topics' : 'Topics',
                items: const [NgOption('a', 'Alpha')],
                value: selected,
                onChanged: (v) => setState(() => selected = v),
                onRemove: (id) => removed = id,
              );
            },
          ),
        ),
      ),
    );
    var node = t.getSemantics(find.bySemanticsIdentifier('topics'));
    expect(node.getSemanticsData().hint, 'Choose topics');
    expect(node.getSemanticsData().label, 'Topics');
    await t.tap(find.text('Alpha'));
    await t.pumpAndSettle();
    expect(selected, ['a']);
    update(() => updated = true);
    await t.pumpAndSettle();
    node = t.getSemantics(find.bySemanticsIdentifier('topics'));
    expect(node.getSemanticsData().hint, 'New help');
    expect(node.getSemanticsData().label, 'Assigned topics');
    expect(selected, ['a']);
    await t.tap(find.byTooltip('Remove Alpha'));
    await t.pumpAndSettle();
    expect(removed, 'a');
    handle.dispose();
  });
  testWidgets('standalone metadata preserves selection and separate removal', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    var changed = false;
    var removed = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgChip(
            label: 'Alpha',
            semanticIdentifier: 'alpha-chip',
            semanticHint: 'Select this topic',
            onChanged: (v) => changed = v,
            onRemove: () => removed = true,
          ),
        ),
      ),
    );
    final node = t.getSemantics(find.bySemanticsIdentifier('alpha-chip'));
    expect(node.getSemanticsData().hint, 'Select this topic');
    expect(find.bySemanticsLabel('Alpha'), findsWidgets);
    await t.tap(find.text('Alpha'));
    await t.pumpAndSettle();
    expect(changed, isTrue);
    expect(removed, isFalse);
    await t.tap(find.byTooltip('Remove Alpha'));
    await t.pumpAndSettle();
    expect(removed, isTrue);
    handle.dispose();
  });
  test('semantic metadata rejects blank values', () {
    expect(() => NgChipRules.validateSemantics(' ', null), throwsArgumentError);
    expect(() => NgChipRules.validateSemantics(null, ' '), throwsArgumentError);
    NgChipRules.validateSemantics(null, null);
  });
}
