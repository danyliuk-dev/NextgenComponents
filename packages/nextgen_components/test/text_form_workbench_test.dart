import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));
void main() {
  testWidgets(
    'text fields retain labels, decoration, focus and readonly selection',
    (t) async {
      final controller = TextEditingController(text: 'Original');
      final focus = FocusNode();
      await t.pumpWidget(
        host(
          NgTextBox(
            label: 'Project',
            controller: controller,
            focusNode: focus,
            readOnly: true,
            maxLength: 30,
            helperText: 'Guidance',
            prefix: const Icon(Icons.edit),
          ),
        ),
      );
      focus.requestFocus();
      await t.pump();
      expect(focus.hasFocus, isTrue);
      expect(
        t.widget<TextFormField>(find.byType(TextFormField)).controller,
        controller,
      );
      expect(
        t.widget<EditableText>(find.byType(EditableText)).readOnly,
        isTrue,
      );
      expect(find.text('Guidance'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      controller.text = 'Updated externally';
      await t.pump();
      expect(find.text('Updated externally'), findsOneWidget);
      await t.pumpWidget(host(const SizedBox()));
      controller.dispose();
      focus.dispose();
    },
  );
  testWidgets(
    'textarea rejects invalid configuration and validates readonly content',
    (t) async {
      await t.pumpWidget(host(const NgTextArea(rows: 0)));
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(host(const NgTextBox(label: 'Name', maxLength: 0)));
      expect(t.takeException(), isArgumentError);
      final key = GlobalKey<FormState>();
      await t.pumpWidget(
        host(
          Form(
            key: key,
            child: NgTextArea(
              label: 'Notes',
              readOnly: true,
              initialValue: '',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await t.pump();
      expect(find.text('Required'), findsOneWidget);
    },
  );
  testWidgets(
    'invalid form does not save; pending save excludes duplicate actions and allows retry',
    (t) async {
      final pending = Completer<void>();
      int saved = 0, invalid = 0;
      bool fail = true;
      await t.pumpWidget(
        host(
          NgForm(
            onInvalidSubmit: () => invalid++,
            onValidSubmit: () async {
              saved++;
              await pending.future;
              if (fail) throw StateError('secret');
            },
            child: NgTextBox(
              label: 'Name',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      );
      await t.tap(find.text('Save'));
      await t.pump();
      expect(invalid, 1);
      expect(saved, 0);
      await t.enterText(find.byType(TextFormField), 'Alex');
      await t.pump();
      final action = t.widget<NgButton>(find.byType(NgButton)).onPressed!;
      action();
      action();
      await t.pump();
      expect(saved, 1);
      expect(find.text('Saving…'), findsOneWidget);
      expect(t.widget<NgButton>(find.byType(NgButton)).onPressed, isNull);
      pending.complete();
      await t.pumpAndSettle();
      expect(find.text('Unable to save. Try again.'), findsOneWidget);
      expect(find.textContaining('secret'), findsNothing);
      fail = false;
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(saved, 2);
      expect(find.text('Unable to save. Try again.'), findsNothing);
    },
  );
  testWidgets(
    'disabled form prevents submit and disposal ignores pending completion',
    (t) async {
      int calls = 0;
      final pending = Completer<void>();
      await t.pumpWidget(
        host(
          NgForm(
            enabled: false,
            onValidSubmit: () => calls++,
            child: const Text('Draft'),
          ),
        ),
      );
      expect(t.widget<NgButton>(find.byType(NgButton)).onPressed, isNull);
      expect(calls, 0);
      await t.pumpWidget(
        host(
          NgForm(
            key: const ValueKey(1),
            onValidSubmit: () => pending.future,
            child: const Text('Draft'),
          ),
        ),
      );
      await t.tap(find.text('Save'));
      await t.pump();
      await t.pumpWidget(host(const Text('Replacement')));
      pending.completeError(StateError('late failure'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('Replacement'), findsOneWidget);
    },
  );
}
