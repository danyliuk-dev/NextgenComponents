# NgToggleButton — Toggle button

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Switch a single setting on or off while keeping the action label visible. Examples include a preview border, a pinned item or a formatting option.

## Behavior and practical rules


### Controlled selection and click events

Value/value is application-owned. Store ValueChanged/onChanged and pass the new value back. OnClick/onClick is an independent activation notification: selection is requested first, then click runs. Blazor awaits the selection callback; Flutter callbacks are synchronous. If selection handling throws, the click callback is not reached. A click-only toggle stays interactive but never changes its own value. With neither callback, or Disabled/disabled=true, it is disabled. Disable the control while an application request is pending; automatic async-operation locking is not supplied.

### Content and accessible names

Label/label remains required, nonblank and limited to 120 UTF-16 code units. ChildContent/child replaces visible content; Leading/leading supplies a decorative icon, image or avatar. These slots must contain display content, not nested buttons, links or inputs. AriaLabel/semanticLabel optionally overrides the main accessible name. Keep visible wording in the name. Blazor AriaLabelledBy overrides the label when its IDs resolve; AriaDescribedBy supplies help. Flutter uses semanticIdentifier/semanticHint. Names and hints must be nonblank when supplied. Templates do not replace the explicit name.

Id/Class/Title are Blazor DOM hooks. Flutter has no equivalent CSS-class contract; use its widget layout and semantics APIs. Blazor exports button/aria-pressed, Flutter retains Material's native checked semantics. These are platform-specific contracts, not a screen-reader certification.

### Focus and visibility

TabIndex/tabIndex accepts 0 (default) or -1 only. -1 skips Tab traversal without disabling pointer activation or explicit focus. Blazor FocusAsync() is available through @ref after interactive rendering; hidden or disabled controls do not receive focus. Flutter accepts an application-owned FocusNode; create it once, requestFocus(), and dispose it after removing its widget. Each enabled group item remains a separate Tab stop; Enter/Space activates it. There is no arrow-key radiogroup contract.

Visible/visible=false removes the action from layout, keyboard traversal and semantics. It does not reset the parent's selected state. If the application hides the focused action, it must choose the next focus target. Re-showing a button restores its controlled state, not its old focus.


### Shared appearance and per-item overrides

Size/size accepts sm, md, lg. Rounded/rounded accepts sm, md, lg, full. FillMode/fillMode accepts solid, outline, flat, link, clear. ThemeColor/themeColor accepts base, primary, secondary, tertiary, info, success, warning, error, dark, light, inverse. Invalid tokens throw. Defaults are md/md/outline/primary, preserving Nextgen's selection emphasis rather than copying Telerik defaults. Colors adapt to the active theme; dark/light are readable theme tokens, not fixed black/white swatches. Exact theme pixels and ThemeBuilder compatibility are not claimed.

Solid fills the button, outline outlines it, flat omits the resting border/background, link adds underlined text, and clear uses neutral text. Selected toggles retain a distinct filled state in every mode; Flutter also shows a check mark so custom bold content cannot hide selection, while Blazor adds an inset selected outline. Hover and focus remain separate from selection. Disabled styles indicate non-interactivity. A link fill is visual styling and does not turn a button into a navigation link.

ButtonGroup applies these settings to every item. ItemAppearance/itemAppearance may return NgButtonAppearance with nullable fields; null fields inherit group values. Use this for a command's accent without changing other items. Tokens apply to commands and toggles equally. The Formatting commands and choices demo combines all appearance controls, per-item accents, icons, mixed actions, hidden selection, disabled controls and vertical layout.


## Blazor example

```razor
<p id="preview-help">Toggle the preview outline.</p>
<NgToggleButton @ref="toggle" Id="preview-toggle" Label="Preview outline" AriaDescribedBy="preview-help"
    @bind-Value="selected" OnClick="()=>clicks++" Size="lg" Rounded="full" FillMode="outline" ThemeColor="success">
  <Leading><span>★</span></Leading><ChildContent><strong>Preview outline</strong></ChildContent>
</NgToggleButton>
<NgButton OnClick="()=>toggle!.FocusAsync().AsTask()">Focus preview</NgButton>
<p>Selected: @selected. Activations: @clicks</p>
@code { private NgToggleButton? toggle; private bool selected; private int clicks; }

```

