import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

NgDiagramModel sample() => NgDiagramModel(
  nodes: const [
    NgDiagramNode('a', 'Start', 10, 10),
    NgDiagramNode('b', 'End', 400, 10, shape: NgDiagramShape.ellipse),
  ],
  edges: const [NgDiagramEdge('e', 'a', 'b', text: 'Next')],
);
void main() {
  test(
    'fit bounds centers distant nodes, clamps zoom and validates viewport',
    () {
      final d = NgDiagramModel(
        nodes: const [
          NgDiagramNode('fit', 'Fit', 3000, 3000, width: 200, height: 100),
        ],
        width: 5000,
        height: 5000,
      );
      final view = d.fitView(448, 248);
      expect([view.zoom, view.scrollX, view.scrollY], [2, 5976, 5976]);
      expect(d.fitView(148, 98).zoom, .5);
      expect(d.fitView(1, 1).zoom, .25);
      expect(NgDiagramModel().fitView(300, 200).scrollX, 0);
      expect(() => d.fitView(double.nan, 200), throwsArgumentError);
    },
  );
  testWidgets(
    'fit scrolls distant node into view and preserves read-only graph',
    (tester) async {
      final d = NgDiagramModel(
        nodes: const [NgDiagramNode('fit', 'Fit', 3000, 3000)],
        width: 5000,
        height: 5000,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NgDiagram(
                value: d,
                readOnly: true,
                onChanged: (_) => fail("Navigation changed graph"),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Fit diagram'));
      await tester.pumpAndSettle();
      final node = tester.getRect(find.text('Fit'));
      expect(node.left, greaterThanOrEqualTo(0));
      expect(node.right, lessThanOrEqualTo(800));
      expect(node.top, greaterThan(0));
      expect(node.bottom, lessThanOrEqualTo(600));
      expect(d.nodes.single.x, 3000);
    },
  );

  test('maximum Unicode graph JSON roundtrip', () {
    final nodes = List.generate(
      100,
      (i) =>
          NgDiagramNode('n${i.toString().padLeft(63, 'x')}', '漢' * 100, 0, 0),
    );
    final edges = List.generate(
      200,
      (i) => NgDiagramEdge(
        'e${i.toString().padLeft(63, 'x')}',
        nodes[i % 100].id,
        nodes[(i + 1) % 100].id,
        text: '漢' * 100,
      ),
    );
    final graph = NgDiagramModel(nodes: nodes, edges: edges);
    expect(NgDiagramModel.fromJson(graph.toJson()).edges.length, 200);
  });

  test('graph roundtrip, move, cascade, anchors and independent edits', () {
    final d = sample();
    expect(NgDiagramModel.fromJson(d.toJson()).toJson(), d.toJson());
    final m = d.move('a', -100, 900);
    expect(m.nodes.first.x, 0);
    expect(m.nodes.first.y, 520);
    expect(d.nodes.first.x, 10);
    expect(d.removeNode('a').edges, isEmpty);
    expect(d.removeEdge('e').nodes.length, 2);
    expect(d.line(d.edges.first).start, const Offset(170, 50));
    expect(d.line(d.edges.first).end, const Offset(400, 50));
    expect(
      d
          .upsertNode(d.nodes.first.copyWith(shape: NgDiagramShape.diamond))
          .line(d.edges.first)
          .start,
      const Offset(170, 50),
    );
    expect(
      d.upsertEdge(const NgDiagramEdge('e', 'b', 'a')).edges.single.from,
      'b',
    );
  });
  test('invalid geometry, IDs, endpoints and JSON rejected', () {
    final d = sample();
    for (final action in <void Function()>[
      () => NgDiagramModel(nodes: [d.nodes.first, d.nodes.first]),
      () => NgDiagramModel(
        nodes: d.nodes,
        edges: const [NgDiagramEdge('e', 'a', 'missing')],
      ),
      () => NgDiagramModel(
        nodes: d.nodes,
        edges: const [NgDiagramEdge('e', 'a', 'a')],
      ),
      () => d.upsertNode(d.nodes.first.copyWith(x: double.nan)),
      () => d.upsertNode(d.nodes.first.copyWith(width: 10)),
      () => d.move('a', double.infinity, 0),
      () => d.upsertNode(const NgDiagramNode('bad id', 'Text', 0, 0)),
      () => NgDiagramModel.fromJson('{"version":2,"nodes":[],"edges":[]}'),
      () => NgDiagramModel.fromJson(
        '{"version":1,"width":1000,"height":600,"nodes":[{"id":"a","text":"A"}],"edges":[]}',
      ),
    ]) {
      expect(action, throwsArgumentError);
    }
  });
  testWidgets(
    'drag commits once, keyboard movement, zoom, selection and read only',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var d = sample();
      String? node, edge;
      var changes = 0;
      var readOnly = false;
      late StateSetter parent;
      await tester.pumpWidget(
        MaterialApp(
          theme: NgTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, set) {
                  parent = set;
                  return NgDiagram(
                    value: d,
                    onChanged: (v) => set(() {
                      d = v;
                      changes++;
                    }),
                    selectedNodeId: node,
                    onSelectedNodeIdChanged: (v) => set(() => node = v),
                    selectedEdgeId: edge,
                    onSelectedEdgeIdChanged: (v) => set(() => edge = v),
                    readOnly: readOnly,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.drag(find.text('Start'), const Offset(80, 40));
      await tester.pumpAndSettle();
      expect(changes, 1);
      expect(d.nodes.first.x, closeTo(90, 1));
      expect(d.nodes.first.y, closeTo(50, 1));
      expect(node, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(d.nodes.first.x, closeTo(100, 1));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(d.nodes.first.y, closeTo(51, 1));
      await tester.tap(find.text('Zoom out'));
      await tester.pumpAndSettle();
      expect(find.text('75%'), findsOneWidget);
      await tester.tap(find.text('Fit width'));
      await tester.pumpAndSettle();
      final horizontal = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .firstWhere((s) => s.widget.axisDirection == AxisDirection.right);
      expect(horizontal.position.maxScrollExtent, 0);
      final before = d;
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Start')),
      );
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(identical(before, d), true);
      await tester.tap(find.text('Connections'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Next: a → b'));
      await tester.tap(find.text('Next: a → b'));
      await tester.pumpAndSettle();
      expect(edge, 'e');
      expect(node, isNull);
      parent(() => readOnly = true);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start'));
      await tester.drag(find.text('Start'), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(identical(before, d), true);
      parent(() => d = NgDiagramModel());
      await tester.pumpAndSettle();
      expect(find.text('No nodes yet.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
