# NgComboBox — Searchable selection

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select one NgOption key from a local collection.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgComboBox) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgComboBox)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### IDs, drafts and validation
Value/value is an option ID, never its display label. Items need unique nonempty IDs and nonempty labels. Replace item collections to publish changes. Renaming the selected item updates its visible label without changing the ID. When the selected item disappears, the editor becomes empty while the parent still owns the old ID: clear or replace that ID in your application. In Flutter, replace the component key to discard an unrelated invalid draft; initial draft state otherwise remains local.

Typing a case-insensitive exact enabled label selects its ID; duplicate labels resolve to the first enabled match. Arbitrary text stays visible and blocks validation without replacing the last valid model ID. Clearing emits null. Disabled items cannot be selected. Use @bind-Value and model annotations in Blazor; required and NgForm/Form in Flutter. Never persist an old ID merely because the draft is invalid: validate the enclosing form first.

### Filtering and presentation
FilterMode/filterMode is contains, startsWith or endsWith; MinLength/minLength defaults to 0. A positive minimum hides suggestions until enough text is entered. Placeholder labels empty input. ReadOnly/readOnly blocks typing, selection and clear while allowing inspection. ShowClearButton/showClearButton exposes a labelled clear action. The application owns any required-value error after clearing.

ItemTemplate/itemBuilder decorates an option; its accessible name remains NgOption.Label. Keep templates noninteractive. Blazor EmptyText customizes the empty popup message. Flutter RawAutocomplete closes an empty popup; there is no equivalent empty popup template. Blazor shows disabled matches; Flutter omits them. Native keyboard navigation and popup positioning differ; Flutter active options now have a visible highlight.

### Remaining scope
No remote loading, virtualization, custom values, arbitrary model adapter, debounce, full popup header/footer templates or appearance variants. A parent data refresh can replace the displayed draft; preserve application drafts separately when needed. Web checks do not certify native/mobile or screen-reader parity.

Flutter caches the currently computed popup options until the next text edit. After replacing Items or filter configuration, edit the query to recompute suggestions. A stale callback for a removed, renamed or newly disabled option is rejected against the current collection.

## Blazor example

```razor
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgForm Model="model" OnValidSubmit="Save">
<NgComboBox Label="Assignee" Items="people" @bind-Value="model.Person" ReadOnly="locked" ShowClearButton FilterMode="startsWith" MinLength="1" Placeholder="Search a person">
<ItemTemplate Context="person"><strong>@person.Label</strong><small> · Team member</small></ItemTemplate>
</NgComboBox>
<NgButton Type="submit" Primary>Save selection</NgButton>
</NgForm>
<NgButton OnClick="Rename">Rename selected</NgButton><p>@status</p>
@code {
 private bool locked;private string status="Not saved";private Draft model=new();
 private NgOption[] people=[new("a","Alex"),new("b","Bella"),new("x","Blocked",true)];
 private void Save()=>status=$"Saved ID: {model.Person}";
 private void Rename(){people=people.Select(p=>p.Value==model.Person?p with{Label="Alex Morgan"}:p).ToArray();}
 public class Draft{[System.ComponentModel.DataAnnotations.Required] public string? Person{get;set;}="a";}
}

```

## Flutter example

```dart
bool locked=false;String? person='a';String status='Not saved';
List<NgOption> people=[const NgOption('a','Alex'),const NgOption('b','Bella'),const NgOption('x','Blocked',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgForm(submitLabel:'Save selection',onValidSubmit:()=>setState(()=>status='Saved ID: $person'),child:
NgComboBox(label:'Assignee',value:person,items:people,required:true,readOnly:locked,showClearButton:true,filterMode:'startsWith',minLength:1,placeholder:'Search a person',onChanged:(v)=>setState(()=>person=v),itemBuilder:(_,o)=>Text('${o.label} · Team member'))),
NgButton(onPressed:()=>setState(()=>people=people.map((o)=>o.value==person?NgOption(o.value,'Alex Morgan'):o).toList()),child:const Text('Rename selected')),
Text(status)]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Choose an option" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Input collection. Replace it when changing records or configuration. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `ShowClearButton` | `bool` | false | See the behavior rules and model contract above. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `EmptyText` | `string` | "No matches" | See the behavior rules and model contract above. |
| `FilterMode` | `string` | "contains" | See the behavior rules and model contract above. |
| `MinLength` | `int` | 0 | See the behavior rules and model contract above. |
| `ItemTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
| `Value` | `string?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `String?` | Current value; see state ownership and model rules above. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `onChanged` | `ValueChanged<String?>?` | Store the new value using setState or your state manager. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `showClearButton` | `bool` | See the behavior rules and model contract above. |
| `filterMode` | `String` | See the behavior rules and model contract above. |
| `placeholder` | `String?` | Hint displayed for empty input. |
| `minLength` | `int` | See the behavior rules and model contract above. |
| `itemBuilder` | `Widget Function(BuildContext, NgOption)?` | See the behavior rules and model contract above. |

```dart
const NgComboBox({
    super.key,
    this.label = 'Choose an option',
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.showClearButton = false,
    this.filterMode = 'contains',
    this.minLength = 0,
    this.placeholder,
    this.itemBuilder,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgComboBox.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/forms.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
