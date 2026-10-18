# NgWizard — Multi-step wizard

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Guide a user through an application-owned form with guarded forward transitions and completion.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgWizard) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgWizard)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### One transition pipeline

The parent owns Value/value and durable draft data. Linear/linear defaults to true. Header selection, built-in buttons and actions supplied to custom buttons all use the same pipeline: BeforeChange/beforeChange, forward/Finish validation, then ValueChanged/onChanged or OnFinish/onFinish. NgWizardChange contains Current/current, Target/target and IsFinish/isFinish. Return false from the async guard to cancel silently; show any explanation in application-owned UI. Guard exceptions and validation/save exceptions show a generic retry message. Backward movement runs the guard but does not validate. Finish targets the current final enabled step and runs both guard and validation. An empty/null validation message allows continuation.

### Busy, completion and reset

Only one action runs at a time. Successful Finish blocks repeat local submission until reset. Increment ResetKey/resetKey to clear busy/error/completed state even when the current index stays unchanged. Changed index, item metadata, Disabled or Linear also invalidates pending results. A result from an obsolete guard/validator is ignored, including after disposal. This does not cancel your HTTP request, roll back a running save, clear form fields or provide server idempotency: the application owns cancellation, draft reset and safe persistence. Presentation changes alone do not reset completion. Replace collections instead of mutating lists in place.

### Layout and step templates

Position/position accepts `top` (default), `bottom`, `start` or `end`. Side placement is relative to Rtl/rtl and uses a vertical step rail; below 600 px it stacks above the content. Vertical remains available for top/bottom layouts. DisplayMode/displayMode and IndicatorTemplate/indicatorBuilder / LabelTemplate/labelBuilder follow Stepper contracts. Template contexts retain model labels as accessible names. Only active step content is rendered; keep draft controllers/models in the parent. Full content retention and automatic focus movement are not implemented.

### Built-in and custom actions

BackText/backText, NextText/nextText and FinishText/finishText customize built-in captions; each must be nonempty and at most 120 characters. ActionsTemplate/actionsBuilder replaces the action bar and receives NgWizardActions: Value/value, Busy/busy, Finished/finished, IsLast/isLast, CanBack/canBack, CanNext/canNext and CanFinish/canFinish, plus BackAsync/back, NextAsync/next and FinishAsync/finish callbacks. Use IsLast to choose the forward button and Can… to enable it; busy state is not the same as the last step. Await callbacks when handling them yourself. Do not cache the context across renders or bypass it by directly changing Value. The callbacks recheck current navigation, busy, disabled and completion rules. A missing change callback disables navigation, but a single final step can still finish if a finish handler exists.

The English status/error messages are currently built in. Full localization, animated transitions, roving arrow-key focus and complete screen-reader/native-platform validation remain open. Detailed form validation and persistence belong to the application.

## Blazor example

```razor
<NgCheckBox Label="Block transitions" @bind-Value="blocked"/>
<NgButton OnClick="Restart">Restart wizard</NgButton>
<NgWizard Label="Application" Items="steps" @bind-Value="current" ResetKey="reset"
          Position="start" BeforeChange="AllowChange" ValidateStep="Validate" OnFinish="Save">
  <IndicatorTemplate Context="step"><span>@(step.Index==0?"✎":"✓")</span></IndicatorTemplate>
  <ChildContent Context="index">
    @if(index==0){<NgTextBox Label="Applicant name" @bind-Value="name"/>}
    else{<p>Review: @name</p>}
  </ChildContent>
  <ActionsTemplate Context="actions">
    <div class="ng-wizard-actions">
      <NgButton Disabled="@(!actions.CanBack)" OnClick="actions.BackAsync">Previous</NgButton>
      @if(!actions.IsLast){<NgButton Primary Disabled="@(!actions.CanNext)" OnClick="actions.NextAsync">Continue</NgButton>}
      else{<NgButton Primary Disabled="@(!actions.CanFinish)" OnClick="actions.FinishAsync">Save application</NgButton>}
    </div>
  </ActionsTemplate>
</NgWizard>
<p>@status</p>
@code {
  private int current,reset; private bool blocked; private string? name;
  private string status="Not saved";
  private readonly NgStep[] steps=[new("Contact"),new("Review")];
  private Task<bool> AllowChange(NgWizardChange change)=>Task.FromResult(!blocked);
  private Task<string?> Validate(int index)=>Task.FromResult<string?>(index==0&&string.IsNullOrWhiteSpace(name)?"Enter your name.":null);
  private Task Save(){status="Saved locally";return Task.CompletedTask;}
  private void Restart(){reset++;current=0;status="Not saved";}
}

```

## Flutter example

