import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final multiline in [false, true]) {
    testWidgets('Debounce coalesces and cancels stale work: $multiline', (
      t,
    ) async {
      final first = TextEditingController(text: 'Initial');
      final second = TextEditingController(text: 'Replacement');
      var controller = first;
      var enabled = true, locked = false, listen = true;
      var delay = 300;
      var size = 'medium';
      final changes = <String>[], delayed = <String>[];
      Widget host() => MaterialApp(
        home: Scaffold(
          body: multiline
              ? NgTextArea(
                  controller: controller,
                  enabled: enabled,
                  readOnly: locked,
                  size: size,
                  debounceDelay: delay,
                  onChanged: changes.add,
                  onDebouncedChange: listen ? delayed.add : null,
                  showClearButton: true,
                )
              : NgTextBox(
                  label: 'Notes',
                  controller: controller,
                  enabled: enabled,
                  readOnly: locked,
                  size: size,
                  debounceDelay: delay,
                  onChanged: changes.add,
                  onDebouncedChange: listen ? delayed.add : null,
                  showClearButton: true,
                ),
        ),
      );
      Future<void> type(String value) async {
        await t.enterText(find.byType(TextFormField), value);
        await t.pump();
      }

      await t.pumpWidget(host());
      await type('A');
      await t.pump(const Duration(milliseconds: 200));
      await type('AB');
      expect(changes, ['A', 'AB']);
      expect(delayed, isEmpty);
      await t.pump(const Duration(milliseconds: 299));
      expect(delayed, isEmpty);
      // A regular rebuild and selection update must not discard the latest edit.
      size = 'large';
      await t.pumpWidget(host());
      controller.selection = const TextSelection.collapsed(offset: 1);
      await t.pump(const Duration(milliseconds: 1));
      expect(delayed, ['AB']);
      await type('External cancel');
      controller.text = 'External';
      await t.pump(const Duration(milliseconds: 400));
      expect(delayed, ['AB']);
      await type('Lock cancel');
      locked = true;
      await t.pumpWidget(host());
      await t.pump(const Duration(milliseconds: 400));
      expect(delayed, ['AB']);
      locked = false;
      await t.pumpWidget(host());
      await type('Disabled cancel');
      enabled = false;
      await t.pumpWidget(host());
      await t.pump(const Duration(milliseconds: 400));
      expect(delayed, ['AB']);
      enabled = true;
      await t.pumpWidget(host());
      await type('Delay cancel');
      delay = 600;
      await t.pumpWidget(host());
      await t.pump(const Duration(milliseconds: 700));
      expect(delayed, ['AB']);
      await type('Handler cancel');
      listen = false;
      await t.pumpWidget(host());
      await t.pump(const Duration(milliseconds: 700));
      expect(delayed, ['AB']);
      listen = true;
      await t.pumpWidget(host());
      await type('Controller cancel');
      controller = second;
      await t.pumpWidget(host());
      await t.pump(const Duration(milliseconds: 700));
      expect(delayed, ['AB']);
      await t.tap(find.byTooltip('Clear Notes'));
      await t.pump();
      expect(controller.text, '');
      expect(changes.last, '');
      expect(delayed, ['AB']);
      await t.pump(const Duration(milliseconds: 600));
      expect(delayed, ['AB', '']);
      delay = 0;
      await t.pumpWidget(host());
      await type('Zero');
      expect(delayed.last, 'Zero');
      delay = 300;
      await t.pumpWidget(host());
      await type('Disposed');
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      expect(delayed.last, 'Zero');
      first.dispose();
      second.dispose();
    });
  }
  testWidgets(
    'Native form reset replaces pending notification with reset value',
    (t) async {
      final form = GlobalKey<FormState>();
      final delayed = <String>[];
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: form,
              child: NgTextBox(
                label: 'Name',
                initialValue: 'Initial',
                onDebouncedChange: delayed.add,
              ),
            ),
          ),
        ),
      );
      await t.enterText(find.byType(TextFormField), 'Draft');
      await t.pump();
      form.currentState!.reset();
      await t.pump(const Duration(milliseconds: 300));
      expect(delayed, ['Initial']);
    },
  );
  testWidgets('Delay bounds are enforced', (t) async {
    for (final editor in [
      const NgTextBox(label: 'Name', debounceDelay: -1),
      const NgTextArea(debounceDelay: 60001),
    ]) {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: editor)));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
}
