import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components.dart';

enum NgDiagramShape { rectangle, ellipse, diamond }

class NgDiagramNode {
  final String id, text;
  final double x, y, width, height;
  final NgDiagramShape shape;
  const NgDiagramNode(
    this.id,
    this.text,
    this.x,
    this.y, {
    this.width = 160,
    this.height = 80,
    this.shape = NgDiagramShape.rectangle,
  });
  NgDiagramNode copyWith({
    String? text,
    double? x,
    double? y,
    double? width,
    double? height,
    NgDiagramShape? shape,
  }) => NgDiagramNode(
    id,
    text ?? this.text,
    x ?? this.x,
    y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    shape: shape ?? this.shape,
  );
  Map<String, Object> toMap() => {
    'id': id,
    'text': text,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'shape': shape.name,
  };
}

class NgDiagramEdge {
  final String id, from, to, text;
  final bool directed;
  const NgDiagramEdge(
    this.id,
    this.from,
    this.to, {
    this.text = '',
    this.directed = true,
  });
  Map<String, Object> toMap() => {
    'id': id,
    'from': from,
    'to': to,
    'text': text,
    'directed': directed,
  };
}

class NgDiagramLine {
  final Offset start, end;
  const NgDiagramLine(this.start, this.end);
}

class NgDiagramView {
  final double zoom, scrollX, scrollY;
  const NgDiagramView(this.zoom, this.scrollX, this.scrollY);
}

class NgDiagramModel {
  /// Fits node bounds with 24px padding at 25–200%; empty graphs use 100%.
  NgDiagramView fitView(double viewportWidth, double viewportHeight) {
    if (!viewportWidth.isFinite ||
        !viewportHeight.isFinite ||
        viewportWidth <= 0 ||
        viewportHeight <= 0) {
      throw ArgumentError('Viewport dimensions must be positive and finite.');
    }
    if (nodes.isEmpty) return const NgDiagramView(1, 0, 0);
    final left = nodes.map((n) => n.x).reduce(math.min);
    final top = nodes.map((n) => n.y).reduce(math.min);
    final right = nodes.map((n) => n.x + n.width).reduce(math.max);
    final bottom = nodes.map((n) => n.y + n.height).reduce(math.max);
    final scale = math
        .min(
          (viewportWidth - 48) / (right - left),
          (viewportHeight - 48) / (bottom - top),
        )
        .clamp(.25, 2.0);
    return NgDiagramView(
      scale,
      ((left + right) / 2 * scale - viewportWidth / 2).clamp(
        0.0,
        math.max(0.0, width * scale - viewportWidth),
      ),
      ((top + bottom) / 2 * scale - viewportHeight / 2).clamp(
        0.0,
        math.max(0.0, height * scale - viewportHeight),
      ),
    );
  }

