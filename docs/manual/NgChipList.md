# NgChipList — Controlled tag collection

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Present filter topics or selected tags with single/multiple selection and application-owned removal.

## Behavior and practical rules

### State and events

The parent owns Value/value and stores selection callbacks. Selectable/selectable defaults to true. Disable it for a display-only label. OnRemove/onRemove is optional: providing it shows a separate, named remove action. Removal never changes selection or data automatically. Reject a request by leaving state unchanged; accept it by removing the ID from both items and selected values in one update. Removal does not fire the selection callback. Keep durable state in the parent.

### Keyboard and accessibility

Selection and removal have separate accessible actions. Tab moves through enabled actions; Enter or Space activates the focused action. Selected state is exposed to assistive technology. Disabled chips cannot be selected or removed. Native Flutter chip keyboard behavior includes its delete action. Arrow-key list navigation and focus transfer after removing a focused item are not implemented. Test screen-reader behavior in your target browser.

### Scope

Labels must be nonblank and at most 120 UTF-16 code units. Labels render as text, never HTML. Light/dark styling and wrapping are supported. Icons, avatars, custom templates, drag sorting, editable tags and virtualization are deferred. Web is the verified target; mobile verification is a separate phase.

### Collection contract

Use NgOption IDs, not display labels. IDs must be unique, 1–64 ASCII letters, digits, underscores or hyphens. Up to 50 items are supported. Selected IDs must be unique and exist in items; single mode accepts at most one. Multiple/multiple defaults to false. AllowEmpty/allowEmpty defaults to true; false prevents deselecting the last choice, but does not invent an initial selection or block application-owned removal. Callbacks return IDs in item order. No-op selection does not emit a callback. Empty items with empty value displays No tags.

When switching from multiple to single selection, normalize the selection in the same update. Disabled selected items stay visible; another single choice can replace them. The example below removes both the item and its selected ID atomically. For async removal, hold state until success and disable controls while pending.

## Blazor example

```razor
<NgChipList Label="Topics" Items="items" @bind-Value="selected" Multiple OnRemove="Remove" />
@code {
    private IReadOnlyList<NgOption> items = [new("design", "Design"), new("web", "Web"), new("locked", "Locked", true)];
    private IReadOnlyList<string> selected = ["design"];
    private void Remove(string id) {
        items = items.Where(item => item.Value != id).ToArray();
        selected = selected.Where(value => value != id).ToArray();
    }
}
```

## Flutter example

```dart
List<NgOption> items = const [NgOption('design', 'Design'), NgOption('web', 'Web'), NgOption('locked', 'Locked', disabled: true)];
List<String> selected = ['design'];
Widget build(BuildContext context) => NgChipList(label: 'Topics', items: items,
  value: selected, multiple: true,
  onChanged: (v) => setState(() => selected = v),
  onRemove: (id) => setState(() {
    items = items.where((item) => item.value != id).toList();
    selected = selected.where((value) => value != id).toList();
  }));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Tags" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | required | Input collection. Replace it when changing records or configuration. |
| `Value` | `IReadOnlyList<string>` | [] | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<IReadOnlyList<string>>` | not set | New value for the parent to store and pass back. |
| `OnRemove` | `EventCallback<string>` | not set | See the behavior rules and model contract above. |
| `Selectable` | `bool` | true | See the behavior rules and model contract above. |
| `Multiple` | `bool` | false | Allow multiple selected IDs instead of a single choice. |
| `AllowEmpty` | `bool` | true | Allow the user to clear the last selection; does not create an initial value. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `value` | `List<String>` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<List<String>>?` | Store the new value using setState or your state manager. |
| `onRemove` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `selectable` | `bool` | See the behavior rules and model contract above. |
| `multiple` | `bool` | Allow multiple selected IDs instead of a single choice. |
| `allowEmpty` | `bool` | Allow the user to clear the last selection; does not create an initial value. |
| `disabled` | `bool` | Disable user interaction. |

```dart
const NgChipList({
    super.key,
    this.label = 'Tags',
    required this.items,
    this.value = const [],
    this.onChanged,
    this.onRemove,
    this.selectable = true,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgChipList.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/chips.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
