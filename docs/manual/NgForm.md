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

Automatic model-driven editor generation, conditional schemas, full Telerik event/API compatibility remain unimplemented. This block is Web-only verification.

### Responsive fields and actions (0.50)
Fields/fields is an explicit ordered list of field fragments/widgets. Supply it instead of ChildContent/child; combining them throws. An empty list is allowed. Legacy content keeps its existing layout. The library does not inspect the model or generate editors.

Columns/columns is the maximum number of columns (1–4, default 1). MinColumnWidth/minColumnWidth is the preferred minimum width (120–1200 CSS/logical pixels, default 240); Gap/gap is spacing in both directions (0–64, default 16). Width comes from the form's container, not the screen. Columns reduce as space narrows; one column can shrink below the preferred minimum to fit. Flutter requires bounded horizontal constraints; use Expanded when placing the form in a Row. Custom field content must itself support shrinking. Fields occupy one cell unless FieldSpans/fieldSpans is supplied; nested groups are not supplied.

Changing width, columns or gaps preserves the existing field widgets, values and validation. Keep the field list order stable for positional identity; use a replacement form key when replacing the entire schema. Flutter keyed fields support reordering; do not reuse keys. Tab/focus order follows source order. Flutter Wrap and CSS Grid use each row's tallest cell without forcing editors to equal heights.

Actions is a Blazor fragment below all fields, inside the disabled fieldset; use Type="submit" for save buttons. Flutter actionsBuilder replaces the default Save button and receives (context, submit). The submit callback is null while disabled/busy; wire it directly to the button. Retained submit callbacks recheck current permissions. Pointer/focus interaction with custom Flutter actions is blocked while saving or disabled. Custom programmatic actions, overlays and side effects still require application guards. Actions remain outside the field grid and can wrap on narrow screens. Omitting actionsBuilder retains Flutter's existing submit button.


### Live validation summary (0.51)
SummaryTitle/summaryTitle localizes the default heading; the default is "Please correct the highlighted fields." The default summary lists individual errors. SummaryTemplate/summaryBuilder replaces the heading and list and receives a read-only snapshot of message strings. Supply localized validator messages in the application. Duplicates and empty strings are retained so an invalid field never silently becomes valid. Message order follows platform validation registration, not a promised cross-platform order. Default text is rendered as plain text, never HTML.

ShowSummary/showSummary hides the entire summary, including the custom template; it does not disable validation or field errors. Empty summaries are hidden. Blazor follows EditContext validation notifications (including field-level errors before submission). Flutter starts summary collection on the first attempted submit; later field changes revalidate the registered fields after the frame and update the summary without calling onInvalidSubmit or saving. Validators must be synchronous and free of side effects. Flutter native FormState.reset also triggers that refresh after a submit attempt; replace the form key for a pristine reset.

Changing presentation or hiding/revealing the summary preserves fields and errors. Replacing the model/key resets validation as described above. Blazor unsubscribes from old EditContext notifications; disposed Flutter forms ignore queued refreshes. A custom template should contain descriptive content; field-focus links and a standardized error-to-field ID mapping are not supplied. The live-region wrapper remains around custom content, but full screen-reader certification is still open.


### Field spans (0.52)
FieldSpans/fieldSpans is an optional integer list matching Fields/fields exactly. Values 1–4 request that many columns; 0 occupies the whole available row. An omitted list gives every field one column. Invalid lengths, values outside 0–4 or spans without explicit fields throw. A requested span is clamped to the columns currently available, so narrow forms stay within their container. The preferred minimum width still determines how many columns fit.

Fields retain source order and flow to the next row when the remaining space is insufficient; gaps are not filled by moving later fields backwards. A full-row field starts a new row and subsequent fields follow it. Row height follows the tallest field; vertical row spans are not supported. Changing spans does not reset values, focus or validation. Keep the field order stable, or use the previously documented keyed-field/reset rules.

Blazor uses per-instance container-query rules with validated numeric widths and a single-column fallback in browsers without container-query support. Flutter uses Wrap with the same available-column and span rules. Field fragments must support shrinking. This is explicit layout, not automatic model/schema generation or nested field groups.


## Blazor example