```dart
int current = 0, reset = 0; bool blocked = false; String status = 'Not saved';
final name = TextEditingController(); final steps = const [NgStep('Contact'),NgStep('Review')];
@override void dispose(){name.dispose();super.dispose();}
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Block transitions',value:blocked,onChanged:(v)=>setState(()=>blocked=v)),
  NgButton(onPressed:()=>setState((){reset++;current=0;status='Not saved';}),child:const Text('Restart wizard')),
  NgWizard(label:'Application',items:steps,value:current,onChanged:(v)=>setState(()=>current=v),resetKey:reset,
    position:'start',beforeChange:(change)async=>!blocked,
    validateStep:(index)async=>index==0&&name.text.trim().isEmpty?'Enter your name.':null,
    onFinish:()async{setState(()=>status='Saved locally');},
    indicatorBuilder:(_,step)=>Icon(step.index==0?Icons.person_outline:Icons.check,size:20),
    contentBuilder:(_,index)=>index==0?NgTextBox(label:'Applicant name',controller:name):Text('Review: ${name.text}'),
    actionsBuilder:(_,a)=>Wrap(spacing:16,runSpacing:8,children:[
      NgButton(onPressed:a.canBack?a.back:null,child:const Text('Previous')),
      if(!a.isLast)NgButton(primary:true,onPressed:a.canNext?a.next:null,child:const Text('Continue'))
      else NgButton(primary:true,onPressed:a.canFinish?a.finish:null,child:const Text('Save application'))])),
  Text(status),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Wizard" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgStep>` | required | Input collection. Replace it when changing records or configuration. |
| `Value` | `int` | 0 | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<int>` | not set | New value for the parent to store and pass back. |
| `Linear` | `bool` | true | Restrict forward navigation to the next enabled step; earlier steps remain accessible. |
| `Vertical` | `bool` | false | Use a vertical root layout; see the component keyboard and layout rules. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ValidateStep` | `Func<int,Task<string?>>?` | not set | Async current-step validation; null/empty allows forward navigation or completion. |
| `OnFinish` | `EventCallback` | not set | Completion handler; success disables subsequent completion until reset. |
| `ChildContent` | `RenderFragment<int>` | required | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `Rtl` | `bool` | false | See the behavior rules and model contract above. |
| `Position` | `string` | "top" | See the behavior rules and model contract above. |
| `DisplayMode` | `string` | "all" | See the behavior rules and model contract above. |
| `ResetKey` | `int` | 0 | See the behavior rules and model contract above. |
| `BackText` | `string` | "Back" | See the behavior rules and model contract above. |
| `NextText` | `string` | "Next" | See the behavior rules and model contract above. |
| `FinishText` | `string` | "Finish" | See the behavior rules and model contract above. |
| `IndicatorTemplate` | `RenderFragment<NgStepContext>?` | not set | See the behavior rules and model contract above. |
| `LabelTemplate` | `RenderFragment<NgStepContext>?` | not set | See the behavior rules and model contract above. |
| `ActionsTemplate` | `RenderFragment<NgWizardActions>?` | not set | See the behavior rules and model contract above. |
| `BeforeChange` | `Func<NgWizardChange,Task<bool>>?` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgStep>` | Input collection. Replace it when changing records or configuration. |
| `value` | `int` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<int>?` | Store the new value using setState or your state manager. |
| `linear` | `bool` | Restrict forward navigation to the next enabled step; earlier steps remain accessible. |
| `vertical` | `bool` | Use a vertical root layout; see the component keyboard and layout rules. |
| `disabled` | `bool` | Disable user interaction. |
| `rtl` | `bool` | See the behavior rules and model contract above. |
| `position` | `String` | See the behavior rules and model contract above. |
| `displayMode` | `String` | See the behavior rules and model contract above. |
| `backText` | `String` | See the behavior rules and model contract above. |
| `nextText` | `String` | See the behavior rules and model contract above. |
| `finishText` | `String` | See the behavior rules and model contract above. |
| `resetKey` | `int` | See the behavior rules and model contract above. |
| `indicatorBuilder` | `Widget Function(BuildContext, NgStepContext)?` | See the behavior rules and model contract above. |
| `labelBuilder` | `Widget Function(BuildContext, NgStepContext)?` | See the behavior rules and model contract above. |
| `actionsBuilder` | `Widget Function(BuildContext, NgWizardActions)?` | See the behavior rules and model contract above. |
| `beforeChange` | `Future<bool> Function(NgWizardChange)?` | See the behavior rules and model contract above. |
| `validateStep` | `Future<String?> Function(int)?` | Async current-step validation; null/empty allows forward navigation or completion. |
| `onFinish` | `Future<void> Function()?` | Completion handler; success disables subsequent completion until reset. |
| `contentBuilder` | `Widget Function(BuildContext, int)` | Build content for the current zero-based step; keep durable draft state in the parent. |

```dart
const NgWizard({
    super.key,
    this.label = 'Wizard',
    required this.items,
    this.value = 0,
    this.onChanged,
    this.linear = true,
    this.vertical = false,
    this.disabled = false,
    this.rtl = false,
    this.position = 'top',
    this.displayMode = 'all',
    this.resetKey = 0,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.finishText = 'Finish',
    this.indicatorBuilder,
    this.labelBuilder,
    this.actionsBuilder,
    this.beforeChange,
    this.validateStep,
    this.onFinish,
    required this.contentBuilder,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgWizard.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/steps.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
