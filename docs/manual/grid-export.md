# Grid export

Blazor and Flutter Web support a complete bounded CSV/TSV workflow from 0.68. The [Grid example](NgDataGrid.md) prepares a file, displays its row count and plain-text preview, then offers an explicit download. File generation is platform-independent; saving or downloading is supplied by the application.

## Choose records and columns

Set `Export` / `export` to `NgGridExport<T>`. It adds a scope selector, Prepare export, progress/cancel and result/error messages. Without this configuration, there are no export controls.

| Scope | Local Items | Remote adapter |
|---|---|---|
| Page / page | Rendered data records on the current page; collapsed descendants are omitted. | Currently rendered records from the downloaded page. No additional read. |
| Filtered / filtered | All filtered/sorted records across pages, including collapsed groups. | Requires a separate ReadExportData/readExportData callback. |
| Selected / selected | Selected IDs intersected with the full filtered dataset, in its current order. Unknown or filtered-out IDs are excluded. | Requires ReadExportData/readExportData; the server intersects the snapshotted selected IDs with the query. |

Group headers and aggregate rows are never exported as records. Local nested groups retain their flattened group order. A collapsed page can produce a valid zero-record file. CanSelect controls selection actions, not export authorization: existing protected selections are still eligible for selected export. Restrict data and columns in your application/backend when permissions require it.

`ColumnKeys` / `columnKeys` is an ordered subset of unique existing column keys. Empty means all Grid columns in display order. There must be at least one resolved column. UI-only selection/actions columns are never included. Cell templates are not serialized. Default values use each column's Text/text formatting; optional `Format` / `format` receives the key and record and returns a plain string. Use it for explicit locale-independent numbers/dates or redaction. The examples export quantity using invariant text. Titles become optional headers and are escaped by the same rules as cells.

## File contract

`NgGridExportFile` contains FileName/fileName, Content/content, MimeType/mimeType, RowCount/rowCount, immutable ColumnKeys/columnKeys and UTF-8 Bytes/bytes. `NgGridCsv.Create` / `NgGridCsv.create` is also usable directly with records, columns and options.

| Option | Default | Meaning |
|---|---|---|
| FileName / fileName | records.csv | Plain file name; no path separators, CR/LF or NUL. Use a .tsv name when selecting tab delimiter. |
| Delimiter / delimiter | comma | Comma, semicolon or tab only. Tab selects text/tab-separated-values; others text/csv. Both MIME types include UTF-8. |
| IncludeHeaders / includeHeaders | true | Include column titles as the first record. |
| IncludeBom / includeBom | true | Prefix U+FEFF, encoded as UTF-8 EF BB BF. |
| MaxRows / maxRows | 10000 | Positive record-count cap; exceeded limits fail without truncation or partial delivery. |
| MaxCharacters / maxCharacters | 5000000 | Positive UTF-16 code-unit cap on the entire encoded text, including BOM, quoting, delimiters and line endings. This is not a byte limit. |
| ReadOnly / readOnly | false | Blocks new export requests and invalidates pending component work. |

Every cell is quoted. Embedded double quotes are doubled; commas, tabs, Unicode and embedded newlines are retained inside the quoted cell. Record separators are CRLF, including after the final record. Missing values use column formatting, normally an empty string. With no rows, headers can still be emitted; with headers and BOM both disabled, an empty export is an empty string.

Formula-like cells beginning with `=`, `+`, `-` or `@` after leading whitespace/BOM are prefixed with an apostrophe before quoting. Values beginning directly with tab, CR or LF are also prefixed. The same explicit Unicode whitespace set is used by both implementations. This applies to headers and custom formatting, and intentionally includes negative numeric strings. The apostrophe is part of the exported text and may be visible in consumers. There is no option to emit active formulas.

CSV/TSV are text formats: they do not carry spreadsheet types, styles or explicit text-cell metadata. A consuming spreadsheet can still reinterpret numeric-looking text, dates or leading zeros according to its import settings. XLSX, PDF and styled spreadsheet output are separate capabilities.

## Remote export protocol

`ReadExportData` / `readExportData` receives an `NgGridExportRequest`: scope, search, ordered sort descriptors, remote group keys, selected IDs and MaxRows. The query, selected IDs and column configuration are snapshotted before awaiting the adapter. The request has no pagination: the adapter must return the complete requested set or fail when it exceeds the cap. Do not implement it by returning the current ordinary page. The UI disables remote Filtered/Selected scopes when this adapter is absent.

The adapter returns records in the desired final order. It owns authorization, search/sort/group translation, query consistency and the selected/filter intersection. A bounded backend query can fetch MaxRows + 1 records and reject overflow. The Grid rejects blank/duplicate row IDs, unselected IDs returned for Selected scope, too many rows and oversized text. It cannot independently verify server filtering, ordering or completeness. Full export does not repeatedly call ReadData or ReadGroupedData and does not alter current page, selection or group expansion.

The gallery's ordinary remote Grid supplies a delayed synthetic adapter and a failure switch; the grouped HTTP fixture remains read-only and has no export endpoint. The library does not bundle a database provider or streaming export service.

## Lifecycle and delivery

`OnExport` / `onExport` receives the complete validated file exactly once per successful preparation attempt. In Blazor it additionally receives a cancellation token. The application can retain it for preview, save it or offer a download. In the gallery, a separate Download last export action uses a data URL; this keeps the actual browser download tied to a user gesture. For large exports, provide a server download instead of retaining large data URLs.

Export is single-flight. Read loading/error, pending Grid saves and read-only export disable new preparation. Cancel, DataVersion changes, replacement read adapters, removed export configuration, read-only changes and component disposal invalidate pending preparation. Blazor cancels the operation token; Flutter discards obsolete futures. Once OnExport has been invoked, application side effects are application-owned: cancellation cannot retract a saved file or undo a started download. Honor the token in asynchronous Blazor delivery; Flutter delivery should make an immediate handoff or manage its own cancellation.

Changing search, sort, page or selection during preparation does not rewrite the captured request. The resulting artifact describes that snapshot. Source-record objects are not deep-cloned; use immutable records and pure formatting callbacks. Use DataVersion when switching storage or export policies. A completed artifact retained by the application remains its responsibility; locking the Grid does not revoke earlier downloads.

Adapter, formatting, limit and delivery failures display generic ErrorText, without exception details. Prepare export remains available for retry. No partial file is handed off by the serializer. The gallery retains the previous successful artifact after a later failure, explicitly labelled Last export.

ScopeText, PageText, FilteredText, SelectedText, ExportText, CancelText, BusyText, ReadyText and ErrorText (lower camel case in Flutter) localize the built-in controls and messages. Native/mobile filesystem delivery and physical screen-reader certification remain unverified.
