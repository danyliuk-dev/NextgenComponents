import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget app(Widget child) => MaterialApp(
  theme: NgTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  test('formula precedence, references, ranges and dependency updates', () {
    final s = NgSheet(
      cells: {
        'A1': '10',
        'A2': '20',
        'A3': 'text',
        'B1': '=A1+A2*2',
        'B2': '=SUM(A1:A3)',
        'B3': '=AVERAGE(A1:A3)',
        'C1': '=-(2+3)*4/2',
        'C2': '=COUNT(A1:A3)',
        'C3': '=MIN(A1:A3)+MAX(A1:A3)',
      },
    );
    expect(s.evaluate('B1').number, 50);
    expect(s.evaluate('B2').number, 30);
    expect(s.evaluate('B3').number, 15);
    expect(s.evaluate('C1').number, -10);
    expect(s.evaluate('C2').number, 2);
    expect(s.evaluate('C3').number, 30);
    final edited = s.set('A1', '50');
    expect(edited.evaluate('B1').number, 90);
    expect(s.evaluate('B1').number, 50);
  });
  test(
    'formula failures propagate and malicious/unsupported text is never executed',
    () {
      for (final e in {
        '=1/0': '#DIV/0!',
        '=Z99': '#REF!',
        '=UNKNOWN(1)': '#NAME?',
        '=1+': '#FORMULA!',
        '=1e309': '#NUM!',
        '=A2+1': '#VALUE!',
        '=A1': '#CYCLE!',
      }.entries) {
        expect(
          NgSheet(cells: {'A1': e.key, 'A2': 'text'}).evaluate('A1').error,
          e.value,
        );
      }
      expect(
        NgSheet(cells: {'A1': '=B1', 'B1': '=A1'}).evaluate('A1').error,
        '#CYCLE!',
      );
      expect(
        NgSheet(cells: {'A1': '=AVERAGE(B1:B3)'}).evaluate('A1').error,
        '#DIV/0!',
      );
      expect(
        NgSheet(
          cells: {'A1': '=SUM(B1:B3)', 'B1': '=1/0'},
        ).evaluate('A1').error,
        '#DIV/0!',
      );
    },
  );
  test('large average stays finite', () {
    expect(
      NgSheet(
        cells: {'A1': '1e308', 'A2': '1e308', 'B1': '=AVERAGE(A1:A2)'},
      ).evaluate('B1').number,
      1e308,
    );
  });
  test('shared dependency fanout is cached and nesting bounded', () {
    final cells = {'A1': '1'};
    for (var r = 2; r <= 80; r++) {
      cells['A$r'] = '=A${r - 1}+A${r - 1}';
    }
    expect(NgSheet(rows: 80, cells: cells).evaluate('A80').number, isNotNull);
    expect(
      NgSheet(cells: {'A1': '=${'(' * 70}1${')' * 70}'}).evaluate('A1').error,
      '#LIMIT!',
    );
    expect(NgSheet.format(1e20), '1e+20');
  });
  test('paste is atomic, preserves formulas and rejects oversized blocks', () {
    final s = NgSheet(rows: 3, columns: 3, cells: {'A1': 'old'});
    final next = s.paste('A1', '2\t3\r\n=SUM(A1:B1)\ttext');
    expect(next.evaluate('A2').number, 5);
    expect(s.raw('A1'), 'old');
    expect(() => s.paste('C3', '1\t2'), throwsArgumentError);
    expect(s.raw('C3'), '');
    expect(() => s.set('A1', 'x' * 1001), throwsArgumentError);
  });
  final records = [
    NgPivotRecord('1', {'Team': 'A', 'Quarter': 'Q1'}, 10),
    NgPivotRecord('2', {'Team': 'A', 'Quarter': 'Q1'}, 20),
    NgPivotRecord('3', {'Team': 'B', 'Quarter': 'Q2'}, 90),
    NgPivotRecord('4', {'Team': '', 'Quarter': 'Q2'}, null),
  ];
  test(
    'pivot averages weight source records; count includes null; blank differs from total',
    () {
      expect(NgPivotMath.aggregate(records, NgAggregate.average), 40);
      expect(NgPivotMath.aggregate(records, NgAggregate.count), 4);
      expect(NgPivotMath.aggregate(records, NgAggregate.sum), 120);
      expect(NgPivotMath.aggregate(records, NgAggregate.min), 10);
      expect(NgPivotMath.aggregate(records, NgAggregate.max), 90);
      expect(
        NgPivotMath.filter(records, 'Team', 'Quarter', '', null).length,
        1,
      );
      expect(
        NgPivotMath.filter(records, 'Team', 'Quarter', null, null).length,
        4,
      );
      expect(NgPivotMath.aggregate([], NgAggregate.sum), isNull);
      expect(
        () => NgPivotMath.validate([records.first, records.first]),
        throwsArgumentError,
      );
      expect(
        () => NgPivotMath.validate([NgPivotRecord('x', {}, double.infinity)]),
        throwsArgumentError,
      );
    },
  );
  testWidgets('sheet edit, undo, redo, selection and atomic paste', (t) async {
    NgSheet s = NgSheet(rows: 3, columns: 3, cells: {'A1': '2', 'B1': '=A1*3'});
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) =>
              NgSpreadsheet(value: s, onChanged: (v) => set(() => s = v)),
        ),
      ),
    );
    await t.enterText(find.byType(TextField).first, '5');
    await t.tap(find.text('Apply cell'));
    await t.pump();
    expect(s.evaluate('B1').number, 15);
    await t.tap(find.text('Undo'));
    await t.pump();
    expect(s.evaluate('B1').number, 6);
    await t.tap(find.text('Redo'));
    await t.pump();
    expect(s.evaluate('B1').number, 15);
    await t.tap(find.text('15'));
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await t.pump();
    expect(find.text('B2'), findsOneWidget);
    await t.tap(find.text('Paste cells'));
    await t.pump();
    await t.enterText(find.byType(TextField).last, '7\t8');
    await t.ensureVisible(find.text('Paste at B2'));
    await t.tap(find.text('Paste at B2'));
    await t.pump();
    expect(s.raw('C2'), '8');
  });
  testWidgets('pivot drilldown returns original records and empty state', (
    t,
  ) async {
    NgPivotSelection? selected;
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      app(NgPivotGrid(items: records, onCellSelected: (s) => selected = s)),
    );
    await t.tap(find.bySemanticsLabel('A / Q1: 30'));
    await t.pump();
    expect(selected?.records.map((r) => r.id), ['1', '2']);
    await t.pumpWidget(app(const NgPivotGrid(items: [])));
    expect(find.text('No pivot data.'), findsOneWidget);
    semantics.dispose();
  });
}
