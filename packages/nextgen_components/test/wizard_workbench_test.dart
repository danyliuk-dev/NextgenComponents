import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  const steps = [NgStep('Contact'), NgStep('Review', optional: true)];
  test('presentation rejects unknown modes, positions and empty labels', () {
    expect(() => NgStepRules.validatePresentation(' '), throwsArgumentError);
    expect(
      () => NgStepRules.validatePresentation('Progress', 'icons'),
      throwsArgumentError,
    );
    expect(
      () => NgStepRules.validatePresentation('Progress', 'all', 'left'),
      throwsArgumentError,
    );
  });
  testWidgets('indicator-only templates preserve complete accessible names', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgStepper(
            items: steps,
            value: 1,
            rtl: true,
            displayMode: 'indicators',
            onChanged: (_) {},
            indicatorBuilder: (_, s) => const Text('X'),
          ),
        ),
      ),
    );
    expect(find.text('Review'), findsNothing);
    expect(find.bySemanticsLabel('Step 2: Review, Optional'), findsOneWidget);
    expect(
      t.getCenter(find.text('X').first).dx,
      greaterThan(t.getCenter(find.text('X').last).dx),
    );
    semantics.dispose();
  });
  testWidgets(
    'custom actions use guard then validator and rejected transitions stay put',
    (t) async {
      var value = 0;
      var allow = false;
      final log = <String>[];
      late NgWizardActions actions;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, set) => NgWizard(
                items: steps,
                value: value,
                onChanged: (v) {
                  log.add('change');
                  set(() => value = v);
                },
                beforeChange: (change) async {
                  log.add(
                    'guard:${change.current}:${change.target}:${change.isFinish}',
                  );
                  return allow;
                },
                validateStep: (i) async {
                  log.add('validate');
                  return null;
                },
                actionsBuilder: (_, a) {
                  actions = a;
                  return TextButton(
                    onPressed: a.canNext ? a.next : null,
                    child: const Text('Proceed'),
                  );
                },
                contentBuilder: (_, i) => Text('Panel $i'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Proceed'));
      await t.pumpAndSettle();
      expect(value, 0);
      expect(log, ['guard:0:1:false']);
      allow = true;
      log.clear();
      await t.tap(find.text('Proceed'));
      await t.pumpAndSettle();
      expect(value, 1);
      expect(log, ['guard:0:1:false', 'validate', 'change']);
      log.clear();
      await actions.back();
      await t.pumpAndSettle();
      expect(value, 0);
      expect(log, ['guard:1:0:false', 'change']);
    },
  );
  testWidgets(
    'reset at same step cancels stale guard and duplicate custom actions',
    (t) async {
      var value = 0, reset = 0, calls = 0;
      late StateSetter update;
      late NgWizardActions actions;
      final pending = Completer<bool>();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, set) {
                update = set;
                return NgWizard(
                  items: steps,
                  value: value,
                  resetKey: reset,
                  onChanged: (v) => set(() => value = v),
                  beforeChange: (_) {
                    calls++;
                    return pending.future;
                  },
                  actionsBuilder: (_, a) {
                    actions = a;
                    return const Text('Actions');
                  },
                  contentBuilder: (_, i) => Text('Panel $i'),
                );
              },
            ),
          ),
        ),
      );
      final cached = actions;
      final first = cached.next();
      await t.pump();
      await cached.next();
      expect(calls, 1);
      update(() => reset++);
      await t.pump();
      pending.complete(true);
      await first;
      await t.pumpAndSettle();
      expect(value, 0);
      expect(actions.busy, false);
      expect(actions.canNext, true);
    },
  );
  testWidgets(
    'finish guard and completion reset work with one step and cached handlers',
    (t) async {
      var reset = 0, saves = 0;
      var allow = false;
      late StateSetter update;
      late NgWizardActions actions;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, set) {
                update = set;
                return NgWizard(
                  items: const [NgStep('Review')],
                  resetKey: reset,
                  beforeChange: (c) async {
                    expect(c.isFinish, true);
                    return allow;
                  },
                  onFinish: () async {
                    saves++;
                  },
                  actionsBuilder: (_, a) {
                    actions = a;
                    return const Text('Actions');
                  },
                  contentBuilder: (_, i) => const Text('Summary'),
                );
              },
            ),
          ),
        ),
      );
      await actions.finish();
      await t.pumpAndSettle();
      expect(saves, 0);
      allow = true;
      final cached = actions;
      await cached.finish();
      await t.pumpAndSettle();
      await cached.finish();
      expect(saves, 1);
      expect(actions.finished, true);
      update(() => reset++);
      await t.pumpAndSettle();
      expect(actions.canFinish, true);
      await actions.finish();
      await t.pumpAndSettle();
      expect(saves, 2);
    },
  );
  testWidgets(
    'all four layouts mirror logical sides and missing callback disables movement',
    (t) async {
      for (final position in ['top', 'bottom', 'start', 'end']) {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NgWizard(
                items: steps,
                position: position,
                rtl: true,
                contentBuilder: (_, i) => const Text('Content'),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final rail = t.getCenter(find.byType(NgStepper)),
            body = t.getCenter(find.text('Content'));
        if (position == 'top') expect(rail.dy, lessThan(body.dy));
        if (position == 'bottom') expect(rail.dy, greaterThan(body.dy));
        if (position == 'start') expect(rail.dx, greaterThan(body.dx));
        if (position == 'end') expect(rail.dx, lessThan(body.dx));
        expect(
          t.widget<NgButton>(find.widgetWithText(NgButton, 'Next')).onPressed,
          isNull,
        );
        expect(t.takeException(), isNull);
      }
    },
  );
}
