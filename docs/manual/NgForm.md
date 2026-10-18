# NgForm — Form validation

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Validate fields and run a save handler only after successful validation.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgForm) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgForm)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Blazor Model uses DataAnnotations; OnValidSubmit receives a valid form and OnInvalidSubmit reports a failed submission. Keep one model instance while editing. Flutter uses a GlobalKey<FormState>, field validators/required rules and the supplied submit handler. Return null for valid field values, otherwise an error message. Network failures belong to the application save flow, not numeric/date parsing. Avoid nested forms. Maintain a separate saved record so Cancel can discard the draft.

## Blazor example

```razor
<NgForm Model="model" OnValidSubmit="Save">
    <NgTextBox Label="Name" @bind-Value="model.Name"/>
    <NgButton Type="submit" Primary>Save</NgButton>
</NgForm>
<p>@status</p>
@code {
 private Draft model=new(); private string? status;
 private void Save()=>status=$"Saved: {model.Name}";
 public class Draft { [System.ComponentModel.DataAnnotations.Required] public string? Name {get;set;} }
}
```

## Flutter example

```dart
String name = '';
Widget build(BuildContext context) => NgForm(submitLabel: 'Save',
  onValidSubmit: () => debugPrint('Saved: $name'),
  child: NgTextBox(label: 'Name', onChanged: (v) => name = v,
    validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Model` | `object` | required | See the behavior rules and model contract above. |
| `Name` | `string` | "ng-form" | See the behavior rules and model contract above. |
| `ShowSummary` | `bool` | true | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `OnValidSubmit` | `EventCallback<EditContext>` | not set | See the behavior rules and model contract above. |
| `OnInvalidSubmit` | `EventCallback<EditContext>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `child` | `Widget` | See the behavior rules and model contract above. |
| `onValidSubmit` | `VoidCallback` | See the behavior rules and model contract above. |
| `submitLabel` | `String` | See the behavior rules and model contract above. |
| `formKey` | `GlobalKey<FormState>?` | See the behavior rules and model contract above. |

```dart
const NgForm({
    super.key,
    required this.child,
    required this.onValidSubmit,
    this.submitLabel = 'Save',
    this.formKey,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgForm.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/forms.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
