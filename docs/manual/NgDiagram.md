# NgDiagram — Interactive diagram

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display and edit a graph of nodes and directed or undirected connections.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDiagram) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDiagram)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Selection and movement
Click a node or connection to select it. The other selection type is first cleared through its callback with null. Store both selected IDs. Unknown IDs are not highlighted; remove stale selection when deleting data. Dragging previews a new position, and only pointer release proposes coordinates through ValueChanged/onChanged. Accept by returning the proposed graph; rejection retains the original coordinates and removes the drag preview. Selection is a separate proposal and may still change when movement is rejected. Escape cancels drag. Tab focuses nodes; Enter/Space selects; arrows move 10 units, Shift+arrow moves 1. Movement stays inside the canvas. Flutter exposes keyboard-selectable Connections; Blazor SVG connections are focusable.

### Labels and empty state

NodeLabel/nodeLabel and EdgeLabel/edgeLabel format plain-text display and accessible names without changing raw IDs, coordinates or JSON. Full labels are used in accessible names and tooltips/list entries; canvas labels may be shortened to fit. EmptyText/emptyText replaces the empty-graph message. The default values retain existing labels. These are not arbitrary templates.

### Zoom and viewport
Zoom changes by 25 percentage points, within 25–200%. Fit width fits the entire canvas width; 100% resets zoom. The viewport is 420 logical/CSS pixels tall, with internal scrolling. Zoom does not alter model coordinates or JSON. Fit diagram fits node bounds in both axes with 24 px padding and centers by scrolling; it preserves selection and works in ReadOnly. Empty graphs disable it. Minimum zoom can still require scrolling for large graphs; canvas boundaries constrain centering and long connection labels may extend beyond bounds. Fitting is explicit, not automatic layout.

NgDiagramModel.FitView/fitView(viewportWidth,viewportHeight) returns NgDiagramView (Zoom/ScrollX/ScrollY or lowerCamelCase). Sizes must be finite and positive. An empty graph returns 100% and zero scroll.

### Model and persistence
Value is immutable. Store the new graph from callbacks; an independent replacement cancels active drag. ReadOnly or a missing ValueChanged/onChanged disables movement but retains selection, zoom and scrolling. SelectionReadOnly/selectionReadOnly independently disables node and edge selection; movement can remain enabled. Missing selection callbacks disable their respective selection action without clearing the other selection. A successful selection first requests clearing the opposite ID; both IDs remain parent-owned. Any parent update cancels active drag and invalidates captured actions, including replacement graphs reusing node IDs. Zoom also cancels drag. Blazor rechecks graph identity and permissions after awaiting selection callbacks, before proposing a move. Host-side asynchronous responses still need ordering against newer data. The application owns create/edit/delete actions and their permissions. The gallery shows a properties panel, connections, 20-change history and import; NgDiagram itself has no undo history.

UpsertNode/UpsertEdge add or replace by ID. RemoveNode also removes incident edges; RemoveEdge keeps nodes. Move(id,x,y) clamps coordinates to the canvas and returns a new model. For example: graph = graph.Move("start",80,120), or graph = graph.move('start',80,120). ToJson/toJson and FromJson/fromJson use the shared version-1 Nextgen schema, not Telerik JSON. Catch invalid imports and retain the previous graph. No automatic file storage or upload.

