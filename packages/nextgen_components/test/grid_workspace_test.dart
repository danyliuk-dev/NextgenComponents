import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test(
    'nested groups preserve first appearance, ordered rows and unique paths',
    () {
      final groups = ngGroupTree<String>(
        ['A/x/1', 'B/x/2', 'A/y/3', 'A/x/4'],
        [(s) => s.split('/')[0], (s) => s.split('/')[1]],
      );
      expect(groups.map((g) => g.key), ['A', 'B']);
      expect(groups.first.items, ['A/x/1', 'A/x/4', 'A/y/3']);
      expect(groups.first.children.map((g) => g.key), ['x', 'y']);
      expect(ngAllGroups(groups).map((g) => g.id).toSet().length, 5);
      expect(ngGroupId(['a:', 'b']), isNot(ngGroupId(['a', ':b'])));
      expect(ngGroupId(['']), '0:');
      expect(
        () => ngGroupTree(
          ['a'],
          List.generate(
            9,
            (_) =>
                (String s) => s,
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'aggregates ignore missing and nonfinite values, average original records',
    () {
      final rows = <double?>[2, 4, null, double.nan, double.infinity, 12];
      for (final entry in {
        'sum': 18.0,
        'average': 6.0,
        'min': 2.0,
        'max': 12.0,
        'count': 3.0,
      }.entries) {
        expect(
          NgGroupAggregate<double?>(
            'Value',
            (v) => v,
            operation: entry.key,
          ).calculate(rows),
          entry.value,
        );
      }
      expect(NgGroupAggregate<double?>('Sum', (v) => v).calculate([]), 0);
      expect(
        NgGroupAggregate<double?>(
          'Mean',
          (v) => v,
          operation: 'average',
        ).calculate([null]),
        isNull,
      );
      expect(
        NgGroupAggregate<double?>(
          'Custom',
          (v) => v,
          format: (v) => '${v!.toInt()} units',
        ).text([2]),
        'Custom: 2 units',
      );
      expect(
        () => NgGroupAggregate<int>(
          'Bad',
          (v) => v.toDouble(),
          operation: 'bad',
        ).calculate([]),
        throwsArgumentError,
      );
    },
  );
  testWidgets(
    'nested collapse preserves paging, aggregates and selection; bulk uses filtered groups',
    (t) async {
      var collapsed = <String>{'unknown'};
      final original = collapsed;
      var selected = <String>{'A/x/1', 'hidden'};
      var readOnly = false, accept = true, enabled = true;
      var calls = 0;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (c, set) {
                update = set;
                return NgDataGrid<String>(
                  items: const ['A/x/1', 'B/x/2', 'A/y/3', 'A/x/4'],
                  columns: [NgDataColumn('id', 'ID', (s) => s)],
                  rowId: (s) => s,
                  groupSelectors: [
                    (s) => s.split('/')[0],
                    (s) => s.split('/')[1],
                  ],
                  groupAggregates: [
                    NgGroupAggregate(
                      'Sum',
                      (s) => double.parse(s.split('/')[2]),
                    ),
                  ],
                  collapsibleGroups: enabled,
                  collapsedGroups: collapsed,
                  groupExpansionReadOnly: readOnly,
                  onCollapsedGroupsChanged: (v) {
                    calls++;
                    if (accept) set(() => collapsed = v);
                  },
                  selectedIds: selected,
                  onSelectionChanged: (v) => set(() => selected = v),
                  initialPageSize: 2,
                  pageSizes: const [2, 4],
                );
              },
            ),
          ),
        ),
      );
      Finder toggle(String label) => find.ancestor(
        of: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == label,
        ),
        matching: find.byType(TextButton),
      );
      final semantics = t.ensureSemantics();
      try {
        final node = t.getSemantics(toggle('Collapse A / x'));
        expect(node.flagsCollection.isButton, isTrue);
        expect(node.flagsCollection.isExpanded, Tristate.isTrue);
      } finally {
        semantics.dispose();
      }
      expect(find.text(' · Sum: 8'), findsOneWidget);
      expect(find.text(' · Sum: 5'), findsOneWidget);
      final staleRow = t
          .widget<Checkbox>(find.byType(Checkbox).at(1))
          .onChanged!;
      final stalePage = t
          .widget<Checkbox>(find.byType(Checkbox).first)
          .onChanged!;
      await t.tap(toggle('Collapse A / x'));
      await t.pump();
      expect(collapsed, {
        'unknown',
        ngGroupId(['A', 'x']),
      });
      expect(original, {'unknown'});
      expect(find.text('A/x/1'), findsNothing);
      expect(find.text('1–2 of 4'), findsOneWidget);
      expect(t.widget<Checkbox>(find.byType(Checkbox).first).onChanged, isNull);
      staleRow(true);
      stalePage(true);
      await t.pump();
      expect(selected, {'A/x/1', 'hidden'});
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      expect(find.text('A/y/3'), findsOneWidget);
      expect(find.text('B/x/2'), findsOneWidget);
      await t.tap(toggle('Collapse A'));
      await t.pump();
      expect(find.text('A/y/3'), findsNothing);
      expect(find.text('B/x/2'), findsOneWidget);
      await t.tap(find.byType(Checkbox).first);
      await t.pump();
      expect(selected, {'A/x/1', 'hidden', 'B/x/2'});
      await t.enterText(find.byType(TextField), 'A/');
      await t.pump();
      await t.tap(find.widgetWithText(TextButton, 'Collapse all groups'));
      await t.pump();
      expect(collapsed, {
        'unknown',
        ngGroupId(['A']),
        ngGroupId(['A', 'x']),
        ngGroupId(['A', 'y']),
      });
      await t.tap(find.widgetWithText(TextButton, 'Expand all groups'));
      await t.pump();
      expect(collapsed, {'unknown'});
      expect(find.text('A/x/1'), findsOneWidget);
      final staleToggle = t.widget<TextButton>(toggle('Collapse A')).onPressed!;
      final staleBulk = t
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Collapse all groups'),
          )
          .onPressed!;
      update(() => readOnly = true);
      await t.pump();
      final before = calls;
      staleToggle();
      staleBulk();
      await t.pump();
      expect(calls, before);
      update(() {
        readOnly = false;
        accept = false;
      });
      await t.pump();
      await t.tap(toggle('Collapse A'));
      await t.pump();
      expect(collapsed, {'unknown'});
      expect(calls, before + 1);
      update(() {
        accept = true;
        collapsed = {
          ngGroupId(['A']),
          'unknown',
        };
        enabled = false;
      });
      await t.pump();
      expect(find.text('A/x/1'), findsOneWidget);
      staleToggle();
      staleBulk();
      await t.pump();
      expect(calls, before + 1);
      update(() => enabled = true);
      await t.pump();
      expect(find.text('A/x/1'), findsNothing);
      await t.enterText(find.byType(TextField), 'B/');
      await t.pump();
      staleToggle();
      await t.pump();
      expect(calls, before + 1);
      expect(find.text(' · Sum: 2'), findsNWidgets(2));
    },
  );
  testWidgets(
    'external collapse is honored without callback and all controls are locked',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NgDataGrid<String>(
              items: const ['a'],
              columns: [NgDataColumn('id', 'ID', (s) => s)],
              rowId: (s) => s,
              groupBy: (s) => s,
              collapsibleGroups: true,
              collapsedGroups: {
                ngGroupId(['a']),
              },
            ),
          ),
        ),
      );
      expect(find.text('a'), findsNothing);
      expect(
        t
            .widgetList<TextButton>(find.byType(TextButton))
            .every((b) => b.onPressed == null),
        isTrue,
      );
    },
  );
}
