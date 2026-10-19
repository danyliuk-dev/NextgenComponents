import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final multiline in [false, true]) {
    testWidgets('Appearance keeps editing and validation state: $multiline', (
      t,
    ) async {
      final controller = TextEditingController(text: 'Draft');
      final form = GlobalKey<FormState>();
      var changes = 0;
      Widget host(String size, String fill) => MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: multiline
                ? NgTextArea(
                    controller: controller,
                    size: size,
                    fillMode: fill,
                    autoSize: true,
                    rows: 2,
                    maxRows: 4,
                    validator: (_) => 'Review required',
                    onChanged: (_) => changes++,
                  )
                : NgTextBox(
                    label: 'Name',
                    controller: controller,
                    size: size,
                    fillMode: fill,
                    validator: (_) => 'Review required',
                    onChanged: (_) => changes++,
                  ),
          ),
        ),
      );
      await t.pumpWidget(host('small', 'theme'));
      await t.tap(find.byType(TextFormField));
      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 3,
      );
      expect(form.currentState!.validate(), false);
      await t.pumpAndSettle();
      final small = t.getSize(find.byType(TextFormField)).height;
      await t.pumpWidget(host('large', 'filled'));
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(TextFormField)).height, greaterThan(small));
      expect(controller.text, 'Draft');
      expect(
        controller.selection,
        const TextSelection(baseOffset: 1, extentOffset: 3),
      );
      expect(find.text('Review required'), findsOneWidget);
      expect(changes, 0);
      await t.enterText(find.byType(TextFormField), 'New draft');
      expect(changes, 1);
      await t.pumpWidget(host('medium', 'outline'));
      await t.pumpAndSettle();
      expect(controller.text, 'New draft');
      expect(changes, 1);
      await t.pumpWidget(const SizedBox());
      controller.dispose();
    });
  }
  testWidgets('Invalid appearance fails explicitly', (t) async {
    for (final editor in [
      const NgTextBox(label: 'Name', size: 'invalid'),
      const NgTextArea(fillMode: 'invalid'),
    ]) {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: editor)));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
}
