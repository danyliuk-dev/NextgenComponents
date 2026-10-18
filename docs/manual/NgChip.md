# NgChip — Compact selectable or removable tag

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Show a short status, toggle a tag, or offer an explicit remove action.

## Behavior and practical rules

### State and events

The parent owns Value/value and stores selection callbacks. Selectable/selectable defaults to true. Disable it for a display-only label. OnRemove/onRemove is optional: providing it shows a separate, named remove action. Removal never changes selection or data automatically. Reject a request by leaving state unchanged; accept it by removing the ID from both items and selected values in one update. Removal does not fire the selection callback. Keep durable state in the parent.

### Keyboard and accessibility

Selection and removal have separate accessible actions. Tab moves through enabled actions; Enter or Space activates the focused action. Selected state is exposed to assistive technology. Disabled chips cannot be selected or removed. Delete or Backspace requests removal from a focused interactive chip. Holding the key does not repeatedly remove chips. ChipList adds Left/Right and Home/End navigation with focus recovery after removal; see the keyboard rules below. Test screen-reader behavior in your target browser.

### Scope

Labels must be nonblank and at most 120 UTF-16 code units. Labels render as text, never HTML. Light/dark styling and wrapping are supported. Icons and avatars can be supplied as leading content, and custom labels and remove icons are supported. Drag sorting, editable tags and virtualization are not established Telerik Chip/ChipList requirements and remain possible extensions, not parity claims. Web is the verified target; mobile verification is a separate phase.

A missing selection callback prevents selection. Removal remains independently available when supplied. For a static status, set Selectable/selectable to false. Removing a standalone chip means the parent stops rendering it.

### Appearance and custom content (0.15)

Size/size accepts sm, md or lg. Rounded/rounded accepts sm, md, lg or full. FillMode/fillMode accepts solid or outline. ThemeColor/themeColor accepts base, info, success, warning or error. Invalid values throw; defaults remain md/full/outline/base for compatibility with 0.14. These defaults differ from Telerik. Colors adapt to light/dark themes; this is not a pixel-match claim.

Leading/leading accepts decorative content such as a small icon or avatar. ChildContent/child replaces the visible label. RemoveContent/removeIcon replaces the removal symbol. Always retain a meaningful Label/label: it supplies the accessible name regardless of the visual template. Do not put buttons, links, text fields or other interactive controls inside these templates. The parent owns image loading and image errors; there is no built-in avatar downloader or Telerik SVG icon registry.

OnClick/onClick is independent of selection: it runs after the selection callback on activation, also when selection is disabled. Removal only invokes the remove callback. Disabled chips invoke neither. A missing selection callback keeps selection unchanged, while an available click callback can still run a command. Blazor awaits the selection handler before invoking click; the next boolean is calculated before either callback. Flutter callbacks are synchronous. Do not use click to toggle selection a second time.


## Blazor example

```razor
<NgChip Label="Build succeeded" Selectable="false" ThemeColor="success" FillMode="solid" Size="lg" Rounded="md" OnClick="()=>clicks++">
    <Leading><span>✓</span></Leading>
    <ChildContent><strong>Build succeeded</strong></ChildContent>
</NgChip>
@if (visible) {
    <NgChip Label="Favourite" @bind-Value="selected" OnRemove="()=>visible=false">
        <RemoveContent>−</RemoveContent>
    </NgChip>
}
<p>Activity opened @clicks times</p>
@code {
    private bool selected, visible = true;
    private int clicks;
}
```

## Flutter example

```dart
bool selected = false, visible = true;
int clicks = 0;
Widget build(BuildContext context) => Wrap(spacing: 8, children: [
  NgChip(label: 'Build succeeded', selectable: false, themeColor: 'success',
    fillMode: 'solid', size: 'lg', rounded: 'md', leading: const Icon(Icons.check, size: 18),
    child: const Text('Build succeeded'), onClick: () => setState(() => clicks++)),
  if (visible) NgChip(label: 'Favourite', value: selected,
    onChanged: (v) => setState(() => selected = v),
    removeIcon: const Icon(Icons.remove, size: 18),
    onRemove: () => setState(() => visible = false)),
  Text('Activity opened $clicks times'),
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
| `OnClick` | `EventCallback` | not set | Application click handler. |
| `Size` | `string` | "md" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "full" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "outline" | Chip fill: solid or outline; see the documented defaults. |
| `ThemeColor` | `string` | "base" | Chip semantic color: base, info, success, warning or error. |
| `Leading` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `RemoveContent` | `RenderFragment?` | not set | Decorative replacement for the remove symbol; accessible action label is retained. |

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
| `onClick` | `VoidCallback?` | Application click handler. |
| `size` | `String` | See the behavior rules and model contract above. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `themeColor` | `String` | Chip semantic color: base, info, success, warning or error. |
| `leading` | `Widget?` | See the behavior rules and model contract above. |
| `child` | `Widget?` | See the behavior rules and model contract above. |
| `removeIcon` | `Widget?` | Replacement widget for the remove symbol; accessible action label is retained. |

```dart
const NgChip({
    super.key,
    required this.label,
    this.value = false,
    this.selectable = true,
    this.disabled = false,
    this.onChanged,
    this.onRemove,
    this.onClick,
    this.size = 'md',
    this.rounded = 'full',
    this.fillMode = 'outline',
    this.themeColor = 'base',
    this.leading,
    this.child,
    this.removeIcon,
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
