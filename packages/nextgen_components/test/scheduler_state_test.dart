import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  final date = DateTime(2026, 10, 19);
  final event = NgScheduleEvent(
    'a',
    'Review',
    date.add(const Duration(hours: 10)),
    date.add(const Duration(hours: 11)),
  );
  Widget app(Widget child) => MaterialApp(
    theme: NgTheme.light(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
  test('week starts, complete display boundaries and required identity', () {
    expect(NgScheduleRules.weekStart(date, 7), DateTime(2026, 10, 18));
    expect(NgScheduleRules.weekStart(date, 3), DateTime(2026, 10, 14));
    expect(() => NgScheduleRules.weekStart(date, 0), throwsArgumentError);
    expect(
      NgScheduleRules.canDisplay(DateTime(2, 1, 1), NgScheduleView.day, 1),
      isTrue,
    );
    expect(
      NgScheduleRules.canDisplay(DateTime(1, 12, 31), NgScheduleView.day, 1),
      isFalse,
    );
    expect(
      NgScheduleRules.canDisplay(DateTime(9998, 12, 31), NgScheduleView.day, 1),
      isTrue,
    );
    expect(
      NgScheduleRules.canDisplay(
        DateTime(9998, 12, 31),
        NgScheduleView.week,
        1,
      ),
      isFalse,
    );
    expect(
      NgScheduleRules.validate(
        NgScheduleEvent(' ', 'Title', date, date.add(const Duration(hours: 1))),
      ),
      isNotNull,
    );
  });
  testWidgets(
    'controlled day view proposals can be rejected; daily create and navigation',
    (t) async {
      NgScheduleView? proposal;
      DateTime? moved, created;
      Widget build(NgScheduleView view) => app(
        NgScheduler(
          date: date,
          view: view,
          items: [event],
          onViewChanged: (v) => proposal = v,
          onDateChanged: (d) => moved = d,
          onCreate: (d) => created = d,
        ),
      );
      await t.pumpWidget(build(NgScheduleView.week));
      await t.tap(find.text('Day'));
      await t.pump();
      expect(proposal, NgScheduleView.day);
      expect(find.text('Next week'), findsOneWidget);
      await t.pumpWidget(build(proposal!));
      expect(find.text('+ Add'), findsOneWidget);
      await t.tap(find.text('Next day'));
      expect(moved, DateTime(2026, 10, 20));
      await t.tap(find.text('+ Add'));
      expect(created, date);
    },
  );
  testWidgets('independent locks and absent callbacks disable actions', (
    t,
  ) async {
    DateTime? moved;
    int edits = 0;
    await t.pumpWidget(
      app(
        NgScheduler(
          date: date,
          items: [event],
          view: NgScheduleView.day,
          readOnly: true,
          onDateChanged: (d) => moved = d,
          onEdit: (_) => edits++,
        ),
      ),
    );
    expect(
      t
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Review'),
              matching: find.byType(TextButton),
            ),
          )
          .onPressed,
      isNull,
    );
    await t.tap(find.text('Next day'));
    expect(moved, DateTime(2026, 10, 20));
    expect(edits, 0);
    await t.pumpWidget(
      app(
        NgScheduler(
          date: date,
          items: [event],
          view: NgScheduleView.day,
          navigationReadOnly: true,
          onDateChanged: (d) => moved = d,
          onEdit: (_) => edits++,
        ),
      ),
    );
    expect(
      t
          .widget<NgButton>(
            find.ancestor(
              of: find.text('Next day'),
              matching: find.byType(NgButton),
            ),
          )
          .onPressed,
      isNull,
    );
    await t.tap(find.text('Review'));
    expect(edits, 1);
    await t.pumpWidget(
      app(NgScheduler(date: date, items: [event], view: NgScheduleView.day)),
    );
    expect(
      t
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Review'),
              matching: find.byType(TextButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets(
    'captured actions reject changed data, locks, date and disposal',
    (t) async {
      int edits = 0, creates = 0, moves = 0;
      Widget build({
        List<NgScheduleEvent>? items,
        bool locked = false,
        DateTime? shown,
      }) => app(
        NgScheduler(
          date: shown ?? date,
          view: NgScheduleView.day,
          items: items ?? [event],
          readOnly: locked,
          onEdit: (_) => edits++,
          onCreate: (_) => creates++,
          onDateChanged: (_) => moves++,
        ),
      );
      await t.pumpWidget(build());
      final edit = t
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Review'),
              matching: find.byType(TextButton),
            ),
          )
          .onPressed!;
      final create = t
          .widget<NgButton>(
            find.ancestor(
              of: find.text('+ Add'),
              matching: find.byType(NgButton),
            ),
          )
          .onPressed!;
      final next = t
          .widget<NgButton>(
            find.ancestor(
              of: find.text('Next day'),
              matching: find.byType(NgButton),
            ),
          )
          .onPressed!;
      await t.pumpWidget(
        build(items: [NgScheduleEvent('a', 'Changed', event.start, event.end)]),
      );
      edit();
      expect(edits, 0);
      await t.pumpWidget(build(locked: true));
      edit();
      create();
      expect(edits + creates, 0);
      await t.pumpWidget(build(shown: DateTime(2026, 10, 20)));
      edit();
      create();
      next();
      expect(edits + creates + moves, 0);
      await t.pumpWidget(const SizedBox());
      edit();
      create();
      next();
      expect(edits + creates + moves, 0);
    },
  );
  testWidgets(
    'formatted overnight events, midnight exclusion and custom empty text',
    (t) async {
      final overnight = NgScheduleEvent(
        'night',
        'Night',
        DateTime(2026, 10, 18, 23),
        DateTime(2026, 10, 19, 1),
      );
      final midnight = NgScheduleEvent(
        'mid',
        'Midnight',
        DateTime(2026, 10, 18, 23),
        date,
      );
      await t.pumpWidget(
        app(
          NgScheduler(
            date: date,
            view: NgScheduleView.day,
            items: [overnight, midnight],
            eventLabel: (e) => 'Shift: ${e.title}',
          ),
        ),
      );
      expect(find.text('Shift: Night'), findsOneWidget);
      expect(find.text('Shift: Midnight'), findsNothing);
      await t.pumpWidget(
        app(
          NgScheduler(
            date: date,
            view: NgScheduleView.day,
            items: const [],
            emptyText: 'No shifts',
          ),
        ),
      );
      expect(find.text('No shifts'), findsOneWidget);
    },
  );
  testWidgets('date boundary disables navigation without overflowing', (
    t,
  ) async {
    for (final d in [DateTime(2, 1, 1), DateTime(9998, 12, 31)]) {
      await t.pumpWidget(
        app(
          NgScheduler(
            date: d,
            view: NgScheduleView.day,
            items: const [],
            onDateChanged: (_) {},
          ),
        ),
      );
      final name = d.year == 2 ? 'Previous day' : 'Next day';
      expect(
        t
            .widget<NgButton>(
              find.ancestor(
                of: find.text(name),
                matching: find.byType(NgButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(t.takeException(), isNull);
    }
  });
}
