import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));
Finder action(String label) =>
    find.byWidgetPredicate((w) => w is IconButton && w.tooltip == label);
void main() {
  for (final multiline in [false, true]) {
    testWidgets(
      'Clear updates form, emits once and restores focus (multiline=$multiline)',
      (t) async {
        final form = GlobalKey<FormState>(), focus = FocusNode();
        final controller = TextEditingController(text: 'Draft');
        var changes = 0, commits = 0;
        String? validate(String? value) =>
            value == null || value.isEmpty ? 'Required' : null;
        await t.pumpWidget(
          host(
            Form(
              key: form,
              child: multiline
                  ? NgTextArea(
                      label: 'Draft',
                      controller: controller,
                      focusNode: focus,
                      showClearButton: true,
                      validator: validate,
                      onChanged: (_) => changes++,
                      onSubmitted: (_) => commits++,
                    )
                  : NgTextBox(
                      label: 'Draft',
                      controller: controller,
                      focusNode: focus,
                      showClearButton: true,
                      validator: validate,
                      onChanged: (_) => changes++,
                      onSubmitted: (_) => commits++,
                    ),
            ),
          ),
        );
        await t.tap(action('Clear Draft'));
        await t.pump();
        expect(controller.text, '');
        expect(changes, 1);
        expect(commits, 0);
        expect(focus.hasFocus, true);
        expect(form.currentState!.validate(), false);
        await t.pump();
        expect(find.text('Required'), findsOneWidget);
        expect(t.widget<IconButton>(action('Clear Draft')).onPressed, isNull);
        controller.text = 'External';
        await t.pump();
        expect(changes, 1);
        expect(
          t.widget<IconButton>(action('Clear Draft')).onPressed,
          isNotNull,
        );
        await t.pumpWidget(host(const SizedBox()));
        controller.dispose();
        focus.dispose();
      },
    );
  }
  testWidgets('Owned initial value retains form reset and supports clearing', (
    t,
  ) async {
    final form = GlobalKey<FormState>();
    await t.pumpWidget(
      host(
        Form(
          key: form,
          child: const NgTextBox(
            label: 'Name',
            initialValue: 'Initial',
            showClearButton: true,
          ),
        ),
      ),
    );
    await t.tap(action('Clear Name'));
    await t.pump();
    expect(find.text('Initial'), findsNothing);
    form.currentState!.reset();
    await t.pump();
    expect(find.text('Initial'), findsOneWidget);
    expect(t.widget<IconButton>(action('Clear Name')).onPressed, isNotNull);
  });
  testWidgets(
    'Password reveal, locks and replacement reject retained actions',
    (t) async {
      final first = TextEditingController(text: 'secret'),
          second = TextEditingController(text: 'replacement');
      Widget page(
        TextEditingController c, {
        bool locked = false,
        bool enabled = true,
      }) => host(
        NgTextBox(
          label: 'Password',
          controller: c,
          password: true,
          showPasswordToggle: true,
          showClearButton: true,
          readOnly: locked,
          enabled: enabled,
        ),
      );
      await t.pumpWidget(page(first));
      expect(
        t.widget<EditableText>(find.byType(EditableText)).obscureText,
        true,
      );
      final oldClear = t
          .widget<IconButton>(action('Clear Password'))
          .onPressed!;
      final oldReveal = t
          .widget<IconButton>(action('Show password'))
          .onPressed!;
      await t.tap(action('Show password'));
      await t.pump();
      expect(
        t.widget<EditableText>(find.byType(EditableText)).obscureText,
        false,
      );
      await t.pumpWidget(page(first, locked: true));
      oldClear();
      oldReveal();
      await t.pump();
      expect(first.text, 'secret');
      expect(
        t.widget<EditableText>(find.byType(EditableText)).obscureText,
        true,
      );
      await t.pumpWidget(page(second));
      oldClear();
      oldReveal();
      await t.pump();
      expect(second.text, 'replacement');
      expect(
        t.widget<EditableText>(find.byType(EditableText)).obscureText,
        true,
      );
      await t.pumpWidget(page(second, enabled: false));
      expect(t.widget<IconButton>(action('Show password')).onPressed, isNull);
      await t.pumpWidget(host(const SizedBox()));
      oldClear();
      oldReveal();
      first.dispose();
      second.dispose();
    },
  );
}
