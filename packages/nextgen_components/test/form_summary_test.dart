import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  testWidgets(
    'Summary snapshots update, stay immutable and hide without disabling validation',
    (t) async {
      bool show = true, custom = true;
      int saves = 0, invalid = 0;
      List<String>? snapshot;
      Widget view() => host(
        NgForm(
          showSummary: show,
          summaryTitle: 'Review the draft',
          summaryBuilder: custom
              ? (_, errors) {
                  snapshot = errors;
                  return Text('Issues: ${errors.join(" | ")}');
                }
              : null,
          onValidSubmit: () => saves++,
          onInvalidSubmit: () => invalid++,
          fields: [
            NgTextBox(
              label: 'Name',
              validator: (v) => (v ?? '').isEmpty ? 'Name required' : null,
            ),
            NgTextBox(
              label: 'Owner',
              validator: (v) => (v ?? '').isEmpty ? 'Owner required' : null,
            ),
          ],
        ),
      );
      await t.pumpWidget(view());
      expect(find.textContaining('Issues:'), findsNothing);
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(invalid, 1);
      expect(snapshot, ['Name required', 'Owner required']);
      final original = snapshot!;
      expect(() => original.add('Injected'), throwsUnsupportedError);
      await t.enterText(find.byType(TextFormField).last, 'Owner');
      await t.pumpAndSettle();
      expect(snapshot, ['Name required']);
      expect(original, ['Name required', 'Owner required']);
      expect(invalid, 1);
      expect(saves, 0);
      show = false;
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(find.textContaining('Issues:'), findsNothing);
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(invalid, 2);
      expect(saves, 0);
      show = true;
      custom = false;
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(find.text('Review the draft'), findsOneWidget);
      expect(find.text('• Name required'), findsOneWidget);
      await t.enterText(find.byType(TextFormField).first, 'Name');
      await t.pumpAndSettle();
      expect(find.text('Review the draft'), findsNothing);
      expect(saves, 0);
      expect(invalid, 2);
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 1);
      await t.enterText(find.byType(TextFormField).first, '');
      await t.pumpAndSettle();
      expect(find.text('• Name required'), findsOneWidget);
    },
  );
  testWidgets(
    'Empty error text still blocks submission and reaches the custom summary',
    (t) async {
      int saves = 0;
      List<String>? errors;
      await t.pumpWidget(
        host(
          NgForm(
            onValidSubmit: () => saves++,
            summaryBuilder: (_, items) {
              errors = items;
              return Text('Error count: ${items.length}');
            },
            fields: [NgTextBox(label: 'Name', validator: (_) => '')],
          ),
        ),
      );
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saves, 0);
      expect(errors, ['']);
      expect(find.text('Error count: 1'), findsOneWidget);
    },
  );
  testWidgets('Queued validation refresh is discarded on disposal', (t) async {
    await t.pumpWidget(
      host(
        NgForm(
          onValidSubmit: () {},
          fields: [
            NgTextBox(
              label: 'Name',
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField), 'Draft');
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Replacing form key clears previous summary and scheduled refresh',
    (t) async {
      var key = GlobalKey<FormState>();
      Widget view() => host(
        NgForm(
          formKey: key,
          onValidSubmit: () {},
          fields: [
            NgTextBox(
              label: 'Name',
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
            ),
          ],
        ),
      );
      await t.pumpWidget(view());
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(find.text('• Required'), findsOneWidget);
      await t.enterText(find.byType(TextFormField), 'Draft');
      key = GlobalKey<FormState>();
      await t.pumpWidget(view());
      await t.pumpAndSettle();
      expect(find.text('• Required'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
}
