# NgForm — Form validation

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Validate fields and run a save handler only after successful validation.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgForm) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgForm)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Validation and asynchronous saving
Blazor wraps EditForm/DataAnnotationsValidator; place a Type="submit" button inside ChildContent or Actions. Flutter wraps Form, runs every registered validator and supplies its own submit button. Do not nest forms. ShowSummary/showSummary controls the summary, not field-level validation. OnInvalidSubmit/onInvalidSubmit reports failed validation; persistence runs only when all fields pass.

OnValidSubmit/onValidSubmit may be asynchronous. While it is pending, further submissions are ignored and content interaction is blocked. Blazor uses a disabled fieldset; Flutter blocks pointer/focus interaction. Custom overlays and programmatic callbacks still belong to the application. Disabled/enabled=false also blocks submissions. BusyText/busyText and ErrorText/errorText can be localized. A thrown save exception shows the generic configured error and enables retry; the component does not expose exception details.

### Reset and persistence boundaries
The application owns the model, transport and persisted result. To reset draft state, touched fields and validation, replace both the model and the component key (Blazor @key, Flutter Key); external Flutter formKey must also be new. Disposed forms ignore late local state updates. Reset does not cancel transport or undo a save already accepted by the server. Snapshot the submitted values and use backend idempotency for important operations. A completed submission does not permanently lock the form: a later explicit submit may save again.

Automatic model-driven editor generation, conditional schemas, custom summary templates, full Telerik event/API compatibility remain unimplemented. This block is Web-only verification.

### Responsive fields and actions (0.50)
Fields/fields is an explicit ordered list of field fragments/widgets. Supply it instead of ChildContent/child; combining them throws. An empty list is allowed. Legacy content keeps its existing layout. The library does not inspect the model or generate editors.

Columns/columns is the maximum number of columns (1–4, default 1). MinColumnWidth/minColumnWidth is the preferred minimum width (120–1200 CSS/logical pixels, default 240); Gap/gap is spacing in both directions (0–64, default 16). Width comes from the form's container, not the screen. Columns reduce as space narrows; one column can shrink below the preferred minimum to fit. Flutter requires bounded horizontal constraints; use Expanded when placing the form in a Row. Custom field content must itself support shrinking. Each field occupies one cell; spans and nested groups are not supplied.

Changing width, columns or gaps preserves the existing field widgets, values and validation. Keep the field list order stable for positional identity; use a replacement form key when replacing the entire schema. Flutter keyed fields support reordering; do not reuse keys. Tab/focus order follows source order. Flutter Wrap and CSS Grid use each row's tallest cell without forcing editors to equal heights.

Actions is a Blazor fragment below all fields, inside the disabled fieldset; use Type="submit" for save buttons. Flutter actionsBuilder replaces the default Save button and receives (context, submit). The submit callback is null while disabled/busy; wire it directly to the button. Retained submit callbacks recheck current permissions. Pointer/focus interaction with custom Flutter actions is blocked while saving or disabled. Custom programmatic actions, overlays and side effects still require application guards. Actions remain outside the field grid and can wrap on narrow screens. Omitting actionsBuilder retains Flutter's existing submit button.


## Blazor example

```razor
<div class="ng-prompt-actions"><NgButton OnClick="()=>columns=columns==2?1:2">Change columns</NgButton><NgButton OnClick="()=>gap=gap==16?32:16">Change spacing</NgButton></div>
<p>Maximum columns: @columns · Gap: @gap</p>
<NgCheckBox Label="Simulate save failure" @bind-Value="fail"/>
<NgCheckBox Label="Disable form" @bind-Value="disabled"/>
<NgForm @key="model" Model="model" Fields="FormFields" Columns="columns" Gap="gap" Disabled="disabled" OnValidSubmit="Save">
 <Actions><NgButton Type="submit" Primary>Save application</NgButton><span>All fields are validated before saving.</span></Actions>
</NgForm>
<NgButton OnClick="Reset">Reset application</NgButton>
<p role="status">@status</p>
@code {
 private Draft model=new(); private bool fail,disabled; private int columns=2,gap=16; private string status="Not saved";
 private IReadOnlyList<RenderFragment> FormFields=>new[]{NameField,OwnerField,NotesField,ReferenceField};
 private RenderFragment NameField=>@<NgTextBox Label="Application name" @bind-Value="model.Name" MaxLength="80" HelperText="Required before saving."/>;
 private RenderFragment OwnerField=>@<NgTextBox Label="Owner" @bind-Value="model.Owner"/>;
 private RenderFragment NotesField=>@<NgTextArea Label="Notes" @bind-Value="model.Notes" Rows="2"/>;
 private RenderFragment ReferenceField=>@<NgTextBox Label="Reference" @bind-Value="model.Reference"/>;
 private void Reset(){model=new();status="Not saved";}
 private async Task Save(){var draft=model;var denied=fail;var name=draft.Name;await Task.Delay(1000);if(denied)throw new InvalidOperationException();if(ReferenceEquals(model,draft))status=$"Saved: {name}";}
 public class Draft{[System.ComponentModel.DataAnnotations.Required] public string? Name{get;set;} public string? Owner{get;set;} public string? Notes{get;set;} public string? Reference{get;set;}}
}

```

