# NgChip — Compact selectable or removable tag

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Show a short status, toggle a tag, or offer an explicit remove action.

## Behavior and practical rules

### State and events

The parent owns Value/value and stores selection callbacks. Selectable/selectable defaults to true. Disable it for a display-only label. OnRemove/onRemove is optional: providing it shows a separate, named remove action. Removal never changes selection or data automatically. Reject a request by leaving state unchanged; accept it by removing the ID from both items and selected values in one update. Removal does not fire the selection callback. Keep durable state in the parent.

### Keyboard and accessibility

Selection and removal have separate accessible actions. Tab moves through enabled actions; Enter or Space activates the focused action. Selected state is exposed to assistive technology. Disabled chips cannot be selected or removed. Native Flutter chip keyboard behavior includes its delete action. Arrow-key list navigation and focus transfer after removing a focused item are not implemented. Test screen-reader behavior in your target browser.

### Scope

Labels must be nonblank and at most 120 UTF-16 code units. Labels render as text, never HTML. Light/dark styling and wrapping are supported. Icons, avatars, custom templates, drag sorting, editable tags and virtualization are deferred. Web is the verified target; mobile verification is a separate phase.

A missing selection callback prevents selection. Removal remains independently available when supplied. For a static status, set Selectable/selectable to false. Removing a standalone chip means the parent stops rendering it.

## Blazor example

```razor
@if (visible) {
    <NgChip Label="Favourite" @bind-Value="selected" OnRemove="()=>visible=false" />
}
<NgChip Label="Published" Selectable="false" />
@code {
    private bool selected, visible = true;
}
```

## Flutter example

```dart
bool selected = false, visible = true;
Widget build(BuildContext context) => Wrap(spacing: 8, children: [
  if (visible) NgChip(label: 'Favourite', value: selected,
    onChanged: (v) => setState(() => selected = v),
    onRemove: () => setState(() => visible = false)),
  const NgChip(label: 'Published', selectable: false),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | required | Visible label or accessible name. |
| `Value` | `bool` | false | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<bool>` | not set | New value for the parent to store and pass back. |
| `Selectable` | `bool` | true | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `OnRemove` | `EventCallback` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `bool` | Current value; see state ownership and model rules above. |
| `selectable` | `bool` | See the behavior rules and model contract above. |
| `disabled` | `bool` | Disable user interaction. |
| `onChanged` | `ValueChanged<bool>?` | Store the new value using setState or your state manager. |
| `onRemove` | `VoidCallback?` | See the behavior rules and model contract above. |

```dart
const NgChip({
    super.key,
    required this.label,
    this.value = false,
    this.selectable = true,
    this.disabled = false,
    this.onChanged,
    this.onRemove,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgChip.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/chips.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
