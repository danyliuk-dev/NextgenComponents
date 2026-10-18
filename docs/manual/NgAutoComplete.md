# NgAutoComplete — Text suggestions

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Enter free text with suggestions from a local string list.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgAutoComplete) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgAutoComplete)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Free text and filtering
AutoComplete accepts free text; choosing a suggestion is optional. Blazor uses @bind-Value. Flutter initialValue is a starting draft, not a controlled value; use a new key for a wholesale reset. onChanged reports typing and accepted suggestions. Application validation and persistence remain separate.

FilterMode/filterMode accepts contains, startsWith or endsWith (case-insensitive). MinLength/minLength must be nonnegative; default 1 hides suggestions for empty input. Placeholder is guidance, not an accessible label. ReadOnly/readOnly blocks editing and selection; Disabled/enabled=false blocks normal interaction.

### Native popup differences
Blazor retains the browser datalist. The supplied options are prefiltered, and Chrome may apply its own additional matching/display behavior. Flutter uses Material Autocomplete and an owned controller/focus node. Suggestion presentation, opening and keyboard behavior remain framework-native. Replace item lists when updating data; type again to refresh an already-open Flutter suggestion list.

No remote async loading, debounce, virtualization, item/header/footer templates, clear action, custom popup API or full screen-reader certification is supplied. Filtering is not locale-aware collation; case folding can differ for non-ASCII strings. Web is the verified platform target.

## Blazor example

```razor
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgAutoComplete Label="City" Items="cities" @bind-Value="city" FilterMode="startsWith" MinLength="2" ReadOnly="locked" Placeholder="Type at least two letters"/>
<p>Current city: @city</p>
@code { private bool locked;private string? city;private readonly string[] cities=["London","Lisbon","Los Angeles","Berlin"]; }

```

## Flutter example

```dart
bool locked=false;String city='';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgAutoComplete(label:'City',items:const ['London','Lisbon','Los Angeles','Berlin'],filterMode:'startsWith',minLength:2,readOnly:locked,placeholder:'Type at least two letters',onChanged:(v)=>setState(()=>city=v)),
Text('Current city: $city')]);

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
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `FilterMode` | `string` | "contains" | See the behavior rules and model contract above. |
| `MinLength` | `int` | 1 | See the behavior rules and model contract above. |
| `Value` | `string?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `initialValue` | `String` | Starting field value, not continuous controlled state. |
| `filterMode` | `String` | See the behavior rules and model contract above. |
| `placeholder` | `String?` | Hint displayed for empty input. |
| `items` | `List<String>` | Input collection. Replace it when changing records or configuration. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `minLength` | `int` | See the behavior rules and model contract above. |

```dart
const NgAutoComplete({
    super.key,
    this.label = 'Search',
    required this.items,
    this.initialValue = '',
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.filterMode = 'contains',
    this.minLength = 1,
    this.placeholder,
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
