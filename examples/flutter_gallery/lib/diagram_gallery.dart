import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class DiagramGallery extends StatefulWidget {
  final bool dark, compact;
  final ValueChanged<bool> onDark, onCompact;
  final VoidCallback onBack;
  const DiagramGallery({
    super.key,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
    required this.onBack,
  });
  @override
  State<DiagramGallery> createState() => _DiagramGalleryState();
}

class _DiagramGalleryState extends State<DiagramGallery> {
  static NgDiagramModel sample() => NgDiagramModel(
    nodes: const [
      NgDiagramNode('draft', 'Draft', 50, 180, shape: NgDiagramShape.ellipse),
      NgDiagramNode(
        'review',
        'Review',
        350,
        160,
        height: 120,
        shape: NgDiagramShape.diamond,
      ),
      NgDiagramNode(
        'release',
        'Release',
        700,
        180,
        shape: NgDiagramShape.ellipse,
      ),
      NgDiagramNode('revise', 'Revise', 350, 400),
    ],
    edges: const [
      NgDiagramEdge('submit', 'draft', 'review', text: 'Submit'),
      NgDiagramEdge('approve', 'review', 'release', text: 'Approve'),
      NgDiagramEdge('changes', 'review', 'revise', text: 'Changes'),
      NgDiagramEdge('retry', 'revise', 'draft', text: 'Retry'),
    ],
  );
  NgDiagramModel graph = sample();
  final List<NgDiagramModel> undo = [];
  final nodeText = TextEditingController(text: 'New step'),
      edgeText = TextEditingController(),
      source = TextEditingController();
  String? nodeId, edgeId, from, to;
  NgDiagramShape shape = NgDiagramShape.rectangle;
  bool readOnly = false, directed = true;
  String status = '';
  @override
  void dispose() {
    nodeText.dispose();
    edgeText.dispose();
    source.dispose();
    super.dispose();
  }

  void apply(NgDiagramModel next) {
    if (readOnly) return;
    setState(() {
      undo.add(graph);
      if (undo.length > 20) undo.removeAt(0);
      graph = next;
      if (!graph.nodes.any((n) => n.id == nodeId)) nodeId = null;
      if (!graph.edges.any((e) => e.id == edgeId)) edgeId = null;
      if (!graph.nodes.any((n) => n.id == from)) from = null;
      if (!graph.nodes.any((n) => n.id == to)) to = null;
      status = 'Graph updated.';
    });
  }

  void change(NgDiagramModel Function() action) {
    if (readOnly) return;
    try {
      apply(action());
    } on ArgumentError catch (e) {
      setState(() => status = e.message.toString());
    }
  }

  void selectNode(String? id) {
    setState(() {
      nodeId = id;
      if (id != null) {
        final n = graph.nodes.firstWhere((n) => n.id == id);
        nodeText.text = n.text;
        shape = n.shape;
      }
    });
  }

  void selectEdge(String? id) {
    setState(() {
      edgeId = id;
      if (id != null) {
        final e = graph.edges.firstWhere((e) => e.id == id);
        from = e.from;
        to = e.to;
        edgeText.text = e.text;
        directed = e.directed;
      }
    });
  }

  String newId(String prefix) {
    var i = 1;
    while (graph.nodes.any((n) => n.id == '$prefix$i') ||
        graph.edges.any((e) => e.id == '$prefix$i')) {
      i++;
    }
    return '$prefix$i';
  }

  void addNode() {
    final id = newId('node');
    change(
      () => graph.upsertNode(
        NgDiagramNode(id, nodeText.text, 40, 40, shape: shape),
      ),
    );
    if (graph.nodes.any((n) => n.id == id)) {
      edgeId = null;
      selectNode(id);
    }
  }

  void saveEdge(bool add) {
    final id = add ? newId('edge') : edgeId;
    if (id == null) return;
    change(
      () => graph.upsertEdge(
        NgDiagramEdge(
          id,
          from ?? '',
          to ?? '',
          text: edgeText.text,
          directed: directed,
        ),
      ),
    );
    if (graph.edges.any((e) => e.id == id)) {
      nodeId = null;
      selectEdge(id);
    }
  }

  void delete() {
    if (nodeId != null) {
      change(() => graph.removeNode(nodeId!));
    } else if (edgeId != null) {
      change(() => graph.removeEdge(edgeId!));
    }
  }

