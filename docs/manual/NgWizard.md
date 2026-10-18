# NgWizard — Multi-step wizard

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Guide a user through an application-owned form with guarded forward transitions and completion.

## Behavior and practical rules

### Configuration and state
Items and Value follow NgStepper rules: 1–30 steps, enabled zero-based current index, unique positions and valid labels. Linear defaults to true. Back moves to the preceding enabled step. Next moves to the following enabled step, skipping disabled entries. Earlier headers are reachable; later headers obey Linear. With Linear=false, clicking a later header validates only the current step, not every skipped step. Optional is a label, not a separate Skip action.

ValueChanged/onChanged is a request to the parent. Store it and render the returned index; otherwise the wizard remains on the current step. ChildContent is RenderFragment<int> in Blazor; contentBuilder is Widget Function(BuildContext,int) in Flutter. Only active content is rendered. Keep drafts/controllers/validation keys in the parent so data survives navigation; do not rely on child widget state. Blazor consumers can key their content by index when they need fresh child instances.

### Validation and asynchronous work
ValidateStep/validateStep receives the current index before forward movement (Next or a future header) and before Finish. Return null or an empty string to allow the action; return a user-facing message to block it. Backward movement does not validate. Use EditContext.Validate or FormState.validate in this callback if embedding a form; the wizard does not automatically validate nested fields. On Finish, revalidate all business-critical values in your save service, including earlier steps.

During validation/saving, navigation buttons and headers are disabled and Checking… is announced. Duplicate activation is ignored. Validation failure keeps the current step and displays its message. Exceptions show a generic retryable error. A changed current index, changed step configuration, disabled state or disposal invalidates pending UI results, so an old validator cannot navigate a newly reset wizard. This does not cancel network work: own transport cancellation in your application. Vertical/theme changes alone preserve the pending operation.

### Completion and reset
Finish appears when no later enabled step exists. It requires OnFinish/onFinish. After successful completion it shows Completed. and disables further navigation/saving. Failed saves remain retryable. Completion is local UI state, not a server idempotency guarantee: use an idempotency key for durable operations. A callback already running may still have external effects after disposal/reset; protect your application's result updates accordingly.

Use a new @key/ValueKey to reset the whole wizard, including completion, then reset the parent draft/index. Changing the current index, step configuration or Disabled also resets local status. The gallery demonstrates resetting while a delayed validator is running. Do not change configuration during a durable save unless the host handles its consequences.

### Accessibility and scope
Tab and Enter/Space operate controls; status/error messages are announced. Stepper orientation is horizontal/wrapping or vertical, above content. No automatic focus move into the new form, custom button templates, side/bottom stepper placements, built-in persistence, animated transitions or native/mobile certification. Keep the form's visible headings and labels meaningful.

## Blazor example

```razor
<NgWizard Items="steps" @bind-Value="current" ValidateStep="Validate" OnFinish="Save" Context="index">
 @if(index==0){<label>Name <input @bind="name" @bind:event="oninput" /></label>}
 else{<p>Review: @name</p>}
</NgWizard>
<p>@status</p>
@code {
 private int current; private string name="",status="Not saved";
 private NgStep[] steps=[new("Contact"),new("Review")];
 private Task<string?> Validate(int index)=>Task.FromResult<string?>(index==0&&name.Trim().Length<2?"Enter at least two characters.":null);
 private Task Save(){status=$"Saved: {name}";return Task.CompletedTask;}
}
```

## Flutter example

```dart
int current = 0;
String name = '', status = 'Not saved';
final steps = const [NgStep('Contact'), NgStep('Review')];
Widget build(BuildContext context) => Column(children: [
 NgWizard(items: steps, value: current,
  onChanged: (v) => setState(() => current = v),
  validateStep: (index) async => index == 0 && name.trim().length < 2 ? 'Enter at least two characters.' : null,
  onFinish: () async { setState(() => status = 'Saved: $name'); },
  contentBuilder: (context, index) => index == 0
    ? TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'Name'), onChanged: (v) => name = v)
    : Text('Review: $name')),
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
