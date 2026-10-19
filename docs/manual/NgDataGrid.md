# NgDataGrid — Data grid

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Page, search and sort local or remote records.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDataGrid) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDataGrid)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

ReadData/readData enables asynchronous page loading; Items/items is used only in local mode. The request contains 1-based Page/page, PageSize/pageSize, Search/search and an ordered immutable Sorts/sorts list. Return only the requested page and Total/total after filtering, before paging. The demo simulates a remote data adapter with a delay; replace its body with your HTTP/database call. A newer request or source replacement invalidates older results and errors; Blazor also passes a cancellation token. Flutter ignores stale futures but does not abort the transport. Loading hides old rows and blocks selection. Failure shows ErrorText/errorText and RetryText/retryText without exposing exception details. Change DataVersion/dataVersion to reload page 1; keep reader identity stable. Blazor ReloadAsync reloads the current page. A shrinking total clamps the page and fetches it again. Invalid totals, duplicate IDs and oversized pages become retryable errors. MultiSort/multiSort appends clicked columns by priority; clicking again toggles direction without moving priority. Clear sorting restores source order. Local sorting is stable. Row/column IDs must be unique and nonblank. Selection remains parent-owned and page selection preserves hidden/protected IDs. CanSelect/canSelect and SelectionReadOnly/selectionReadOnly still apply. Virtualization, remote grouping, built-in CRUD and export remain open. See [data workspace](../data-workspace.md). GroupBy/groupBy enables one local grouping level over string keys; empty strings are a valid group and keys are case-sensitive. Search and sort run first, then groups gather matching records in first-appearance order while preserving sorted order within each group, then the flattened grouped rows are paged. Headers do not consume page slots. A group crossing a page boundary repeats its header; the count is the complete filtered group count, not only the current page. GroupText/groupText formats the key and count as plain text. Selection/page selection covers data rows only and retains off-page IDs. Enabling/disabling grouping resets to page 1; changing a grouping rule in-place requires DataVersion/dataVersion to reset paging. Selectors must be pure. GroupBy/groupBy cannot be combined with ReadData/readData: remote grouping requires a separate group-aware protocol and is rejected, not approximated from one server page. Group collapse, multiple levels, aggregates and remote grouping remain open.

## Blazor example

```razor
<h3>Local grouped inventory</h3>
<NgCheckBox Label="Group by product" @bind-Value="grouped"/>
<NgDataGrid TItem="Product" Label="Grouped inventory" Items="rows" Columns="columns" RowId="r=>r.Id" GroupBy="@(grouped?ProductGroup:null)" GroupText="GroupCaption" MultiSort="true" @bind-SelectedIds="localSelected" CanSelect="r=>r.Count<100"/>
<p>Local selection: @string.Join(", ",localSelected.Order())</p>
<h3>Remote paging adapter</h3>
<NgCheckBox Label="Fail requests" @bind-Value="fail"/>
<NgButton OnClick="()=>version++">Reload source</NgButton>
<NgDataGrid TItem="Product" ReadData="Read" DataVersion="version" MultiSort="true" Columns="columns" RowId="r=>r.Id" @bind-SelectedIds="selected" CanSelect="r=>r.Count<100" PageSizes="new[]{5,10,20}"/>
<p>Requests: @requests · Latest query: @query</p>
@code {
 public record Product(string Id,string Name,int Count);
 private bool grouped=true; private HashSet<string> localSelected=[]; private string ProductGroup(Product row)=>row.Name; private string GroupCaption(string key,int count)=>$"{key}: {count} matching records";
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
Set<String> localSelected = {}; bool grouped=true;
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
  NgDataGrid<({String id,String name,int count})>(label:'Grouped inventory',items:rows,columns:columns,rowId:(r)=>r.id,groupBy:grouped?(r)=>r.name:null,groupText:(key,count)=>'$key: $count matching records',multiSort:true,selectedIds:localSelected,onSelectionChanged:(v)=>setState(()=>localSelected=v),canSelect:(r)=>r.count<100),
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
