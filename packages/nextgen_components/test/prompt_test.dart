import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test(
    'Cancel reaches provider and a late completion cannot overwrite a newer response',
    () async {
      final session = NgPromptSession(), pending = Completer<String>();
      late NgPromptCancellation token;
      final old = session.run(' old ', (p, c) {
        expect(p, 'old');
        token = c;
        return pending.future;
      });
      expect(session.isBusy, isTrue);
      expect(
        await session.run('duplicate', (_, _) async => 'duplicate'),
        isNull,
      );
      session.cancel();
      expect(token.isCancelled, isTrue);
      await token.whenCancelled;
      await session.run('new', (_, _) async => 'new response');
      pending.complete('late');
      expect(await old, isNull);
      expect(session.responses.single.text, 'new response');
      session.dispose();
    },
  );
  test(
    'Errors preserve history, validate limits and clearing rejects late work',
    () async {
      final session = NgPromptSession();
      await expectLater(
        session.run(' ', (_, _) async => 'bad'),
        throwsArgumentError,
      );
      await expectLater(
        session.run('x' * 8001, (_, _) async => 'bad'),
        throwsArgumentError,
      );
      await session.run('good', (_, _) async => 'good');
      await session.run(
        'bad',
        (_, _) => throw StateError('private provider details'),
      );
      expect(session.error, 'Generation failed. Try again.');
      expect(session.responses.length, 1);
      for (final output in [' ', 'x' * 32001]) {
        await session.run('invalid', (_, _) async => output);
        expect(session.error, isNotNull);
      }
      for (var i = 0; i < 22; i++) {
        await session.run('history $i', (_, _) async => 'ok');
      }
      expect(session.responses.length, 20);
      expect(session.responses.first.prompt, 'history 2');
      expect(() => session.responses.clear(), throwsUnsupportedError);
      final pending = Completer<String>();
      final old = session.run('clear', (_, _) => pending.future);
      session.clear();
      pending.complete('late');
      expect(await old, isNull);
      expect(session.responses, isEmpty);
      session.dispose();
    },
  );
  test('Disposed sessions do not notify on late result', () async {
    final session = NgPromptSession(), pending = Completer<String>();
    var notices = 0;
    session.addListener(() => notices++);
    final old = session.run('request', (_, _) => pending.future);
    session.dispose();
    pending.complete('late');
    expect(await old, isNull);
    expect(notices, 1);
  });
  testWidgets(
    'PromptBox uses UTF-16 bounds, trims submission and accepts external replacement',
    (tester) async {
      String? submitted;
      Widget box(String value) => MaterialApp(
        home: Scaffold(
          body: NgPromptBox(
            value: value,
            maxLength: 6,
            onSubmit: (v) => submitted = v,
          ),
        ),
      );
      await tester.pumpWidget(box(''));
      await tester.enterText(find.byType(TextField), '😀😀😀😀');
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      await tester.enterText(find.byType(TextField), ' ok ');
      await tester.pump();
      await tester.tap(find.text('Send'));
      expect(submitted, 'ok');
      await tester.pumpWidget(box('reset'));
      expect(find.text('reset'), findsOneWidget);
    },
  );
  testWidgets(
    'AI request, feedback, regenerate, cancellation and read-only state',
    (tester) async {
      final pending = Completer<String>();
      var calls = 0, completed = 0;
      NgPromptFeedback? feedback;
      Widget page({bool readOnly = false}) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NgAIPrompt(
              value: 'draft',
              readOnly: readOnly,
              suggestions: const ['Suggestion'],
              generate: (p, c) {
                calls++;
                return calls == 1
                    ? Future.value('<b>plain response</b>')
                    : pending.future;
              },
              onCompleted: (_) => completed++,
              onFeedback: (v) => feedback = v,
            ),
          ),
        ),
      );
      await tester.pumpWidget(page());
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.text('<b>plain response</b>'), findsOneWidget);
      expect(completed, 1);
      await tester.ensureVisible(find.text('Helpful'));
      await tester.tap(find.text('Helpful'));
      await tester.pump();
      expect(feedback?.helpful, true);
      await tester.tap(find.text('Helpful'));
      await tester.pump();
      expect(feedback?.helpful, isNull);
      await tester.tap(find.text('Regenerate'));
      await tester.pump();
      expect(find.text('Generating…'), findsOneWidget);
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      pending.complete('late result');
      await tester.pumpAndSettle();
      expect(find.text('late result'), findsNothing);
      expect(completed, 1);
      await tester.pumpWidget(page(readOnly: true));
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    },
  );
  testWidgets(
    'Provider error supports retry and successful result clears error',
    (tester) async {
      var fail = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NgAIPrompt(
                value: 'request',
                generate: (_, _) async {
                  if (fail) throw StateError('secret');
                  return 'recovered';
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.text('Generation failed. Try again.'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Retry request'));
      await tester.pumpAndSettle();
      expect(find.text('recovered'), findsOneWidget);
      expect(find.text('Generation failed. Try again.'), findsNothing);
    },
  );
}
