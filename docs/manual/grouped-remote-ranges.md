# Grouped remote ranges

Use `ReadGroupedRange` (Blazor) or `readGroupedRange` (Flutter) with fixed-height virtualization to scroll a server result containing group headers and records. The client retains a bounded window instead of downloading every group or record. This mode is separate from [grouped record paging](remote-grouped-data.md) and [flat remote ranges](remote-ranges.md).

[Open the Blazor HTTP example](http://127.0.0.1:5180/grouped-range). [Open the Flutter HTTP example](http://127.0.0.1:5181/?grouped-range).

## Contract

`NgGroupedRangeRequest` contains `StartIndex/startIndex`, `Count/count`, `Search/search`, ordered `Sorts/sorts`, `GroupKeys/groupKeys` and `CollapsedGroups/collapsedGroups`. Group keys are one to eight distinct application-defined field identifiers. Collapsed IDs encode full paths using `NgDataOperations.GroupId` / `ngGroupId`; do not concatenate display labels.

Offsets count **visible slots**, including group headers and records, after applying search, sort, grouping and accepted collapse state. A header occupies one slot. A collapsed header remains visible, but its descendants occupy no slots. Changing the accepted collapse set resets the viewport and requests a new server window; a rejected proposal does not change the result. Unknown collapsed IDs are preserved. Disabling `CollapsibleGroups/collapsibleGroups` sends an empty collapse set.

`NgGroupedRangeResult<T>` echoes the start index and supplies:

- `Total/total`: total visible slots, from 0 to 100,000, including headers.
- `RecordTotal/recordTotal`: filtered record count before collapse, from 0 to 100,000.
- `Entries/entries`: exactly `min(count, max(0, total-startIndex))` entries. Each has a full `Path/path`, `IsGroup/isGroup`, and `Item/item` for a record. A group header does not use `Item`.
- `Groups/groups`: metadata for every entry path and ancestor in this window, including ancestors whose header is outside the window. Each metadata entry has the full path, filtered record count before collapse, and optional numeric summaries.

Entries are depth-first and groups are contiguous. An in-window group begins with its header. A window may start inside a leaf group without repeating ancestor headers. The first slot of the complete result is always a root header. Records use a path with the same depth as the group-key list and stable nonblank IDs unique within the response. Metadata must be complete, unique and relevant; child counts cannot exceed their parent count. Summaries have unique nonblank titles and finite values or null. Server counts are checked for consistency, not independently recomputed from unloaded records.

The entire envelope is validated before any row becomes interactive. Bad offsets, missing entries, malformed metadata, duplicate IDs and records below a collapsed group produce the ordinary safe error and Retry action. Requests are limited to 512 slots. Rows are fixed at 40–128 pixels; the viewport contains at most 128 rows. There is no column virtualization or variable-height row support.

## Server responsibilities

Authorize and filter the data on your server, apply deterministic ordering with a stable tie-breaker, group it, apply the requested collapsed IDs and return the exact visible-slot window. Keep counts and entries from a consistent query snapshot. When external data changes, update `DataVersion/dataVersion` or refresh the query. The client rejects obsolete successes and failures after a query, source, grouping or collapse change. Blazor propagates cancellation; Flutter ignores obsolete futures.

`NgGroupedRange.Window` / `NgGroupedRange.window` is a reference **in-memory** adapter over a complete filtered/sorted collection. It constructs the logical group tree on the server; it is not a database query provider, streaming engine or a claim of bounded server memory. Production applications provide their own transport and database implementation.

Shrinking totals may return an empty window beyond the new end; the virtual view corrects its position and loads the new tail. Retry preserves the requested position. Search, sort, group-key changes and accepted collapse reset the position. After an error the old records are not available for editing, selection or export.

## Blazor example

```razor
<NgDataGrid TItem="int" ReadGroupedRange="Read" RemoteGroupKeys="keys"
 Virtualize="true" RowHeight="48" ViewportHeight="384" Columns="columns"
 RowId="i=>i.ToString()" CollapsibleGroups="true" @bind-CollapsedGroups="collapsed"
 @bind-SelectedIds="selected" LoadedWindowText="Loaded slots" Label="Grouped inventory" />
@code {
 private readonly string[] keys=["region"];
 private readonly int[] source=Enumerable.Range(1,1000).ToArray();
 private readonly NgDataColumn<int>[] columns=[new("id","Record",i=>i)];
 private HashSet<string> collapsed=[],selected=[];
 private async Task<NgGroupedRangeResult<int>> Read(NgGroupedRangeRequest request,CancellationToken token){
   await Task.Delay(100,token);
   var filtered=NgDataOperations.Query(source,columns,request.Search,request.Sorts);
   return NgGroupedRange.Window(filtered,new Func<int,string>[]{i=>i<=500?"North":"South"},Array.Empty<NgGroupAggregate<int>>(),request);
 }
}
```

## Flutter example

Place this code in a `State` class with the component package and Material imports. It uses a delayed in-memory adapter; the linked gallery uses the same real HTTP endpoint as Blazor.

```dart
final keys=<String>['region'];
final source=List.generate(1000,(i)=>i+1);
final columns=<NgDataColumn<int>>[NgDataColumn('id','Record',(i)=>i)];
Set<String> collapsed={},selected={};
Future<NgGroupedRangeResult<int>> read(NgGroupedRangeRequest request)async{
  await Future<void>.delayed(const Duration(milliseconds:100));
  final filtered=NgDataOperations.queryMany(source,columns,request.search,request.sorts);
  return NgGroupedRange.window<int>(filtered,[(i)=>i<=500?'North':'South'],[],request);
}
@override
Widget build(BuildContext context)=>NgDataGrid<int>(
 readGroupedRange:read,remoteGroupKeys:keys,virtualize:true,rowHeight:48,viewportHeight:384,
 columns:columns,rowId:(i)=>'$i',collapsibleGroups:true,collapsedGroups:collapsed,
 onCollapsedGroupsChanged:(v)=>setState(()=>collapsed=v),selectedIds:selected,
 onSelectionChanged:(v)=>setState(()=>selected=v),loadedWindowText:'Loaded slots',label:'Grouped inventory');
```

## Selection, editing and export

Selection stays application-owned. A header has no selection checkbox. Header selection includes eligible records in the retained window, including overscan, and preserves previously selected off-window IDs. Group collapse never clears those IDs. Protected records and selection locks still apply.

Group actions are controlled by `GroupExpansionReadOnly/groupExpansionReadOnly`. Expand/collapse loaded groups affects only headers in the retained window; it does not imply all server groups. A header outside the retained window can be expanded by updating the application-owned collapsed set. `ExpandWindowGroupsText/expandWindowGroupsText`, `CollapseWindowGroupsText/collapseWindowGroupsText`, `LoadedWindowText/loadedWindowText` and `SelectWindowText/selectWindowText` support application translations.

Existing single-record editing can persist loaded records through the application callback. Successful persistence refreshes the grouped query. [CSV/TSV Page export](grid-export.md) includes only loaded records, excluding headers and summary rows. Full filtered/selected export requires a separate bounded `ReadExportData/readExportData` adapter. It must not mistake the retained window for the entire result.

## HTTP exercise

The linked examples contain 10,000 synthetic records under `region` and optional `kind` groups. Both call `POST /api/grouped-range-inventory` with JSON fields matching the lower-camel-case request names above. The response uses `startIndex`, `total`, `recordTotal`, `entries` and `groups`; each entry uses `path`, `isGroup`, `item`. Group metadata uses `path`, `count`, `summaries` (`title`, `value`).

Try nesting, accepted/rejected collapse, group and selection locks, searching, sorting, jumping to the end, exporting the loaded records, malformed responses, failures and Retry. Slow reads exercise obsolete-response protection. Enable the smaller server dataset and scroll beyond its end to exercise shrink correction. These are public synthetic fixtures; never put private application data in the demo endpoint.

## Compatibility and remaining boundaries

This opt-in mode cannot be combined with `Items/items`, ordinary page readers, grouped page readers, flat range readers, local group selectors or local aggregates. Existing modes retain their contracts. The library and its matching gallery/SDK must be updated together; an older library does not expose this new API.

Variable row heights, column virtualization, drag-to-group, aggregate footer templates, database providers, batch/cell editing, native-platform validation and full screen-reader certification remain separate work. Fixed-height templates must fit the configured row height.
