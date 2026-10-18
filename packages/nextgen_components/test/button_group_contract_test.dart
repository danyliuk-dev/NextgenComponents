import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  const items = [
    NgOption('bold', 'Bold'),
    NgOption('italic', 'Italic'),
    NgOption('clear', 'Clear'),
    NgOption('locked', 'Locked', disabled: true),
  ];
  testWidgets(
    'mixed commands preserve selection and ordered toggle callbacks',
    (t) async {
      final handle = t.ensureSemantics();
      var selected = <String>['bold'];
      final events = <String>[];
      var hidden = false, disabled = false;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return NgButtonGroup(
                  items: items,
                  value: selected,
                  multiple: true,
                  allowEmpty: false,
                  isCommand: (i) => i.value == 'clear',
                  isVisible: (i) => !hidden || i.value != 'bold',
                  disabled: disabled,
                  onChanged: (v) => setState(() {
                    selected = v;
                    events.add('changed:${v.join(",")}');
                  }),
                  onClick: (id) => events.add('clicked:$id'),
                  itemBuilder: (i) => Text('Visual ${i.label}'),
                  leadingBuilder: (i) => const Icon(Icons.star),
                );
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Visual Italic'));
      await t.pumpAndSettle();
      expect(events, ['changed:bold,italic', 'clicked:italic']);
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      expect(find.bySemanticsLabel('Italic'), findsWidgets);
      events.clear();
      await t.tap(find.text('Visual Clear'));
      await t.pumpAndSettle();
      expect(selected, ['bold', 'italic']);
      expect(events, ['clicked:clear']);
      events.clear();
      await t.tap(find.text('Visual Locked'));
      await t.pumpAndSettle();
      expect(events, isEmpty);
      update(() => hidden = true);
      await t.pumpAndSettle();
      expect(find.text('Visual Bold'), findsNothing);
      expect(selected, ['bold', 'italic']);
      update(() => hidden = false);
      await t.pumpAndSettle();
      expect(find.text('Visual Bold'), findsOneWidget);
      update(() => disabled = true);
      await t.pumpAndSettle();
      await t.tap(find.text('Visual Clear'));
      expect(events, isEmpty);
      handle.dispose();
    },
  );
  testWidgets('click-only toggles activate without mutating controlled state', (
    t,
  ) async {
    final events = <String>[];
    final focus = FocusNode();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgToggleButton(
            label: 'Flag',
            value: true,
            onClick: () => events.add('click'),
            focusNode: focus,
            tabIndex: -1,
          ),
        ),
      ),
    );
    focus.requestFocus();
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pumpAndSettle();
    expect(events, ['click']);
    expect(t.widget<NgToggleButton>(find.byType(NgToggleButton)).value, isTrue);
    await t.pumpWidget(const SizedBox.shrink());
    focus.dispose();
  });
  testWidgets(
    'forbidden last deselection still emits click; command selection rejected',
    (t) async {
      var changes = 0, clicks = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgButtonGroup(
              items: items,
              value: const ['bold'],
              allowEmpty: false,
              isCommand: (i) => i.value == 'clear',
              onChanged: (_) => changes++,
              onClick: (_) => clicks++,
            ),
          ),
        ),
      );
      await t.tap(find.text('Bold'));
      await t.pumpAndSettle();
      expect(changes, 0);
      expect(clicks, 1);
      await t.pumpWidget(
        MaterialApp(
          home: NgButtonGroup(
            items: items,
            value: const ['clear'],
            isCommand: (i) => i.value == 'clear',
          ),
        ),
      );
      expect(t.takeException(), isArgumentError);
    },
  );
  testWidgets(
    'visibility and metadata do not turn display content into actions',
    (t) async {
      final handle = t.ensureSemantics();
      var changed = false;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgToggleButton(
              label: 'Flag',
              semanticLabel: 'Flag setting',
              semanticIdentifier: 'flag',
              semanticHint: 'Change the flag',
              child: const Text('Custom'),
              leading: const Icon(Icons.flag),
              onChanged: (v) => changed = v,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Flag setting'), findsWidgets);
      expect(
        t
            .getSemantics(find.bySemanticsIdentifier('flag'))
            .getSemanticsData()
            .hint,
        'Change the flag',
      );
      await t.tap(find.text('Custom'));
      expect(changed, isTrue);
      await t.pumpWidget(
        const MaterialApp(home: NgToggleButton(label: 'Flag', visible: false)),
      );
      expect(find.text('Flag'), findsNothing);
      handle.dispose();
    },
  );
  testWidgets('button theme text meets contrast in enabled states', (t) async {
    for (final brightness in Brightness.values) {
      late BuildContext ctx;
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      );
      for (final tone in [
        'base',
        'primary',
        'secondary',
        'tertiary',
        'info',
        'success',
        'warning',
        'error',
        'dark',
        'light',
        'inverse',
      ]) {
        for (final fill in ['solid', 'outline', 'flat', 'link', 'clear']) {
          for (final selected in [false, true]) {
            final style = NgButtonRules.style(
              ctx,
              'md',
              'md',
              fill,
              tone,
              selected,
            );
            final fg = style.foregroundColor!.resolve({})!;
            final raw = style.backgroundColor!.resolve({})!;
            final bg = raw.a == 0 ? Theme.of(ctx).colorScheme.surface : raw;
            final a = fg.computeLuminance(), b = bg.computeLuminance();
            final ratio = ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05);
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$brightness $tone $fill selected=$selected',
            );
          }
        }
      }
    }
  });
}
