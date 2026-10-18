# NgForm — Form validation

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Validate fields and run a save handler only after successful validation.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgForm) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgForm)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Validation and asynchronous saving
Blazor wraps EditForm/DataAnnotationsValidator; place a Type="submit" button inside ChildContent. Flutter wraps Form, runs every registered validator and supplies its own submit button. Do not nest forms. ShowSummary/showSummary controls the summary, not field-level validation. OnInvalidSubmit/onInvalidSubmit reports failed validation; persistence runs only when all fields pass.

OnValidSubmit/onValidSubmit may be asynchronous. While it is pending, further submissions are ignored and content interaction is blocked. Blazor uses a disabled fieldset; Flutter blocks pointer/focus interaction. Custom overlays and programmatic callbacks still belong to the application. Disabled/enabled=false also blocks submissions. BusyText/busyText and ErrorText/errorText can be localized. A thrown save exception shows the generic configured error and enables retry; the component does not expose exception details.

### Reset and persistence boundaries
The application owns the model, transport and persisted result. To reset draft state, touched fields and validation, replace both the model and the component key (Blazor @key, Flutter Key); external Flutter formKey must also be new. Disposed forms ignore late local state updates. Reset does not cancel transport or undo a save already accepted by the server. Snapshot the submitted values and use backend idempotency for important operations. A completed submission does not permanently lock the form: a later explicit submit may save again.

Automatic model-driven editor generation, conditional schemas, custom summary templates, field grids and full Telerik event/API compatibility remain unimplemented. This block is Web-only verification.

## Blazor example

```razor
<NgCheckBox Label="Simulate save failure" @bind-Value="fail"/>
<NgForm @key="model" Model="model" OnValidSubmit="Save">
<NgTextBox Label="Application name" @bind-Value="model.Name" MaxLength="80" HelperText="Required before saving."/>
<NgTextArea Label="Notes" @bind-Value="model.Notes" Rows="3" MaxLength="200"/>
<NgButton Type="submit" Primary>Save application</NgButton>
</NgForm>
<NgButton OnClick="Reset">Reset application</NgButton>
<p role="status">@status</p>
@code {
 private Draft model=new(); private bool fail; private string status="Not saved";
 private void Reset(){model=new();status="Not saved";}
 private async Task Save(){var draft=model;var denied=fail;var name=draft.Name;await Task.Delay(1000);if(denied)throw new InvalidOperationException();if(ReferenceEquals(model,draft))status=$"Saved: {name}";}
 public class Draft{[System.ComponentModel.DataAnnotations.Required] public string? Name{get;set;} public string? Notes{get;set;}}
}

```

## Flutter example

```dart
int revision = 0; bool fail = false; String name = '', notes = '', status = 'Not saved';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Simulate save failure',value:fail,onChanged:(v)=>setState(()=>fail=v)),
NgForm(key:ValueKey(revision),submitLabel:'Save application',onValidSubmit:()async{
final version=revision,denied=fail;final snapshot=name;
await Future<void>.delayed(const Duration(seconds:1));
if(denied)throw StateError('Demo failure');
if(mounted&&version==revision)setState(()=>status='Saved: $snapshot');
},child:Column(children:[
NgTextBox(label:'Application name',initialValue:name,maxLength:80,helperText:'Required before saving.',onChanged:(v)=>name=v,validator:(v)=>v==null||v.trim().isEmpty?'Enter an application name.':null),
NgTextArea(label:'Notes',initialValue:notes,rows:3,maxLength:200,onChanged:(v)=>notes=v)])),
NgButton(onPressed:()=>setState((){revision++;name='';notes='';status='Not saved';}),child:const Text('Reset application')),
Text(status)]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Model` | `object` | required | See the behavior rules and model contract above. |
| `Name` | `string` | "ng-form" | See the behavior rules and model contract above. |
| `ShowSummary` | `bool` | true | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `BusyText` | `string` | "Saving…" | See the behavior rules and model contract above. |
| `ErrorText` | `string` | "Unable to save. Try again." | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `OnValidSubmit` | `EventCallback<EditContext>` | not set | See the behavior rules and model contract above. |
| `OnInvalidSubmit` | `EventCallback<EditContext>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `child` | `Widget` | See the behavior rules and model contract above. |
| `onValidSubmit` | `FutureOr<void> Function()` | See the behavior rules and model contract above. |
| `onInvalidSubmit` | `VoidCallback?` | See the behavior rules and model contract above. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `showSummary` | `bool` | See the behavior rules and model contract above. |
| `busyText` | `String` | See the behavior rules and model contract above. |
| `errorText` | `String` | See the behavior rules and model contract above. |
| `submitLabel` | `String` | See the behavior rules and model contract above. |
| `formKey` | `GlobalKey<FormState>?` | See the behavior rules and model contract above. |

```dart
const NgForm({
    super.key,
    required this.child,
    required this.onValidSubmit,
    this.submitLabel = 'Save',
    this.onInvalidSubmit,
    this.enabled = true,
    this.showSummary = true,
    this.busyText = 'Saving…',
    this.errorText = 'Unable to save. Try again.',
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
