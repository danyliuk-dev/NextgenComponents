import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  test('filter contracts reject bad configuration and distinguish modes', () {
    expect(NgFilterRules.matches('Alpha', 'ph', 'contains', 2), isTrue);
    expect(NgFilterRules.matches('Alpha', 'ph', 'startsWith', 0), isFalse);
    expect(NgFilterRules.matches('Alpha', 'HA', 'endsWith', 0), isTrue);
    expect(NgFilterRules.matches('Alpha', 'a', 'contains', 2), isFalse);
    expect(() => NgFilterRules.validate('wrong', 0), throwsArgumentError);
    expect(() => NgFilterRules.validate('contains', -1), throwsArgumentError);
    expect(
      () => NgFilterRules.validateItems(const [
        NgOption('a', 'A'),
        NgOption('a', 'B'),
      ]),
      throwsArgumentError,
    );
  });
  testWidgets('autocomplete minimum and prefix filter accept free text', (
    t,
  ) async {
    String value = '';
    await t.pumpWidget(
      app(
        NgAutoComplete(
          items: const ['London', 'Los Angeles', 'Lisbon'],
          filterMode: 'startsWith',
          minLength: 2,
          onChanged: (v) => value = v,
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField), 'L');
    await t.pumpAndSettle();
    expect(find.text('London'), findsNothing);
    await t.enterText(find.byType(TextFormField), 'Lo');
    await t.pumpAndSettle();
    expect(find.text('London'), findsOneWidget);
    expect(find.text('Lisbon'), findsNothing);
    await t.tap(find.text('London'));
    await t.pumpAndSettle();
    expect(value, 'London');
    await t.enterText(find.byType(TextFormField), 'Anywhere');
    await t.pumpAndSettle();
    expect(value, 'Anywhere');
  });
  testWidgets(
    'combo refreshes selected label, clears and retains invalid draft ID',
    (t) async {
      String? selected = 'a';
      bool readonly = false;
      var items = const [NgOption('a', 'Alex'), NgOption('b', 'Bella')];
      late StateSetter update;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) {
              update = set;
              return NgComboBox(
                label: 'Assignee',
                value: selected,
                items: items,
                showClearButton: true,
                readOnly: readonly,
                onChanged: (v) => set(() => selected = v),
                itemBuilder: (_, o) => Text('Team ${o.label}'),
              );
            },
          ),
        ),
      );
      update(
        () => items = const [NgOption('a', 'Renamed'), NgOption('b', 'Bella')],
      );
      await t.pump();
      expect(find.text('Renamed'), findsOneWidget);
      expect(selected, 'a');
      await t.enterText(find.byType(TextFormField), 'Unknown');
      await t.pump();
      expect(selected, 'a');
      expect(find.text('Choose an option from the list.'), findsOneWidget);
      await t.tap(find.byTooltip('Clear Assignee'));
      await t.pump();
      expect(selected, isNull);
      update(
        () => items = const [
          NgOption('a', 'Renamed'),
          NgOption('b', 'Bella', disabled: true),
        ],
      );
      await t.pump();
      t
          .widget<RawAutocomplete<NgOption>>(
            find.byType(RawAutocomplete<NgOption>),
          )
          .onSelected!(const NgOption('b', 'Bella'));
      await t.pump();
      expect(selected, isNull);
      update(() => readonly = true);
      await t.pump();
      expect(t.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
      expect(
        t.widget<EditableText>(find.byType(EditableText)).readOnly,
        isTrue,
      );
    },
  );
  testWidgets(
    'multiselect atomic bulk respects disabled selections and controlled validation',
    (t) async {
      var selected = <String>['locked'];
      final original = selected;
      bool readonly = false;
      late StateSetter update;
      final form = GlobalKey<FormState>();
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) {
              update = set;
              return Form(
                key: form,
                child: NgMultiSelect(
                  label: 'Services',
                  value: selected,
                  required: true,
                  maxSelected: 2,
                  showActions: true,
                  readOnly: readonly,
                  items: const [
                    NgOption('a', 'Alpha'),
                    NgOption('b', 'Beta'),
                    NgOption('locked', 'Mandatory', disabled: true),
                  ],
                  onChanged: (v) => set(() => selected = v),
                  itemBuilder: (_, o) => Text('Service ${o.label}'),
                  tagBuilder: (_, o) => Text('Chosen ${o.label}'),
                ),
              );
            },
          ),
        ),
      );
      await t.tap(find.text('Select filtered'));
      await t.pump();
      expect(selected, ['locked']);
      expect(find.text('Select at most 2 options.'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'Be');
      await t.pump();
      await t.tap(find.text('Select filtered'));
      await t.pump();
      expect(selected, ['locked', 'b']);
      expect(original, ['locked']);
      await t.tap(find.text('Clear selection'));
      await t.pump();
      expect(selected, ['locked']);
      update(() => selected = []);
      await t.pump();
      expect(form.currentState!.validate(), isFalse);
      await t.pump();
      expect(find.text('Services is required'), findsOneWidget);
      update(() => selected = ['a']);
      await t.pump();
      expect(form.currentState!.validate(), isTrue);
      update(() => readonly = true);
      await t.pump();
      expect(
        t
            .widget<NgButton>(find.widgetWithText(NgButton, 'Clear selection'))
            .onPressed,
        isNull,
      );
    },
  );
}