  final double width, height;
  final List<NgDiagramNode> nodes;
  final List<NgDiagramEdge> edges;
  NgDiagramModel({
    List<NgDiagramNode> nodes = const [],
    List<NgDiagramEdge> edges = const [],
    this.width = 1000,
    this.height = 600,
  }) : nodes = List.unmodifiable(nodes),
       edges = List.unmodifiable(edges) {
    if (!width.isFinite ||
        !height.isFinite ||
        width < 200 ||
        width > 5000 ||
        height < 200 ||
        height > 5000)
      throw ArgumentError('Canvas dimensions must be 200–5000.');
    if (nodes.length > 100 || edges.length > 200)
      throw ArgumentError('Use at most 100 nodes and 200 connections.');
    final ids = <String>{};
    for (final n in nodes) {
      if (!_id(n.id) ||
          !ids.add(n.id) ||
          n.text.trim().isEmpty ||
          n.text.length > 100)
        throw ArgumentError(
          'Nodes need unique IDs and text (1–100 characters).',
        );
      if (!n.x.isFinite ||
          !n.y.isFinite ||
          !n.width.isFinite ||
          !n.height.isFinite ||
          n.width < 60 ||
          n.width > 400 ||
          n.height < 40 ||
          n.height > 240 ||
          n.x < 0 ||
          n.y < 0 ||
          n.x + n.width > width ||
          n.y + n.height > height)
        throw ArgumentError(
          'Node bounds must fit the canvas; size is 60–400 × 40–240.',
        );
    }
    final edgeIds = <String>{};
    for (final e in edges) {
      if (!_id(e.id) ||
          !edgeIds.add(e.id) ||
          !ids.contains(e.from) ||
          !ids.contains(e.to) ||
          e.from == e.to ||
          e.text.length > 100)
        throw ArgumentError(
          'Connections need unique IDs, two different existing nodes and text up to 100 characters.',
        );
    }
  }
  static bool _id(String id) => RegExp(r'^[a-zA-Z0-9_-]{1,64}$').hasMatch(id);
  NgDiagramModel upsertNode(NgDiagramNode node) => NgDiagramModel(
    nodes: nodes.any((n) => n.id == node.id)
        ? nodes.map((n) => n.id == node.id ? node : n).toList()
        : [...nodes, node],
    edges: edges,
    width: width,
    height: height,
  );
  NgDiagramModel upsertEdge(NgDiagramEdge edge) => NgDiagramModel(
    nodes: nodes,
    edges: edges.any((e) => e.id == edge.id)
        ? edges.map((e) => e.id == edge.id ? edge : e).toList()
        : [...edges, edge],
    width: width,
    height: height,
  );
  NgDiagramModel removeNode(String id) => NgDiagramModel(
    nodes: nodes.where((n) => n.id != id).toList(),
    edges: edges.where((e) => e.from != id && e.to != id).toList(),
    width: width,
    height: height,
  );
  NgDiagramModel removeEdge(String id) => NgDiagramModel(
    nodes: nodes,
    edges: edges.where((e) => e.id != id).toList(),
    width: width,
    height: height,
  );
  NgDiagramModel move(String id, double x, double y) {
    if (!x.isFinite || !y.isFinite)
      throw ArgumentError('Coordinates must be finite.');
    final matches = nodes.where((n) => n.id == id);
    if (matches.isEmpty) throw ArgumentError('Unknown node ID.');
    final n = matches.first;
    return upsertNode(
      n.copyWith(
        x: x.clamp(0, width - n.width),
        y: y.clamp(0, height - n.height),
      ),
    );
  }

  NgDiagramLine line(NgDiagramEdge edge) {
    final a = nodes.firstWhere((n) => n.id == edge.from),
        b = nodes.firstWhere((n) => n.id == edge.to);
    final d = Offset(
      b.x + b.width / 2 - a.x - a.width / 2,
      b.y + b.height / 2 - a.y - a.height / 2,
    );
    if (d == Offset.zero)
      return NgDiagramLine(
        Offset(a.x + a.width / 2, a.y + a.height / 2),
        Offset(b.x + b.width / 2, b.y + b.height / 2),
      );
    return NgDiagramLine(_anchor(a, d), _anchor(b, -d));
  }

  static Offset _anchor(NgDiagramNode n, Offset d) {
    final x = d.dx.abs() / (n.width / 2), y = d.dy.abs() / (n.height / 2);
    final scale =
        1 /
        switch (n.shape) {
          NgDiagramShape.ellipse => math.sqrt(x * x + y * y),
          NgDiagramShape.diamond => x + y,
          _ => math.max(x, y),
        };
    return Offset(
      n.x + n.width / 2 + d.dx * scale,
      n.y + n.height / 2 + d.dy * scale,
    );
  }

