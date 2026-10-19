# NgTreeView — Tree view

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Browse and select hierarchical records.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgTreeView) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgTreeView)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

HasChildren/hasChildren marks an unloaded branch. LoadChildren/loadChildren returns its children on the first explicit expansion; a failed expansion displays ErrorText/errorText and can be retried. Keep lazy branches initially collapsed. LoadingText/loadingText is shown while waiting. Children are cached for collapse/reopen, including an empty result which turns the branch into a leaf. Duplicate/cyclic IDs across the resolved tree are rejected as load errors. Search examines loaded nodes only and does not fetch descendants. Replace the immutable root collection, loader, or DataVersion/dataVersion to invalidate the cache and pending results; keep references stable across selection/expansion rebuilds. Blazor sends cancellation; Flutter discards stale futures without transport cancellation. Selection and expansion remain parent-controlled; locks and disabled nodes are rechecked after loading. Returned children do not mutate the parent root collection. Templates and custom empty text remain supported. Virtualization, drag/drop, complete keyboard/screen-reader parity remain open. Checkboxes/checkboxes enables independent multi-checking through CheckedIds/checkedIds and CheckedIdsChanged/onCheckedChanged. Store the proposed fresh set in the parent; rejecting it keeps the previous display. CheckingReadOnly/checkingReadOnly and CanCheck/canCheck protect checking independently of row selection and expansion. Disabled nodes cannot change. CheckLabel/checkLabel supplies a localized accessible checkbox label. Checks preserve unknown, filtered and collapsed IDs and never mutate the supplied set. Checking a lazy parent does not load or check children. Each checkbox is keyboard reachable; Space changes that checkbox without selecting or expanding its row. CheckChildren/checkChildren (default false) enables a cascade over the parent record plus its eligible, already loaded descendants. The checkbox is checked when all those IDs are present, unchecked when none are, and mixed otherwise. Clicking mixed checks the complete eligible branch; clicking checked clears it. One callback contains the whole proposed set. Disabled nodes and CanCheck/canCheck=false nodes are subtree barriers, preserving all IDs below them. Filtering and collapsing do not narrow this branch operation. CheckingReadOnly does not change the aggregate display. Independently checking every child does not check the parent record: its own ID also participates. Newly loaded descendants do not inherit marks and can turn a previously checked parent mixed without emitting a callback. Changing the cascade mode, predicate, source or loaded children only recomputes display; it does not normalize parent data. Unknown IDs and excluded branches are retained. Full-remote checking, upward ID normalization, automatic pruning and fetching unseen descendants remain application policy. Flutter partialCheckText supplies a localized spoken value for a mixed checkbox (default Partially checked). The current Flutter Web SDK renders a mixed checkbox visually and reports CheckedState.mixed internally, but its legacy DOM checkbox role maps aria-checked to false. The explicit spoken value preserves the partial-state information; exact Web ARIA mixed-state parity and physical screen-reader verification remain open. Blazor uses native indeterminate plus aria-checked=mixed. ShowCheckActions/showCheckActions (default false) displays Check loaded nodes and Clear loaded checks. These actions always cover the complete eligible loaded forest, independently of search, collapse and CheckChildren/checkChildren. They never load new children. Protected/disabled roots and subtrees are excluded; unknown IDs and existing protected checks are preserved. One fresh set is proposed per action; the parent can accept or reject it. Empty/no-op actions, CheckingReadOnly and absent checking callbacks disable the buttons. Stale actions recheck current data, permissions and visibility settings. CheckLoadedText/checkLoadedText and ClearLoadedText/clearLoadedText localize the two button labels. Loading new children updates action availability without changing checked IDs.

## Blazor example

