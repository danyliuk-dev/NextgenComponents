import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'Section reorder and responsive layout retain state and share validation',
    (t) async {
      var reverse = false;
      var width = 760.0;
      var columns = 2;
      var saves = 0;
      final focus = FocusNode();
      Widget host() => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: width,
                child: NgForm(
                  onValidSubmit: () => saves++,
                  sections: (reverse ? [1, 0] : [0, 1])
                      .map(
                        (i) => i == 0
                            ? NgFormSection(
                                id: 'identity',
                                title: 'Identity',
                                description: 'Required fields',
                                columns: columns,
                                fields: [
                                  NgTextBox(
                                    label: 'Name',
                                    focusNode: focus,
                                    validator: (v) =>
                                        (v ?? '').isEmpty ? 'Enter name' : null,
                                  ),
                                  const NgTextBox(label: 'Owner'),
                                ],
                              )
                            : NgFormSection(
                                id: 'notes',
                                title: 'Notes section',
                                columns: 2,
                                fieldSpans: [0],
                                fields: [
                                  NgTextArea(
                                    label: 'Notes',
                                    validator: (v) => (v ?? '').isEmpty
                                        ? 'Enter notes'
                                        : null,
                                  ),
                                ],
                              ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpWidget(host());
      expect(find.byType(Form), findsOneWidget);
      await t.enterText(find.byType(TextFormField).at(0), 'Draft');
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 0);
      expect(find.text('Enter notes'), findsOneWidget);
      focus.requestFocus();
      await t.pump();
      reverse = true;
      width = 320;
      columns = 3;
      await t.pumpWidget(host());
      await t.pumpAndSettle();
      expect(find.text('Draft'), findsOneWidget);
      expect(focus.hasFocus, true);
      expect(find.text('Enter notes'), findsOneWidget);
      final boxes = find.byType(NgTextBox);
      expect(
        t.getTopLeft(boxes.at(1)).dy,
        greaterThan(t.getTopLeft(boxes.at(0)).dy),
      );
      await t.enterText(find.byType(TextFormField).first, 'Delivery');
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save'));
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 1);
      expect(find.text('Enter notes'), findsNothing);
      await t.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );
  testWidgets(
    'Section headings and descriptions are plain text; disabled guards all fields',
    (t) async {
      var saves = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgForm(
              enabled: false,
              onValidSubmit: () => saves++,
              sections: const [
                NgFormSection(
                  id: 'a',
                  title: '<b>Identity</b>',
                  description: 'Description',
                  fields: [NgTextBox(label: 'Name')],
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('<b>Identity</b>'), findsOneWidget);
      expect(
        t
            .widget<Semantics>(
              find
                  .ancestor(
                    of: find.text('<b>Identity</b>'),
                    matching: find.byType(Semantics),
                  )
                  .first,
            )
            .properties
            .header,
        true,
      );
      expect(
        t
            .widget<AbsorbPointer>(
              find.byKey(const ValueKey('ng-form-content')),
            )
            .absorbing,
        true,
      );
      expect(t.widget<NgButton>(find.byType(NgButton)).onPressed, isNull);
      expect(saves, 0);
    },
  );
  testWidgets('Invalid sections and mixed content are rejected', (t) async {
    const valid = NgFormSection(id: 'a', title: 'A', fields: []);
    final forms = [
      NgForm(onValidSubmit: () {}, fields: const [], sections: const [valid]),
      NgForm(
        onValidSubmit: () {},
        child: const Text('Legacy'),
        sections: const [valid],
      ),
      NgForm(
        onValidSubmit: () {},
        fieldSpans: const [],
        sections: const [valid],
      ),
      for (final sections in <List<NgFormSection>>[
        [valid, valid],
        [const NgFormSection(id: ' ', title: 'A', fields: [])],
        [const NgFormSection(id: 'a', title: ' ', fields: [])],
        [const NgFormSection(id: 'a', title: 'A', fields: [], columns: 5)],
        [
          const NgFormSection(
            id: 'a',
            title: 'A',
            fields: [],
            minColumnWidth: 119,
          ),
        ],
        [const NgFormSection(id: 'a', title: 'A', fields: [], gap: 65)],
        [
          const NgFormSection(id: 'a', title: 'A', fields: [], fieldSpans: [1]),
        ],
        [
          const NgFormSection(
            id: 'a',
            title: 'A',
            fields: [Text('x')],
            fieldSpans: [5],
          ),
        ],
      ])
        NgForm(onValidSubmit: () {}, sections: sections),
    ];
    for (final form in forms) {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: form)));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
}
