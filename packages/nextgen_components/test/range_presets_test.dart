import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'Range presets apply atomically, repair drafts and guard stale actions',
    (t) async {
      final form = GlobalKey<FormState>();
      final first = NgDateRangePreset(
        id: 'first',
        label: 'First',
        start: DateTime(2026, 10, 20, 14),
        end: DateTime(2026, 10, 23, 8),
      );
      final blocked = NgDateRangePreset(
        id: 'blocked',
        label: 'Sunday',
        start: DateTime(2026, 10, 25),
        end: DateTime(2026, 10, 26),
      );
      final outside = NgDateRangePreset(
        id: 'outside',
        label: 'Outside',
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 2),
      );
      final disabled = NgDateRangePreset(
        id: 'disabled',
        label: 'Disabled',
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 10, 23),
        disabled: true,
      );
      var presets = [first, blocked, outside, disabled];
      NgDateRange? value;
      var locked = false, enabled = true, clear = true;
      final changes = <NgDateRange?>[];
      late StateSetter set;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, s) {
                set = s;
                return Form(
                  key: form,
                  child: NgDateRangePicker(
                    value: value,
                    presets: presets,
                    showClearButton: clear,
                    required: true,
                    readOnly: locked,
                    enabled: enabled,
                    min: DateTime(2026, 10, 1),
                    max: DateTime(2026, 10, 31),
                    disabledDate: (d) => d.weekday == DateTime.sunday,
                    onChanged: (v) {
                      changes.add(v);
                      set(() => value = v);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
      VoidCallback? action(String label) => t
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, label))
          .onPressed;
      expect(action('Sunday'), isNull);
      expect(action('Outside'), isNull);
      expect(action('Disabled'), isNull);
      await t.tap(find.text('First'));
      await t.pump();
      expect(changes, hasLength(1));
      expect(value!.start, DateTime(2026, 10, 20));
      expect(value!.end, DateTime(2026, 10, 23));
      expect(form.currentState!.validate(), isTrue);
      await t.enterText(find.byType(TextFormField).first, 'invalid');
      await t.pump();
      expect(form.currentState!.validate(), isFalse);
      await t.tap(find.text('First'));
      await t.pump();
      expect(changes, hasLength(2));
      expect(form.currentState!.validate(), isTrue);
      expect(
        t.widget<EditableText>(find.byType(EditableText).first).controller.text,
        '2026-10-20',
      );
      final retained = action('First')!;
      set(() => locked = true);
      await t.pump();
      retained();
      expect(changes, hasLength(2));
      set(() {
        locked = false;
        enabled = false;
      });
      await t.pump();
      retained();
      expect(changes, hasLength(2));
      set(() {
        enabled = true;
        presets = [blocked];
      });
      await t.pump();
      retained();
      expect(changes, hasLength(2));
      final retainedClear = action('Clear range')!;
      set(() => clear = false);
      await t.pump();
      retainedClear();
      expect(changes, hasLength(2));
      set(() => clear = true);
      await t.pump();
      await t.tap(find.text('Clear range'));
      await t.pump();
      expect(changes, hasLength(3));
      expect(value, isNull);
      expect(form.currentState!.validate(), isFalse);
      await t.pumpWidget(const SizedBox());
      retained();
      retainedClear();
      expect(changes, hasLength(3));
    },
  );
  testWidgets('Malformed preset lists are rejected', (t) async {
    NgDateRangePreset preset(String id, String label, int start, int end) =>
        NgDateRangePreset(
          id: id,
          label: label,
          start: DateTime(2026, 10, start),
          end: DateTime(2026, 10, end),
        );
    for (final presets in [
      [preset('', 'Bad', 1, 2)],
      [preset('a', ' ', 1, 2)],
      [preset('a', 'Reverse', 4, 2)],
      [preset('a', 'One', 1, 2), preset('a', 'Two', 2, 3)],
    ]) {
      await t.pumpWidget(
        MaterialApp(home: NgDateRangePicker(value: null, presets: presets)),
      );
      expect(t.takeException(), isArgumentError);
      await t.pumpWidget(const SizedBox());
    }
  });
}
