# NgDataGrid — Data grid

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display, sort, filter, select and page local records.

## Behavior and practical rules

NgDataColumn<T> supplies a stable key, title and Value/value accessor. Return typed values for sorting; Format/format changes display only. Template/cellBuilder customizes a cell. RowId must return a unique stable ID. Save selection callbacks and replace Items/items after edits so the grid recalculates. Toolbar and row actions allow the application to own editing and persistence. This local grid does not implement server data binding, virtualization, column grouping or Excel export; see [data workspace](../data-workspace.md).

## Blazor example

```razor
<NgDataGrid TItem="Product" Items="rows" Columns="columns" RowId="r=>r.Id" @bind-SelectedIds="selected"/>
@code { public record Product(string Id,string Name,int Count); private Product[] rows=[new("a","Desk",12),new("b","Chair",120)]; private HashSet<string> selected=[]; private NgDataColumn<Product>[] columns=[new("name","Name",r=>r.Name),new("count","Quantity",r=>r.Count)]; }
```

## Flutter example

```dart
final rows = [(id: 'a', name: 'Desk', count: 12), (id: 'b', name: 'Chair', count: 120)];
Set<String> selected = {};
Widget build(BuildContext context) => NgDataGrid<({String id, String name, int count})>(
  items: rows, rowId: (r) => r.id, selectedIds: selected,
  onSelectionChanged: (v) => setState(() => selected = v),
  columns: [NgDataColumn('name','Name',(r) => r.name),
    NgDataColumn('count','Quantity',(r) => r.count)]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Items` | `IReadOnlyList<TItem>` | required | Input collection. Replace it when changing records or configuration. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | required | Column definitions; see the data model and example. |
| `RowId` | `Func<TItem,string>` | required | See the behavior rules and model contract above. |
| `Label` | `string` | "Records" | Visible label or accessible name. |
| `EmptyText` | `string` | "No matching records." | See the behavior rules and model contract above. |
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
| `columns` | `List<NgDataColumn<T>>` | Column definitions; see the data model and example. |
| `rowId` | `String Function(T)` | See the behavior rules and model contract above. |
| `selectedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onSelectionChanged` | `ValueChanged<Set<String>>?` | See the behavior rules and model contract above. |
| `rowActions` | `Widget Function(BuildContext, T)?` | See the behavior rules and model contract above. |
| `toolbar` | `Widget?` | See the behavior rules and model contract above. |
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `initialPageSize` | `int` | See the behavior rules and model contract above. |

```dart
const NgDataGrid({
    super.key,
    required this.items,
    required this.columns,
    required this.rowId,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActions,
    this.toolbar,
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
