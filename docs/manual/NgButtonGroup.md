# NgButtonGroup — Single and multiple choice buttons

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Present a small set of related settings as visible buttons. Use single selection for alignment or a view mode, and multiple selection for independent styles or filters.

## Behavior and practical rules

### Choose a selection mode

Items/items is a flat list of NgOption values. Value/value is a list of selected IDs even in single-selection mode. Multiple/multiple defaults to false: activating a different option replaces the previous selection. With Multiple/multiple true, options toggle independently. The parent must store ValueChanged/onChanged and pass the new list back. Changes produce a new list in item order; input collections are never modified.

### Decide whether users can clear the selection

AllowEmpty/allowEmpty defaults to true, so clicking the last selected button clears it. Set it to false to prevent a user from removing the last choice. This rule does not create an initial selection and does not reject an empty value supplied by the parent: initialize a value if your application requires one. A prevented action emits no change event. Unknown or disabled activation IDs are ignored by the selection rules.

### Updates, disabled options and validation

Each option has an ID, label and disabled flag. Disabled/disabled disables the whole group; a missing callback also disables all buttons. A disabled selected option remains visible. Selecting another item in single mode replaces the prior selection, even if that prior item is disabled. Programmatic reset remains possible while controls are disabled.

IDs must be unique, contain 1–64 ASCII letters, digits, underscores or hyphens, and labels must be nonblank with at most 120 UTF-16 code units. Supply at most 50 options. Selected IDs must be unique and exist in Items/items; single mode accepts at most one. When removing options or switching to single mode, normalize the selected list in the same parent update. Empty items with an empty value displays No options.

### Layout and keyboard

Horizontal groups wrap onto new lines on narrow screens. Vertical/vertical stacks buttons. Tab and Shift+Tab move between enabled buttons; Enter and Space activate them. Each button exposes its pressed state, and the group has a shared accessible label. This is a group of toggle buttons, not an arrow-key radiogroup. Routes, content panels, mixed command buttons, icons and custom templates are outside this release. Use NgRadioGroup for radio input semantics.

## Blazor example

```razor
<NgButtonGroup Label="Text alignment" Items="alignments" @bind-Value="alignment" AllowEmpty="false" />
<NgButtonGroup Label="Text styles" Items="styles" @bind-Value="format" Multiple />
<p>Alignment: @string.Join(", ", alignment). Styles: @string.Join(", ", format)</p>
@code {
    private IReadOnlyList<string> alignment = ["left"], format = [];
    private readonly NgOption[] alignments = [new("left", "Left"), new("center", "Center"), new("right", "Right")];
    private readonly NgOption[] styles = [new("bold", "Bold"), new("italic", "Italic"), new("underline", "Underline", true)];
}
```

## Flutter example

```dart
List<String> alignment = ['left'], format = [];
final alignments = const [NgOption('left', 'Left'), NgOption('center', 'Center'), NgOption('right', 'Right')];
final styles = const [NgOption('bold', 'Bold'), NgOption('italic', 'Italic'), NgOption('underline', 'Underline', disabled: true)];
Widget build(BuildContext context) => Column(children: [
  NgButtonGroup(label: 'Text alignment', items: alignments, value: alignment,
    allowEmpty: false, onChanged: (value) => setState(() => alignment = value)),
  NgButtonGroup(label: 'Text styles', items: styles, value: format, multiple: true,
    onChanged: (value) => setState(() => format = value)),
  Text('Alignment: ${alignment.join(", ")}. Styles: ${format.join(", ")}'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Options" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | required | Input collection. Replace it when changing records or configuration. |
| `Value` | `IReadOnlyList<string>` | [] | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<IReadOnlyList<string>>` | not set | New value for the parent to store and pass back. |
| `Multiple` | `bool` | false | Allow multiple selected IDs instead of a single choice. |
| `AllowEmpty` | `bool` | true | Allow the user to clear the last selection; does not create an initial value. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Vertical` | `bool` | false | Use a vertical root layout; see the component keyboard and layout rules. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `value` | `List<String>` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<List<String>>?` | Store the new value using setState or your state manager. |
| `multiple` | `bool` | Allow multiple selected IDs instead of a single choice. |
| `allowEmpty` | `bool` | Allow the user to clear the last selection; does not create an initial value. |
| `disabled` | `bool` | Disable user interaction. |
| `vertical` | `bool` | Use a vertical root layout; see the component keyboard and layout rules. |

```dart
const NgButtonGroup({
    super.key,
    this.label = 'Options',
    required this.items,
    this.value = const [],
    this.onChanged,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
    this.vertical = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgButtonGroup.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/selection.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
