# NgDropDownList — Dropdown list

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select one NgOption key from a local collection.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDropDownList) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDropDownList)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgOption contains value, label and disabled. Keys must be unique; selection stores the key, not the displayed label. Disabled entries cannot be selected. Replace the items collection when it changes and clear an obsolete selected key in the parent. Blazor binding requires ValueExpression for InputBase-based fields; use @bind-Value. Flutter initialValue initializes form state; reset using the supported controller/key pattern. Use form validation for a required choice. Large datasets and remote loading are outside this implementation.

ReadOnly/readOnly and Disabled/enabled prevent user selection. These native choice controls use disabled interaction in read-only mode and do not promise focusable read-only text. HelperText/helperText adds visible guidance. IDs and labels must be nonempty and IDs unique; invalid option configuration throws. Selected disabled items can remain visible but cannot be chosen by user action. Removing a selected key never selects another option implicitly.

RadioGroup Orientation/orientation accepts horizontal (existing default) or vertical. ItemTemplate/itemBuilder customizes decorative content; the option label remains the accessible name. Do not put interactive controls inside the item template. Flutter label taps and native radio selection obey the same disabled/read-only rules. RadioGroup external missing keys and required rules remain application-owned; it is not a standalone Flutter FormField.

DropDownList preserves an unknown selected key as an unavailable entry and rejects form submission until it is replaced or cleared by the application. Blazor supports an empty placeholder option; Flutter placeholder is a hint for null and does not add a clear command. A stale Flutter popup result after a parent rebuild is ignored. Placeholder is not required validation: use model annotations on Blazor and validator on Flutter. Text filtering, remote loading, virtualization, grouping and custom popup templates remain open; use ComboBox for searchable input.

## Blazor example

```razor
<NgForm Model="model" OnValidSubmit="Save">
 <NgDropDownList Label="Team" @bind-Value="model.Team" Items="items" ReadOnly="readOnly" Placeholder="Choose a team" HelperText="Unavailable selections must be replaced." />
 <NgButton Type="submit">Save team</NgButton>
</NgForm>
<NgButton OnClick="Remove">Remove selected option</NgButton>
<NgButton OnClick="Toggle">Read only</NgButton>
<p>Selected team: @model.Team</p><p>@status</p>
@code {
 private Draft model=new(); private bool readOnly; private string status="";
 private NgOption[] items=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)];
 private void Remove()=>items=items.Where(o=>o.Value!=model.Team).ToArray();
 private void Toggle()=>readOnly=!readOnly;
 private void Save()=>status="Saved team: "+model.Team;
 private sealed class Draft { public string Team {get;set;}="design"; }
}
```

## Flutter example

```dart
String? team='design'; bool readOnly=false; String status='';
List<NgOption> items=[const NgOption('design','Design'),const NgOption('dev','Engineering'),const NgOption('locked','Unavailable',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 NgForm(submitLabel:'Save team',onValidSubmit:()=>setState(()=>status='Saved team: $team'),child:
  NgDropDownList(label:'Team',value:team,items:items,readOnly:readOnly,placeholder:'Choose a team',helperText:'Unavailable selections must be replaced.',onChanged:(v)=>setState(()=>team=v))),
 NgButton(onPressed:()=>setState(()=>items=items.where((o)=>o.value!=team).toList()),child:const Text('Remove selected option')),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Selected team: $team'),Text(status),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "" | Visible label or accessible name. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `HelperText` | `string?` | not set | See the behavior rules and model contract above. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Input collection. Replace it when changing records or configuration. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `Value` | `string` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `String?` | Current value; see state ownership and model rules above. |
| `placeholder` | `String?` | Hint displayed for empty input. |
| `helperText` | `String?` | See the behavior rules and model contract above. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `onChanged` | `ValueChanged<String?>?` | Store the new value using setState or your state manager. |
| `validator` | `FormFieldValidator<String>?` | Return null when valid or a user-facing validation error. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |

```dart
const NgDropDownList({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.placeholder,
    this.helperText,
    this.enabled = true,
    this.readOnly = false,
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
