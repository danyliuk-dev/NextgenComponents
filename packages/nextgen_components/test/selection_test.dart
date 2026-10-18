import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  const items = [
    NgOption('a', 'Alpha'),
    NgOption('b', 'Beta'),
    NgOption('c', 'Locked', disabled: true),
  ];
  test(
    'selection rules preserve inputs and enforce limits and empty choice',
    () {
      final source = ['a'];
      expect(NgSelectionRules.toggle(items, source, 'b', true, true), [
        'a',
        'b',
      ]);
      expect(source, ['a']);
      expect(NgSelectionRules.toggle(items, source, 'b', false, true), ['b']);
      expect(NgSelectionRules.toggle(items, source, 'a', false, false), ['a']);
      expect(NgSelectionRules.toggle(items, source, 'a', false, true), isEmpty);
      expect(NgSelectionRules.toggle(items, source, 'c', true, true), ['a']);
      expect(NgSelectionRules.toggle(items, ['b', 'a'], 'b', true, false), [
        'a',
      ]);
      expect(
        () => NgSelectionRules.toggle(items, source, 'b', true, true).clear(),
        throwsUnsupportedError,
      );
      expect(
        () => NgSelectionRules.validate(items, ['a', 'a'], true),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate(items, ['a', 'b'], false),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate(items, ['missing'], true),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate([items[0], items[0]], [], true),
        throwsArgumentError,
      );
      expect(
        () => NgSelectionRules.validate(
          List.generate(51, (i) => NgOption('n$i', 'Node')),
          [],
          true,
        ),
        throwsArgumentError,
      );
    },
  );
  testWidgets('toggle retains focus, controlled state and disabled behavior', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    bool value = false, disabled = false;
    int changes = 0;
    late StateSetter update;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, set) {
              update = set;
              return NgToggleButton(
                label: 'Border',
                value: value,
                disabled: disabled,
                onChanged: (v) => set(() {
                  value = v;
                  changes++;
                }),
              );
            },
          ),
        ),
      ),
    );
    expect(
      t.getSemantics(find.byType(NgToggleButton)),
      matchesSemantics(
        label: 'Border',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasCheckedState: true,
        isCheckStateMixed: false,
        isChecked: false,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pumpAndSettle();
    expect(value, true);
    expect(changes, 1);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pumpAndSettle();
    expect(value, false);
    expect(changes, 2);
    update(() => disabled = true);
    await t.pumpAndSettle();
    await t.tap(find.text('Border'));
    await t.pump();
    expect(changes, 2);
    update(() => value = true);
    await t.pump();
    expect(t.widget<NgToggleButton>(find.byType(NgToggleButton)).value, true);
    semantics.dispose();
  });
  testWidgets(
    'group emits once, rejects last deselection and supports reset/empty',
    (t) async {
      List<String> value = ['a'];
      bool multiple = false, allowEmpty = false, empty = false;
      int changes = 0;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return NgButtonGroup(
                  items: empty ? [] : items,
                  value: empty ? [] : value,
                  multiple: multiple,
                  allowEmpty: allowEmpty,
                  onChanged: (v) => set(() {
                    value = v;
                    changes++;
                  }),
                );
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Alpha'));
      await t.pump();
      expect(changes, 0);
      await t.tap(find.text('Beta'));
      await t.pump();
      expect(value, ['b']);
      expect(changes, 1);
      await t.tap(find.text('Locked'));
      await t.pump();
      expect(changes, 1);
      update(() => multiple = true);
      await t.pump();
      await t.tap(find.text('Alpha'));
      await t.pump();
      expect(value, ['a', 'b']);
      await t.tap(find.text('Beta'));
      await t.pump();
      expect(value, ['a']);
      update(() => allowEmpty = true);
      await t.pump();
      await t.tap(find.text('Alpha'));
      await t.pump();
      expect(value, isEmpty);
      update(() {
        value = ['b'];
        empty = true;
      });
      await t.pump();
      expect(find.text('No options'), findsOneWidget);
      update(() => empty = false);
      await t.pump();
      expect(
        t
            .widgetList<NgToggleButton>(find.byType(NgToggleButton))
            .where((b) => b.value)
            .single
            .label,
        'Beta',
      );
    },
  );
}
