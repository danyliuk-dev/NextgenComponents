# Data workspace — 0.3

Current work and remaining blocks: [work plan](roadmap.md). Historical release sections describe their own checkpoint; later sections supersede earlier Remaining lists.


Five additional components on both Blazor and Flutter Web: DataGrid, TreeList, TreeView, Pager and Breadcrumb. Each library now has 27 implemented catalogue subsets. These components are original implementations; Telerik source is not included.

The table below records the original 0.3 release. Later sections supersede its completed gaps (grouping, CRUD, CSV/TSV export, tree checking and virtual rendering).

## Scope and reference audit

| Control | Implemented in this release | Remaining reference capabilities |
|---|---|---|
| NgDataGrid | Generic columns with typed sort values, formatted/custom cells, stable single/multi-column sort, local/remote cross-column text search, async page adapters, paging, row/page selection, toolbar and row-action slots, empty state, horizontal scrolling | Virtualization, column filters, grouping, column resize/reorder/pinning, export, built-in CRUD modes, persistent state, cell keyboard navigation |
| NgTreeList | Nested generic data, lazy child loading, expand/collapse, sibling sorting, search with ancestor context, node selection, custom data cells | Virtualization, paging, built-in editing/dragging, multi-column filters, treegrid keyboard pattern |
| NgTreeView | Nested data, lazy child loading, expand/collapse, selection, disabled nodes, search retaining ancestors, Up/Down/Home/End navigation, Right/Left expansion and parent/child focus, Enter/Space selection | Checkboxes, drag-and-drop, virtualization, full screen-reader audit |
| NgPager | Range/count, first/previous/numbered/next/last buttons, selectable page sizes, disabled boundaries, empty/shrunk-data page clamp | Direct page entry, localization API, persisted state |
| NgBreadcrumb | Current-item marker, ancestor navigation callback, wrapping layout | Icons, router integration, overflow menus, editable path |

