import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

class RowData {
  final String id, name;
  final int amount;
  const RowData(this.id, this.name, this.amount);
}

const rows = [
  RowData('a', 'Alpha', 120),
  RowData('b', 'Beta', 9000),
  RowData('c', 'Gamma', 75),
  RowData('d', 'Delta', 120),
];
final columns = [
  NgDataColumn<RowData>('name', 'Name', (r) => r.name),
  NgDataColumn<RowData>('amount', 'Budget', (r) => r.amount),
];
const tree = [
  NgTreeNode(
    'root',
    'Root',
    children: [
      NgTreeNode('a', 'Alpha'),
      NgTreeNode('b', 'Beta', children: [NgTreeNode('c', 'Child')]),
      NgTreeNode('disabled', 'Locked', disabled: true),
    ],
  ),
];
Widget app(Widget child) => MaterialApp(
  theme: NgTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  test(
    'query sorts numbers stably, filters before paging and preserves input',
    () {
      expect(
        NgDataOperations.query(
          rows,
          columns,
          '',
          'amount',
          false,
        ).map((r) => r.id),
        ['c', 'a', 'd', 'b'],
      );
      expect(
        NgDataOperations.query(
          rows,
          columns,
          '',
          'amount',
          true,
        ).map((r) => r.id),
        ['b', 'a', 'd', 'c'],
      );
      expect(
        NgDataOperations.query(
          rows,
          columns,
          ' ALP ',
          'amount',
          false,
        ).map((r) => r.id),
        ['a'],
      );
      expect(rows.first.id, 'a');
      expect(NgDataOperations.clampPage(9, 0, 5), 1);
      expect(NgDataOperations.clampPage(9, 6, 5), 2);
    },
  );
  test(
    'tree search retains ancestors, expansion and sibling sorting preserve hierarchy',
    () {
      expect(
        NgDataOperations.flatten(tree, {}, (s) => s).map((r) => r.node.id),
        ['root'],
      );
      final found = NgDataOperations.flatten(
        tree,
        {},
        (s) => s,
        search: 'child',
      );
      expect(found.map((r) => r.node.id), ['root', 'b', 'c']);
      expect(found.map((r) => r.depth), [0, 1, 2]);
      final sorted = NgDataOperations.flatten(
        tree,
        {'root', 'b'},
        (s) => s,
        compareNodes: (a, b) => b.item.compareTo(a.item),
      );
      expect(sorted.map((r) => r.node.id), ['root', 'disabled', 'b', 'c', 'a']);
      expect(
        () => NgDataOperations.flatten(
          [const NgTreeNode('x', 'One'), const NgTreeNode('x', 'Two')],
          {},
          (s) => s,
        ),
        throwsArgumentError,
      );
    },
  );
  testWidgets('pager exposes one accessible action per named button', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    var page = 1;
    await t.pumpWidget(
      app(
        NgPager(
          total: 18,
          page: page,
          pageSize: 5,
          onPageChanged: (v) => page = v,
          onPageSizeChanged: (_) {},
        ),
      ),
    );
    expect(find.bySemanticsLabel('Next page'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Next page'));
    await t.pump();
    expect(page, 2);
    semantics.dispose();
  });
  testWidgets(
    'grid selection persists across page and sort; input sets not mutated',
    (t) async {
      final original = <String>{};
      Set<String> selection = original;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) => NgDataGrid<RowData>(
              items: rows,
              columns: columns,
              rowId: (r) => r.id,
              initialPageSize: 2,
              selectedIds: selection,
              onSelectionChanged: (v) => set(() => selection = v),
            ),
          ),
        ),
      );
      await t.tap(find.byType(Checkbox).at(1));
      await t.pump();
      expect(selection, {'a'});
      expect(original, isEmpty);
      await t.ensureVisible(find.byTooltip('Next page'));
      await t.tap(find.byTooltip('Next page'));
      await t.pump();
      expect(find.text('Gamma'), findsOneWidget);
      expect(selection, {'a'});
      await t.ensureVisible(find.text('Budget'));
      await t.tap(find.text('Budget'));
      await t.pump();
      expect(selection, {'a'});
    },
  );
  testWidgets('grid clamps page after source shrink and shows empty state', (
    t,
  ) async {
    List<RowData> source = rows;
    late StateSetter update;
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) {
            update = set;
            return NgDataGrid<RowData>(
              items: source,
              columns: columns,
              rowId: (r) => r.id,
              initialPageSize: 2,
            );
          },
        ),
      ),
    );
    await t.ensureVisible(find.byTooltip('Last page'));
    await t.tap(find.byTooltip('Last page'));
    await t.pump();
    update(() => source = [rows.first]);
    await t.pump();
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == 'Alpha'),
      findsOneWidget,
    );
    expect(find.text('1–1 of 1'), findsOneWidget);
    update(() => source = []);
    await t.pump();
    expect(find.text('No matching records.'), findsOneWidget);
    expect(find.text('0–0 of 0'), findsOneWidget);
  });
  testWidgets('grid search resets page and returns only matching rows', (
    t,
  ) async {
    await t.pumpWidget(
      app(
        NgDataGrid<RowData>(
          items: rows,
          columns: columns,
          rowId: (r) => r.id,
          initialPageSize: 2,
        ),
      ),
    );
    await t.tap(find.byTooltip('Last page'));
    await t.pump();
    await t.enterText(find.byType(TextField), 'Alpha');
    await t.pump();
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == 'Alpha'),
      findsOneWidget,
    );
    expect(find.text('1–1 of 1'), findsOneWidget);
  });
  testWidgets(
    'tree keyboard selects, disabled node cannot select, filter shows path',
    (t) async {
      Set<String> expanded = {'root'};
      String? selected;
      await t.pumpWidget(
        app(
          StatefulBuilder(
            builder: (c, set) => NgTreeView<String>(
              items: tree,
              text: (s) => s,
              expandedIds: expanded,
              onExpandedChanged: (v) => set(() => expanded = v),
              selectedId: selected,
              onSelected: (v) => set(() => selected = v),
            ),
          ),
        ),
      );
      await t.tap(find.text('Alpha'));
      await t.pump();
      expect(selected, 'a');
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pump();
      expect(selected, 'b');
      await t.tap(find.text('Locked'));
      await t.pump();
      expect(selected, 'b');
      await t.enterText(find.byType(TextField), 'Child');
      await t.pump();
      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Text && w.data == 'Child'),
        findsOneWidget,
      );
      expect(find.text('Alpha'), findsNothing);
    },
  );
  testWidgets('TreeList expands rows and sorts siblings', (t) async {
    Set<String> expanded = {};
    await t.pumpWidget(
      app(
        StatefulBuilder(
          builder: (c, set) => NgTreeList<String>(
            items: tree,
            columns: [NgDataColumn('name', 'Name', (s) => s)],
            expandedIds: expanded,
            onExpandedChanged: (v) => set(() => expanded = v),
          ),
        ),
      ),
    );
    expect(find.text('Alpha'), findsNothing);
    await t.tap(find.byTooltip('Expand Root'));
    await t.pump();
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == 'Alpha'),
      findsOneWidget,
    );
    await t.tap(find.text('Name'));
    await t.pump();
    await t.tap(find.text('Name'));
    await t.pump();
    final table = t.widget<DataTable>(find.byType(DataTable));
    expect(table.rows.map((r) => (r.key as ValueKey).value), [
      'root',
      'disabled',
      'b',
      'a',
    ]);
  });
  testWidgets('breadcrumb navigates ancestor; current node is not a button', (
    t,
  ) async {
    String? id;
    await t.pumpWidget(
      app(
        NgBreadcrumb(
          items: const [
            NgBreadcrumbItem('all', 'All projects'),
            NgBreadcrumbItem('design', 'Design'),
          ],
          onNavigate: (v) => id = v,
        ),
      ),
    );
    await t.tap(find.text('All projects'));
    expect(id, 'all');
    expect(find.byType(TextButton), findsOneWidget);
  });
  testWidgets('required numeric input blocks blank and invalid budget', (
    t,
  ) async {
    var saves = 0;
    await t.pumpWidget(
      app(
        NgForm(
          onValidSubmit: () => saves++,
          child: const NgNumericTextBox(
            label: 'Budget',
            value: 120,
            required: true,
            min: 0,
            max: 1000000,
          ),
        ),
      ),
    );
    await t.enterText(find.byType(TextFormField), '');
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 0);
    expect(find.text('Budget is required'), findsOneWidget);
    await t.enterText(find.byType(TextFormField), 'NaN');
    await t.tap(find.text('Save'));
    await t.pump();
    expect(saves, 0);
  });
}