```razor
<NgCheckBox Label="Selection read-only" @bind-Value="selectionReadOnly"/>
<NgCheckBox Label="Expansion read-only" @bind-Value="expansionReadOnly"/>
<NgCheckBox Label="Fail requests" @bind-Value="fail"/>
<NgCheckBox Label="Checking read-only" @bind-Value="checkingReadOnly"/>
<NgCheckBox Label="Protect Design" @bind-Value="protectDesign"/>
<NgCheckBox Label="Reject check changes" @bind-Value="rejectChecks"/>
<NgCheckBox Label="Cascade loaded children" @bind-Value="cascade"/>
<NgButton OnClick="Reset">Reset tree</NgButton>
<NgTreeView TItem="string" Items="nodes" Text="s=>s" LoadChildren="Load" Checkboxes="true" ShowCheckActions="true" CheckChildren="cascade" CheckedIds="checkedIds" CheckedIdsChanged="AcceptChecks" CheckingReadOnly="checkingReadOnly" CanCheck="CanCheckNode" DataVersion="version" @bind-ExpandedIds="expanded" @bind-SelectedId="selected" SelectionReadOnly="selectionReadOnly" ExpansionReadOnly="expansionReadOnly" EmptyText="No teams found."/>
<p>Checked IDs: @string.Join(", ",checkedIds.Order())</p>
<p>Selected team: @(selected??"none") · Child requests: @requests</p>
@code {
 private bool rejectChecks; private bool cascade=true;
 private void AcceptChecks(HashSet<string> next){if(!rejectChecks)checkedIds=next;}
 private bool CanCheckNode(NgTreeNode<string> n)=>!protectDesign || n.Id!="a";
 private bool checkingReadOnly,protectDesign=true; private HashSet<string> checkedIds=["offscreen"];
 private bool selectionReadOnly,expansionReadOnly,fail; private int version,requests;
 private string? selected; private HashSet<string> expanded=[];
 private static readonly NgTreeNode<string>[] nodes=[new("root","Projects",HasChildren:true)];
 private void Reset(){version++;expanded=[];selected=null;checkedIds=["offscreen"];}
 private async Task<IReadOnlyList<NgTreeNode<string>>> Load(NgTreeNode<string> node,CancellationToken token){
   requests++;await Task.Delay(350,token);await InvokeAsync(StateHasChanged);if(fail)throw new InvalidOperationException("Demo failure");
   return node.Id=="root"?[new("a","Design"),new("b","Engineering",HasChildren:true)]:[new("api","API"),new("web","Web")];
 }
}
```

## Flutter example

