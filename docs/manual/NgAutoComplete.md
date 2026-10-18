# NgAutoComplete — Text suggestions

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Enter free text with suggestions from a local string list.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgAutoComplete) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgAutoComplete)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Text outside the suggestions is allowed. Use ComboBox when the value must be an existing key. Flutter initialValue sets the starting text; recreate the widget with a new Key for a complete external reset. Searching is local; the application owns server requests, debounce and cancellation. Store callbacks before submitting the draft.

## Blazor example

```razor
<NgAutoComplete Label="City" Items="cities" @bind-Value="city"/>
@code { private string? city; private string[] cities=["Kyiv","Lviv","Odesa"]; }
```

## Flutter example

```dart
String city = '';
Widget build(BuildContext context) => NgAutoComplete(label: 'City',
  items: const ['Kyiv','Lviv','Odesa'], initialValue: city,
  onChanged: (v) => city = v);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Search" | Visible label or accessible name. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `Items` | `IReadOnlyList<string>` | [] | Input collection. Replace it when changing records or configuration. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Value` | `string?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<String>` | Input collection. Replace it when changing records or configuration. |
| `initialValue` | `String` | Starting field value, not continuous controlled state. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `enabled` | `bool` | See the behavior rules and model contract above. |

```dart
const NgAutoComplete({
    super.key,
    this.label = 'Search',
    required this.items,
    this.initialValue = '',
    this.onChanged,
    this.enabled = true,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgAutoComplete.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/forms.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
