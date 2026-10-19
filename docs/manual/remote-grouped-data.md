# Remote grouped Grid data

[Grid manual](NgDataGrid.md) · [Models](models.md)

Use `ReadGroupedData` / `readGroupedData` when the server owns filtering, sorting, grouping and summaries. Use the ordinary `ReadData` adapter for ungrouped pages. These modes are mutually exclusive. Remote grouped mode also rejects local `GroupBy`, `GroupSelectors` and `GroupAggregates`: calculating a full group from one downloaded page would produce misleading results.

## Request

`NgGroupedDataRequest` contains a 1-based page, page size, search text, ordered sort descriptors and one to eight distinct, nonblank group field keys. Field keys are application-defined identifiers. The sample endpoint accepts only `name` and `availability` and explicitly maps them to selectors.

```json
{
  "page": 1,
  "pageSize": 5,
  "search": "Desk",
  "sorts": [{"key": "count", "descending": true}],
  "groupKeys": ["name", "availability"]
}
```

The Grid snapshots request lists. Changing `RemoteGroupKeys` / `remoteGroupKeys`, the reader or `DataVersion` / `dataVersion` resets paging and invalidates pending reads. Search, sorting and page-size changes request page 1. Stable adapter identity avoids unnecessary reads.

## Response

`NgGroupedDataResult<T>` contains the requested data rows with complete group paths, the total filtered record count, and metadata for exactly the group paths represented on that page (including every ancestor). Metadata order is irrelevant; row order determines group display order.

```json
{
  "items": [
    {"item": {"id": "p40", "name": "Desk", "count": 160},
     "path": ["Desk", "Protected"]}
  ],
  "total": 20,
  "groups": [
    {"path": ["Desk"], "count": 20,
     "summaries": [{"title": "Total quantity", "value": 1680},
                   {"title": "Average", "value": 84}]},
    {"path": ["Desk", "Protected"], "count": 8,
     "summaries": [{"title": "Total quantity", "value": 1056},
                   {"title": "Average", "value": 132}]}
  ]
}
```

This response illustrates a request with `pageSize: 1`. The five-row request above must return five rows. Page length must equal `min(pageSize, max(0, total - (page - 1) * pageSize))`. An out-of-range page after data shrink therefore returns zero rows and no metadata; the Grid then requests the corrected last page.

Each path has exactly as many string segments as requested group keys. Empty segments are valid values. Records belonging to each group must be contiguous, including at ancestor levels. Return counts and numeric summaries over the complete filtered group, before pagination. Compute parent averages from records, not by averaging child averages. The sample uses first-appearance group ordering after stable sorting; another backend may choose a different deterministic group order.

## Validation and failure behavior

The client rejects invalid totals or page sizes, duplicate/blank row IDs, wrong path depth, interleaved groups, duplicate/missing/unused metadata, counts smaller than loaded membership, counts greater than the overall total, and sibling counts exceeding their parent count. Summary titles must be nonblank and unique per group; values must be finite numbers or null. A malformed envelope becomes a localized error with Retry; no partial rows or group metadata are exposed.

These checks detect internal contradictions. They cannot independently prove the server's full counts or calculations. The backend must produce a consistent snapshot and correct filtered totals.

The Grid renders server values directly. `RemoteSummaryText` / `remoteSummaryText` receives a title and nullable value for plain-text formatting; the default shows up to two decimal places and an em dash for null. Null means missing, not zero. Summary titles can be localized by the server. No HTML is interpreted.

New requests, reader replacement and disposal invalidate older successes and failures. Blazor passes a cancellation token; the HTTP example forwards it. Flutter ignores obsolete futures but does not cancel the transport. Loading/error states clear rows and metadata and disable selection/expansion actions. A rejected grouped response never falls back to client-side grouping.

## Collapse, selection and page scope

Collapse remains a caller-controlled view operation after record paging, using the same encoded full-path IDs as local grouping. It sends no HTTP request and does not change page ranges, total counts or summaries. Ancestor headers repeat across page boundaries, with the parent's saved collapsed state. Page selection affects only eligible rendered rows and preserves all other selected IDs.

The bulk buttons are deliberately named **Expand page groups** and **Collapse page groups**. They affect all group paths in the current valid response, including children hidden by a collapsed parent. They preserve unknown and off-page collapsed IDs and never fetch other groups. Customize these labels with `ExpandPageGroupsText` / `expandPageGroupsText` and `CollapsePageGroupsText` / `collapsePageGroupsText`.

## Running the HTTP example

Start the Blazor gallery on `http://127.0.0.1:5180` and the Flutter gallery on `http://127.0.0.1:5181`. The Grid manual preview includes local grouping, HTTP grouped inventory and the earlier ordinary remote paging example. Both HTTP examples call the same read-only `/api/grouped-inventory` fixture endpoint. The Flutter transport uses `package:web`; put the shown Dart imports at file scope and the remaining snippet inside a State class.

The endpoint uses 40 synthetic product records and a 350 ms delay. It accepts POST requests with the schema above. Its explicit CORS origin is the local Flutter gallery. No database is involved.

- **Remote nested groups** changes the request from one to two group keys and automatically resets the page.
- **Fail grouped requests**, then **Reload grouped source**, produces an HTTP error. Clear the switch and use Retry.
- **Malformed grouped response**, then reload, produces an internally inconsistent group count to demonstrate client validation. Clear the switch and retry.
- **Small remote dataset** makes the next request use seven fixture rows. To exercise last-page correction, enable it on a later page and move to another page; reloading the source intentionally resets to page 1.

`NgGroupedData.Page` / `NgGroupedData.page<T>` is a reference adapter for an already filtered and sorted in-memory collection. It groups the full collection, computes summaries, pages the grouped records and emits only the metadata needed by that page. A database-backed application should implement the same contract using its own query/provider; this helper is not a SQL optimizer. `NgGroupedData.Validate` / `validate<T>` exposes the client validator for adapter tests. Flutter also supplies `request.toJson()` and `NgGroupedDataResult<T>.fromJson(json, decodeItem)`; Blazor uses System.Text.Json's web defaults in the example.

## Limits

This is record-page grouping, not lazy group paging or virtual scrolling. The server does not receive collapsed IDs. Loading unseen group contents, remote tree cascading, database query translation, built-in CRUD, export and native-target verification are separate blocks. Summaries use nullable double values; decimal accounting requires an application-specific contract and formatting policy.
