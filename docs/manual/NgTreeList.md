# NgTreeList — Tree list

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Combine hierarchical rows with typed columns.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgTreeList) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgTreeList)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

HasChildren/hasChildren marks an unloaded branch. LoadChildren/loadChildren returns its children on the first explicit expansion; a failed expansion displays ErrorText/errorText and can be retried. Keep lazy branches initially collapsed. LoadingText/loadingText is shown while waiting. Children are cached for collapse/reopen, including an empty result which turns the branch into a leaf. Duplicate/cyclic IDs across the resolved tree are rejected as load errors. Search examines loaded nodes only and does not fetch descendants. Replace the immutable root collection, loader, or DataVersion/dataVersion to invalidate the cache and pending results; keep references stable across selection/expansion rebuilds. Blazor sends cancellation; Flutter discards stale futures without transport cancellation. Selection and expansion remain parent-controlled; locks and disabled nodes are rechecked after loading. Returned children do not mutate the parent root collection. Templates and custom empty text remain supported. Virtualization, drag/drop, checkbox selection and complete keyboard/screen-reader parity remain open.

## Blazor example

```razor
<NgCheckBox Label="Selection read-only" @bind-Value="selectionReadOnly"/>
<NgCheckBox Label="Expansion read-only" @bind-Value="expansionReadOnly"/>
<NgCheckBox Label="Fail requests" @bind-Value="fail"/>
<NgButton OnClick="Reset">Reset tree</NgButton>
<NgTreeList TItem="string" Items="nodes" Columns="columns" LoadChildren="Load" DataVersion="version" @bind-ExpandedIds="expanded" @bind-SelectedId="selected" SelectionReadOnly="selectionReadOnly" ExpansionReadOnly="expansionReadOnly" EmptyText="No teams found."/>
<p>Selected team: @(selected??"none") · Child requests: @requests</p>
@code {
 private bool selectionReadOnly,expansionReadOnly,fail; private int version,requests;
 private string? selected; private HashSet<string> expanded=[];
 private static readonly NgTreeNode<string>[] nodes=[new("root","Projects",HasChildren:true)];
 private static readonly NgDataColumn<string>[] columns=[new("name","Name",s=>s)];
 private void Reset(){version++;expanded=[];selected=null;}
 private async Task<IReadOnlyList<NgTreeNode<string>>> Load(NgTreeNode<string> node,CancellationToken token){
   requests++;await Task.Delay(350,token);await InvokeAsync(StateHasChanged);if(fail)throw new InvalidOperationException("Demo failure");
   return node.Id=="root"?[new("a","Design"),new("b","Engineering",HasChildren:true)]:[new("api","API"),new("web","Web")];
 }
}
```

## Flutter example

```dart
final nodes = <NgTreeNode<String>>[const NgTreeNode('root','Projects',hasChildren: true)];
Set<String> expanded = {};
String? selected;
bool selectionReadOnly = false, expansionReadOnly = false, fail = false;
int version = 0, requests = 0;
Future<List<NgTreeNode<String>>> load(NgTreeNode<String> node) async {
  requests++; await Future<void>.delayed(const Duration(milliseconds: 350)); if (mounted) setState(() {});
  if (fail) throw StateError('Demo failure');
  return node.id == 'root' ? [const NgTreeNode('a','Design'),const NgTreeNode('b','Engineering',hasChildren:true)]
    : [const NgTreeNode('api','API'),const NgTreeNode('web','Web')];
}
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
 NgCheckBox(label:'Selection read-only',value:selectionReadOnly,onChanged:(v)=>setState(()=>selectionReadOnly=v)),
 NgCheckBox(label:'Expansion read-only',value:expansionReadOnly,onChanged:(v)=>setState(()=>expansionReadOnly=v)),
 NgCheckBox(label:'Fail requests',value:fail,onChanged:(v)=>setState(()=>fail=v)),
 NgButton(onPressed:()=>setState((){version++;expanded={};selected=null;}),child:const Text('Reset tree')),
 NgTreeList<String>(items:nodes,columns: [NgDataColumn('name','Name',(s) => s)], loadChildren:load,dataVersion:version,
   expandedIds:expanded,onExpandedChanged:(v)=>setState(()=>expanded=v),selectedId:selected,onSelected:(v)=>setState(()=>selected=v),
   selectionReadOnly:selectionReadOnly,expansionReadOnly:expansionReadOnly,emptyText:'No teams found.'),
 Text('Selected team: ${selected??"none"} · Child requests: $requests'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `ExpansionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `EmptyTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No matching items." | See the behavior rules and model contract above. |
| `Label` | `string` | "Hierarchy" | Visible label or accessible name. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | [] | Column definitions; see the data model and example. |
| `ExpandedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `ExpandedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string?>` | not set | Selected item ID for the parent to store. |
| `Items` | `IReadOnlyList<NgTreeNode<T>>` | [] | Input collection. Replace it when changing records or configuration. |
| `LoadChildren` | `Func<NgTreeNode<T>,CancellationToken,Task<IReadOnlyList<NgTreeNode<T>>>>?` | not set | Async child adapter for unloaded HasChildren branches; first explicit expansion. |
| `DataVersion` | `object?` | not set | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `LoadingText` | `string` | "Loading children…" | Localized loading status. |
| `ErrorText` | `string` | "Unable to load children. Expand to retry." | Localized failure status; raw service errors are not rendered. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `items` | `List<NgTreeNode<T>>` | Input collection. Replace it when changing records or configuration. |
| `loadChildren` | `Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)?` | Async child adapter for unloaded HasChildren branches; first explicit expansion. |
| `dataVersion` | `Object?` | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `loadingText` | `String` | Localized loading status. |
| `errorText` | `String` | Localized failure status; raw service errors are not rendered. |
| `columns` | `List<NgDataColumn<T>>` | Column definitions; see the data model and example. |
| `expandedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onExpandedChanged` | `ValueChanged<Set<String>>` | Requested open state; store it with setState or your state manager. |
| `onSelected` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `expansionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `emptyBuilder` | `Widget?` | See the behavior rules and model contract above. |

```dart
const NgTreeList({
    super.key,
    required this.items,
    this.loadChildren,
    this.dataVersion,
    this.loadingText = 'Loading children…',
    this.errorText = 'Unable to load children. Expand to retry.',
    required this.columns,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Hierarchy',
    this.selectionReadOnly = false,
    this.expansionReadOnly = false,
    this.emptyBuilder,
    this.emptyText = 'No matching items.',
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTreeList.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
