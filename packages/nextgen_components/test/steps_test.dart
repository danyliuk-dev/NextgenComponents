import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  const steps = [
    NgStep('Contact'),
    NgStep('Unavailable', disabled: true),
    NgStep('Preferences', optional: true),
    NgStep('Review'),
  ];
  test('step contracts enforce enabled positions, bounds and linear flow', () {
    expect(NgStepRules.adjacent(steps, 0, 1), 2);
    expect(NgStepRules.adjacent(steps, 2, -1), 0);
    expect(NgStepRules.adjacent(steps, 3, 1), -1);
    expect(NgStepRules.canMove(steps, 0, 3, true), false);
    expect(NgStepRules.canMove(steps, 0, 2, true), true);
    expect(NgStepRules.canMove(steps, 3, 0, true), true);
    expect(NgStepRules.canMove(steps, 0, 3, false), true);
    expect(NgStepRules.canMove(steps, 0, 1, false), false);
    for (final value in [-1, 1, 4]) {
      expect(() => NgStepRules.validate(steps, value), throwsArgumentError);
    }
    expect(() => NgStepRules.adjacent(steps, 0, 0), throwsArgumentError);
    expect(() => NgStepRules.validate([], 0), throwsArgumentError);
    expect(
      () => NgStepRules.validate([const NgStep(' ')], 0),
      throwsArgumentError,
    );
  });
  testWidgets(
    'validation blocks forward, disabled steps skip and backward does not validate',
    (tester) async {
      int value = 0, calls = 0;
      bool valid = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => NgWizard(
                items: steps,
                value: value,
                onChanged: (v) => setState(() => value = v),
                validateStep: (i) async {
                  calls++;
                  return valid ? null : 'Name required';
                },
                contentBuilder: (_, i) => Text('Panel $i'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Name required'), findsOneWidget);
      expect(value, 0);
      valid = true;
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(value, 2);
      expect(find.text('Panel 2'), findsOneWidget);
      expect(calls, 2);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(value, 0);
      expect(calls, 2);
    },
  );
  testWidgets(
    'pending validator blocks duplicates and ignores an external reset',
    (tester) async {
      int value = 0, calls = 0;
      late StateSetter update;
      final pending = Completer<String?>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return NgWizard(
                  items: steps,
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                  validateStep: (i) {
                    calls++;
                    return pending.future;
                  },
                  contentBuilder: (_, i) => Text('Panel $i'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(calls, 1);
      expect(find.text('Checking…'), findsOneWidget);
      update(() => value = 3);
      await tester.pump();
      pending.complete(null);
      await tester.pumpAndSettle();
      expect(value, 3);
      expect(find.text('Panel 3'), findsOneWidget);
    },
  );
  testWidgets('finish can retry after failure and succeeds only once', (
    tester,
  ) async {
    int saves = 0;
    bool fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgWizard(
            items: const [NgStep('Save')],
            onFinish: () async {
              saves++;
              if (fail) throw StateError('private error');
            },
            contentBuilder: (_, _) => const Text('Review data'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to complete this action. Try again.'),
      findsOneWidget,
    );
    expect(find.text('private error'), findsNothing);
    fail = false;
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Completed.'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(saves, 2);
  });
  testWidgets('disposed pending validation cannot navigate', (tester) async {
    int calls = 0;
    final pending = Completer<String?>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgWizard(
            items: steps,
            validateStep: (_) => pending.future,
            onChanged: (_) => calls++,
            contentBuilder: (_, _) => const Text('Draft'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete(null);
    await tester.pump();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('stepper wraps at narrow width and shows validation states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgStepper(
            items: const [
              NgStep('First', valid: true),
              NgStep('Second', valid: false),
              NgStep('Third', optional: true),
            ],
            onChanged: (v) => selected = v,
          ),
        ),
      ),
    );
    expect(find.text('Needs attention'), findsOneWidget);
    await tester.tap(find.text('Third'));
    await tester.pump();
    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });
}
