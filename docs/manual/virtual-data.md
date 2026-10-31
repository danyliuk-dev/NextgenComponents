# Virtual scrolling for large data views

`NgDataGrid`, `NgTreeView` and `NgTreeList` support opt-in fixed-height virtual rendering; Grid also supports measured variable-height rows on Blazor and Flutter Web. Turn on `Virtualize` / `virtualize`, then set `RowHeight` / `rowHeight` (default 48) and `ViewportHeight` / `viewportHeight` (default 384). Heights must be finite; rows must be at least 40 pixels and the viewport at least one row high. The default nonvirtual behavior is unchanged.

## Data and loading boundaries

| Mode | Scrollable data | Loading behavior |
|---|---|---|
| Local Grid | All matching records, including expanded local group rows | Search, sort, grouping and aggregates still run over the in-memory collection. The local pager is hidden. |
| Remote Grid | The current server page, including its grouped metadata | Existing `ReadData` / `ReadGroupedData` adapters and pager remain. Scrolling never fetches another page or invents placeholders for unloaded records. Use an explicit page size such as 500. |
| Trees | The flattened, expanded, currently loaded nodes | Existing lazy child adapters still run on expansion; scrolling itself does not fetch children. |

The modes above virtualize rendering only. Continuous remote scrolling with bounded client data uses the separate [ReadRange contract](remote-ranges.md). Lazy group paging remains unsupported. Searching and flattening a large tree still visit its loaded nodes.

## Blazor

```razor
<NgDataGrid TItem="int" Items="records" Columns="columns" RowId="i=>i.ToString()"
    Virtualize="true" RowHeight="48" ViewportHeight="384"
    @bind-SelectedIds="selected" />
@code {
    private readonly int[] records=Enumerable.Range(1,10000).ToArray();
    private readonly NgDataColumn<int>[] columns=[new("id","Record",i=>i)];
    private HashSet<string> selected=[];
}
```

Fixed-height mode uses Blazor's `Virtualize` with table-row spacers. Keep the scrolling element focusable. Rows and templates must fit the configured height; avoid multiline content, expanding editors inside cells and images without fixed dimensions. The Grid's editing panel is outside the viewport. Table columns use fixed layout in this mode and retain horizontal scrolling.

## Flutter

```dart
NgDataGrid<int>(
  items: List.generate(10000, (i) => i + 1),
  columns: [NgDataColumn('id', 'Record', (int i) => i)],
  rowId: (i) => '$i',
  virtualize: true,
  rowHeight: 48,
  viewportHeight: 384,
  selectedIds: selected,
  onSelectionChanged: (ids) => setState(() => selected = ids),
)
```

Flutter uses a lazy `ListView` and constructs cell templates only for the current window and its framework cache. The selection column stays 48 pixels wide. Virtual data columns share the available width, with a minimum of 200 pixels per column and horizontal scrolling. The header stays above the scrollable body; its height is additional to `viewportHeight`. The ordinary DataTable retains its existing intrinsic sizing. Use a bounded-width parent and keep custom cells within the configured row height.

The same three settings apply directly to TreeView and TreeList. Existing selected/checked/expanded IDs, callbacks, read-only flags, disabled records, templates, search and lazy-child adapters keep their contracts. Changing modes does not grant permission to change caller-owned state.

## Selection, export and focus

- Local virtual Grid's **Select results** action applies to eligible records across the current expanded filtered result, including offscreen records. Collapsed group records remain excluded. In remote mode **Select page** still covers the loaded page. Protected and hidden selected IDs are preserved.
- Export scope `Page` means the logical displayed dataset, not the handful of recycled DOM/widget rows. For a local virtual Grid it covers all expanded filtered records; for a remote Grid it covers the current server page. `Filtered` and `Selected` keep their existing contracts and limits. Configure the export page label as “Current view” in an application that offers virtualization.
- Row selection and checked IDs survive recycling. A parent can reject a callback; widgets do not silently adopt it.
- Virtual Flutter tables support PageUp/PageDown and Ctrl+Home/Ctrl+End while focus is within a row; the visible scrollbar also supports direct scrolling.
- TreeView arrows, Home and End scroll an offscreen target into view before moving focus; Enter/Space retain selection behavior. Disabled nodes are skipped. TreeList retains its existing button/Tab navigation; full treegrid keyboard navigation is not claimed.
- Scrolling a focused row away can remove it from the render tree. Do not use DOM/widget identity as application selection state. Full screen-reader and native-platform certification remains open.

## Runnable performance exercise

Open [Blazor virtual data](http://127.0.0.1:5180/virtual-data) or [Flutter virtual data](http://127.0.0.1:5181/?virtual-data=1). Both galleries also link from Data workspace.

1. Scroll from the first to the 10,000th record. Check that only a small window exists, while selected IDs persist.
2. Search, sort, group by thousand, collapse groups and toggle the 12-record dataset. Verify the last records remain reachable after changing the result size.
3. Switch to server pages. A page contains at most 500 records; scrolling must not increment the read counter. The pager loads the next page.
4. Expand all 100 tree branches. With 100 children each, 10,100 nodes are available. Use Home/End and selection, then inspect TreeList and collapse the hierarchy.

The demonstrations use synthetic in-memory data and a delayed page adapter. They are not a production database benchmark. Automated tests assert bounded cell construction on 10,000 records, last-row reachability, shrink recovery, selection retention, tree keyboard traversal and the server-page boundary. See [verification](../verification.md) for actual browser observations.


## Variable row height

Set `VariableRowHeight="true"` / `variableRowHeight: true` together with virtualization on Grid. Cells, templates, group headers and inline editors are measured automatically. `RowHeight` / `rowHeight` remains the minimum row height and the estimate for rows not yet measured. Use content with a finite natural height; Flutter cells must not require an unbounded vertical `Expanded` or nested vertical scroll view. Provide explicit dimensions for embedded media where possible.

This mode covers local results and the currently loaded server page, with or without grouping. Continuous `ReadRange` / `readRange` and `ReadGroupedRange` / `readGroupedRange` require fixed heights and reject the setting. Trees retain their fixed-height mode. Column virtualization remains separate.

Only visible rows and a small buffer build cell templates. Height metadata grows with the number of visited rows; this is rendering virtualization, not a bound on local application data. Unmeasured records use the estimate, so the scrollbar thumb and total extent can change as new rows appear. The renderer preserves the visible anchor when measured heights change and keeps the end visible after an end jump. Width changes invalidate cached heights. Search, sort, page changes and changes in the expanded row sequence reset scrolling to the beginning; caller-owned selection is preserved. Offscreen changes are measured when those rows return to view.

Selection and export continue to use logical records, not the rendered window. Group rows cannot become selected records. A cell editor keeps its application draft when scrolled out; scroll it into view again to continue editing. Whole-record and batch review panels remain outside the viewport. No full accessibility or native Flutter certification is claimed.

The Grid manual's **Measured virtual rows** example and the **Variable row height** checkbox in the virtual data exercise demonstrate this mode. Verify the last of 10,000 records, filtering, sorting, grouping, server-page boundaries, shrinking to 12 records, and selection retention.
