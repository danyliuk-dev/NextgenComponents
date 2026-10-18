# NgDropDownList — Dropdown list

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select one NgOption key from a local collection.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDropDownList) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDropDownList)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgOption contains value, label and disabled. Keys must be unique; selection stores the key, not the displayed label. Disabled entries cannot be selected. Replace the items collection when it changes and clear an obsolete selected key in the parent. Blazor binding requires ValueExpression for InputBase-based fields; use @bind-Value. Flutter initialValue initializes form state; reset using the supported controller/key pattern. Use form validation for a required choice. Large datasets and remote loading are outside this implementation.

## Blazor example

```razor
<NgDropDownList Label="Team" Items="options" @bind-Value="team"/>
@code { private string team="design"; private NgOption[] options=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)]; }
```

## Flutter example

```dart
String? team = 'design';
Widget build(BuildContext context) => NgDropDownList(label: 'Team', value: team,
  items: const [NgOption('design','Design'), NgOption('dev','Engineering'),
    NgOption('locked','Unavailable', disabled: true)],
  onChanged: (v) => setState(() => team = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "" | Visible label or accessible name. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Input collection. Replace it when changing records or configuration. |
| `Value` | `string` | "" | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<string>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<string>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | not set | Additional HTML/ARIA attributes; do not bypass component validation. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `String?` | Current value; see state ownership and model rules above. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `onChanged` | `ValueChanged<String?>?` | Store the new value using setState or your state manager. |
| `validator` | `FormFieldValidator<String>?` | Return null when valid or a user-facing validation error. |

```dart
const NgDropDownList({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDropDownList.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