### Geometry and limits
Shapes: rectangle, ellipse, diamond (PascalCase enum names in C#). Nodes store ID, text, top-left X/Y and width/height (default 160×80). Labels are visually shortened but available in tooltips/accessibility/properties. Connections run straight between shape boundaries along the centers; directed connections have an end arrow. On-canvas connection labels shorten to 24 characters.

Canvas dimensions: 200–5000 (default 1000×600); up to 100 nodes and 200 edges. Nodes: 60–400 × 40–240, fully inside the canvas. IDs: 1–64 ASCII letters/digits/_/-, unique separately for nodes and edges. Node text is nonempty and at most 100 UTF-16 units; edge text 0–100. Coordinates are finite. Edges require two different existing nodes. Cycles and parallel edges are allowed; workflow rules belong to the application. Overlaps are not resolved automatically; coincident centers yield a zero-length line.

No automatic layout, obstacle routing, connector drawing, pointer resizing, groups, multiple selection, image/templates, export, minimap, pinch zoom or collaboration. Blazor loads diagram.js automatically from static web assets and requires interactive rendering; if drag fails, check the module and ValueChanged handling. Native/mobile and screen-reader audits remain separate.

## Blazor example

```razor
<div class="row">
<NgButton OnClick="()=>readOnly=!readOnly">Toggle move lock</NgButton>
<NgButton OnClick="()=>selectionReadOnly=!selectionReadOnly">Toggle selection lock</NgButton>
<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>
<NgButton OnClick="()=>graph=Sample(120,140)">Replace graph</NgButton>
<NgButton OnClick="()=>graph=graph.Nodes.Count==0?Sample():new()">Toggle empty graph</NgButton>
</div>
<p>Movement: @(readOnly?"locked":"enabled") · Selection: @(selectionReadOnly?"locked":"enabled") · Acceptance: @(accept?"enabled":"rejected")</p>
<p>Start position: @(graph.Nodes.Count==0?"none":$"{graph.Nodes[0].X}, {graph.Nodes[0].Y}") · Move proposals: @moves</p>
<NgDiagram Label="Process" Value="graph" ValueChanged="Change" ReadOnly="readOnly" SelectionReadOnly="selectionReadOnly"
    NodeLabel="@(n=>$"Task {n.Text}")" EdgeLabel="@(e=>$"Flow {e.Text}")" EmptyText="Nothing to connect"
    @bind-SelectedNodeId="selectedNode" @bind-SelectedEdgeId="selectedEdge"/>
<p>Node: @(selectedNode??"none") · Connection: @(selectedEdge??"none")</p>
@code {
    private string? selectedNode, selectedEdge;
    private bool readOnly,selectionReadOnly;
    private bool accept=true;
    private int moves;
    private NgDiagramModel graph=Sample();
    private static NgDiagramModel Sample(double x=40,double y=100)=>new([
        new("start","Start",x,y,Shape:NgDiagramShape.Ellipse),
        new("work","Processing",360,100)
    ],[new("next","start","work","Continue")]);
    private void Change(NgDiagramModel next){moves++;if(accept)graph=next;}
}
```

## Flutter example

```dart
NgDiagramModel sample([double x=40,double y=100]) => NgDiagramModel(nodes: [
  NgDiagramNode('start', 'Start', x, y, shape: NgDiagramShape.ellipse),
  const NgDiagramNode('work', 'Processing', 360, 100),
], edges: const [NgDiagramEdge('next', 'start', 'work', text: 'Continue')]);
late NgDiagramModel graph=sample();
String? selectedNode, selectedEdge;
bool readOnly=false, selectionReadOnly=false, accept=true;
int moves=0;
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch, children:[
  Wrap(spacing:8,runSpacing:8,children:[
    NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle move lock')),
    NgButton(onPressed:()=>setState(()=>selectionReadOnly=!selectionReadOnly),child:const Text('Toggle selection lock')),
    NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
    NgButton(onPressed:()=>setState(()=>graph=sample(120,140)),child:const Text('Replace graph')),
    NgButton(onPressed:()=>setState(()=>graph=graph.nodes.isEmpty?sample():NgDiagramModel()),child:const Text('Toggle empty graph')),
  ]),
  Text('Movement: ${readOnly?"locked":"enabled"} · Selection: ${selectionReadOnly?"locked":"enabled"} · Acceptance: ${accept?"enabled":"rejected"}'),
  Text('Start position: ${graph.nodes.isEmpty?"none":"${graph.nodes.first.x.round()}, ${graph.nodes.first.y.round()}"} · Move proposals: $moves'),
  NgDiagram(label: 'Process', value: graph, readOnly:readOnly, selectionReadOnly:selectionReadOnly,
    nodeLabel:(n)=>'Task ${n.text}',edgeLabel:(e)=>'Flow ${e.text}',emptyText:'Nothing to connect',
    onChanged: (v) => setState(() {moves++;if(accept)graph=v;}),
    selectedNodeId: selectedNode, selectedEdgeId: selectedEdge,
    onSelectedNodeIdChanged: (v) => setState(() => selectedNode = v),
    onSelectedEdgeIdChanged: (v) => setState(() => selectedEdge = v)),
  Text('Node: ${selectedNode??"none"} · Connection: ${selectedEdge??"none"}'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Diagram" | Visible label or accessible name. |
| `Value` | `NgDiagramModel` | required | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<NgDiagramModel>` | not set | New value for the parent to store and pass back. |
| `SelectedNodeId` | `string?` | not set | See the behavior rules and model contract above. |
| `SelectedNodeIdChanged` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `SelectedEdgeId` | `string?` | not set | See the behavior rules and model contract above. |
| `SelectedEdgeIdChanged` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `NodeLabel` | `Func<NgDiagramNode,string>?` | not set | See the behavior rules and model contract above. |
| `EdgeLabel` | `Func<NgDiagramEdge,string>?` | not set | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No nodes yet." | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgDiagramModel` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<NgDiagramModel>?` | Store the new value using setState or your state manager. |
| `selectedNodeId` | `String?` | See the behavior rules and model contract above. |
| `selectedEdgeId` | `String?` | See the behavior rules and model contract above. |
| `onSelectedNodeIdChanged` | `ValueChanged<String?>?` | See the behavior rules and model contract above. |
| `onSelectedEdgeIdChanged` | `ValueChanged<String?>?` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `nodeLabel` | `String Function(NgDiagramNode)?` | See the behavior rules and model contract above. |
| `edgeLabel` | `String Function(NgDiagramEdge)?` | See the behavior rules and model contract above. |
| `emptyText` | `String` | See the behavior rules and model contract above. |

```dart
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
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDiagram.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/diagram.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
