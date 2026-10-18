import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test('hidden ancestors and separators never invoke', () {
    expect(
      NgNavigationRules.canInvoke([
        NgMenuItem('a', 'A', visible: false, children: [NgMenuItem('b', 'B')]),
      ], 'b'),
      false,
    );
    expect(
      NgNavigationRules.canInvoke([
        NgMenuItem('s', 'Section', separator: true),
      ], 's'),
      false,
    );
    expect(
      () => NgNavigationRules.validateMenu([
        NgMenuItem(
          's',
          'Section',
          separator: true,
          children: [NgMenuItem('b', 'B')],
        ),
      ]),
      throwsArgumentError,
    );
    expect(
      () => NgNavigationRules.validatePresentation(' '),
      throwsArgumentError,
    );
    expect(
      () => NgNavigationRules.validatePresentation('Nav', 'left'),
      throwsArgumentError,
    );
  });
  testWidgets('menu keeps custom names, hidden entries and keep-open actions', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    var invoked = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgMenu(
            rtl: true,
            closeOnClick: false,
            items: [
              NgMenuItem(
                'file',
                'File',
                children: [
                  NgMenuItem('hidden', 'Hidden', visible: false),
                  NgMenuItem('s', 'Section', separator: true),
                  NgMenuItem('run', 'Run'),
                  NgMenuItem('locked', 'Locked', disabled: true),
                ],
              ),
            ],
            itemBuilder: (_, i) => Text('Custom ${i.text}'),
            leadingBuilder: (_, i) => const Icon(Icons.star),
            onInvoke: (_) => invoked++,
          ),
        ),
      ),
    );
    await t.tap(find.text('Custom File'));
    await t.pumpAndSettle();
    expect(find.text('Custom Hidden'), findsNothing);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.bySemanticsLabel('Run'), findsOneWidget);
    await t.tap(find.text('Custom Run'));
    await t.pumpAndSettle();
    expect(invoked, 1);
    expect(find.text('Custom Run'), findsOneWidget);
    expect(
      t
          .widget<MenuItemButton>(
            find.widgetWithText(MenuItemButton, 'Custom Locked'),
          )
          .onPressed,
      isNull,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('Custom Run'), findsNothing);
    semantics.dispose();
  });
  testWidgets(
    'drawer end follows RTL, selection can keep overlay open and disabled still dismisses',
    (t) async {
      bool expanded = true, rtl = false, disabled = false;
      String? chosen;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return NgDrawer(
                  label: 'Test navigation',
                  items: const [
                    NgOption('one', 'One'),
                    NgOption('hidden', 'Hidden'),
                    NgOption('sep', 'Section'),
                    NgOption('two', 'Two'),
                  ],
                  expanded: expanded,
                  onExpandedChanged: (v) => set(() => expanded = v),
                  onSelectedIdChanged: (v) => set(() => chosen = v),
                  selectedId: chosen,
                  position: 'end',
                  rtl: rtl,
                  disabled: disabled,
                  closeOnSelect: false,
                  isVisible: (i) => i.value != 'hidden',
                  isSeparator: (i) => i.value == 'sep',
                  header: const Text('Workspace'),
                  footer: const Text('Signed in'),
                  leadingBuilder: (_, i) => const Icon(Icons.star),
                  itemBuilder: (_, i) => Text('Custom ${i.label}'),
                  child: const Text('Draft'),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Hidden'), findsNothing);
      expect(find.text('Custom Section'), findsNothing);
      expect(find.text('Signed in'), findsOneWidget);
      expect(t.getCenter(find.text('Workspace')).dx, greaterThan(400));
      await t.tap(find.text('Custom Two'));
      await t.pumpAndSettle();
      expect(chosen, 'two');
      expect(expanded, true);
      update(() {
        rtl = true;
        disabled = true;
      });
      await t.pumpAndSettle();
      expect(t.getCenter(find.text('Workspace')).dx, lessThan(400));
      expect(
        t.widget<ListTile>(find.widgetWithText(ListTile, 'Custom One')).enabled,
        false,
      );
      await t.tap(find.byTooltip('Close navigation'));
      await t.pumpAndSettle();
      expect(expanded, false);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('drawer without selection handler has no active destinations', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgDrawer(
            items: const [NgOption('a', 'Alpha')],
            expanded: true,
            overlay: false,
            child: const Text('Page'),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.widget<ListTile>(find.byType(ListTile)).enabled, false);
  });
}
