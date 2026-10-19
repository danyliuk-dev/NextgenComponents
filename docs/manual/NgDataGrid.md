# NgDataGrid — Data grid

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Page, search and sort local or remote records.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDataGrid) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDataGrid)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

ReadData/readData enables asynchronous page loading; Items/items is used only in local mode. The request contains 1-based Page/page, PageSize/pageSize, Search/search and an ordered immutable Sorts/sorts list. Return only the requested page and Total/total after filtering, before paging. The demo simulates a remote data adapter with a delay; replace its body with your HTTP/database call. A newer request or source replacement invalidates older results and errors; Blazor also passes a cancellation token. Flutter ignores stale futures but does not abort the transport. Loading hides old rows and blocks selection. Failure shows ErrorText/errorText and RetryText/retryText without exposing exception details. Change DataVersion/dataVersion to reload page 1; keep reader identity stable. Blazor ReloadAsync reloads the current page. A shrinking total clamps the page and fetches it again. Invalid totals, duplicate IDs and oversized pages become retryable errors. MultiSort/multiSort appends clicked columns by priority; clicking again toggles direction without moving priority. Clear sorting restores source order. Local sorting is stable. Row/column IDs must be unique and nonblank. Selection remains parent-owned and page selection preserves hidden/protected IDs. CanSelect/canSelect and SelectionReadOnly/selectionReadOnly still apply. Virtualization, remote grouping, built-in CRUD and export remain open. See [data workspace](../data-workspace.md).

### Local grouping and paging

GroupBy/groupBy enables one local grouping level over string keys; empty strings are a valid group and keys are case-sensitive. Search and sort run first, then groups gather matching records in first-appearance order while preserving sorted order within each group, then the flattened grouped rows are paged. Headers do not consume page slots. A group crossing a page boundary repeats its header; the count is the complete filtered group count, not only the current page. GroupText/groupText formats the key and count as plain text. Selection/page selection covers data rows only and retains off-page IDs. Enabling/disabling grouping resets to page 1; changing a grouping rule in-place requires DataVersion/dataVersion to reset paging. Selectors must be pure. GroupBy/groupBy cannot be combined with ReadData/readData: remote grouping requires a separate group-aware protocol and is rejected, not approximated from one server page. Remote grouping, virtualization and built-in CRUD remain open.

### Nested groups

GroupSelectors/groupSelectors accepts up to eight ordered string selectors for nested groups; use it instead of GroupBy/groupBy, never together. Each level keeps first-appearance order. Change DataVersion/dataVersion when changing the level order or rule; the demo uses its grouping switches as the version.

### Controlled expansion

CollapsibleGroups/collapsibleGroups opts into controlled expansion. CollapsedGroups/collapsedGroups stores full-path IDs from NgDataOperations.GroupId(path) / ngGroupId(path), not raw keys. IDs use length-prefixed UTF-16 segments, so repeated labels, empty keys and separator characters do not collide. Store the fresh set from CollapsedGroupsChanged/onCollapsedGroupsChanged to accept a request, or ignore it to reject. Hidden and unknown IDs survive updates. GroupExpansionReadOnly/groupExpansionReadOnly and missing callbacks disable controls; external collapsed state is still displayed. Turning collapsibility off ignores, but does not erase, stored state. GroupToggleLabel/groupToggleLabel receives the path and current expanded state; ExpandGroupsText/expandGroupsText and CollapseGroupsText/collapseGroupsText localize actions.

### Bulk actions and selection

Bulk actions affect every currently filtered group, including off-page descendants; filtered-out/unknown IDs are retained. Collapse is a view operation after paging: record ranges, page counts and full group counts stay unchanged, and each visited page repeats the necessary ancestor headers. Fully collapsed pages show headers only, not an empty-result message. Page selection includes only eligible rendered data rows; existing hidden selections are preserved.

### Group summaries

GroupAggregates/groupAggregates supplies NgGroupAggregate descriptors: title, numeric value selector, operation (sum, average, min, max, count) and optional format callback. Aggregates use all filtered records at each level, independently of paging and collapse; parent averages are record-weighted. Null/NaN/infinite values are ignored; count counts finite numeric values, while the header count counts records. Empty sum/count are zero, empty average/min/max are missing (displayed as an em dash). Results use double precision, not financial decimal arithmetic. Invalid operations fail validation. Headers and aggregate formatting are plain text; callbacks must be pure. The grid uses native keyboard buttons for toggling; no screen-reader certification or native-target parity is claimed.

