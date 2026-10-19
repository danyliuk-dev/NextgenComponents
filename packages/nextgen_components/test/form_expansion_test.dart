import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'Collapsed fields remain validated and keep values on reopening',
    (t) async {
      var expanded = true;
      var saves = 0;
      final focus = FocusNode();
      final controller = TextEditingController(text: 'Draft');
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return NgForm(
                  onValidSubmit: () => saves++,
                  sections: [
                    NgFormSection(
                      id: 'a',
                      title: 'Details',
                      expanded: expanded,
                      onExpandedChanged: (value) =>
                          setState(() => expanded = value),
                      fields: [
                        NgTextBox(
                          label: 'Name',
                          controller: controller,
                          focusNode: focus,
                          validator: (_) => 'Review name',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await t.tap(find.byType(TextFormField));
      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 3,
      );
      await t.pump();
      update(() => expanded = false);
      await t.pumpAndSettle();
      expect(focus.hasFocus, false);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(TextFormField, skipOffstage: false), findsOneWidget);
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 0);
      expect(find.text('• Review name'), findsOneWidget);
      await t.tap(find.text('Details'));
      await t.pumpAndSettle();
      expect(expanded, true);
      expect(controller.text, 'Draft');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 1, extentOffset: 3),
      );
      expect(find.text('Review name'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      focus.dispose();
      controller.dispose();
    },
  );
  testWidgets(
    'Toggle requests are controlled and stale descendant callbacks are guarded',
    (t) async {
      var rootExpanded = true, enabled = true, listen = true;
      var requests = 0;
      var requested = false;
      Widget host() => MaterialApp(
        home: Scaffold(
          body: NgForm(
            enabled: enabled,
            onValidSubmit: () {},
            sections: [
              NgFormSection(
                id: 'parent',
                title: 'Parent',
                expanded: rootExpanded,
                sections: [
                  NgFormSection(
                    id: 'leaf',
                    title: 'Leaf',
                    expanded: true,
                    onExpandedChanged: listen
                        ? (value) {
                            requests++;
                            requested = value;
                          }
                        : null,
                    fields: const [NgTextBox(label: 'Name')],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      VoidCallback callback() =>
          t.widget<TextButton>(find.byType(TextButton)).onPressed!;
      await t.pumpWidget(host());
      final initial = callback();
      initial();
      await t.pump();
      expect(requests, 1);
      expect(requested, false);
      expect(find.byType(TextFormField), findsOneWidget);
      enabled = false;
      await t.pumpWidget(host());
      initial();
      expect(requests, 1);
      enabled = true;
      await t.pumpWidget(host());
      final beforeCollapse = callback();
      rootExpanded = false;
      await t.pumpWidget(host());
      beforeCollapse();
      expect(requests, 1);
      rootExpanded = true;
      await t.pumpWidget(host());
      final beforeRemoval = callback();
      listen = false;
      await t.pumpWidget(host());
      beforeRemoval();
      expect(requests, 1);
      listen = true;
      await t.pumpWidget(host());
      final beforeDispose = callback();
      await t.pumpWidget(const SizedBox());
      beforeDispose();
      expect(requests, 1);
    },
  );
  testWidgets('Busy guard disables disclosures while saving', (t) async {
    // A completer keeps submission pending until the explicit release below.
    final done = Completer<void>();
    var requests = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgForm(
            onValidSubmit: () => done.future,
            sections: [
              NgFormSection(
                id: 'a',
                title: 'Details',
                onExpandedChanged: (_) => requests++,
                fields: const [NgTextBox(label: 'Name')],
              ),
            ],
          ),
        ),
      ),
    );
    final stale = t.widget<TextButton>(find.byType(TextButton)).onPressed!;
    await t.tap(find.text('Save'));
    await t.pump();
    stale();
    expect(requests, 0);
    expect(t.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
    done.complete();
    await t.pumpAndSettle();
    expect(t.widget<TextButton>(find.byType(TextButton)).onPressed, isNotNull);
  });
}
