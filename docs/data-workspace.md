# Data workspace — 0.3

Five additional components on both Blazor and Flutter Web: DataGrid, TreeList, TreeView, Pager and Breadcrumb. Each library now has 27 implemented catalogue subsets. These components are original implementations; Telerik source is not included.

## Scope and reference audit

| Control | Implemented in this release | Remaining reference capabilities |
|---|---|---|
| NgDataGrid | Generic columns with typed sort values, formatted/custom cells, stable single-column sort, local cross-column text search, paging, row/page selection, toolbar and row-action slots, empty state, horizontal scrolling | Server loading, virtualization, column filters, multi-sort, grouping, column resize/reorder/pinning, export, built-in CRUD modes, persistent state, cell keyboard navigation |
| NgTreeList | Nested generic data, expand/collapse, sibling sorting, search with ancestor context, node selection, custom data cells | Remote children, virtualization, paging, built-in editing/dragging, multi-column filters, treegrid keyboard pattern |
| NgTreeView | Nested data, expand/collapse, selection, disabled nodes, search retaining ancestors, Up/Down/Home/End navigation, Right/Left expansion and parent/child focus, Enter/Space selection | Checkboxes, drag-and-drop, remote loading, virtualization, full screen-reader audit |
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
