import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  late NgDiagramModel graph;
  late StateSetter parent;
  bool accept = true,
      readOnly = false,
      selectionReadOnly = false,
      moveCallback = true,
      selectionCallback = true;
  int moves = 0, selections = 0;
  String? node, edge;
  NgDiagramModel sample() => NgDiagramModel(
    nodes: const [
      NgDiagramNode('a', 'Start', 40, 80),
      NgDiagramNode('b', 'End', 400, 80),
    ],
    edges: const [NgDiagramEdge('e', 'a', 'b', text: 'Next')],
  );
  Future<void> mount(WidgetTester t) async {
    await t.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));
    graph = sample();
    accept = true;
    readOnly = false;
    selectionReadOnly = false;
    moveCallback = true;
    selectionCallback = true;
    moves = 0;
    selections = 0;
    node = null;
    edge = null;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, set) {
                parent = set;
                return NgDiagram(
                  value: graph,
                  readOnly: readOnly,
                  selectionReadOnly: selectionReadOnly,
                  nodeLabel: (n) => 'Task ${n.text}',
                  edgeLabel: (e) => 'Flow ${e.text}',
                  emptyText: 'Nothing to connect',
                  onChanged: moveCallback
                      ? (v) {
                          moves++;
                          set(() {
                            if (accept) graph = v;
                          });
                        }
                      : null,
                  selectedNodeId: node,
                  selectedEdgeId: edge,
                  onSelectedNodeIdChanged: selectionCallback
                      ? (v) {
                          selections++;
                          set(() => node = v);
                        }
                      : null,
                  onSelectedEdgeIdChanged: selectionCallback
                      ? (v) {
                          selections++;
                          set(() => edge = v);
                        }
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Finder gesture() => find
      .ancestor(
        of: find.text('Task Start'),
        matching: find.byType(GestureDetector),
      )
      .first;
  Future<void> tap(WidgetTester t, String label) async {
    await t.ensureVisible(find.text(label));
    await t.tap(find.text(label));
    await t.pumpAndSettle();
  }

  testWidgets('display labels preserve raw IDs and graph text', (t) async {
    await mount(t);
    await tap(t, 'Task Start');
    expect(node, 'a');
    expect(graph.nodes.first.text, 'Start');
    await tap(t, 'Connections');
    await tap(t, 'Flow Next: a → b');
    expect(edge, 'e');
    expect(node, isNull);
    expect(graph.edges.first.text, 'Next');
  });
  testWidgets('movement and selection locks are independent', (t) async {
    await mount(t);
    parent(() => selectionReadOnly = true);
    await t.pump();
    await t.drag(find.text('Task Start'), const Offset(60, 20));
    await t.pumpAndSettle();
    expect(moves, 1);
    expect(selections, 0);
    expect(graph.nodes.first.x, closeTo(100, 1));
    parent(() {
      selectionReadOnly = false;
      readOnly = true;
    });
    await t.pump();
    await tap(t, 'Task Start');
    expect(node, 'a');
    final before = graph;
    await t.drag(find.text('Task Start'), const Offset(60, 20));
    await t.pumpAndSettle();
    expect(identical(before, graph), true);
    await tap(t, 'Zoom out');
    expect(find.text('75%'), findsOneWidget);
  });
  testWidgets('missing handlers disable mutations and selection side effects', (
    t,
  ) async {
    await mount(t);
    parent(() {
      moveCallback = false;
      selectionCallback = false;
    });
    await t.pump();
    final g = t.widget<GestureDetector>(gesture());
    expect(g.onPanStart, isNull);
    expect(g.onTap, isNull);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(moves, 0);
    expect(selections, 0);
    await tap(t, 'Fit diagram');
    expect(t.takeException(), isNull);
  });
  testWidgets('rejected drag retains accepted coordinates and can retry', (
    t,
  ) async {
    await mount(t);
    parent(() => accept = false);
    await t.pump();
    final before = graph;
    await t.drag(find.text('Task Start'), const Offset(70, 30));
    await t.pumpAndSettle();
    expect(moves, 1);
    expect(identical(before, graph), true);
    expect(node, 'a');
    parent(() => accept = true);
    await t.pump();
    await t.drag(find.text('Task Start'), const Offset(70, 30));
    await t.pumpAndSettle();
    expect(graph.nodes.first.x, closeTo(110, 1));
    expect(moves, 2);
  });
  testWidgets('replacement and locking during active drag cancel completion', (
    t,
  ) async {
    await mount(t);
    var g = await t.startGesture(t.getCenter(find.text('Task Start')));
    await g.moveBy(const Offset(50, 30));
    await t.pump();
    parent(() => graph = sample().move('a', 200, 200));
    await t.pump();
    await g.up();
    await t.pumpAndSettle();
    expect(moves, 0);
    expect(graph.nodes.first.x, 200);
    g = await t.startGesture(t.getCenter(find.text('Task Start')));
    await g.moveBy(const Offset(50, 30));
    await t.pump();
    parent(() => readOnly = true);
    await t.pump();
    await g.up();
    await t.pumpAndSettle();
    expect(moves, 0);
  });
  testWidgets(
    'captured selection keyboard and gesture ignore replacement and disposal',
    (t) async {
      await mount(t);
      final g = t.widget<GestureDetector>(gesture());
      final focus = t.widget<Focus>(
        find
            .ancestor(of: find.text('Task Start'), matching: find.byType(Focus))
            .first,
      );
      parent(() => graph = NgDiagramModel());
      await t.pump();
      g.onTap!();
      g.onPanStart!(DragStartDetails());
      g.onPanEnd!(DragEndDetails());
      focus.onKeyEvent!(
        FocusNode(),
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        ),
      );
      expect(moves, 0);
      expect(selections, 0);
      expect(find.text('Nothing to connect'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      g.onTap!();
      g.onPanCancel!();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('zoom cancels active drag without changing graph', (t) async {
    await mount(t);
    final g = await t.startGesture(t.getCenter(find.text('Task Start')));
    await g.moveBy(const Offset(50, 30));
    await t.pump();
    final zoom = t.widget<NgButton>(
      find.ancestor(of: find.text('Zoom in'), matching: find.byType(NgButton)),
    );
    zoom.onPressed!();
    await t.pump();
    await g.up();
    await t.pumpAndSettle();
    expect(moves, 0);
    expect(find.text('125%'), findsOneWidget);
  });
}
