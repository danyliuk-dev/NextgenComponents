# Continuous remote Grid ranges

`ReadRange` / `readRange` enables continuous scrolling over a flat server result with one retained data window. Enable `Virtualize` / `virtualize`; omit local Items, ReadData, ReadGroupedData and all grouping descriptors. Existing page adapters retain their pager and behavior. Row height is fixed, 40–128 pixels; the viewport must contain between 1 and 128 rows. The default is 48px rows in a 384px viewport.

## Request and response

| Field | Contract |
|---|---|
| startIndex | Zero-based offset in the complete filtered and sorted result; 0–100,000. |
| count | Requested window size, 1–512; adapters must support arbitrary offsets and counts. |
| search | Current search string. The server defines matching rules. |
| sorts | Ordered key/descending descriptors. Validate supported keys on the server. |
| response startIndex | Must exactly echo the requested offset. |
| response total | Full filtered record count, 0–100,000. |
| response items | Exactly min(count, max(0, total − startIndex)) records. IDs must be nonblank and unique within the window. |

Example JSON request: `{"startIndex":99980,"count":20,"search":"","sorts":[{"key":"id","descending":false}]}`. A response is `{"startIndex":99980,"items":[...20 records...],"total":100000}`. Record JSON is application-owned. No total-only or short-page response is accepted within the result. An offset beyond a shrinking total returns an empty window and the new total; the renderer corrects its position.

Apply filtering and stable sorting before offset/limit. Add a unique ID tie-breaker in the database. Count and rows should come from one consistent server snapshot. Clients validate each envelope but cannot prove cross-window consistency: concurrent insertions/reordering can otherwise repeat or skip records. Use application snapshot/version tokens in your adapter and change DataVersion after accepting a new dataset. IDs must be stable across every window. Do not allocate the full result in the client adapter.

## Blazor example

```razor
<NgDataGrid TItem="int" ReadRange="Read" Virtualize="true"
    Columns="columns" RowId="i=>i.ToString()" />
@code {
    private readonly NgDataColumn<int>[] columns=[new("id","Record",i=>i)];
    private Task<NgDataRangeResult<int>> Read(NgDataRangeRequest q, CancellationToken token) {
        token.ThrowIfCancellationRequested();
        var count=Math.Min(q.Count, Math.Max(0, 100000-q.StartIndex));
        return Task.FromResult(new NgDataRangeResult<int>(q.StartIndex,
            Enumerable.Range(q.StartIndex+1,count).ToArray(),100000));
    }
}
```

## Flutter example

Place these members in a State class with Material and nextgen_components imports:

```dart
Future<NgDataRangeResult<int>> read(NgDataRangeRequest q) async {
  final count = (100000 - q.startIndex).clamp(0, q.count);
  return NgDataRangeResult(q.startIndex,
      List.generate(count, (i) => q.startIndex + i + 1), 100000);
}
@override
Widget build(BuildContext context) => NgDataGrid<int>(
  readRange: read, virtualize: true,
  columns: [NgDataColumn('id', 'Record', (i) => i)],
  rowId: (i) => '$i',
);
```

These examples generate only the requested window. The runnable galleries replace that adapter with HTTP: [Blazor](http://127.0.0.1:5180/remote-range) and [Flutter](http://127.0.0.1:5181/?remote-range=1). Start the Blazor API on 5180 for both. The synthetic fixture uses an in-memory server dataset; it is not a database performance benchmark.

## Lifecycle, selection and export

Search, sort, reader replacement and DataVersion changes reset to the start and invalidate older results. Blazor forwards cancellation tokens; Flutter ignores obsolete futures and debounces scrolling for 50ms, but does not cancel the application's transport. Dispose prevents later results from updating UI. Use a stable reader method; construct transport clients outside build/render methods.

Only one accepted window is retained, including overscan/prefetch records. Framework window sizes differ; applications must not depend on exact counts. The old window is cleared during a new read. Malformed responses and transport failures display the generic error and Retry; Retry requests the current position. Export and window selection cannot use failed/loading records. Offscreen selected IDs remain caller-owned and survive scrolling, resets and errors. CanSelect and SelectionReadOnly still apply.

The header selects eligible records in the **loaded window**, including offscreen overscan. Export scope Page means that same loaded window, not the whole server result; its label is LoadedWindowText/loadedWindowText. SelectWindowText/selectWindowText localizes the header action. Filtered/Selected export requires the separate bounded ReadExportData/readExportData adapter. Scrolling invalidates an in-flight export. Persistence remains application-owned; editing uses the existing guarded workflow and a successful refresh resets the range query.

Focus the scroll area (Blazor) or a row (Flutter) before Ctrl+Home/Ctrl+End or PageUp/PageDown. Recycling can remove a focused row. Selection does not depend on DOM/widget identity. Variable-height rows, remote grouped ranges, column virtualization, totals above 100,000, full treegrid keyboard behavior and native/screen-reader certification remain outside this contract.

## Exercise

Select the first row, jump to the end and verify R100000 and retained selection. Toggle Fail reads, scroll to a different window, clear the flag and Retry. Repeat with Malformed response. Enable Slow reads, change the search twice, and confirm the final query wins. Enable Server has 12 records and scroll into an unloaded range to observe total correction. Refresh query resets to the beginning. Prepare export downloads only the loaded window; the two full-remote scopes are disabled without an export adapter.
