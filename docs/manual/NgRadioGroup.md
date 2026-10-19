# NgRadioGroup — Radio group

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select one NgOption key from a local collection.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgRadioGroup) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgRadioGroup)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgOption contains value, label and disabled. Keys must be unique; selection stores the key, not the displayed label. Disabled entries cannot be selected. Replace the items collection when it changes and clear an obsolete selected key in the parent. Blazor binding requires ValueExpression for InputBase-based fields; use @bind-Value. Flutter initialValue initializes form state; reset using the supported controller/key pattern. Use form validation for a required choice. Large datasets and remote loading are outside this implementation.

ReadOnly/readOnly and Disabled/enabled prevent user selection. These native choice controls use disabled interaction in read-only mode and do not promise focusable read-only text. HelperText/helperText adds visible guidance. IDs and labels must be nonempty and IDs unique; invalid option configuration throws. Selected disabled items can remain visible but cannot be chosen by user action. Removing a selected key never selects another option implicitly.

RadioGroup Orientation/orientation accepts horizontal (existing default) or vertical. ItemTemplate/itemBuilder customizes decorative content; the option label remains the accessible name. Do not put interactive controls inside the item template. Flutter label taps and native radio selection obey the same disabled/read-only rules. RadioGroup external missing keys and required rules remain application-owned; it is not a standalone Flutter FormField.

DropDownList preserves an unknown selected key as an unavailable entry and rejects form submission until it is replaced or cleared by the application. Blazor supports an empty placeholder option; Flutter placeholder is a hint for null and does not add a clear command. A stale Flutter popup result after a parent rebuild is ignored. Placeholder is not required validation: use model annotations on Blazor and validator on Flutter. Text filtering, remote loading, virtualization, grouping and custom popup templates remain open; use ComboBox for searchable input.

## Blazor example

```razor
<NgRadioGroup Label="Team" Items="items" @bind-Value="team" ReadOnly="readOnly" Orientation="@orientation" HelperText="Choose one available team.">
 <ItemTemplate Context="item"><strong>Team · @item.Label</strong></ItemTemplate>
</NgRadioGroup>
<NgButton OnClick="Toggle">Read only</NgButton>
<NgButton OnClick="Layout">Change layout</NgButton>
<p>Selected team: @team</p>
@code {
 private string team="design",orientation="vertical"; private bool readOnly;
 private NgOption[] items=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)];
 private void Toggle()=>readOnly=!readOnly;
 private void Layout()=>orientation=orientation=="vertical"?"horizontal":"vertical";
}
```

## Flutter example

```dart
String? team='design'; bool readOnly=false; String orientation='vertical';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 NgRadioGroup(label:'Team',value:team,orientation:orientation,readOnly:readOnly,helperText:'Choose one available team.',
  items:const[NgOption('design','Design'),NgOption('dev','Engineering'),NgOption('locked','Unavailable',disabled:true)],
  itemBuilder:(_,o)=>Text('Team · ${o.label}',style:const TextStyle(fontWeight:FontWeight.bold)),onChanged:(v)=>setState(()=>team=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 NgButton(onPressed:()=>setState(()=>orientation=orientation=='vertical'?'horizontal':'vertical'),child:const Text('Change layout')),
 Text('Selected team: $team'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Input collection. Replace it when changing records or configuration. |
| `Value` | `string` | "" | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<string>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<string>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Orientation` | `string` | "horizontal" | See the behavior rules and model contract above. |
| `HelperText` | `string?` | not set | See the behavior rules and model contract above. |
| `ItemTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `orientation` | `String` | See the behavior rules and model contract above. |
| `value` | `String?` | Current value; see state ownership and model rules above. |
| `helperText` | `String?` | See the behavior rules and model contract above. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `onChanged` | `ValueChanged<String?>?` | Store the new value using setState or your state manager. |
| `itemBuilder` | `Widget Function(BuildContext, NgOption)?` | See the behavior rules and model contract above. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |

```dart
const NgRadioGroup({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.helperText,
    this.itemBuilder,
    this.orientation = 'horizontal',
    this.enabled = true,
    this.readOnly = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgRadioGroup.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
