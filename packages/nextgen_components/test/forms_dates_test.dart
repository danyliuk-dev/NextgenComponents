import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(
  theme: NgTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  testWidgets(
    'date range validates parent replacement and unavailable endpoints',
    (t) async {
      NgDateRange? range = NgDateRange(
        DateTime(2026, 10, 20),
        DateTime(2026, 10, 23),
      );
      late StateSetter change;
      final form = GlobalKey<FormState>();
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) {
              change = set;
              return Form(
                key: form,
                child: NgDateRangePicker(
                  value: range,
                  disabledDate: (d) => d.day == 25,
                  onChanged: (v) => set(() => range = v),
                ),
              );
            },
          ),
        ),
      );
      expect(form.currentState!.validate(), isTrue);
      change(
        () =>
            range = NgDateRange(DateTime(2026, 10, 24), DateTime(2026, 10, 23)),
      );
      await t.pump();
      expect(form.currentState!.validate(), isFalse);
      change(
        () =>
            range = NgDateRange(DateTime(2026, 10, 20), DateTime(2026, 10, 25)),
      );
      await t.pump();
      expect(form.currentState!.validate(), isFalse);
      change(() => range = null);
      await t.pump();
      expect(form.currentState!.validate(), isTrue);
    },
  );
  testWidgets('readonly date editors suppress picker and keyboard changes', (
    t,
  ) async {
    var changes = 0;
    await t.pumpWidget(
      app(
        NgDateRangePicker(
          value: NgDateRange(DateTime(2026, 10, 20), DateTime(2026, 10, 23)),
          readOnly: true,
          onChanged: (_) => changes++,
        ),
      ),
    );
    expect(
      t.widgetList<TextField>(find.byType(TextField)).every((f) => f.readOnly),
      isTrue,
    );
    expect(
      t
          .widgetList<IconButton>(find.byType(IconButton))
          .every((b) => b.onPressed == null),
      isTrue,
    );
    expect(changes, 0);
  });
  testWidgets('calendar readonly also prevents keyboard focus', (t) async {
    await t.pumpWidget(
      app(
        NgCalendar(
          value: DateTime(2026, 10, 20),
          readOnly: true,
          onChanged: (_) {},
        ),
      ),
    );
    expect(
      t.widget<ExcludeFocus>(find.byType(ExcludeFocus).first).excluding,
      isTrue,
    );
  });
  test('date configuration rejects inverted bounds', () {
    expect(
      () => NgDateRules.checkBounds(
        DateTime(2026, 10, 23),
        DateTime(2026, 10, 20),
      ),
      throwsArgumentError,
    );
  });

  test('strict calendar and wall-clock rules reject rollover', () {
    expect(NgDateRules.parseDate('2024-02-29'), DateTime(2024, 2, 29));
    for (final text in [
      '2026-02-29',
      '2026-04-31',
      '2026-13-01',
      '0000-01-01',
      '2026-1-01',
    ]) {
      expect(NgDateRules.parseDate(text), isNull);
    }
    expect(NgDateRules.parseTime('24:00'), isNull);
    expect(NgDateRules.parseTime('12:60'), isNull);
    expect(
      NgDateRules.parseDateTime('2026-10-22 09:30'),
      DateTime(2026, 10, 22, 9, 30),
    );
    expect(
      NgDateRules.rangeError(
        NgDateRange(DateTime(2026, 10, 23), DateTime(2026, 10, 22)),
      ),
      isNotNull,
    );
    expect(
      NgDateRules.rangeError(NgDateRange(DateTime(2026), null)),
      isNotNull,
    );
  });
  testWidgets('invalid date draft blocks form and preserves last valid value', (
    t,
  ) async {
    DateTime? value = DateTime(2026, 10, 22);
    var saves = 0;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => NgForm(
            onValidSubmit: () => saves++,
            child: NgDateInput(
              label: 'Date',
              value: value,
              min: DateTime(2026),
              max: DateTime(2026, 12, 31),
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField), '2026-02-29');
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 0);
    expect(value, DateTime(2026, 10, 22));
    await t.enterText(find.byType(TextFormField), '2027-01-01');
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 0);
    await t.enterText(find.byType(TextFormField), '2026-11-03');
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 1);
    expect(value, DateTime(2026, 11, 3));
  });
  testWidgets(
    'picker selection repairs invalid draft even for unchanged value',
    (t) async {
      DateTime? value = DateTime(2026, 10, 22);
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) => NgDatePicker(
              label: 'Date',
              value: value,
              min: DateTime(2026, 10, 1),
              max: DateTime(2026, 10, 31),
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      );
      await t.enterText(find.byType(TextFormField), 'broken');
      await t.pump();
      await t.tap(find.byTooltip('Choose Date'));
      await t.pumpAndSettle();
      await t.tap(find.text('22').last);
      await t.pumpAndSettle();
      expect(find.text('broken'), findsNothing);
      expect(find.text('2026-10-22'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('disabled selected calendar date renders safely', (t) async {
    await t.pumpWidget(
      app(
        NgCalendar(
          value: DateTime(2026, 10, 18),
          min: DateTime(2026, 10, 1),
          max: DateTime(2026, 10, 31),
          disabledDate: (d) => d.weekday == 7,
          onChanged: (_) {},
        ),
      ),
    );
    await t.pump();
    expect(t.takeException(), isNull);
  });
  testWidgets('range validates order and then clears on correction', (t) async {
    NgDateRange? value = NgDateRange(
      DateTime(2026, 10, 22),
      DateTime(2026, 10, 23),
    );
    var saves = 0;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => NgForm(
            onValidSubmit: () => saves++,
            child: NgDateRangePicker(
              value: value,
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField).last, '2026-10-21');
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 0);
    expect(find.text('End date must not precede start date.'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).last, '2026-10-24');
    await t.pump();
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 1);
  });
  testWidgets('combo rejects arbitrary or disabled option', (t) async {
    String? value = 'a';
    var saves = 0;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => NgForm(
            onValidSubmit: () => saves++,
            child: NgComboBox(
              label: 'Person',
              value: value,
              required: true,
              items: const [
                NgOption('a', 'Alex'),
                NgOption('b', 'Blocked', disabled: true),
              ],
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField), 'Blocked');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 0);
    expect(value, 'a');
    await t.enterText(find.byType(TextFormField), 'Alex');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 1);
  });
  testWidgets('multiselect copies values, enforces limit and permits removal', (
    t,
  ) async {
    final original = ['a'];
    List<String> value = original;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => NgMultiSelect(
            value: value,
            maxSelected: 1,
            items: const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')],
            onChanged: (v) => set(() => value = v),
          ),
        ),
      ),
    );
    await t.tap(find.text('Beta'));
    await t.pump();
    expect(value, ['a']);
    await t.tap(find.byTooltip('Delete').first);
    await t.pump();
    expect(value, isEmpty);
    expect(original, ['a']);
    await t.tap(find.text('Beta'));
    await t.pump();
    expect(value, ['b']);
  });
}