  String toJson() => const JsonEncoder.withIndent('  ').convert({
    'version': 1,
    'width': width,
    'height': height,
    'nodes': nodes.map((n) => n.toMap()).toList(),
    'edges': edges.map((e) => e.toMap()).toList(),
  });
  static NgDiagramModel fromJson(String json) {
    if (json.length > 1000000)
      throw ArgumentError('Diagram JSON exceeds 1000000 characters.');
    void keys(dynamic value, List<String> allowed) {
      if (value is! Map<String, dynamic> ||
          value.keys.any((k) => !allowed.contains(k)))
        throw const FormatException();
    }

    try {
      final d = jsonDecode(json);
      keys(d, ['version', 'width', 'height', 'nodes', 'edges']);
      if (d['version'] is! int || d['version'] != 1)
        throw const FormatException();
      final nodes = (d['nodes'] as List).map((n) {
        keys(n, ['id', 'text', 'x', 'y', 'width', 'height', 'shape']);
        return NgDiagramNode(
          n['id'] as String,
          n['text'] as String,
          (n['x'] as num).toDouble(),
          (n['y'] as num).toDouble(),
          width: n.containsKey('width') ? (n['width'] as num).toDouble() : 160,
          height: n.containsKey('height')
              ? (n['height'] as num).toDouble()
              : 80,
          shape: n.containsKey('shape')
              ? NgDiagramShape.values.byName(n['shape'] as String)
              : NgDiagramShape.rectangle,
        );
      }).toList();
      final edges = (d['edges'] as List).map((e) {
        keys(e, ['id', 'from', 'to', 'text', 'directed']);
        return NgDiagramEdge(
          e['id'] as String,
          e['from'] as String,
          e['to'] as String,
          text: e.containsKey('text') ? e['text'] as String : '',
          directed: e.containsKey('directed') ? e['directed'] as bool : true,
        );
      }).toList();
      return NgDiagramModel(
        nodes: nodes,
        edges: edges,
        width: (d['width'] as num).toDouble(),
        height: (d['height'] as num).toDouble(),
      );
    } on Object {
      throw ArgumentError(
        'Invalid diagram JSON. Expected version 1 and valid graph.',
      );
    }
  }
}

class NgDiagram extends StatefulWidget {
  final String label;
  final NgDiagramModel value;
  final ValueChanged<NgDiagramModel>? onChanged;
  final String? selectedNodeId, selectedEdgeId;
  final ValueChanged<String?>? onSelectedNodeIdChanged, onSelectedEdgeIdChanged;
  final bool readOnly, selectionReadOnly;
  final String Function(NgDiagramNode)? nodeLabel;
  final String Function(NgDiagramEdge)? edgeLabel;
  final String emptyText;
  const NgDiagram({
    super.key,
    this.label = 'Diagram',
    required this.value,
    this.onChanged,
    this.selectedNodeId,
    this.selectedEdgeId,
    this.onSelectedNodeIdChanged,
    this.onSelectedEdgeIdChanged,
    this.readOnly = false,
    this.selectionReadOnly = false,
    this.nodeLabel,
    this.edgeLabel,
    this.emptyText = 'No nodes yet.',
  });
  @override
  State<NgDiagram> createState() => _NgDiagramState();
}