## Blazor example

```razor
<h3>Local grouped inventory</h3>
<NgCheckBox Label="Group by product" @bind-Value="grouped"/>
<NgCheckBox Label="Also group by availability" @bind-Value="nested"/>
<NgCheckBox Label="Show group totals" @bind-Value="totals"/>
<NgCheckBox Label="Lock group expansion" @bind-Value="groupLocked"/>
<NgDataGrid TItem="Product" Label="Grouped inventory" Items="rows" Columns="columns" RowId="r=>r.Id" GroupSelectors="Grouping" DataVersion="@($"{grouped}/{nested}")" CollapsibleGroups="true" @bind-CollapsedGroups="collapsed" GroupExpansionReadOnly="groupLocked" GroupAggregates="@(totals?aggregates:[])" GroupText="GroupCaption" MultiSort="true" @bind-SelectedIds="localSelected" CanSelect="r=>r.Count<100"/>
<p>Local selection: @string.Join(", ",localSelected.Order())</p>
<h3>Remote paging adapter</h3>
<NgCheckBox Label="Fail requests" @bind-Value="fail"/>
<NgButton OnClick="()=>version++">Reload source</NgButton>
<NgDataGrid TItem="Product" ReadData="Read" DataVersion="version" MultiSort="true" Columns="columns" RowId="r=>r.Id" @bind-SelectedIds="selected" CanSelect="r=>r.Count<100" PageSizes="new[]{5,10,20}"/>
<p>Requests: @requests · Latest query: @query</p>
@code {
 public record Product(string Id,string Name,int Count);
 private bool grouped=true,nested=true,totals=true,groupLocked;
 private HashSet<string> collapsed=[];
 private IReadOnlyList<Func<Product,string>> Grouping=>!grouped?[]:nested?[ProductGroup,r=>r.Count<100?"Available":"Protected"]:[ProductGroup];
 private static readonly NgGroupAggregate<Product>[] aggregates=[new("Total quantity",r=>r.Count),new("Average",r=>r.Count,"average",v=>v?.ToString("0.0")??"—")]; private HashSet<string> localSelected=[]; private string ProductGroup(Product row)=>row.Name; private string GroupCaption(string key,int count)=>$"{key}: {count} matching records";
 private bool fail; private int version,requests; private string query="";
 private HashSet<string> selected=[];
 private static readonly Product[] rows=Enumerable.Range(1,40).Select(i=>new Product($"p{i}",i%2==0?"Desk":"Chair",i*4)).ToArray();
 private static readonly NgDataColumn<Product>[] columns=[new("name","Name",r=>r.Name),new("count","Quantity",r=>r.Count)];
 private async Task<NgDataResult<Product>> Read(NgDataRequest request,CancellationToken token){
   requests++;query=$"{request.Search} / page {request.Page} / {request.Sorts.Count} sorts";
   await Task.Delay(350,token);await InvokeAsync(StateHasChanged);
   if(fail)throw new InvalidOperationException("Demo failure");
   var result=NgDataOperations.Query(rows,columns,request.Search,request.Sorts);
   return new(result.Skip((request.Page-1)*request.PageSize).Take(request.PageSize).ToArray(),result.Count);
 }
}
```

## Flutter example

