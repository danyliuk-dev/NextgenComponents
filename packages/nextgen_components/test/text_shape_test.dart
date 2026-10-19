import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final multiline in [false, true]) {
    testWidgets(
      'Shape and flat fill retain state and themed borders: $multiline',
      (t) async {
        final controller = TextEditingController(text: 'Draft');
        final focus = FocusNode();
        final form = GlobalKey<FormState>();
        var changes = 0;
        const focused = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 3),
        );
        const error = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        );
        Widget host(String rounded, String fill) => MaterialApp(
          theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
              focusedBorder: focused,
              errorBorder: error,
              focusedErrorBorder: error,
            ),
          ),
          home: Scaffold(
            body: Form(
              key: form,
              child: multiline
                  ? NgTextArea(
                      controller: controller,
                      focusNode: focus,
                      rounded: rounded,
                      fillMode: fill,
                      autoSize: true,
                      rows: 2,
                      maxRows: 4,
                      validator: (_) => 'Review',
                      onChanged: (_) => changes++,
                    )
                  : NgTextBox(
                      label: 'Name',
                      controller: controller,
                      focusNode: focus,
                      rounded: rounded,
                      fillMode: fill,
                      validator: (_) => 'Review',
                      onChanged: (_) => changes++,
                    ),
            ),
          ),
        );
        await t.pumpWidget(host('theme', 'theme'));
        await t.tap(find.byType(TextFormField));
        controller.selection = const TextSelection(
          baseOffset: 1,
          extentOffset: 3,
        );
        expect(form.currentState!.validate(), false);
        await t.pumpAndSettle();
        final original = t.getSize(find.byType(TextFormField));
        for (final entry in {
          'large': 16.0,
          'none': 0.0,
          'small': 4.0,
          'medium': 8.0,
          'full': 9999.0,
          'theme': 11.0,
        }.entries) {
          await t.pumpWidget(host(entry.key, 'flat'));
          await t.pumpAndSettle();
          final decoration = t
              .widget<TextField>(find.byType(TextField))
              .decoration!;
          expect(
            (decoration.border! as OutlineInputBorder).borderRadius.topLeft.x,
            entry.value,
          );
          expect(decoration.enabledBorder!.borderSide.style, BorderStyle.none);
          expect(decoration.disabledBorder!.borderSide.style, BorderStyle.none);
          expect(decoration.focusedBorder!.borderSide, focused.borderSide);
          expect(decoration.errorBorder!.borderSide, error.borderSide);
          expect(decoration.focusedErrorBorder!.borderSide, error.borderSide);
          expect(focus.hasFocus, true);
          expect(controller.text, 'Draft');
          expect(
            controller.selection,
            const TextSelection(baseOffset: 1, extentOffset: 3),
          );
          expect(find.text('Review'), findsOneWidget);
          expect(changes, 0);
          expect(t.getSize(find.byType(TextFormField)), original);
        }
        await t.pumpWidget(host('theme', 'theme'));
        await t.pumpAndSettle();
        final restored = t
            .widget<TextField>(find.byType(TextField))
            .decoration!;
        expect(restored.enabledBorder, isNull);
        expect(restored.focusedBorder, focused);
        await t.pumpWidget(const SizedBox());
        controller.dispose();
        focus.dispose();
      },
    );
  }
  testWidgets('Invalid corners rejected for both public editors', (t) async {
    for (final editor in [
      const NgTextBox(label: 'Name', rounded: 'bad'),
      const NgTextArea(rounded: 'bad'),
    ]) {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: editor)));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
  testWidgets('Underline and explicitly absent borders retain their shape', (
    t,
  ) async {
    for (final border in [const UnderlineInputBorder(), InputBorder.none]) {
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(border: border),
          ),
          home: const Scaffold(
            body: NgTextBox(label: 'Name', rounded: 'large', fillMode: 'flat'),
          ),
        ),
      );
      await t.pumpAndSettle();
      final actual = t
          .widget<TextField>(find.byType(TextField))
          .decoration!
          .border!;
      if (border == InputBorder.none) {
        expect(actual, InputBorder.none);
      } else {
        expect(actual, isA<UnderlineInputBorder>());
        expect((actual as UnderlineInputBorder).borderRadius.topLeft.x, 16);
      }
    }
  });
}