```dart
final nodes = <NgTreeNode<String>>[const NgTreeNode('root','Projects',hasChildren: true)];
Set<String> checkedIds = {"offscreen"};
bool checkingReadOnly=false,protectDesign=true,rejectChecks=false,cascade=true;
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
 NgCheckBox(label:'Checking read-only',value:checkingReadOnly,onChanged:(v)=>setState(()=>checkingReadOnly=v)),
 NgCheckBox(label:'Protect Design',value:protectDesign,onChanged:(v)=>setState(()=>protectDesign=v)),
 NgCheckBox(label:'Reject check changes',value:rejectChecks,onChanged:(v)=>setState(()=>rejectChecks=v)),
 NgCheckBox(label:'Cascade loaded children',value:cascade,onChanged:(v)=>setState(()=>cascade=v)),
 NgButton(onPressed:()=>setState((){version++;expanded={};selected=null;checkedIds={"offscreen"};}),child:const Text('Reset tree')),
 NgTreeView<String>(items:nodes,text: (s) => s, loadChildren:load,dataVersion:version,checkboxes:true,showCheckActions:true,checkChildren:cascade,checkedIds:checkedIds,onCheckedChanged:(v){if(!rejectChecks)setState(()=>checkedIds=v);},checkingReadOnly:checkingReadOnly,canCheck:(n)=>!protectDesign || n.id!="a",
   expandedIds:expanded,onExpandedChanged:(v)=>setState(()=>expanded=v),selectedId:selected,onSelected:(v)=>setState(()=>selected=v),
   selectionReadOnly:selectionReadOnly,expansionReadOnly:expansionReadOnly,emptyText:'No teams found.'),
 Text('Checked IDs: ${(checkedIds.toList()..sort()).join(", ")}'),
 Text('Selected team: ${selected??"none"} · Child requests: $requests'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `ItemTemplate` | `RenderFragment<TItem>?` | not set | See the behavior rules and model contract above. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `ExpansionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `EmptyTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No matching items." | See the behavior rules and model contract above. |
| `Label` | `string` | "Folders" | Visible label or accessible name. |
| `Text` | `Func<TItem,string>` | required | See the behavior rules and model contract above. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string?>` | not set | Selected item ID for the parent to store. |
| `ExpandedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `ExpandedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |
| `Items` | `IReadOnlyList<NgTreeNode<T>>` | [] | Input collection. Replace it when changing records or configuration. |
| `LoadChildren` | `Func<NgTreeNode<T>,CancellationToken,Task<IReadOnlyList<NgTreeNode<T>>>>?` | not set | Async child adapter for unloaded HasChildren branches; first explicit expansion. |
| `DataVersion` | `object?` | not set | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `LoadingText` | `string` | "Loading children…" | Localized loading status. |
| `ErrorText` | `string` | "Unable to load children. Expand to retry." | Localized failure status; raw service errors are not rendered. |
| `ShowCheckActions` | `bool` | false | Show explicit check/clear actions for all eligible loaded nodes. Default false. |
| `CheckLoadedText` | `string` | "Check loaded nodes" | Localized check-loaded button label. |
| `ClearLoadedText` | `string` | "Clear loaded checks" | Localized clear-loaded button label. |
| `CheckChildren` | `bool` | false | Cascade over the parent record and eligible loaded descendants; mixed checks the full branch. Default false. |
| `Checkboxes` | `bool` | false | Show independent node checkboxes (default false). |
| `CheckedIds` | `HashSet<string>` | [] | Parent-owned checked IDs; hidden/unknown IDs are preserved. |
| `CheckedIdsChanged` | `EventCallback<HashSet<string>>` | not set | Proposed fresh set; store to accept or ignore to reject. |
| `CheckingReadOnly` | `bool` | false | Lock checking independently of selection and expansion. |
| `CanCheck` | `Func<NgTreeNode<T>,bool>?` | not set | Pure node predicate; false protects existing checked state. |
| `CheckLabel` | `Func<T,string>?` | not set | Localized checkbox accessible name from the item. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `itemBuilder` | `Widget Function(BuildContext, T)?` | See the behavior rules and model contract above. |
| `items` | `List<NgTreeNode<T>>` | Input collection. Replace it when changing records or configuration. |
| `loadChildren` | `Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)?` | Async child adapter for unloaded HasChildren branches; first explicit expansion. |
| `dataVersion` | `Object?` | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `loadingText` | `String` | Localized loading status. |
| `errorText` | `String` | Localized failure status; raw service errors are not rendered. |
| `text` | `String Function(T)` | See the behavior rules and model contract above. |
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `expansionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `checkboxes` | `bool` | Show independent node checkboxes (default false). |
| `checkingReadOnly` | `bool` | Lock checking independently of selection and expansion. |
| `checkChildren` | `bool` | Cascade over the parent record and eligible loaded descendants; mixed checks the full branch. Default false. |
| `partialCheckText` | `String` | Flutter spoken value for mixed checks; default Partially checked. See Web ARIA limitation. |
| `showCheckActions` | `bool` | Show explicit check/clear actions for all eligible loaded nodes. Default false. |
| `checkLoadedText` | `String` | Localized check-loaded button label. |
| `clearLoadedText` | `String` | Localized clear-loaded button label. |
| `checkedIds` | `Set<String>` | Parent-owned checked IDs; hidden/unknown IDs are preserved. |
| `onCheckedChanged` | `ValueChanged<Set<String>>?` | Proposed fresh set; store with setState to accept. |
| `canCheck` | `bool Function(NgTreeNode<T>)?` | Pure node predicate; false protects existing checked state. |
| `checkLabel` | `String Function(T)?` | Localized checkbox accessible name from the item. |
| `emptyBuilder` | `Widget?` | See the behavior rules and model contract above. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `expandedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onSelected` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `onExpandedChanged` | `ValueChanged<Set<String>>` | Requested open state; store it with setState or your state manager. |

```dart
const NgTreeView({
    super.key,
    required this.items,
    this.loadChildren,
    this.dataVersion,
    this.loadingText = 'Loading children…',
    this.errorText = 'Unable to load children. Expand to retry.',
    required this.text,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Folders',
    this.showCheckActions = false,
    this.checkLoadedText = 'Check loaded nodes',
    this.clearLoadedText = 'Clear loaded checks',
    this.partialCheckText = 'Partially checked',
    this.checkChildren = false,
    this.checkboxes = false,
    this.checkingReadOnly = false,
    this.checkedIds = const {},
    this.onCheckedChanged,
    this.canCheck,
    this.checkLabel,
    this.selectionReadOnly = false,
    this.expansionReadOnly = false,
    this.emptyBuilder,
    this.emptyText = 'No matching items.',
    this.itemBuilder,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTreeView.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
