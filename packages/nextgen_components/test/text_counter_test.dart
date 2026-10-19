import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  for (final multiline in [false, true]) {
    testWidgets(
      'Counter modes preserve editing, limits and callbacks: $multiline',
      (t) async {
        final semantics = t.ensureSemantics();
        final controller = TextEditingController(text: '👨‍👩‍👧‍👦');
        var mode = 'used', custom = false, locked = false;
        int? maximum = 4;
        final changes = <String>[], delayed = <String>[];
        Widget host() => MaterialApp(
          home: Scaffold(
            body: multiline
                ? NgTextArea(
                    controller: controller,
                    maxLength: maximum,
                    counterMode: mode,
                    counterText: custom ? (n, m) => 'Used $n; limit $m' : null,
                    readOnly: locked,
                    showClearButton: true,
                    onChanged: changes.add,
                    onDebouncedChange: delayed.add,
                  )
                : NgTextBox(
                    label: 'Notes',
                    controller: controller,
                    maxLength: maximum,
                    counterMode: mode,
                    counterText: custom ? (n, m) => 'Used $n; limit $m' : null,
                    readOnly: locked,
                    showClearButton: true,
                    onChanged: changes.add,
                    onDebouncedChange: delayed.add,
                  ),
          ),
        );
        await t.pumpWidget(host());
        expect(find.text('1 / 4'), findsOneWidget);
        mode = 'remaining';
        await t.pumpWidget(host());
        expect(find.text('3 remaining'), findsOneWidget);
        await t.showKeyboard(find.byType(TextFormField));
        await t.pump();
        expect(
          t.getSemantics(find.text('3 remaining')).label,
          contains('3 remaining'),
        );
        controller.text = 'abcdef';
        await t.pump();
        expect(find.text('2 over limit'), findsOneWidget);
        expect(controller.text, 'abcdef');
        expect(changes, isEmpty);
        custom = true;
        locked = true;
        await t.pumpWidget(host());
        expect(find.text('Used 6; limit 4'), findsOneWidget);
        mode = 'hidden';
        await t.pumpWidget(host());
        expect(find.text('Used 6; limit 4'), findsNothing);
        locked = false;
        await t.pumpWidget(host());
        await t.enterText(find.byType(TextFormField), '123456');
        await t.pump();
        expect(controller.text, '1234');
        mode = 'used';
        custom = false;
        await t.pumpWidget(host());
        expect(find.text('4 / 4'), findsOneWidget);
        await t.tap(find.byTooltip('Clear Notes'));
        await t.pump();
        expect(find.text('0 / 4'), findsOneWidget);
        await t.pump(const Duration(milliseconds: 300));
        expect(delayed, ['']);
        maximum = null;
        await t.pumpWidget(host());
        expect(find.text('0 characters'), findsOneWidget);
        controller.text = 'e\u0301';
        await t.pump();
        expect(find.text('1 character'), findsOneWidget);
        mode = 'native';
        await t.pumpWidget(host());
        expect(find.text('1 character'), findsNothing);
        await t.pumpWidget(const SizedBox());
        controller.dispose();
        semantics.dispose();
      },
    );
  }
  testWidgets(
    'Counter follows native form reset without controller ownership',
    (t) async {
      final form = GlobalKey<FormState>();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: form,
              child: const NgTextBox(
                label: 'Name',
                initialValue: 'Hello',
                counterMode: 'used',
              ),
            ),
          ),
        ),
      );
      expect(find.text('5 characters'), findsOneWidget);
      await t.enterText(find.byType(TextFormField), 'Hi');
      await t.pump();
      expect(find.text('2 characters'), findsOneWidget);
      form.currentState!.reset();
      await t.pump();
      expect(find.text('5 characters'), findsOneWidget);
    },
  );
  testWidgets('Invalid modes and missing remaining limit fail early', (
    t,
  ) async {
    for (final widget in [
      const NgTextBox(label: 'Name', counterMode: 'bad'),
      const NgTextArea(counterMode: 'remaining'),
    ]) {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
}
