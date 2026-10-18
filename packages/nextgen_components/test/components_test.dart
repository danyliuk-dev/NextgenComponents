import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? NgTheme.dark() : NgTheme.light(),
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: child),
  ),
);
void main() {
  testWidgets('radio labels are individually accessible and clickable', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    String? value = 'a';
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => NgRadioGroup(
            label: 'Access',
            value: value,
            items: const [NgOption('a', 'Viewer'), NgOption('b', 'Editor')],
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Viewer'), findsOneWidget);
    expect(find.bySemanticsLabel('Editor'), findsOneWidget);
    await tester.tap(find.text('Viewer'));
    await tester.pump();
    expect(value, 'a');
    await tester.tap(find.text('Editor'));
    await tester.pump();
    expect(value, 'b');
    semantics.dispose();
  });
  testWidgets('enabled button fires once; disabled button never fires', (
    tester,
  ) async {
    var clicks = 0;
    await tester.pumpWidget(
      app(
        Column(
          children: [
            NgButton(
              primary: true,
              onPressed: () => clicks++,
              child: const Text('Save'),
            ),
            const NgButton(child: Text('Disabled')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.tap(find.text('Disabled'));
    expect(clicks, 1);
  });
  testWidgets('text input updates and form rejects empty value', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    String? value;
    await tester.pumpWidget(
      app(
        Form(
          key: form,
          child: NgTextBox(
            label: 'Name',
            onChanged: (v) => value = v,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'Morgan');
    expect(value, 'Morgan');
    expect(form.currentState!.validate(), isTrue);
    await tester.enterText(find.byType(TextFormField), '');
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Corrected');
    await tester.pump();
    expect(find.text('Required'), findsNothing);
  });
  testWidgets(
    'numeric invalid drafts do not corrupt value and limits validate',
    (tester) async {
      double? value = 5;
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        app(
          Form(
            key: form,
            child: NgNumericTextBox(
              label: 'Seats',
              value: value,
              min: 1,
              max: 100,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '12.5');
      expect(value, 12.5);
      await tester.enterText(find.byType(TextFormField), 'oops');
      expect(value, 12.5);
      expect(form.currentState!.validate(), isFalse);
      await tester.enterText(find.byType(TextFormField), '101');
      expect(form.currentState!.validate(), isFalse);
      expect(value, 12.5);
      await tester.enterText(find.byType(TextFormField), '');
      expect(value, isNull);
      expect(form.currentState!.validate(), isTrue);
    },
  );
  testWidgets('numeric control reflects external reset', (tester) async {
    double? value = 5;
    late StateSetter update;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return NgNumericTextBox(
              label: 'Seats',
              value: value,
              onChanged: (v) => update(() => value = v),
            );
          },
        ),
      ),
    );
    update(() => value = 42);
    await tester.pump();
    expect(find.text('42'), findsOneWidget);
  });
  testWidgets('checkbox and switch change their controlled values', (
    tester,
  ) async {
    var check = false, toggle = false;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              NgCheckBox(
                label: 'Updates',
                value: check,
                onChanged: (v) => setState(() => check = v),
              ),
              NgSwitch(
                label: 'Active',
                value: toggle,
                onChanged: (v) => setState(() => toggle = v),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(check, isTrue);
    expect(toggle, isTrue);
  });
  testWidgets('dropdown changes selection and follows external state', (
    tester,
  ) async {
    String? value = 'a';
    late StateSetter update;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return NgDropDownList(
              label: 'Team',
              value: value,
              items: const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')],
              onChanged: (v) => update(() => value = v),
            );
          },
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(value, 'b');
    update(() => value = 'a');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .initialValue,
      'a',
    );
  });
  testWidgets('radio group selects a value', (tester) async {
    String? value = 'a';
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => NgRadioGroup(
            label: 'Access',
            value: value,
            items: const [NgOption('a', 'Viewer'), NgOption('b', 'Editor')],
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Radio<String>).last);
    await tester.pump();
    expect(value, 'b');
  });
  testWidgets('tabs show selected panel and react to external selection', (
    tester,
  ) async {
    var selected = 0;
    late StateSetter update;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return NgTabs(
              selectedIndex: selected,
              onChanged: (v) => update(() => selected = v),
              items: const [
                NgTab('One', Text('First panel')),
                NgTab('Two', Text('Second panel')),
              ],
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(find.text('Second panel'), findsOneWidget);
    expect(find.text('First panel'), findsNothing);
    update(() => selected = 0);
    await tester.pumpAndSettle();
    expect(find.text('First panel'), findsOneWidget);
  });
  testWidgets('dialog opens and Escape dismisses it', (tester) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => NgButton(
            onPressed: () => NgDialog.show(
              context,
              title: 'Preview',
              child: const Text('Details'),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
  });
  testWidgets('notification dismisses in dark theme', (tester) async {
    var visible = true;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => visible
              ? NgNotification(
                  message: 'Saved',
                  onDismiss: () => setState(() => visible = false),
                )
              : const SizedBox(),
        ),
        dark: true,
      ),
    );
    await tester.tap(find.byTooltip('Dismiss notification'));
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
  });
  testWidgets('tooltip has the supplied accessible message', (tester) async {
    await tester.pumpWidget(
      app(const NgTooltip(text: 'Help text', child: Text('Help'))),
    );
    final state = tester.state<TooltipState>(find.byType(Tooltip));
    state.ensureTooltipVisible();
    await tester.pumpAndSettle();
    expect(find.text('Help text'), findsOneWidget);
  });
}
