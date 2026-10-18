import 'package:nextgen_components/src/dates.dart' show NgTemporalField;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget w) => MaterialApp(home: Scaffold(body: w));
void main() {
  testWidgets(
    'numeric bounds preserve draft, spin repairs and clamps, readonly locks',
    (t) async {
      double? value = 2;
      bool readOnly = false;
      late StateSetter update;
      final form = GlobalKey<FormState>();
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) {
              update = set;
              return Form(
                key: form,
                child: NgNumericTextBox(
                  label: 'Amount',
                  value: value,
                  min: 0,
                  max: 3,
                  step: 0.5,
                  readOnly: readOnly,
                  onChanged: (v) => set(() => value = v),
                ),
              );
            },
          ),
        ),
      );
      await t.enterText(find.byType(TextFormField), '9');
      await t.pumpAndSettle();
      expect(value, 2);
      expect(form.currentState!.validate(), false);
      await t.tap(find.byTooltip('Increase Amount'));
      await t.pumpAndSettle();
      expect(value, 2.5);
      expect(form.currentState!.validate(), true);
      await t.tap(find.byTooltip('Increase Amount'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Increase Amount'));
      await t.pumpAndSettle();
      expect(value, 3);
      for (final bad in ['NaN', 'Infinity', '1e2', '1,2', '-1']) {
        await t.enterText(find.byType(TextFormField), bad);
        await t.pump();
        expect(value, 3);
        expect(form.currentState!.validate(), false);
      }
      await t.enterText(find.byType(TextFormField), '');
      await t.pump();
      expect(value, null);
      expect(form.currentState!.validate(), true);
      update(() => readOnly = true);
      await t.pump();
      expect(t.widget<TextField>(find.byType(TextField)).readOnly, true);
      expect(
        t
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
            .onPressed,
        null,
      );
    },
  );
  testWidgets(
    'time and datetime reject off-step edits without changing models',
    (t) async {
      TimeOfDay? value = const TimeOfDay(hour: 9, minute: 30);
      final form = GlobalKey<FormState>();
      await t.pumpWidget(
        app(
          Form(
            key: form,
            child: NgTimePicker(
              value: value,
              minuteStep: 15,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );
      await t.enterText(find.byType(TextFormField), '09:17');
      await t.pump();
      expect(value!.minute, 30);
      expect(form.currentState!.validate(), false);
      await t.enterText(find.byType(TextFormField), '09:45');
      await t.pump();
      expect(value!.minute, 45);
      expect(form.currentState!.validate(), true);
      DateTime? stamp = DateTime(2026, 10, 20, 9, 30);
      await t.pumpWidget(
        app(
          NgDateTimePicker(
            value: stamp,
            minuteStep: 15,
            onChanged: (v) => stamp = v,
          ),
        ),
      );
      await t.enterText(find.byType(TextFormField), '2026-10-20 09:17');
      await t.pump();
      expect(stamp!.minute, 30);
      await t.enterText(find.byType(TextFormField), '2026-10-20 09:45');
      await t.pump();
      expect(stamp!.minute, 45);
    },
  );
  testWidgets('pending temporal callback ignores parent changes and disposal', (
    t,
  ) async {
    ValueChanged<TimeOfDay>? apply;
    TimeOfDay? value = const TimeOfDay(hour: 9, minute: 0);
    late StateSetter update;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) {
            update = set;
            return NgTemporalField<TimeOfDay>(
              label: 'Time',
              hint: 'hh:mm',
              value: value,
              format: NgDateRules.timeText,
              parse: NgDateRules.parseTime,
              onChanged: (v) => value = v,
              suffixBuilder: (f) {
                apply = f;
                return const Icon(Icons.schedule);
              },
            );
          },
        ),
      ),
    );
    final stale = apply!;
    update(() => value = const TimeOfDay(hour: 10, minute: 0));
    await t.pump();
    stale(const TimeOfDay(hour: 11, minute: 0));
    expect(value!.hour, 10);
    final disposed = apply!;
    await t.pumpWidget(app(const SizedBox()));
    disposed(const TimeOfDay(hour: 12, minute: 0));
    expect(value!.hour, 10);
    expect(t.takeException(), null);
  });
  testWidgets('bad numeric and interval configuration fails explicitly', (
    t,
  ) async {
    await t.pumpWidget(
      app(const NgNumericTextBox(label: 'Bad', value: 1, step: 0)),
    );
    expect(t.takeException(), isArgumentError);
    await t.pumpWidget(app(const NgTimePicker(value: null, minuteStep: 7)));
    expect(t.takeException(), isArgumentError);
  });
}
