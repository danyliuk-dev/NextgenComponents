# NgTreeView — Tree view

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Browse and select hierarchical records.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgTreeView) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgTreeView)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgTreeNode<T> contains a stable unique ID, item, children and disabled flag. The graph must be acyclic. ExpandedIds and SelectedId are controlled: save callbacks and pass updated collections back. Replacing the tree should also remove obsolete IDs from parent selection/expansion. Disabled nodes cannot be selected. Lazy server loading, drag/drop and virtualization are not implemented. SelectionReadOnly/selectionReadOnly blocks selection but permits navigation and expansion. ExpansionReadOnly/expansionReadOnly freezes expansion but permits selection. Search still reveals matching descendant paths without changing expanded IDs; clearing search restores caller state. Whitespace-only search is inactive. Disabled nodes and stale callbacks cannot change state. EmptyText/emptyText and EmptyTemplate/emptyBuilder customize no-results content. IDs must be nonempty. Parent updates can replace or clear state even in read-only mode. Missing selected/expanded IDs are retained in caller state, not automatically pruned. ItemTemplate/itemBuilder is decorative: Text/text supplies the accessible name and search text. Do not place interactive controls in this template. ArrowRight enters only an enabled immediate child; leaves do not move focus to siblings. Full roving-tabindex/focus recovery, type-ahead, checkboxes and multi-selection remain open.

## Blazor example

```razor
<NgCheckBox Label="Selection read-only" @bind-Value="selectionReadOnly"/>
<NgCheckBox Label="Expansion read-only" @bind-Value="expansionReadOnly"/>
<NgTreeView TItem="string" Items="nodes" Text="s=>s" @bind-ExpandedIds="expanded" @bind-SelectedId="selected" SelectionReadOnly="selectionReadOnly" ExpansionReadOnly="expansionReadOnly" EmptyText="No teams found."><ItemTemplate Context="item"><strong>@item</strong><span> · team</span></ItemTemplate></NgTreeView>
<p>Selected team: @(selected??"none")</p>
@code { private bool selectionReadOnly,expansionReadOnly; private string? selected; private HashSet<string> expanded=["root"]; private NgTreeNode<string>[] nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; }
```

## Flutter example

```dart
bool selectionReadOnly = false, expansionReadOnly = false;
Set<String> expanded = {'root'}; String? selected;
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  NgCheckBox(label: 'Selection read-only', value: selectionReadOnly, onChanged: (v) => setState(() => selectionReadOnly = v)),
  NgCheckBox(label: 'Expansion read-only', value: expansionReadOnly, onChanged: (v) => setState(() => expansionReadOnly = v)),
  NgTreeView<String>(
  selectionReadOnly: selectionReadOnly, expansionReadOnly: expansionReadOnly,
  emptyText: 'No teams found.',
  items: const [NgTreeNode('root','Projects',children: [NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],
  text: (s) => s,
  itemBuilder: (context, s) => Text('$s · team', style: const TextStyle(fontWeight: FontWeight.bold)),
  expandedIds: expanded, selectedId: selected,
  onExpandedChanged: (v) => setState(() => expanded = v),
  onSelected: (v) => setState(() => selected = v)),
  Text('Selected team: ${selected ?? "none"}'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `ItemTemplate` | `RenderFragment<TItem>?` | not set | See the behavior rules and model contract above. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `ExpansionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `EmptyTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No matching items." | See the behavior rules and model contract above. |
| `Label` | `string` | "Folders" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgTreeNode<TItem>>` | required | Input collection. Replace it when changing records or configuration. |
| `Text` | `Func<TItem,string>` | required | See the behavior rules and model contract above. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string?>` | not set | Selected item ID for the parent to store. |
| `ExpandedIds` | `HashSet<string>` | [] | See the behavior rules and model contract above. |
| `ExpandedIdsChanged` | `EventCallback<HashSet<string>>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `itemBuilder` | `Widget Function(BuildContext, T)?` | See the behavior rules and model contract above. |
| `items` | `List<NgTreeNode<T>>` | Input collection. Replace it when changing records or configuration. |
| `text` | `String Function(T)` | See the behavior rules and model contract above. |
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `expansionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `emptyBuilder` | `Widget?` | See the behavior rules and model contract above. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `expandedIds` | `Set<String>` | See the behavior rules and model contract above. |
| `onSelected` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `onExpandedChanged` | `ValueChanged<Set<String>>` | Requested open state; store it with setState or your state manager. |

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
    this.selectionReadOnly = false,
    this.expansionReadOnly = false,
    this.emptyBuilder,
    this.emptyText = 'No matching items.',
    this.itemBuilder,
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
