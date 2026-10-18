# NgMultiSelect — Multiple selection

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select several NgOption keys and remove selected items.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgMultiSelect) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgMultiSelect)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Value is a collection of keys, not labels. The callback supplies a new list; replace the parent collection. MaxSelected limits additions while removal remains available. Flutter required demands at least one selection; in Blazor define the rule in the form model. Search is local; large-list virtualization and remote loading are not implemented.

## Blazor example

```razor
<NgMultiSelect Label="Services" Items="options" MaxSelected="2" @bind-Value="selected"/>
@code { private string[] selected=[]; private NgOption[] options=[new("a","Delivery"),new("b","Assembly")]; }
```

## Flutter example

```dart
List<String> selected = [];
Widget build(BuildContext context) => NgMultiSelect(label: 'Services', value: selected,
  items: const [NgOption('a','Delivery'),NgOption('b','Assembly')], maxSelected: 2,
  onChanged: (v) => setState(() => selected = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Options" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Input collection. Replace it when changing records or configuration. |
| `MaxSelected` | `int?` | not set | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Value` | `string[]` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string[]>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string[]>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `List<String>` | Current value; see state ownership and model rules above. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `onChanged` | `ValueChanged<List<String>>?` | Store the new value using setState or your state manager. |
| `maxSelected` | `int?` | See the behavior rules and model contract above. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |

```dart
const NgMultiSelect({
    super.key,
    this.label = 'Options',
    required this.value,
    required this.items,
    this.onChanged,
    this.maxSelected,
    this.enabled = true,
    this.required = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgMultiSelect.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/forms.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
