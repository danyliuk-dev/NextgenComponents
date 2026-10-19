import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(
  theme: NgTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
VoidCallback? action(WidgetTester t, String text) => t
    .widget<NgButton>(
      find.ancestor(of: find.text(text), matching: find.byType(NgButton)),
    )
    .onPressed;
void main() {
  test(
    'protected paste is atomic including unchanged protected destinations',
    () {
      final s = NgSheet(
        rows: 2,
        columns: 3,
        cells: {'A1': '2', 'B1': 'locked', 'C1': '=A1*3'},
      );
      expect(
        () => s.paste('A1', '9\tlocked', canEdit: (a) => a != 'B1'),
        throwsArgumentError,
      );
      expect(s.raw('A1'), '2');
      final next = s.paste('a1', '9', canEdit: (a) => a == 'A1');
      expect(next.evaluate('C1').number, 27);
      expect(s.changedCells(next), ['A1']);
      expect(() => s.changedCells(NgSheet()), throwsArgumentError);
    },
  );
  testWidgets(
    'rejected edits preserve model, draft and history; accepted edits can undo',
    (t) async {
      var sheet = NgSheet(
        rows: 2,
        columns: 2,
        cells: {'A1': '2', 'B1': '=A1*3'},
      );
      bool accept = false;
      int proposals = 0;
      late StateSetter rebuild;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) {
              rebuild = set;
              return NgSpreadsheet(
                value: sheet,
                onChanged: (v) => set(() {
                  proposals++;
                  if (accept) sheet = v;
                }),
              );
            },
          ),
        ),
      );
      await t.enterText(find.byType(TextField).first, '5');
      await t.tap(find.text('Apply cell'));
      await t.pump();
      expect(sheet.raw('A1'), '2');
      expect(find.text('6'), findsOneWidget);
      expect(action(t, 'Undo'), isNull);
      expect(
        t.widget<TextField>(find.byType(TextField).first).controller!.text,
        '5',
      );
      rebuild(() => accept = true);
      await t.pump();
      await t.tap(find.text('Apply cell'));
      await t.pump();
      expect(sheet.raw('A1'), '5');
      expect(find.text('15'), findsOneWidget);
      rebuild(() => accept = false);
      await t.pump();
      await t.tap(find.text('Undo'));
      await t.pump();
      expect(sheet.raw('A1'), '5');
      expect(action(t, 'Undo'), isNotNull);
      expect(action(t, 'Redo'), isNull);
      rebuild(() => accept = true);
      await t.pump();
      await t.tap(find.text('Undo'));
      await t.pump();
      expect(sheet.raw('A1'), '2');
      expect(action(t, 'Redo'), isNotNull);
      expect(proposals, 4);
    },
  );
  testWidgets(
    'protection guards edits, paste and history but permits inspection',
    (t) async {
      var sheet = NgSheet(
        rows: 2,
        columns: 2,
        cells: {'A1': '2', 'B1': '=A1*3'},
      );
      bool protectA = false;
      late StateSetter rebuild;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) {
              rebuild = set;
              return NgSpreadsheet(
                value: sheet,
                canEdit: (a) => a != 'B1' && (!protectA || a != 'A1'),
                onChanged: (v) => set(() => sheet = v),
              );
            },
          ),
        ),
      );
      await t.enterText(find.byType(TextField).first, '4');
      await t.tap(find.text('Apply cell'));
      await t.pump();
      expect(sheet.evaluate('B1').number, 12);
      rebuild(() => protectA = true);
      await t.pump();
      expect(action(t, 'Undo'), isNull);
      expect(action(t, 'Apply cell'), isNull);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Read-only'), findsOneWidget);
      rebuild(() => protectA = false);
      await t.pump();
      await t.tap(find.text('Paste cells'));
      await t.pump();
      await t.enterText(find.byType(TextField).last, '8\t9');
      await t.ensureVisible(find.text('Paste at A1'));
      await t.tap(find.text('Paste at A1'));
      await t.pump();
      expect(sheet.raw('A1'), '4');
      expect(sheet.raw('B1'), '=A1*3');
      expect(find.textContaining('Cell B1 is protected'), findsOneWidget);
      await t.ensureVisible(find.text('12'));
      await t.tap(find.text('12'));
      await t.pump();
      expect(find.text('=A1*3'), findsOneWidget);
      expect(find.text('Read-only'), findsOneWidget);
      expect(action(t, 'Apply cell'), isNull);
    },
  );
  testWidgets('absent callback is readonly and no-op produces no history', (
    t,
  ) async {
    final sheet = NgSheet(rows: 1, columns: 1, cells: {'A1': '2'});
    int proposals = 0;
    await t.pumpWidget(app(NgSpreadsheet(value: sheet)));
    expect(action(t, 'Apply cell'), isNull);
    expect(find.text('Paste cells'), findsNothing);
    await t.pumpWidget(
      app(NgSpreadsheet(value: sheet, onChanged: (_) => proposals++)),
    );
    await t.tap(find.text('Apply cell'));
    await t.pump();
    expect(proposals, 0);
    expect(action(t, 'Undo'), isNull);
    expect(find.text('No changes.'), findsOneWidget);
  });
  testWidgets(
    'stale actions cannot modify replacement sheet or bypass new locks',
    (t) async {
      var sheet = NgSheet(rows: 2, columns: 2, cells: {'A1': '2'});
      bool locked = false, protect = false;
      int proposals = 0;
      late StateSetter rebuild;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) {
              rebuild = set;
              return NgSpreadsheet(
                value: sheet,
                readOnly: locked,
                canEdit: (_) => !protect,
                onChanged: (v) => set(() {
                  sheet = v;
                  proposals++;
                }),
              );
            },
          ),
        ),
      );
      await t.enterText(find.byType(TextField).first, '7');
      final apply = action(t, 'Apply cell')!;
      rebuild(() => locked = true);
      await t.pump();
      apply();
      expect(proposals, 0);
      rebuild(() {
        locked = false;
        protect = true;
      });
      await t.pump();
      apply();
      expect(proposals, 0);
      rebuild(() {
        protect = false;
        sheet = NgSheet(rows: 1, columns: 1, cells: {'A1': '30'});
      });
      await t.pump();
      apply();
      expect(proposals, 0);
      expect(find.text('30'), findsWidgets);
      await t.pumpWidget(const SizedBox());
      apply();
      expect(proposals, 0);
    },
  );
  testWidgets('independent replacement clears history and repairs selection', (
    t,
  ) async {
    var sheet = NgSheet(rows: 2, columns: 2, cells: {'A1': '2', 'B2': '9'});
    late StateSetter rebuild;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) {
            rebuild = set;
            return NgSpreadsheet(
              value: sheet,
              onChanged: (v) => set(() => sheet = v),
            );
          },
        ),
      ),
    );
    await t.enterText(find.byType(TextField).first, '7');
    await t.tap(find.text('Apply cell'));
    await t.pump();
    expect(action(t, 'Undo'), isNotNull);
    await t.tap(find.text('9'));
    await t.pump();
    expect(find.text('B2'), findsOneWidget);
    rebuild(() => sheet = NgSheet(rows: 1, columns: 1, cells: {'A1': '42'}));
    await t.pump();
    expect(find.text('A1'), findsOneWidget);
    expect(action(t, 'Undo'), isNull);
    expect(action(t, 'Redo'), isNull);
  });
}
