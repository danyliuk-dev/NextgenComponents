import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'Spans preserve order, draft, focus and validation across responsive widths',
    (t) async {
      final form = GlobalKey<FormState>();
      final focus = FocusNode();
      double width = 700.5;
      var spans = [2, 1, 0, 1];
      Widget view() => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: NgForm(
                  formKey: form,
                  columns: 3,
                  minColumnWidth: 200,
                  fieldSpans: spans,
                  onValidSubmit: () {},
                  fields: [
                    NgTextBox(
                      key: const ValueKey('first'),
                      label: 'First',
                      focusNode: focus,
                      validator: (_) => 'Review first',
                    ),
                    const NgTextBox(key: ValueKey('second'), label: 'Second'),
                    const NgTextArea(key: ValueKey('notes'), rows: 2),
                    const NgTextBox(key: ValueKey('last'), label: 'Last'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextFormField),
      );
      await t.pumpWidget(view());
      await t.enterText(field('first'), 'Draft');
      form.currentState!.validate();
      focus.requestFocus();
      await t.pumpAndSettle();
      expect(t.getTopLeft(field('first')).dy, t.getTopLeft(field('second')).dy);
      expect(
        t.getSize(field('first')).width,
        greaterThan(t.getSize(field('second')).width * 1.9),
      );
      expect(t.getSize(field('notes')).width, closeTo(width, .01));
      expect(
        t.getTopLeft(field('last')).dy,
        greaterThan(t.getTopLeft(field('notes')).dy),
      );
      width = 280;
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(t.getSize(field('first')).width, closeTo(width, .01));
      expect(
        t.getTopLeft(field('second')).dy,
        greaterThan(t.getTopLeft(field('first')).dy),
      );
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Review first'), findsOneWidget);
      expect(focus.hasFocus, true);
      width = 1000;
      spans = [1, 1, 1, 1];
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(t.getTopLeft(field('notes')).dy, t.getTopLeft(field('first')).dy);
      expect(find.text('Draft'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );
  testWidgets(
    'Oversized spans clamp and full rows start after previous fields',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              child: NgForm(
                columns: 2,
                fieldSpans: const [1, 4, 0],
                onValidSubmit: () {},
                fields: const [Text('First'), Text('Wide'), Text('Full')],
              ),
            ),
          ),
        ),
      );
      final wide = find.text('Wide'), full = find.text('Full');
      expect(
        t.getTopLeft(wide).dy,
        greaterThan(t.getTopLeft(find.text('First')).dy),
      );
      expect(t.getSize(wide).width, 600);
      expect(t.getSize(full).width, 600);
      expect(t.getTopLeft(full).dy, greaterThan(t.getTopLeft(wide).dy));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Invalid spans fail explicitly', (t) async {
    for (final spans in [
      <int>[],
      [-1],
      [5],
      [1, 1],
    ]) {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgForm(
              fields: const [Text('Field')],
              fieldSpans: spans,
              onValidSubmit: () {},
            ),
          ),
        ),
      );
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgForm(
            child: const Text('Legacy'),
            fieldSpans: const [1],
            onValidSubmit: () {},
          ),
        ),
      ),
    );
    expect(t.takeException(), isArgumentError);
  });
}