Audited reference pages: [Grid](https://www.telerik.com/blazor-ui/grid), [TreeList](https://www.telerik.com/blazor-ui/treelist), [TreeView](https://www.telerik.com/blazor-ui/treeview), [Pager](https://www.telerik.com/blazor-ui/pager), [Breadcrumb](https://www.telerik.com/blazor-ui/breadcrumb). These define the wider target; this release does not claim full parity or pixel-identical framework rendering.

## Data contracts

- Blazor: `NgDataColumn<T>` takes a unique key, heading and value getter; optional `Format` and `Template` separate presentation from sorting. Flutter provides equivalent `format` and `cellBuilder`. Supply consistent comparable types within each column. Numeric values sort numerically; string order is case-insensitive (Blazor uses current culture, Flutter lowercase comparison).
- Grid row IDs and tree node IDs must be unique. Duplicate tree IDs/cycles are rejected. Selection uses IDs and survives sort, filter and page changes. Callers own selection and should remove IDs when deleting records. Page selection only affects currently visible rows; hidden selections remain.
- Grid filtering happens before sorting/paging, resets page to one and includes formatted column text. A source update clamps the page to the remaining range. Grid search/sort/page are local widget state; use a new component key for a wholesale reset.
- Trees take nested `NgTreeNode<T>` lists. Search displays matching nodes and their ancestors, automatically opening the retained path; expand buttons are disabled while filtering. Clearing search restores the caller's expansion set. Sorting never moves a child out of its parent. Trees are fully materialized and intended for modest local datasets in this release.
- Expansion/selection callbacks emit fresh sets. Disabled tree nodes cannot be selected. Breadcrumb navigation is a callback; the application determines its route/data behavior.
- Framework-native table, button and field semantics are used. Basic keyboard behavior is tested; do not interpret this as WCAG certification or full Telerik keyboard parity.

## Project gallery

Blazor `/data` and Flutter **Data workspace** show the same 18-project scenario. Team TreeView and Breadcrumb filter the Grid. Select rows across pages, search and sort budgets; a separate TreeList preserves the portfolio hierarchy. The gallery composes a popup editor using existing form controls, with an isolated draft: Save validates and replaces the record, Cancel discards the draft. Team budget totals recompute after save. This is application-composed editing, not a built-in Grid CRUD engine. Data is in memory and resets on reload.

Flutter `NgNumericTextBox` now has optional `required` (default false), used for the editor budget. Empty, non-finite and out-of-range budgets cannot be submitted.

Both galleries support shared light/dark and normal/compact theme settings. Narrow screens stack the team panel and scroll wide tables inside their own viewport. Native mobile/desktop builds remain deferred.

## Grid selection and presentation (0.34)

`CanSelect` / `canSelect` is a per-row predicate. False protects both selected and unselected rows from row and page selection. Existing protected selections are retained. `SelectionReadOnly` / `selectionReadOnly` freezes all selection; search, sorting, paging and application row actions remain available. These are UI controls, not authorization rules.

The header toggles only eligible rows on the current filtered page. A partial eligible selection shows a dash. Blazor exposes `aria-checked="mixed"`; Flutter adds “partially selected” to the accessible name because the current Flutter Web engine reports a mixed checkbox as `aria-checked="false"`. Hidden IDs, other pages and protected IDs are preserved. Callers own selection: accept the callback and pass the returned new set back. Neither platform mutates the supplied set or silently accepts a rejected update. Blazor without a callback displays disabled checkboxes; Flutter without a callback hides the selection column.

`PageSizes` / `pageSizes` configures page choices (positive, distinct, sorted, retaining the current size). `EmptyTemplate` / `emptyBuilder` supplies custom empty-result content (a RenderFragment / Widget). Grid validates nonempty unique row IDs and column keys and requires at least one column. A removed sort column clears sorting.

The Data workspace protects Paused projects, offers Selection read-only, and clears only selectable IDs. App-owned editing remains available. Server data, virtualization, multi-sort/grouping, range/cell selection, direct page entry and localization remain open.

## Tree state and templates (0.35)

TreeView and TreeList now share independent selection and expansion read-only flags. The controls propose changes through callbacks without modifying input collections or accepting rejected changes internally. Read-only does not prevent parent-supplied state updates. Disabled, removed, hidden and newly locked nodes cannot be changed by stale callbacks. Existing missing IDs stay in the parent state; applications decide when to prune them.

Search temporarily opens matching paths and disables expansion actions, without changing the saved expanded set. Clearing search restores that set; whitespace-only search is inactive. Read-only selection does not block expansion, and read-only expansion does not block selection. Search and TreeList sorting remain available.

TreeView `ItemTemplate`/`itemBuilder` customizes decorative node content. TreeList supports the first column's cell template inside the selection button. Keep these templates noninteractive; Text/text or formatted column text remains the accessible name and search source. Both trees offer EmptyText/emptyText and EmptyTemplate/emptyBuilder.

IDs must be nonempty and unique across the tree. TreeList requires at least one column with unique nonempty keys. Leaf IDs in expanded sets are ignored. TreeView ArrowRight only enters an enabled immediate child, never a sibling of a leaf. Full roving tabindex, focus recovery after node removal, type-ahead, checkbox/multiple selection and TreeList treegrid keyboard navigation remain open. Native/mobile and screen-reader certification remain separate.

## Async adapters (0.60)

See the [Grid manual](manual/NgDataGrid.md), [TreeView manual](manual/NgTreeView.md) and [TreeList manual](manual/NgTreeList.md) for runnable loading/error/retry examples and source identity rules. Grid returns only the current server page; trees cache fetched children without mutating input roots. Changing DataVersion invalidates pending results. The examples use delayed local adapters, ready to replace with application HTTP/database calls. Native/mobile and full accessibility certification remain separate.

## Independent tree checkboxes (0.61)

TreeView and TreeList expose opt-in, controlled checked-ID sets on both Web platforms. Checking is independent of row selection and expansion. Read-only state, a node predicate, disabled nodes and absent callbacks protect changes. Each accepted request supplies a fresh set without pruning hidden, collapsed or unknown IDs. Localized accessible labels and keyboard Space are supported. Checking unloaded parents never fetches or checks children.

Remaining: cascading/partial parent checks, check-all, tree virtualization, drag/drop, remote filtering/sorting, native targets and full accessibility certification. Grid virtualization, grouping and built-in CRUD remain open. See both tree manuals.

## Cascading loaded tree checks (0.62)

Opt-in CheckChildren/checkChildren applies a single proposed checked-ID set to the parent record plus eligible loaded descendants. Mixed state means some of those records are checked; activating mixed selects the whole eligible branch, while activating checked clears it. Filtering and collapse do not change that scope. Protected/disabled nodes are subtree barriers and preserve their existing IDs. Unknown IDs are retained. Default independent behavior is unchanged.

Lazy loading never inherits checks or emits a checking callback. Newly loaded descendants can make the parent mixed. The parent record participates in aggregation; independently checking all children does not insert its ID. Mode/predicate/data changes recompute display without normalizing application state. Full-remote cascade, upward ID normalization, check-all, virtualization, drag/drop and native/accessibility certification remain open.

Current Flutter Web SDK maps its internal mixed checkbox state to aria-checked=false in the legacy DOM role; a localized partialCheckText spoken value supplies partial-state information. Native Flutter semantics tests see CheckedState.mixed. Exact Web ARIA parity and physical screen-reader behavior remain unverified.

## Bulk loaded-tree checking (0.63)

TreeView and TreeList expose opt-in check-loaded and clear-loaded actions. Their scope is the entire eligible loaded forest, independent of filtering, expansion and per-node cascade mode. Protected/disabled roots and subtrees are skipped; unknown/protected IDs are preserved. One fresh set is proposed per action, with parent acceptance/rejection. No-op, empty, read-only and missing-callback actions are disabled. Current data and permissions are rechecked when invoked. Lazy loads update availability without inheriting checks. Labels are localizable.

Full-remote checking, upward ID normalization, virtualization, drag/drop and native/accessibility certification remain open. The Flutter mixed-state ARIA limitation documented in 0.62 is unchanged.

## Local Grid grouping (0.64)

GroupBy/groupBy enables one local grouping level. Search and stable sorting run before grouping; groups follow first appearance and retain row order within each group. Paging counts data rows only. Headers repeat when a group crosses a page boundary and display the full filtered count, with a customizable plain-text caption. Group headers cannot be selected; page selection affects only eligible visible data rows and preserves off-page IDs.

Enabling/disabling grouping resets the page; use DataVersion/dataVersion after changing a grouping rule. Empty string keys are valid and keys are case-sensitive. Selectors must be pure. Combining grouping with ReadData/readData is rejected before requests because server pages cannot supply whole-group counts. Collapse, multiple grouping levels, aggregates, remote grouping, virtualization and built-in CRUD remain open.

## Local Grid grouping workspace (0.65)

Local grouping now supports up to eight ordered levels, controlled per-path collapse/expand, filtered expand-all/collapse-all, localized actions and independent expansion locks. Full-path IDs distinguish repeated child labels and preserve hidden/unknown state. Changing rules uses DataVersion. Collapse happens after record paging, retaining page ranges and repeated ancestor headers. Selection includes eligible rendered data rows only and retains hidden selections. Rejected and stale actions do not bypass current state or permissions.

Numeric group summaries support sum, average, min, max and count with custom formatting. Every level aggregates its full filtered records before paging/collapse; parent averages are record-weighted. Null and nonfinite values are excluded. Count counts finite numeric values; group headers count all records. Calculations use double precision. Demo controls switch grouping, nesting, totals and expansion locks on both platforms. See the Grid manual for complete contracts.

Remote grouping requires a separate group-aware loading protocol and remains unsupported. Virtualization, built-in CRUD, drag-to-group UI, aggregate footers/templates and native/accessibility certification remain open. This is a complete bounded local grouping block, not a claim of full Telerik parity.

## Remote Grid grouping and HTTP adapters (0.66)

A separate grouped request/response protocol carries ordered field keys, paged records with full group paths, full filtered counts and server numeric summaries. Both platforms validate an entire envelope before showing it. Malformed paths, counts, missing/duplicate metadata, nonfinite summaries and interleaved groups fail into error/retry. Requests are snapshotted; reader/key/version changes invalidate older results. Shrinking totals trigger a corrected page request. Blazor propagates cancellation; Flutter discards obsolete futures.

Controlled collapse keeps record page ranges and never requests data. Bulk actions explicitly affect current page groups, preserving off-page IDs. Selection covers eligible rendered rows. Both Web galleries use a shared real HTTP fixture endpoint with delay, failure, malformed-response and smaller-dataset controls. Reference in-memory adapter helpers and JSON contracts are documented in the remote grouped-data manual.

Database providers/query translation, lazy group paging, virtualization, CRUD/export and native/accessibility certification remain separate work. Server totals are checked for consistency, not independently recomputed by the client. The next data-management block should be scoped as a complete workflow rather than individual parameters.

## Grid create, edit and delete workflows (0.67)

Both platforms now provide an opt-in single-record inline editor with isolated string drafts, required/custom validation, asynchronous persistence, safe application errors and retry, cancellation, confirmed deletion and current-record permissions. Persistence remains application-owned. Repeated submissions are blocked; removed records, source changes and obsolete completions cannot apply stale UI results. Successful writes refresh local grouping or the current remote query and clamp shrinking pages. Selection remains caller-owned.

The editable inventory demonstrates the whole workflow, protected rows, duplicate-name validation and delayed failures. See [Grid editing](manual/grid-editing.md). Custom editor templates, batch/cell editing, database providers, export, virtualization and native/accessibility certification remain open. The next substantial block is Grid export with query/column scope, formatting, escaping and runnable examples on both Web platforms.

## Grid CSV/TSV export workflows (0.68)

Both Web platforms provide opt-in page, full-filtered and selected-filtered export, ordered column subsets and plain-text formatting. Group headers and aggregate rows are excluded. Page scope exports rendered records; full scopes include collapsed/off-page local records. Full remote scopes require a separate bounded adapter carrying query, sort, grouping and selection snapshots. Export never mislabels a downloaded page as a complete server dataset.

CSV/TSV generation includes UTF-8/BOM options, headers, quoting, CRLF records, Unicode and formula-like text protection. Row/character caps fail without truncation. Single-flight preparation supports cancellation, safe errors, retry and invalidation on source/permission changes. Both demos preview the result and download a real file. See [Grid export](manual/grid-export.md).

XLSX/PDF output, streaming server exports, database providers, virtual scrolling, batch/cell editing and native/accessibility certification remain open. The next substantial data block is virtual scrolling for large Grid and tree datasets, with explicit local/remote boundaries, selection/focus behavior and performance verification.


## Virtual rendering (0.69)

Grid, TreeView and TreeList support opt-in fixed-height virtual rows on both Web platforms. Local Grid scrolls all filtered expanded results; the remote Grid virtualizes its loaded page while retaining paging and the existing adapters. Trees virtualize their expanded loaded nodes and preserve lazy child loading on expansion. Selection/check state stays caller-owned; TreeView navigation can focus rows outside the current window.

See [Virtual data](manual/virtual-data.md) for sizing, templates, selection/export scope, focus behavior, performance tests and the 10,000-record demos. Continuous remote range loading, lazy group paging, variable-height rows, column virtualization and full accessibility/native verification remain open.

## Continuous remote ranges (0.70)

Grid ReadRange/readRange adds flat continuous server scrolling with bounded retained data, exact offset/count validation, stale-response protection, retry, search/sort reset and caller-owned selection. Page export and header selection explicitly target the loaded window, including overscan. Existing page and grouped-page adapters remain unchanged. See [Remote ranges](manual/remote-ranges.md). Lazy group ranges, variable row heights and native/screen-reader certification remain open.

## Grouped remote ranges (0.71)

ReadGroupedRange/readGroupedRange loads exact visible-slot windows after controlled server collapse, with full ancestor metadata, bounded client retention, stale-response rejection, retry, shrink correction and record-only selection/export. Existing page/grouped-page/flat-range adapters remain compatible. See [Grouped remote ranges](manual/grouped-remote-ranges.md). Variable-height rows, column virtualization, batch/cell editing, database providers and native/accessibility validation remain open.
