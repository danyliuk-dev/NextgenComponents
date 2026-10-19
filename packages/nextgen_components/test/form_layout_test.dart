import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget host(Widget child, {double width = 700}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);
void main() {
  testWidgets(
    'Responsive fields retain draft, focus and validation across column changes',
    (t) async {
      final form = GlobalKey<FormState>();
      final focus = FocusNode();
      double width = 700;
      int columns = 2, gap = 16;
      Widget view() => host(
        NgForm(
          formKey: form,
          columns: columns,
          gap: gap,
          onValidSubmit: () {},
          fields: [
            NgTextBox(
              key: const ValueKey('first'),
              label: 'First',
              focusNode: focus,
              validator: (_) => 'Review required',
            ),
            const NgTextBox(key: ValueKey('second'), label: 'Second'),
            const NgTextArea(key: ValueKey('notes'), label: 'Notes', rows: 2),
          ],
        ),
        width: width,
      );
      Finder first() => find.descendant(
        of: find.byKey(const ValueKey('first')),
        matching: find.byType(TextFormField),
      );
      Finder second() => find.descendant(
        of: find.byKey(const ValueKey('second')),
        matching: find.byType(TextFormField),
      );
      await t.pumpWidget(view());
      await t.enterText(first(), 'Draft');
      focus.requestFocus();
      form.currentState!.validate();
      await t.pumpAndSettle();
      expect(t.getTopLeft(first()).dy, t.getTopLeft(second()).dy);
      width = 300;
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(t.getTopLeft(second()).dy, greaterThan(t.getTopLeft(first()).dy));
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Review required'), findsOneWidget);
      expect(focus.hasFocus, true);
      width = 700;
      columns = 1;
      gap = 32;
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(t.getTopLeft(second()).dy, greaterThan(t.getTopLeft(first()).dy));
      columns = 2;
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(t.getTopLeft(first()).dy, t.getTopLeft(second()).dy);
      expect(find.text('Draft'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );
  testWidgets('Keyed fields reorder without swapping their drafts', (t) async {
    final firstKey = GlobalKey();
    bool reverse = false;
    Widget view() {
      final fields = [
        NgTextBox(key: firstKey, label: 'First'),
        const NgTextBox(key: ValueKey('second'), label: 'Second'),
      ];
      return host(
        NgForm(
          onValidSubmit: () {},
          fields: reverse ? fields.reversed.toList() : fields,
          columns: 2,
        ),
      );
    }

    await t.pumpWidget(view());
    await t.enterText(find.byType(TextFormField).first, 'First draft');
    reverse = true;
    await t.pumpWidget(view());
    await t.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(firstKey),
        matching: find.text('First draft'),
      ),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Custom actions validate and recheck retained submit while busy or disabled',
    (t) async {
      final completion = Completer<void>();
      int saves = 0, auxiliary = 0;
      bool enabled = true;
      VoidCallback? retained;
      Widget view() => host(
        NgForm(
          enabled: enabled,
          fields: [
            NgTextBox(
              label: 'Required',
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
            ),
          ],
          onValidSubmit: () {
            saves++;
            return completion.future;
          },
          actionsBuilder: (_, submit) {
            if (submit != null) retained = submit;
            return Wrap(
              children: [
                NgButton(onPressed: submit, child: const Text('Custom save')),
                NgButton(
                  onPressed: () => auxiliary++,
                  child: const Text('Auxiliary'),
                ),
              ],
            );
          },
        ),
      );
      await t.pumpWidget(view());
      await t.tap(find.text('Custom save'));
      await t.pump();
      expect(saves, 0);
      expect(find.text('Required'), findsWidgets);
      await t.enterText(find.byType(TextFormField), 'Ready');
      retained!();
      await t.pump();
      expect(saves, 1);
      retained!();
      await t.pump();
      expect(saves, 1);
      await t.tap(find.text('Auxiliary'), warnIfMissed: false);
      expect(auxiliary, 0);
      expect(find.text('Saving…'), findsOneWidget);
      completion.complete();
      await t.pumpAndSettle();
      enabled = false;
      await t.pumpWidget(view());
      retained!();
      await t.pump();
      expect(saves, 1);
    },
  );
  testWidgets('Field list and layout bounds reject invalid configuration', (
    t,
  ) async {
    for (final widget in [
      NgForm(onValidSubmit: () {}),
      NgForm(
        child: const Text('Legacy'),
        fields: const [],
        onValidSubmit: () {},
      ),
      NgForm(fields: const [], columns: 0, onValidSubmit: () {}),
      NgForm(fields: const [], columns: 5, onValidSubmit: () {}),
      NgForm(fields: const [], minColumnWidth: 119, onValidSubmit: () {}),
      NgForm(fields: const [], gap: 65, onValidSubmit: () {}),
    ]) {
      await t.pumpWidget(host(widget));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
  testWidgets(
    'Empty fields keep actions and a narrow parent does not overflow',
    (t) async {
      await t.pumpWidget(
        host(NgForm(fields: const [], onValidSubmit: () {}), width: 100),
      );
      expect(find.text('Save'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(
        host(
          NgForm(
            fields: const [Text('One'), Text('Two')],
            columns: 4,
            onValidSubmit: () {},
          ),
          width: 100,
        ),
      );
      await t.pumpAndSettle();
      expect(
        t.getTopLeft(find.text('Two')).dy,
        greaterThan(t.getTopLeft(find.text('One')).dy),
      );
      expect(t.takeException(), isNull);
    },
  );
}