class _NgDiagramState extends State<NgDiagram> {
  int revision = 0;
  bool get writable => !widget.readOnly && widget.onChanged != null;
  bool get canSelectNode =>
      !widget.selectionReadOnly && widget.onSelectedNodeIdChanged != null;
  bool get canSelectEdge =>
      !widget.selectionReadOnly && widget.onSelectedEdgeIdChanged != null;
  bool active(int expected) => mounted && revision == expected;
  String nodeText(NgDiagramNode n) => widget.nodeLabel?.call(n) ?? n.text;
  String edgeText(NgDiagramEdge e) => widget.edgeLabel?.call(e) ?? e.text;
  double zoom = 1;
  void fitDiagram(double width, int requested) {
    if (!active(requested)) return;
    final view = widget.value.fitView(width, 418);
    final expected = ++revision;
    setState(() {
      zoom = view.zoom;
      dragging = null;
      ghost = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!active(expected)) return;
      if (horizontal.hasClients)
        horizontal.jumpTo(
          view.scrollX.clamp(0.0, horizontal.position.maxScrollExtent),
        );
      if (vertical.hasClients)
        vertical.jumpTo(
          view.scrollY.clamp(0.0, vertical.position.maxScrollExtent),
        );
    });
  }

  final horizontal = ScrollController(), vertical = ScrollController();
  final Map<String, FocusNode> focus = {};
  String? dragging;
  Offset? startPointer, ghost;
  double startScrollX = 0, startScrollY = 0;
  String message = '';
  @override
  void didUpdateWidget(covariant NgDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    revision++;
    message = '';
    {
      dragging = null;
      ghost = null;
    }
    for (final id in focus.keys.toList()) {
      if (!widget.value.nodes.any((n) => n.id == id)) {
        focus.remove(id)!.dispose();
      }
    }
  }

  @override
  void dispose() {
    horizontal.dispose();
    vertical.dispose();
    for (final f in focus.values) {
      f.dispose();
    }
    super.dispose();
  }

  void selectNode(String id, int expected) {
    if (!active(expected) ||
        !canSelectNode ||
        !widget.value.nodes.any((n) => n.id == id))
      return;
    widget.onSelectedEdgeIdChanged?.call(null);
    widget.onSelectedNodeIdChanged?.call(id);
    focus[id]?.requestFocus();
  }

  void selectEdge(String id, int expected) {
    if (!active(expected) ||
        !canSelectEdge ||
        !widget.value.edges.any((e) => e.id == id))
      return;
    widget.onSelectedNodeIdChanged?.call(null);
    widget.onSelectedEdgeIdChanged?.call(id);
  }

  void move(String id, double x, double y, int expected) {
    if (!active(expected) ||
        !writable ||
        !x.isFinite ||
        !y.isFinite ||
        !widget.value.nodes.any((n) => n.id == id))
      return;
    final n = widget.value.nodes.firstWhere((n) => n.id == id);
    final next = widget.value.move(id, x, y);
    final m = next.nodes.firstWhere((n) => n.id == id);
    selectNode(id, expected);
    if (n.x != m.x || n.y != m.y) widget.onChanged?.call(next);
    setState(() => message = 'Move requested for $id.');
  }

  KeyEventResult key(KeyEvent e, NgDiagramNode n, int expected) {
    if (!active(expected)) return KeyEventResult.ignored;
    if (e is! KeyDownEvent && e is! KeyRepeatEvent)
      return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      setState(() {
        dragging = null;
        ghost = null;
      });
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter ||
        e.logicalKey == LogicalKeyboardKey.space) {
      selectNode(n.id, expected);
      return KeyEventResult.handled;
    }
    if (!writable) return KeyEventResult.ignored;
    final step = HardwareKeyboard.instance.isShiftPressed ? 1.0 : 10.0;
    final delta = switch (e.logicalKey) {
      LogicalKeyboardKey.arrowLeft => Offset(-step, 0),
      LogicalKeyboardKey.arrowRight => Offset(step, 0),
      LogicalKeyboardKey.arrowUp => Offset(0, -step),
      LogicalKeyboardKey.arrowDown => Offset(0, step),
      _ => Offset.zero,
    };
    if (delta == Offset.zero) return KeyEventResult.ignored;
    move(n.id, n.x + delta.dx, n.y + delta.dy, expected);
    return KeyEventResult.handled;
  }

  Offset dragPosition(NgDiagramNode n, Offset pointer) {
    final delta =
        (pointer -
            (startPointer ?? pointer) +
            Offset(
              horizontal.offset - startScrollX,
              vertical.offset - startScrollY,
            )) /
        zoom;
    return Offset(
      (n.x + delta.dx).clamp(0, widget.value.width - n.width),
      (n.y + delta.dy).clamp(0, widget.value.height - n.height),
    );
  }

  Widget node(NgDiagramNode n) {
    final expected = revision, text = nodeText(n);
    final selected = n.id == widget.selectedNodeId;
    final f = focus.putIfAbsent(n.id, () => FocusNode());
    return Positioned(
      left: n.x * zoom,
      top: n.y * zoom,
      width: n.width * zoom,
      height: n.height * zoom,
      child: Focus(
        focusNode: f,
        onFocusChange: (_) {
          if (mounted) setState(() {});
        },
        onKeyEvent: (_, e) => key(e, n, expected),
        child: Semantics(
          button: true,
          selected: selected,
          label: 'Node $text',
          enabled: canSelectNode || writable,
          child: Tooltip(
            message: '$text · ${n.x.round()}, ${n.y.round()}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: canSelectNode ? () => selectNode(n.id, expected) : null,
              onPanDown: !writable
                  ? null
                  : (d) {
                      if (!active(expected) || !writable) return;
                      startPointer = d.globalPosition;
                      startScrollX = horizontal.offset;
                      startScrollY = vertical.offset;
                    },
              onPanStart: !writable
                  ? null
                  : (d) {
                      if (!active(expected) || !writable) return;
                      f.requestFocus();
                      setState(() {
                        dragging = n.id;
                        ghost = dragPosition(n, d.globalPosition);
                      });
                    },
              onPanUpdate: !writable
                  ? null
                  : (d) {
                      if (!active(expected) ||
                          !writable ||
                          dragging != n.id ||
                          startPointer == null)
                        return;
                      setState(() => ghost = dragPosition(n, d.globalPosition));
                    },
              onPanEnd: !writable
                  ? null
                  : (_) {
                      if (!active(expected) || !writable) return;
                      final g = ghost;
                      final id = dragging;
                      setState(() {
                        dragging = null;
                        ghost = null;
                      });
                      if (id == n.id && g != null)
                        move(id!, g.dx, g.dy, expected);
                    },
              onPanCancel: () {
                if (!active(expected)) return;
                setState(() {
                  dragging = null;
                  ghost = null;
                });
              },
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _NodePainter(
                    n.shape,
                    Theme.of(context).colorScheme.surface,
                    (selected || f.hasFocus)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    selected || f.hasFocus ? 3 : 2,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            (n.shape == NgDiagramShape.diamond
                                ? n.width * .25
                                : 10) *
                            zoom,
                      ),
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14 * zoom),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void canvasTap(TapUpDetails d, int expected) {
    if (!active(expected) || !canSelectEdge) return;
    final p = d.localPosition / zoom;
    for (final e in widget.value.edges.reversed) {
      final l = widget.value.line(e), v = l.end - l.start;
      final t = v.distanceSquared == 0
          ? 0.0
          : ((p - l.start).dx * v.dx + (p - l.start).dy * v.dy) /
                v.distanceSquared;
      final nearest = l.start + v * t.clamp(0, 1);
      if ((p - nearest).distance <= 8 / zoom) {
        selectEdge(e.id, expected);
        return;
      }
    }
  }

  void navigate(int expected, VoidCallback action) {
    if (!active(expected)) return;
    setState(() {
      revision++;
      dragging = null;
      ghost = null;
      action();
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final expected = revision;
      final colors = Theme.of(context).colorScheme;
      final d = widget.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NgButton(
                onPressed: zoom <= .25
                    ? null
                    : () => navigate(expected, () {
                        zoom = (zoom - .25).clamp(.25, 2);
                        dragging = null;
                        ghost = null;
                      }),
                child: const Text('Zoom out'),
              ),
              Text('${(zoom * 100).round()}%'),
              NgButton(
                onPressed: zoom >= 2
                    ? null
                    : () => navigate(expected, () {
                        zoom = (zoom + .25).clamp(.25, 2);
                        dragging = null;
                        ghost = null;
                      }),
                child: const Text('Zoom in'),
              ),
              NgButton(
                onPressed: () => navigate(expected, () {
                  zoom = ((c.maxWidth - 2) / d.width).clamp(.25, 2);
                  dragging = null;
                  ghost = null;
                }),
                child: const Text('Fit width'),
              ),
              NgButton(
                onPressed: d.nodes.isEmpty
                    ? null
                    : () => fitDiagram(c.maxWidth - 2, expected),
                child: const Text('Fit diagram'),
              ),
              NgButton(
                onPressed: () => navigate(expected, () {
                  zoom = 1;
                  dragging = null;
                  ghost = null;
                }),
                child: const Text('100%'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Choose a node or connection. Drag a node to move it; Escape cancels. Arrow keys move a focused node by 10 (Shift: 1). Scroll to explore.',
            ),
          ),
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Scrollbar(
              controller: horizontal,
              thumbVisibility: true,
              notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: horizontal,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: d.width * zoom,
                  child: Scrollbar(
                    controller: vertical,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: vertical,
                      child: SizedBox(
                        height: d.height * zoom,
                        child: GestureDetector(
                          onTapUp: (details) => canvasTap(details, expected),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _EdgePainter(
                                    d,
                                    zoom,
                                    colors,
                                    widget.selectedEdgeId,
                                    edgeText,
                                  ),
                                ),
                              ),
                              ...d.nodes.map(node),
                              if (dragging != null && ghost != null)
                                Positioned(
                                  left: ghost!.dx * zoom,
                                  top: ghost!.dy * zoom,
                                  width:
                                      d.nodes
                                          .firstWhere((n) => n.id == dragging)
                                          .width *
                                      zoom,
                                  height:
                                      d.nodes
                                          .firstWhere((n) => n.id == dragging)
                                          .height *
                                      zoom,
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colors.primary.withValues(
                                          alpha: .15,
                                        ),
                                        border: Border.all(
                                          color: colors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (d.nodes.isEmpty) Text(widget.emptyText),
          Semantics(
            liveRegion: true,
            child: Text(
              '${d.nodes.length} nodes · ${d.edges.length} connections · $message',
            ),
          ),
          if (d.edges.isNotEmpty)
            ExpansionTile(
              title: const Text('Connections'),
              children: d.edges
                  .map(
                    (e) => ListTile(
                      title: Text(
                        '${edgeText(e).isEmpty ? e.id : edgeText(e)}: ${e.from} → ${e.to}',
                      ),
                      selected: e.id == widget.selectedEdgeId,
                      enabled: canSelectEdge,
                      onTap: canSelectEdge
                          ? () => selectEdge(e.id, expected)
                          : null,
                    ),
                  )
                  .toList(),
            ),
        ],
      );
    },
  );
}

class _NodePainter extends CustomPainter {
  final NgDiagramShape shape;
  final Color fill, stroke;
  final double thickness;
  _NodePainter(this.shape, this.fill, this.stroke, this.thickness);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path();
    switch (shape) {
      case NgDiagramShape.rectangle:
        path.addRRect(
          RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)),
        );
      case NgDiagramShape.ellipse:
        path.addOval(rect.deflate(2));
      case NgDiagramShape.diamond:
        path.moveTo(size.width / 2, 2);
        path.lineTo(size.width - 2, size.height / 2);
        path.lineTo(size.width / 2, size.height - 2);
        path.lineTo(2, size.height / 2);
        path.close();
    }
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );
  }

  @override
  bool shouldRepaint(covariant _NodePainter old) => true;
}

class _EdgePainter extends CustomPainter {
  final NgDiagramModel model;
  final double zoom;
  final ColorScheme colors;
  final String? selected;
  final String Function(NgDiagramEdge) label;
  _EdgePainter(this.model, this.zoom, this.colors, this.selected, this.label);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(zoom);
    for (final e in model.edges) {
      final l = model.line(e);
      final color = e.id == selected ? colors.primary : colors.onSurfaceVariant;
      canvas.drawLine(
        l.start,
        l.end,
        Paint()
          ..color = color
          ..strokeWidth = (e.id == selected ? 3 : 2),
      );
      final delta = l.end - l.start;
      if (e.directed && delta.distance > 0) {
        final u = delta / delta.distance, normal = Offset(-u.dy, u.dx);
        final base = l.end - u * 10;
        canvas.drawPath(
          Path()
            ..moveTo(l.end.dx, l.end.dy)
            ..lineTo((base + normal * 4).dx, (base + normal * 4).dy)
            ..lineTo((base - normal * 4).dx, (base - normal * 4).dy)
            ..close(),
          Paint()..color = color,
        );
      }
      final display = label(e);
      if (display.isNotEmpty) {
        final text = display.length > 24
            ? '${display.substring(0, 23)}…'
            : display;
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: colors.onSurface,
              backgroundColor: colors.surface,
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          (l.start + l.end) / 2 - Offset(painter.width / 2, painter.height + 6),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) => true;
}
