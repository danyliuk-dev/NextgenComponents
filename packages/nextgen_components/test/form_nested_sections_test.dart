import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'Nested sibling reorder preserves focus, draft and shared validation',
    (t) async {
      var reverse = false;
      var narrow = false;
      var saves = 0;
      final focus = FocusNode();
      Widget host() {
        final children = [
          NgFormSection(
            id: 'leaf',
            title: 'Draft section',
            fields: [NgTextBox(label: 'Name', focusNode: focus)],
          ),
          const NgFormSection(id: 'empty', title: 'Empty section', fields: []),
        ];
        final roots = [
          NgFormSection(
            id: 'a',
            title: 'First group',
            sections: reverse ? children.reversed.toList() : children,
          ),
          NgFormSection(
            id: 'b',
            title: 'Second group',
            sections: [
              NgFormSection(
                id: 'leaf',
                title: 'Required section',
                fields: [
                  NgTextArea(
                    label: 'Notes',
                    validator: (v) => (v ?? '').isEmpty ? 'Enter notes' : null,
                  ),
                ],
              ),
            ],
          ),
        ];
        return MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: narrow ? 320 : 760,
                child: NgForm(
                  onValidSubmit: () => saves++,
                  sections: reverse ? roots.reversed.toList() : roots,
                ),
              ),
            ),
          ),
        );
      }

      await t.pumpWidget(host());
      expect(find.byType(Form), findsOneWidget);
      await t.enterText(find.byType(TextFormField).first, 'Retained draft');
      await t.ensureVisible(find.text('Save'));
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 0);
      expect(find.text('Enter notes'), findsOneWidget);
      focus.requestFocus();
      await t.pump();
      reverse = true;
      narrow = true;
      await t.pumpWidget(host());
      await t.pumpAndSettle();
      expect(find.text('Retained draft'), findsOneWidget);
      expect(focus.hasFocus, true);
      expect(find.text('Enter notes'), findsOneWidget);
      expect(
        t.getTopLeft(find.text('Second group')).dy,
        lessThan(t.getTopLeft(find.text('First group')).dy),
      );
      expect(
        t.getTopLeft(find.text('Empty section')).dy,
        lessThan(t.getTopLeft(find.text('Draft section')).dy),
      );
      await t.enterText(find.byType(TextFormField).first, 'Complete');
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save'));
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 1);
      await t.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );
  testWidgets(
    'Depth boundary and invalid nested trees are checked before rendering',
    (t) async {
      NgFormSection chain(int count) {
        var node = const NgFormSection(id: 'node', title: 'Level', fields: []);
        for (var i = 1; i < count; i++) {
          node = NgFormSection(id: 'node', title: 'Level', sections: [node]);
        }
        return node;
      }

      Widget host(NgFormSection section) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NgForm(onValidSubmit: () {}, sections: [section]),
          ),
        ),
      );
      await t.pumpWidget(host(chain(8)));
      expect(t.takeException(), isNull);
      expect(find.text('Level'), findsNWidgets(8));
      final cycle = <NgFormSection>[];
      final cyclic = NgFormSection(
        id: 'cycle',
        title: 'Cycle',
        sections: cycle,
      );
      cycle.add(cyclic);
      const leaf = NgFormSection(id: 'same', title: 'Leaf', fields: []);
      for (final invalid in [
        chain(9),
        cyclic,
        const NgFormSection(id: 'empty', title: 'Empty'),
        const NgFormSection(
          id: 'both',
          title: 'Both',
          fields: [],
          sections: [],
        ),
        const NgFormSection(
          id: 'spans',
          title: 'Spans',
          sections: [],
          fieldSpans: [],
        ),
        const NgFormSection(
          id: 'duplicate',
          title: 'Duplicate',
          sections: [leaf, leaf],
        ),
        const NgFormSection(
          id: 'parent',
          title: 'Parent',
          sections: [NgFormSection(id: 'bad', title: ' ', fields: [])],
        ),
      ]) {
        await t.pumpWidget(host(invalid));
        expect(t.takeException(), isArgumentError);
        await t.pumpWidget(const SizedBox());
      }
    },
  );
  testWidgets('Disabled guard covers all descendants', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgForm(
            enabled: false,
            onValidSubmit: () {},
            sections: const [
              NgFormSection(
                id: 'root',
                title: 'Root',
                sections: [
                  NgFormSection(
                    id: 'leaf',
                    title: 'Leaf',
                    fields: [NgTextBox(label: 'Name')],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(
      t
          .widget<AbsorbPointer>(find.byKey(const ValueKey('ng-form-content')))
          .absorbing,
      true,
    );
    expect(t.widget<NgButton>(find.byType(NgButton)).onPressed, isNull);
  });
}
