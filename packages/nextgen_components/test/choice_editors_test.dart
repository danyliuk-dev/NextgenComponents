import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));
void main() {
  testWidgets('dropdown removed selection fails validation and recovers', (
    t,
  ) async {
    String? value = 'a';
    var items = [const NgOption('a', 'Alpha'), const NgOption('b', 'Beta')];
    late StateSetter set;
    final key = GlobalKey<FormState>();
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, s) {
            set = s;
            return Form(
              key: key,
              child: NgDropDownList(
                label: 'Team',
                value: value,
                items: items,
                onChanged: (v) => s(() => value = v),
              ),
            );
          },
        ),
      ),
    );
    expect(key.currentState!.validate(), isTrue);
    set(() => items = [const NgOption('b', 'Beta')]);
    await t.pump();
    expect(t.takeException(), isNull);
    expect(key.currentState!.validate(), isFalse);
    await t.pump();
    expect(find.text('Choose an available option.'), findsOneWidget);
    await t.tap(find.byType(DropdownButton<String>));
    await t.pumpAndSettle();
    await t.tap(find.text('Beta').last);
    await t.pumpAndSettle();
    expect(value, 'b');
    expect(key.currentState!.validate(), isTrue);
  });
  testWidgets(
    'pending dropdown callback cannot change after readonly rebuild',
    (t) async {
      var readonly = false;
      late StateSetter set;
      var changes = 0;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, s) {
              set = s;
              return NgDropDownList(
                label: 'Team',
                value: 'a',
                readOnly: readonly,
                items: const [NgOption('a', 'Alpha'), NgOption('b', 'Beta')],
                onChanged: (_) => changes++,
              );
            },
          ),
        ),
      );
      final callback = t
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .onChanged!;
      set(() => readonly = true);
      await t.pump();
      callback('b');
      await t.pump();
      expect(changes, 0);
      expect(
        t
            .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
            .value,
        'a',
      );
    },
  );
  testWidgets(
    'radio templates keep labels and disabled and readonly behavior',
    (t) async {
      String? value = 'a';
      var readonly = false;
      late StateSetter set;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, s) {
              set = s;
              return NgRadioGroup(
                label: 'Team',
                value: value,
                readOnly: readonly,
                orientation: 'vertical',
                helperText: 'Choose one team',
                items: const [
                  NgOption('a', 'Alpha'),
                  NgOption('b', 'Beta'),
                  NgOption('c', 'Locked', disabled: true),
                ],
                itemBuilder: (_, o) => Text('Card ${o.label}'),
                onChanged: (v) => s(() => value = v),
              );
            },
          ),
        ),
      );
      await t.tap(find.text('Card Locked'));
      await t.pump();
      expect(value, 'a');
      await t.tap(find.text('Card Beta'));
      await t.pump();
      expect(value, 'b');
      set(() => readonly = true);
      await t.pump();
      await t.tap(find.text('Card Alpha'));
      await t.pump();
      expect(value, 'b');
      expect(find.text('Choose one team'), findsOneWidget);
    },
  );
  testWidgets('duplicate option IDs reject configuration', (t) async {
    await t.pumpWidget(
      app(
        NgDropDownList(
          label: 'Team',
          value: null,
          items: const [NgOption('a', 'Alpha'), NgOption('a', 'Again')],
        ),
      ),
    );
    expect(t.takeException(), isArgumentError);
  });
}