```dart
final rows = List.generate(40, (i) => (id: 'p${i+1}', name: i.isOdd ? 'Desk' : 'Chair', count: (i+1)*4));
final columns = <NgDataColumn<({String id, String name, int count})>>[
  NgDataColumn('name', 'Name', (r) => r.name), NgDataColumn('count', 'Quantity', (r) => r.count)];
Set<String> localSelected = {}; bool grouped=true,nested=true,totals=true,groupLocked=false;
Set<String> collapsed={};
final aggregates=<NgGroupAggregate<({String id,String name,int count})>>[NgGroupAggregate('Total quantity',(r)=>r.count.toDouble()),NgGroupAggregate('Average',(r)=>r.count.toDouble(),operation:'average',format:(v)=>v?.toStringAsFixed(1)??'—')];
Set<String> selected = {};
bool fail = false;
int version = 0, requests = 0;
String query = '';
Future<NgDataResult<({String id, String name, int count})>> read(NgDataRequest request) async {
  requests++; query = '${request.search} / page ${request.page} / ${request.sorts.length} sorts';
  await Future<void>.delayed(const Duration(milliseconds: 350)); if (mounted) setState(() {});
  if (fail) throw StateError('Demo failure');
  final result = NgDataOperations.queryMany(rows, columns, request.search, request.sorts);
  return NgDataResult(result.skip((request.page-1)*request.pageSize).take(request.pageSize).toList(), result.length);
}
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  const Text('Local grouped inventory'),
  NgCheckBox(label:'Group by product',value:grouped,onChanged:(v)=>setState(()=>grouped=v)),
  NgCheckBox(label:'Also group by availability',value:nested,onChanged:(v)=>setState(()=>nested=v)),
  NgCheckBox(label:'Show group totals',value:totals,onChanged:(v)=>setState(()=>totals=v)),
  NgCheckBox(label:'Lock group expansion',value:groupLocked,onChanged:(v)=>setState(()=>groupLocked=v)),
  NgDataGrid<({String id,String name,int count})>(label:'Grouped inventory',items:rows,columns:columns,rowId:(r)=>r.id,groupSelectors:!grouped?[]:nested?[(r)=>r.name,(r)=>r.count<100?'Available':'Protected']:[(r)=>r.name],dataVersion:'$grouped/$nested',collapsibleGroups:true,collapsedGroups:collapsed,onCollapsedGroupsChanged:(v)=>setState(()=>collapsed=v),groupExpansionReadOnly:groupLocked,groupAggregates:totals?aggregates:[],groupText:(key,count)=>'$key: $count matching records',multiSort:true,selectedIds:localSelected,onSelectionChanged:(v)=>setState(()=>localSelected=v),canSelect:(r)=>r.count<100),
  Text('Local selection: ${(localSelected.toList()..sort()).join(", ")}'),
  const Text('Remote paging adapter'),
  NgCheckBox(label: 'Fail requests', value: fail, onChanged: (v) => setState(() => fail = v)),
  NgButton(onPressed: () => setState(() => version++), child: const Text('Reload source')),
  NgDataGrid<({String id, String name, int count})>(readData: read, dataVersion: version, multiSort: true,
    columns: columns, rowId: (r) => r.id, selectedIds: selected, canSelect: (r) => r.count < 100,
    pageSizes: const [5,10,20], onSelectionChanged: (v) => setState(() => selected = v)),
  Text('Requests: $requests · Latest query: $query'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `ReadData` | `Func<NgDataRequest,CancellationToken,Task<NgDataResult<TItem>>>?` | not set | Async page adapter; return requested rows and filtered total. See request/result contracts above. |
| `GroupBy` | `Func<TItem,string>?` | not set | Pure local string-key selector; grouping precedes paging and cannot be combined with ReadData. |
| `GroupText` | `Func<string,int,string>?` | not set | Plain-text caption from the group key and complete filtered group count. |
| `GroupSelectors` | `IReadOnlyList<Func<TItem,string>>` | [] | Ordered local string selectors, up to eight levels. Mutually exclusive with GroupBy. |
| `GroupAggregates` | `IReadOnlyList<NgGroupAggregate<TItem>>` | [] | Numeric aggregate descriptors over all filtered records in each group. |
| `CollapsibleGroups` | `bool` | false | Enable controlled group expansion and bulk actions. Default false. |
| `CollapsedGroups` | `HashSet<string>` | [] | Parent-owned set of encoded full group path IDs; use GroupId/ngGroupId. |
| `CollapsedGroupsChanged` | `EventCallback<HashSet<string>>` | not set | Propose one fresh collapsed-ID set; accept by storing it. |
| `GroupExpansionReadOnly` | `bool` | false | Lock group expansion independently of row selection. |
| `GroupToggleLabel` | `Func<IReadOnlyList<string>,bool,string>?` | not set | Localized accessible toggle name from path and current expanded state. |
| `ExpandGroupsText` | `string` | "Expand all groups" | Localized expand-all action label. |
| `CollapseGroupsText` | `string` | "Collapse all groups" | Localized collapse-all action label. |
| `DataVersion` | `object?` | not set | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `MultiSort` | `bool` | false | Append sorted columns in priority order; default false. |
| `LoadingText` | `string` | "Loading records…" | Localized loading status. |
| `ErrorText` | `string` | "Unable to load records." | Localized failure status; raw service errors are not rendered. |
| `RetryText` | `string` | "Retry" | Localized retry action text. |
| `Items` | `IReadOnlyList<TItem>` | [] | Input collection. Replace it when changing records or configuration. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | required | Column definitions; see the data model and example. |
| `RowId` | `Func<TItem,string>` | required | See the behavior rules and model contract above. |
| `Label` | `string` | "Records" | Visible label or accessible name. |
| `EmptyText` | `string` | "No matching records." | See the behavior rules and model contract above. |
| `CanSelect` | `Func<TItem,bool>?` | not set | See the behavior rules and model contract above. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `EmptyTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `PageSizes` | `IReadOnlyList<int>` | [5,10,25,50] | See the behavior rules and model contract above. |
| `Selectable` | `bool` | true | See the behavior rules and model contract above. |
| `SelectedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `SelectedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |
| `Toolbar` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `RowActions` | `RenderFragment<TItem>?` | not set | See the behavior rules and model contract above. |
| `InitialPageSize` | `int` | 5 | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `items` | `List<T>` | Input collection. Replace it when changing records or configuration. |
| `readData` | `Future<NgDataResult<T>> Function(NgDataRequest)?` | Async page adapter; return requested rows and filtered total. See request/result contracts above. |
| `dataVersion` | `Object?` | Change to invalidate pending reads and cached data; keep stable otherwise. |
| `groupBy` | `String Function(T)?` | Pure local string-key selector; grouping precedes paging and cannot be combined with ReadData. |
| `groupText` | `String Function(String, int)?` | Plain-text caption from the group key and complete filtered group count. |
| `groupSelectors` | `List<String Function(T)>` | Ordered local string selectors, up to eight levels. Mutually exclusive with GroupBy. |
| `groupAggregates` | `List<NgGroupAggregate<T>>` | Numeric aggregate descriptors over all filtered records in each group. |
| `collapsibleGroups` | `bool` | Enable controlled group expansion and bulk actions. Default false. |
| `groupExpansionReadOnly` | `bool` | Lock group expansion independently of row selection. |
| `collapsedGroups` | `Set<String>` | Parent-owned set of encoded full group path IDs; use GroupId/ngGroupId. |
| `onCollapsedGroupsChanged` | `ValueChanged<Set<String>>?` | Propose one fresh collapsed-ID set; accept with setState. |
| `groupToggleLabel` | `String Function(List<String>, bool)?` | Localized accessible toggle name from path and current expanded state. |
| `expandGroupsText` | `String` | Localized expand-all action label. |
| `collapseGroupsText` | `String` | Localized collapse-all action label. |
| `multiSort` | `bool` | Append sorted columns in priority order; default false. |
| `loadingText` | `String` | Localized loading status. |
| `errorText` | `String` | Localized failure status; raw service errors are not rendered. |
| `retryText` | `String` | Localized retry action text. |
| `columns` | `List<NgDataColumn<T>>` | Column definitions; see the data model and example. |
| `rowId` | `String Function(T)` | See the behavior rules and model contract above. |
| `selectedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onSelectionChanged` | `ValueChanged<Set<String>>?` | See the behavior rules and model contract above. |
| `rowActions` | `Widget Function(BuildContext, T)?` | See the behavior rules and model contract above. |
| `toolbar` | `Widget?` | See the behavior rules and model contract above. |
| `emptyBuilder` | `Widget?` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `canSelect` | `bool Function(T)?` | See the behavior rules and model contract above. |
| `pageSizes` | `List<int>` | See the behavior rules and model contract above. |
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `initialPageSize` | `int` | See the behavior rules and model contract above. |

```dart
const NgDataGrid({
    super.key,
    this.items = const [],
    this.readData,
    this.dataVersion,
    this.groupBy,
    this.groupText,
    this.groupSelectors = const [],
    this.groupAggregates = const [],
    this.collapsibleGroups = false,
    this.groupExpansionReadOnly = false,
    this.collapsedGroups = const {},
    this.onCollapsedGroupsChanged,
    this.groupToggleLabel,
    this.expandGroupsText = 'Expand all groups',
    this.collapseGroupsText = 'Collapse all groups',
    this.multiSort = false,
    this.loadingText = 'Loading records…',
    this.errorText = 'Unable to load records.',
    this.retryText = 'Retry',
    required this.columns,
    required this.rowId,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActions,
    this.toolbar,
    this.emptyBuilder,
    this.selectionReadOnly = false,
    this.canSelect,
    this.pageSizes = const [5, 10, 25, 50],
    this.label = 'Records',
    this.emptyText = 'No matching records.',
    this.initialPageSize = 5,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDataGrid.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
