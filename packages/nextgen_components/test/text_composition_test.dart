import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final multiline in [false, true]) {
    for (final controlled in [false, true]) {
      testWidgets(
        'IME notification: multiline=$multiline controller=$controlled',
        (t) async {
          final controller = controlled ? TextEditingController() : null;
          final changes = <String>[], delayed = <String>[];
          var locked = false;
          var delay = 300;
          Widget host() => MaterialApp(
            home: Scaffold(
              body: multiline
                  ? NgTextArea(
                      controller: controller,
                      readOnly: locked,
                      debounceDelay: delay,
                      onChanged: changes.add,
                      onDebouncedChange: delayed.add,
                    )
                  : NgTextBox(
                      label: 'Name',
                      controller: controller,
                      readOnly: locked,
                      debounceDelay: delay,
                      onChanged: changes.add,
                      onDebouncedChange: delayed.add,
                    ),
            ),
          );
          await t.pumpWidget(host());
          await t.showKeyboard(find.byType(TextFormField));
          Future<void> edit(String text, bool composing) async {
            t.testTextInput.updateEditingValue(
              TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
                composing: composing
                    ? TextRange(start: 0, end: text.length)
                    : TextRange.empty,
              ),
            );
            await t.pump();
          }

          await edit('ni', true);
          expect(changes, ['ni']);
          await t.pump(const Duration(seconds: 1));
          expect(delayed, isEmpty);
          await edit('你', true);
          await t.pump(const Duration(seconds: 1));
          expect(delayed, isEmpty);
          await edit('你', false);
          await t.pump(const Duration(milliseconds: 299));
          expect(delayed, isEmpty);
          await t.pump(const Duration(milliseconds: 1));
          expect(delayed, ['你']);
          // Same-text composition start must suppress an already pending edit.
          await edit('test', false);
          await edit('test', true);
          await t.pump(const Duration(seconds: 1));
          expect(delayed, ['你']);
          await edit('test', false);
          await t.pump(const Duration(milliseconds: 300));
          expect(delayed, ['你', 'test']);
          delay = 0;
          await t.pumpWidget(host());
          await edit('zero', true);
          await t.pump(const Duration(seconds: 1));
          expect(delayed, ['你', 'test']);
          await edit('zero', false);
          await t.pump(const Duration(milliseconds: 1));
          expect(delayed, ['你', 'test', 'zero']);
          delay = 300;
          await t.pumpWidget(host());
          await edit('lock', true);
          await edit('lock', false);
          locked = true;
          await t.pumpWidget(host());
          await t.pump(const Duration(seconds: 1));
          expect(delayed, ['你', 'test', 'zero']);
          locked = false;
          await t.pumpWidget(host());
          await t.showKeyboard(find.byType(TextFormField));
          await edit('dispose', true);
          await edit('dispose', false);
          await t.pumpWidget(const SizedBox());
          await t.pump(const Duration(seconds: 1));
          expect(delayed, ['你', 'test', 'zero']);
          controller?.dispose();
        },
      );
    }
  }
}
