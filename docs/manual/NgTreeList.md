# NgTreeList — Tree list

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Combine hierarchical rows with typed columns.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgTreeList) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgTreeList)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Use NgTreeNode<T> for hierarchy and NgDataColumn<T> for cells. IDs must be unique across the whole tree. Persist expanded/selected IDs through callbacks; replace collections after data changes. Column accessors return underlying values, while format/cell templates define presentation. Application code owns edits and persistence. See [data workspace](../data-workspace.md) for sorting/filtering scope and omitted server/virtualization features.

## Blazor example

```razor
<NgTreeList TItem="string" Items="nodes" Columns="columns" @bind-ExpandedIds="expanded" @bind-SelectedId="selected"/>
@code { private string? selected; private HashSet<string> expanded=["root"]; private NgTreeNode<string>[] nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; private NgDataColumn<string>[] columns=[new("name","Name",s=>s)]; }
```

## Flutter example

```dart
Set<String> expanded = {'root'}; String? selected;
Widget build(BuildContext context) => NgTreeList<String>(
  items: const [NgTreeNode('root','Projects',children: [NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],
  columns: [NgDataColumn('name','Name',(s) => s)],
  expandedIds: expanded, selectedId: selected,
  onExpandedChanged: (v) => setState(() => expanded = v),
  onSelected: (v) => setState(() => selected = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Hierarchy" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgTreeNode<TItem>>` | [] | Input collection. Replace it when changing records or configuration. |
| `Columns` | `IReadOnlyList<NgDataColumn<TItem>>` | [] | Column definitions; see the data model and example. |
| `ExpandedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `ExpandedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string?>` | not set | Selected item ID for the parent to store. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `items` | `List<NgTreeNode<T>>` | Input collection. Replace it when changing records or configuration. |
| `columns` | `List<NgDataColumn<T>>` | Column definitions; see the data model and example. |
| `expandedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onExpandedChanged` | `ValueChanged<Set<String>>` | Requested open state; store it with setState or your state manager. |
| `onSelected` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `label` | `String` | Visible label or accessible name. |

```dart
const NgTreeList({
    super.key,
    required this.items,
    required this.columns,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Hierarchy',
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTreeList.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