## Flutter example

```dart
bool selected = false;
int clicks = 0;
final toggleFocus = FocusNode();
@override
void dispose() { toggleFocus.dispose(); super.dispose(); }
Widget build(BuildContext context) => Column(children: [
  NgToggleButton(label: 'Preview outline', semanticIdentifier: 'preview-toggle', semanticHint: 'Toggle the preview outline.',
    value: selected, onChanged: (v) => setState(() => selected = v), onClick: () => setState(() => clicks++),
    focusNode: toggleFocus, size: 'lg', rounded: 'full', fillMode: 'outline', themeColor: 'success',
    leading: const Icon(Icons.star, size: 16), child: const Text('Preview outline')),
  TextButton(onPressed: toggleFocus.requestFocus, child: const Text('Focus preview')),
  Text('Selected: $selected. Activations: $clicks'),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string?` | not set | See the behavior rules and model contract above. |
| `Class` | `string?` | not set | See the behavior rules and model contract above. |
| `Title` | `string?` | not set | Heading for the section or dialog. |
| `AriaLabel` | `string?` | not set | Optional nonblank main-chip accessible name; labelled-by takes precedence. Visible text and removal names are unchanged. |
| `AriaLabelledBy` | `string?` | not set | Space-separated existing DOM IDs for the accessible name; takes precedence over Label. |
| `AriaDescribedBy` | `string?` | not set | Space-separated existing DOM IDs for contextual guidance; see target-element rules. |
| `TabIndex` | `int` | 0 | 0 keeps normal Tab participation; -1 skips forward/reverse Tab while preserving pointer/application focus. Other values are rejected. |
| `Visible` | `bool` | true | See the behavior rules and model contract above. |
| `Size` | `string` | "md" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "md" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "outline" | Chip fill: solid or outline; see the documented defaults. |
| `ThemeColor` | `string` | "primary" | Chip semantic color: base, info, success, warning or error. |
| `Leading` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `Label` | `string` | required | Visible label or accessible name. |
| `Value` | `bool` | false | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<bool>` | not set | New value for the parent to store and pass back. |
| `OnClick` | `EventCallback` | not set | Application click handler. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `bool` | Current value; see state ownership and model rules above. |
| `disabled` | `bool` | Disable user interaction. |
| `visible` | `bool` | See the behavior rules and model contract above. |
| `onChanged` | `ValueChanged<bool>?` | Store the new value using setState or your state manager. |
| `onClick` | `VoidCallback?` | Application click handler. |
| `size` | `String` | See the behavior rules and model contract above. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `themeColor` | `String` | Chip semantic color: base, info, success, warning or error. |
| `semanticLabel` | `String?` | Optional nonblank native accessible name for the main chip; null uses label. |
| `semanticIdentifier` | `String?` | Optional nonblank automation identifier in the Flutter semantics tree; not a widget Key or DOM id. |
| `semanticHint` | `String?` | Optional nonblank contextual guidance in the semantics tree; not a visible tooltip. |
| `leading` | `Widget?` | See the behavior rules and model contract above. |
| `child` | `Widget?` | See the behavior rules and model contract above. |
| `focusNode` | `FocusNode?` | See the behavior rules and model contract above. |
| `tabIndex` | `int` | 0 keeps normal Tab participation; -1 skips forward/reverse Tab while preserving pointer/application focus. Other values are rejected. |

```dart
const NgToggleButton({
    super.key,
    required this.label,
    this.value = false,
    this.onChanged,
    this.onClick,
    this.disabled = false,
    this.visible = true,
    this.size = 'md',
    this.rounded = 'md',
    this.fillMode = 'outline',
    this.themeColor = 'primary',
    this.semanticLabel,
    this.semanticIdentifier,
    this.semanticHint,
    this.leading,
    this.child,
    this.focusNode,
    this.tabIndex = 0,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgToggleButton.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/selection.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
