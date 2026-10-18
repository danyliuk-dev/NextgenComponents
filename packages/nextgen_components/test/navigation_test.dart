import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test(
    'navigation contracts reject ambiguous IDs and unreachable commands',
    () {
      final children = [NgMenuItem('leaf', 'Leaf')];
      final group = NgMenuItem('group', 'Group', children: children);
      children.clear();
      expect(group.children.length, 1);
      expect(() => group.children.clear(), throwsUnsupportedError);
      NgNavigationRules.validateMenu([group]);
      expect(NgNavigationRules.canInvoke([group], 'leaf'), true);
      expect(NgNavigationRules.canInvoke([group], 'group'), false);
      expect(
        NgNavigationRules.canInvoke([
          NgMenuItem('disabled', 'Disabled', disabled: true, children: [group]),
        ], 'leaf'),
        false,
      );
      expect(
        () => NgNavigationRules.validateMenu([
          group,
          NgMenuItem('leaf', 'Duplicate'),
        ]),
        throwsArgumentError,
      );
      expect(
        () => NgNavigationRules.validateMenu([
          NgMenuItem(
            'a',
            'A',
            children: [
              NgMenuItem('b', 'B', children: [group]),
            ],
          ),
        ]),
        throwsArgumentError,
      );
      expect(
        () => NgNavigationRules.validateMenu(
          List.generate(101, (i) => NgMenuItem('n$i', 'Node')),
        ),
        throwsArgumentError,
      );
      expect(
        () => NgNavigationRules.validateDrawer([
          const NgOption('a', 'A'),
          const NgOption('a', 'Duplicate'),
        ], 260),
        throwsArgumentError,
      );
      expect(
        () => NgNavigationRules.validateDrawer([], 199),
        throwsArgumentError,
      );
    },
  );
  testWidgets('nested menu invokes only the enabled leaf and closes', (
    t,
  ) async {
    String? result;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgMenu(
            items: [
              NgMenuItem(
                'file',
                'File',
                children: [
                  NgMenuItem(
                    'export',
                    'Export',
                    children: [NgMenuItem('pdf', 'PDF')],
                  ),
                  NgMenuItem('delete', 'Delete', disabled: true),
                ],
              ),
            ],
            onInvoke: (id) => result = id,
          ),
        ),
      ),
    );
    await t.tap(find.text('File'));
    await t.pumpAndSettle();
    expect(
      t
          .widget<MenuItemButton>(find.widgetWithText(MenuItemButton, 'Delete'))
          .onPressed,
      isNull,
    );
    await t.tap(find.text('Export'));
    await t.pumpAndSettle();
    await t.tap(find.text('PDF'));
    await t.pumpAndSettle();
    expect(result, 'pdf');
    expect(find.text('PDF'), findsNothing);
  });
  testWidgets(
    'drawer selection, escape, push mode and teardown own only their route',
    (t) async {
      bool expanded = false, overlay = true, present = true;
      String selected = 'overview';
      late StateSetter update;
      final nav = GlobalKey<NavigatorState>();
      await t.pumpWidget(
        MaterialApp(
          navigatorKey: nav,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return present
                    ? NgDrawer(
                        items: const [
                          NgOption('overview', 'Overview'),
                          NgOption('reports', 'Reports'),
                          NgOption('locked', 'Locked', disabled: true),
                        ],
                        selectedId: selected,
                        expanded: expanded,
                        overlay: overlay,
                        onExpandedChanged: (v) => set(() => expanded = v),
                        onSelectedIdChanged: (v) => set(() => selected = v),
                        child: const Text('Workspace'),
                      )
                    : const Text('Removed');
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Open navigation'));
      await t.pumpAndSettle();
      expect(expanded, true);
      expect(
        t.widget<ListTile>(find.widgetWithText(ListTile, 'Locked')).enabled,
        false,
      );
      await t.tap(find.text('Reports'));
      await t.pumpAndSettle();
      expect(selected, 'reports');
      expect(expanded, false);
      expect(find.text('Reports'), findsNothing);
      await t.tap(find.text('Open navigation'));
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(expanded, false);
      update(() => expanded = true);
      await t.pumpAndSettle();
      await t.tapAt(const Offset(700, 300));
      await t.pumpAndSettle();
      expect(expanded, false);
      update(() {
        overlay = false;
        expanded = true;
      });
      await t.pumpAndSettle();
      await t.tap(find.text('Overview'));
      await t.pumpAndSettle();
      expect(expanded, true);
      expect(selected, 'overview');
      update(() => overlay = true);
      await t.pumpAndSettle();
      nav.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Unrelated route')),
        ),
      );
      await t.pumpAndSettle();
      update(() => present = false);
      await t.pumpAndSettle();
      expect(find.text('Unrelated route'), findsOneWidget);
      nav.currentState!.pop();
      await t.pumpAndSettle();
      expect(find.text('Removed'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}