  Widget field(String label, TextEditingController controller) => TextField(
    controller: controller,
    enabled: !readOnly,
    maxLength: 100,
    decoration: InputDecoration(labelText: label),
  );
  Widget endpoint(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$label-$value-${graph.nodes.length}'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: graph.nodes
        .map(
          (n) => DropdownMenuItem(
            value: n.id,
            child: Text(n.text, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: readOnly ? null : onChanged,
  );
  @override
  Widget build(BuildContext context) {
    final selected = graph.nodes.where((n) => n.id == nodeId).firstOrNull;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'NEXTGEN COMPONENTS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    NgButton(
                      onPressed: widget.onBack,
                      child: const Text('Foundation'),
                    ),
                    NgSwitch(
                      label: 'Dark theme',
                      value: widget.dark,
                      onChanged: widget.onDark,
                    ),
                    NgCheckBox(
                      label: 'Compact',
                      value: widget.compact,
                      onChanged: widget.onCompact,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('FLUTTER / DIAGRAMS 0.7'),
                Text(
                  'Connect the steps.\nExplore the process.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Text(
                  'Move nodes, inspect connections and save a portable workflow.',
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NgCheckBox(
                      label: 'Read only',
                      value: readOnly,
                      onChanged: (v) => setState(() => readOnly = v),
                    ),
                    NgButton(
                      onPressed: readOnly || undo.isEmpty
                          ? null
                          : () => setState(() {
                              graph = undo.removeLast();
                              nodeId = edgeId = from = to = null;
                              status = 'Change undone.';
                            }),
                      child: const Text('Undo change'),
                    ),
                    NgButton(
                      onPressed: () => setState(() {
                        graph = sample();
                        undo.clear();
                        nodeId = edgeId = from = to = null;
                        source.clear();
                        status = 'Sample restored.';
                      }),
                      child: const Text('Reset sample'),
                    ),
                  ],
                ),
                NgDiagram(
                  label: 'Release workflow',
                  value: graph,
                  onChanged: apply,
                  selectedNodeId: nodeId,
                  onSelectedNodeIdChanged: selectNode,
                  selectedEdgeId: edgeId,
                  onSelectedEdgeIdChanged: selectEdge,
                  readOnly: readOnly,
                ),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    selected != null
                        ? 'Selected ${selected.id}: ${selected.text} · X ${selected.x.round()}, Y ${selected.y.round()}'
                        : edgeId != null
                        ? 'Selected connection $edgeId'
                        : 'No selection',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Node properties',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                field('Node text', nodeText),
                DropdownButtonFormField<NgDiagramShape>(
                  key: ValueKey(shape),
                  initialValue: shape,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Shape'),
                  items: NgDiagramShape.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: readOnly
                      ? null
                      : (s) => setState(() => shape = s!),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NgButton(
                      onPressed: readOnly ? null : addNode,
                      child: const Text('Add node'),
                    ),
                    NgButton(
                      onPressed: readOnly || selected == null
                          ? null
                          : () => change(
                              () => graph.upsertNode(
                                selected.copyWith(
                                  text: nodeText.text,
                                  shape: shape,
                                ),
                              ),
                            ),
                      child: const Text('Save node'),
                    ),
                    NgButton(
                      onPressed: readOnly || (nodeId == null && edgeId == null)
                          ? null
                          : delete,
                      child: const Text('Delete selected'),
                    ),
                  ],
                ),
                const Text(
                  'Deleting a node also removes its connections. Undo change restores the previous graph.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Connection properties',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                endpoint('From node', from, (v) => setState(() => from = v)),
                const SizedBox(height: 12),
                endpoint('To node', to, (v) => setState(() => to = v)),
                field('Connection text', edgeText),
                NgCheckBox(
                  label: 'Directed',
                  value: directed,
                  onChanged: readOnly
                      ? null
                      : (v) => setState(() => directed = v),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NgButton(
                      onPressed: readOnly ? null : () => saveEdge(true),
                      child: const Text('Add connection'),
                    ),
                    NgButton(
                      onPressed: readOnly || edgeId == null
                          ? null
                          : () => saveEdge(false),
                      child: const Text('Save connection'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Save and restore',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NgButton(
                      onPressed: () => source.text = graph.toJson(),
                      child: const Text('Export JSON'),
                    ),
                    NgButton(
                      onPressed: readOnly
                          ? null
                          : () => change(
                              () => NgDiagramModel.fromJson(source.text),
                            ),
                      child: const Text('Import JSON'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: source,
                  maxLines: 6,
                  maxLength: 1000000,
                  decoration: const InputDecoration(
                    labelText: 'Diagram source',
                  ),
                ),
                Semantics(liveRegion: true, child: Text(status)),
                const SizedBox(height: 24),
                const Text('35 CONTROLS / 41 CATALOGUE ENTRIES · WEB FIRST'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
