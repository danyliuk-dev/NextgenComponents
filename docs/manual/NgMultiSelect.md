# NgMultiSelect — Multiple selection

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select several NgOption keys and remove selected items.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgMultiSelect) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgMultiSelect)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Controlled selection
Value/value is an array/list of option IDs. Items require unique nonempty IDs and nonempty labels. The parent stores emitted copies and passes them back; never mutate an emitted list or source collection in place. Flutter validation reads the current controlled value, including parent-driven changes. In Blazor use model data annotations for required/minimum selection; Flutter exposes required. MaxSelected/maxSelected must be positive if supplied and limits user additions, not externally supplied values.

Disabled options are locked: they cannot be added, removed through a chip, or cleared by bulk actions. An already-selected disabled ID counts toward the limit. Unknown selected IDs are shown as their raw ID and can be removed; the application decides how to reconcile removed records. ReadOnly/readOnly freezes selection while still allowing the list to be filtered. Disabled/enabled=false also disables filtering.

### Search, templates and bulk actions
FilterMode/filterMode accepts contains, startsWith or endsWith; MinLength/minLength defaults to 0. Placeholder and EmptyText/emptyText customize search and no-match guidance. Filtering never removes selections. ItemTemplate/itemBuilder and TagTemplate/tagBuilder decorate list items and selected chips while retaining accessible model labels. Use short noninteractive content.

ShowActions/showActions adds Select filtered and Clear selection. Select filtered takes every enabled match plus the existing selection, preserving order and removing duplicates. If the combined selection exceeds MaxSelected, the entire action is rejected with a message: no partial selection. Clear selection removes every unlocked selection, including those hidden by the filter, and retains disabled selections. These bulk actions are original Nextgen behavior, not a claim of Telerik API compatibility.

### Remaining scope
This implementation is an inline checklist with selected chips, not a popup MultiSelect. Remote data, virtualization, grouping, custom values, summary tags, popup timing/close behavior, localization of every action/status, complete keyboard-focus management and screen-reader/native certification remain open. Case folding follows each platform, not culture-specific collation.

## Blazor example

```razor
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgMultiSelect Label="Services" Items="services" @bind-Value="selected" MaxSelected="3" ShowActions ReadOnly="locked" EmptyText="No matching services">
<ItemTemplate Context="service"><strong>@service.Label</strong><small> · service</small></ItemTemplate>
<TagTemplate Context="service"><span>✓ @service.Label</span></TagTemplate>
</NgMultiSelect>
<p>Selected IDs: @string.Join(", ",selected)</p>
@code {private bool locked;private string[] selected=["locked"];private readonly NgOption[] services=[new("a","Alpha"),new("b","Beta"),new("g","Gamma"),new("locked","Mandatory",true)];}

```

## Flutter example

```dart
bool locked=false;List<String> selected=['locked'];
final services=const [NgOption('a','Alpha'),NgOption('b','Beta'),NgOption('g','Gamma'),NgOption('locked','Mandatory',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgMultiSelect(label:'Services',value:selected,items:services,maxSelected:3,showActions:true,readOnly:locked,emptyText:'No matching services',onChanged:(v)=>setState(()=>selected=v),itemBuilder:(_,o)=>Text('${o.label} · service'),tagBuilder:(_,o)=>Text('✓ ${o.label}')),
Text('Selected IDs: ${selected.join(', ')}')]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Options" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | [] | Input collection. Replace it when changing records or configuration. |
| `MaxSelected` | `int?` | not set | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `ShowActions` | `bool` | false | See the behavior rules and model contract above. |
| `FilterMode` | `string` | "contains" | See the behavior rules and model contract above. |
| `MinLength` | `int` | 0 | See the behavior rules and model contract above. |
| `Placeholder` | `string` | "Filter options…" | Hint displayed for empty input. |
| `EmptyText` | `string` | "No matches" | See the behavior rules and model contract above. |
| `ItemTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
| `TagTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
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
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `showActions` | `bool` | See the behavior rules and model contract above. |
| `filterMode` | `String` | See the behavior rules and model contract above. |
| `placeholder` | `String` | Hint displayed for empty input. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `minLength` | `int` | See the behavior rules and model contract above. |
| `itemBuilder` | `Widget Function(BuildContext, NgOption)?` | See the behavior rules and model contract above. |
| `tagBuilder` | `Widget Function(BuildContext, NgOption)?` | See the behavior rules and model contract above. |

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
    this.readOnly = false,
    this.showActions = false,
    this.filterMode = 'contains',
    this.minLength = 0,
    this.placeholder = 'Filter options…',
    this.emptyText = 'No matches',
    this.itemBuilder,
    this.tagBuilder,
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
