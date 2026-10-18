# NgTreeView — Tree view

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Browse and select hierarchical records.

## Behavior and practical rules

NgTreeNode<T> contains a stable unique ID, item, children and disabled flag. The graph must be acyclic. ExpandedIds and SelectedId are controlled: save callbacks and pass updated collections back. Replacing the tree should also remove obsolete IDs from parent selection/expansion. Disabled nodes cannot be selected. Lazy server loading, drag/drop and virtualization are not implemented.

## Blazor example

```razor
<NgTreeView TItem="string" Items="nodes" Text="s=>s" @bind-ExpandedIds="expanded" @bind-SelectedId="selected"/>
@code { private string? selected; private HashSet<string> expanded=["root"]; private NgTreeNode<string>[] nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; }
```

## Flutter example

```dart
Set<String> expanded = {'root'}; String? selected;
Widget build(BuildContext context) => NgTreeView<String>(
  items: const [NgTreeNode('root','Projects',children: [NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],
  text: (s) => s,
  expandedIds: expanded, selectedId: selected,
  onExpandedChanged: (v) => setState(() => expanded = v),
  onSelected: (v) => setState(() => selected = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Folders" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgTreeNode<TItem>>` | required | Input collection. Replace it when changing records or configuration. |
| `Text` | `Func<TItem,string>` | required | See the behavior rules and model contract above. |
| `SelectedId` | `string?` | not set | See the behavior rules and model contract above. |
| `SelectedIdChanged` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `ExpandedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `ExpandedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `items` | `List<NgTreeNode<T>>` | Input collection. Replace it when changing records or configuration. |
| `text` | `String Function(T)` | See the behavior rules and model contract above. |
| `label` | `String` | Visible label or accessible name. |
| `selectedId` | `String?` | See the behavior rules and model contract above. |
| `expandedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onSelected` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `onExpandedChanged` | `ValueChanged<Set<String>>` | See the behavior rules and model contract above. |

```dart
const NgTreeView({
    super.key,
    required this.items,
    required this.text,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Folders',
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTreeView.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