## Flutter example

```dart
int revision=0,columns=2,gap=16; bool fail=false,disabled=false; String name='',owner='',notes='',reference='',status='Not saved';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>columns=columns==2?1:2),child:const Text('Change columns')),NgButton(onPressed:()=>setState(()=>gap=gap==16?32:16),child:const Text('Change spacing'))]),
 Text('Maximum columns: $columns · Gap: $gap'),
 NgCheckBox(label:'Simulate save failure',value:fail,onChanged:(v)=>setState(()=>fail=v)),
 NgCheckBox(label:'Disable form',value:disabled,onChanged:(v)=>setState(()=>disabled=v)),
 NgForm(key:ValueKey(revision),columns:columns,gap:gap,enabled:!disabled,onValidSubmit:()async{
  final version=revision,denied=fail;final snapshot=name;await Future<void>.delayed(const Duration(seconds:1));
  if(denied)throw StateError('Demo failure');if(mounted&&version==revision)setState(()=>status='Saved: $snapshot');
 },fields:[
  NgTextBox(label:'Application name',initialValue:name,maxLength:80,helperText:'Required before saving.',onChanged:(v)=>name=v,validator:(v)=>v==null||v.trim().isEmpty?'Enter an application name.':null),
  NgTextBox(label:'Owner',initialValue:owner,onChanged:(v)=>owner=v),
  NgTextArea(label:'Notes',initialValue:notes,rows:2,onChanged:(v)=>notes=v),
  NgTextBox(label:'Reference',initialValue:reference,onChanged:(v)=>reference=v),
 ],actionsBuilder:(_,submit)=>Wrap(spacing:12,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[NgButton(primary:true,onPressed:submit,child:const Text('Save application')),const Text('All fields are validated before saving.')])),
 NgButton(onPressed:()=>setState((){revision++;name='';owner='';notes='';reference='';status='Not saved';}),child:const Text('Reset application')),
 Text(status),
]);

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
| `Fields` | `IReadOnlyList<RenderFragment>?` | not set | Explicit ordered fields; do not combine with legacy content. |
| `Columns` | `int` | 1 | Maximum responsive column count (1–4); default 1. |
| `MinColumnWidth` | `int` | 240 | Preferred minimum cell width (120–1200); default 240. |
| `Gap` | `int` | 16 | Horizontal and vertical cell spacing (0–64); default 16. |
| `Actions` | `RenderFragment?` | not set | Full-width action area inside the disabled fieldset; use a submit button. |
| `ChildContent` | `RenderFragment?` | not set | Legacy content with application-owned layout; use ChildContent or Fields. |
| `OnValidSubmit` | `EventCallback<EditContext>` | not set | See the behavior rules and model contract above. |
| `OnInvalidSubmit` | `EventCallback<EditContext>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `child` | `Widget?` | Legacy content with application-owned layout; use child or fields. |
| `fields` | `List<Widget>?` | Explicit ordered fields; do not combine with legacy content. |
| `columns` | `int` | Maximum responsive column count (1–4); default 1. |
| `minColumnWidth` | `int` | Preferred minimum cell width (120–1200); default 240. |
| `gap` | `int` | Horizontal and vertical cell spacing (0–64); default 16. |
| `actionsBuilder` | `Widget Function(BuildContext, VoidCallback?)?` | Custom actions receiving context and a nullable guarded submit callback. |
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
    this.child,
    this.fields,
    this.columns = 1,
    this.minColumnWidth = 240,
    this.gap = 16,
    this.actionsBuilder,
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