```razor
<div class="ng-prompt-actions"><NgButton OnClick="()=>notesSpan=notesSpan==0?2:notesSpan==2?1:0">Change notes span</NgButton><NgButton OnClick="()=>columns=3">Use three columns</NgButton></div>
<div class="ng-prompt-actions"><NgButton OnClick="()=>customSummary=!customSummary">Toggle custom summary</NgButton><NgButton OnClick="()=>showSummary=!showSummary">Toggle summary visibility</NgButton></div>
<div class="ng-prompt-actions"><NgButton OnClick="()=>columns=columns==2?1:2">Change columns</NgButton><NgButton OnClick="()=>gap=gap==16?32:16">Change spacing</NgButton></div>
<p>Maximum columns: @columns · Gap: @gap</p>
<NgCheckBox Label="Simulate save failure" @bind-Value="fail"/>
<NgCheckBox Label="Disable form" @bind-Value="disabled"/>
<NgForm @key="model" Model="model" ShowSummary="showSummary" SummaryTitle="Review this application" SummaryTemplate="@(customSummary?CustomSummary:null)" Fields="FormFields" FieldSpans="@(new[]{1,1,notesSpan,1})" Columns="columns" Gap="gap" Disabled="disabled" OnValidSubmit="Save">
 <Actions><NgButton Type="submit" Primary>Save application</NgButton><span>All fields are validated before saving.</span></Actions>
</NgForm>
<NgButton OnClick="Reset">Reset application</NgButton>
<p role="status">@status</p>
@code {
 private int notesSpan;
 private bool customSummary=true,showSummary=true;
 private RenderFragment<IReadOnlyList<string>> CustomSummary=>errors=>@<div><strong>Review @errors.Count issue(s)</strong><ul>@foreach(var message in errors){<li>@message</li>}</ul></div>;
 private Draft model=new(); private bool fail,disabled; private int columns=2,gap=16; private string status="Not saved";
 private IReadOnlyList<RenderFragment> FormFields=>new[]{NameField,OwnerField,NotesField,ReferenceField};
 private RenderFragment NameField=>@<NgTextBox Label="Application name" @bind-Value="model.Name" MaxLength="80" HelperText="Required before saving."/>;
 private RenderFragment OwnerField=>@<NgTextBox Label="Owner" @bind-Value="model.Owner"/>;
 private RenderFragment NotesField=>@<NgTextArea Label="Notes" @bind-Value="model.Notes" Rows="2"/>;
 private RenderFragment ReferenceField=>@<NgTextBox Label="Reference" @bind-Value="model.Reference"/>;
 private void Reset(){model=new();status="Not saved";}
 private async Task Save(){var draft=model;var denied=fail;var name=draft.Name;await Task.Delay(1000);if(denied)throw new InvalidOperationException();if(ReferenceEquals(model,draft))status=$"Saved: {name}";}
 public class Draft{[System.ComponentModel.DataAnnotations.Required] public string? Name{get;set;} [System.ComponentModel.DataAnnotations.Required(ErrorMessage="Enter an owner.")] public string? Owner{get;set;} public string? Notes{get;set;} public string? Reference{get;set;}}
}

```

## Flutter example

```dart
int notesSpan=0;
bool customSummary=true,showSummary=true;
int revision=0,columns=2,gap=16; bool fail=false,disabled=false; String name='',owner='',notes='',reference='',status='Not saved';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>notesSpan=notesSpan==0?2:notesSpan==2?1:0),child:const Text('Change notes span')),NgButton(onPressed:()=>setState(()=>columns=3),child:const Text('Use three columns'))]),
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>customSummary=!customSummary),child:const Text('Toggle custom summary')),NgButton(onPressed:()=>setState(()=>showSummary=!showSummary),child:const Text('Toggle summary visibility'))]),
 Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>columns=columns==2?1:2),child:const Text('Change columns')),NgButton(onPressed:()=>setState(()=>gap=gap==16?32:16),child:const Text('Change spacing'))]),
 Text('Maximum columns: $columns · Gap: $gap'),
 NgCheckBox(label:'Simulate save failure',value:fail,onChanged:(v)=>setState(()=>fail=v)),
 NgCheckBox(label:'Disable form',value:disabled,onChanged:(v)=>setState(()=>disabled=v)),
 NgForm(fieldSpans:[1,1,notesSpan,1],showSummary:showSummary,summaryTitle:'Review this application',summaryBuilder:customSummary?(_,errors)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Review ${errors.length} issue(s)',style:const TextStyle(fontWeight:FontWeight.bold)),for(final message in errors)Text(message)]):null,key:ValueKey(revision),columns:columns,gap:gap,enabled:!disabled,onValidSubmit:()async{
  final version=revision,denied=fail;final snapshot=name;await Future<void>.delayed(const Duration(seconds:1));
  if(denied)throw StateError('Demo failure');if(mounted&&version==revision)setState(()=>status='Saved: $snapshot');
 },fields:[
  NgTextBox(label:'Application name',initialValue:name,maxLength:80,helperText:'Required before saving.',onChanged:(v)=>name=v,validator:(v)=>v==null||v.trim().isEmpty?'Enter an application name.':null),
  NgTextBox(label:'Owner',initialValue:owner,onChanged:(v)=>owner=v,validator:(v)=>(v??'').trim().isEmpty?'Enter an owner.':null),
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
| `SummaryTitle` | `string` | "Please correct the highlighted fields." | Localized heading for the default validation summary. |
| `SummaryTemplate` | `RenderFragment<IReadOnlyList<string>>?` | not set | Custom summary receiving a read-only snapshot of validation messages. |
| `ShowSummary` | `bool` | true | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `BusyText` | `string` | "Saving…" | See the behavior rules and model contract above. |
| `ErrorText` | `string` | "Unable to save. Try again." | See the behavior rules and model contract above. |
| `Fields` | `IReadOnlyList<RenderFragment>?` | not set | Explicit ordered fields; do not combine with legacy content. |
| `FieldSpans` | `IReadOnlyList<int>?` | not set | One span per field (0–4); zero fills the available row. Omit for one cell per field. |
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
| `fieldSpans` | `List<int>?` | One span per field (0–4); zero fills the available row. Omit for one cell per field. |
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
| `summaryTitle` | `String` | Localized heading for the default validation summary. |
| `summaryBuilder` | `Widget Function(BuildContext, List<String>)?` | Custom summary receiving context and an unmodifiable message list. |
| `submitLabel` | `String` | See the behavior rules and model contract above. |
| `formKey` | `GlobalKey<FormState>?` | See the behavior rules and model contract above. |

```dart
const NgForm({
    super.key,
    this.child,
    this.fields,
    this.fieldSpans,
    this.columns = 1,
    this.minColumnWidth = 240,
    this.gap = 16,
    this.actionsBuilder,
    required this.onValidSubmit,
    this.submitLabel = 'Save',
    this.onInvalidSubmit,
    this.enabled = true,
    this.showSummary = true,
    this.summaryTitle = 'Please correct the highlighted fields.',
    this.summaryBuilder,
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
