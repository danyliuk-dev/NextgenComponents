# NgStepper — Step progress

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display progress through a sequence and request a different active step.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgStepper) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgStepper)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### State and display

Value/value is a zero-based, enabled index owned by the parent. ValueChanged/onChanged requests a new index; selecting the current step does nothing. A missing callback or Disabled/disabled disables navigation. Linear/linear defaults to false: when enabled, allow earlier enabled steps or the next enabled step; disabled steps are skipped. Optional and Valid are display metadata, not automatic validation or a skip command. Use 1–30 steps with nonempty labels of at most 120 UTF-16 units.

DisplayMode/displayMode is `all` (default), `labels` or `indicators`. Vertical/vertical controls orientation; horizontal steps wrap. Rtl/rtl defaults to false and mirrors the layout. IndicatorTemplate/indicatorBuilder and LabelTemplate/labelBuilder receive NgStepContext with the step, zero-based index and current-state flag. They replace display content only. Do not put interactive/focusable controls inside either template.

### Accessibility and integration

The accessible name retains the step number, model label, optional and validity state even in indicators-only mode or with custom templates. Blazor exposes aria-current=step; Flutter exposes selected semantics. Every enabled step remains a native Tab stop with Enter/Space activation; arrow-key roving focus and automatic focus movement are not implemented. To reject asynchronous transitions, use Wizard BeforeChange or handle the controlled callback in the application. Replace the item collection when changing metadata. Display mode and templates use an original API; no Telerik theme or declarative-child compatibility is implied.

## Blazor example

```razor
<NgCheckBox Label="Right-to-left" @bind-Value="rtl"/>
<NgDropDownList Label="Step display" Items="modes" @bind-Value="mode"/>
<NgStepper Label="Publishing progress" Items="steps" @bind-Value="current" Rtl="rtl" DisplayMode="@mode">
  <IndicatorTemplate Context="step"><span>@(step.Current?"★":"○")</span></IndicatorTemplate>
  <LabelTemplate Context="step"><strong>@step.Step.Label</strong></LabelTemplate>
</NgStepper>
<p>Selected step: @(current+1)</p>
@code {
  private int current; private bool rtl; private string mode="all";
  private readonly NgStep[] steps=[new("Draft",Valid:true),new("Details",Optional:true,Valid:false),new("Publish")];
  private readonly NgOption[] modes=[new("all","Indicators and labels"),new("labels","Labels only"),new("indicators","Indicators only")];
}

```

## Flutter example

```dart
int current = 0; bool rtl = false; String mode = 'all';
final steps = const [NgStep('Draft',valid:true),NgStep('Details',optional:true,valid:false),NgStep('Publish')];
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  DropdownButtonFormField<String>(initialValue:mode,decoration:const InputDecoration(labelText:'Step display'),
    items:const [DropdownMenuItem(value:'all',child:Text('Indicators and labels')),DropdownMenuItem(value:'labels',child:Text('Labels only')),DropdownMenuItem(value:'indicators',child:Text('Indicators only'))],
    onChanged:(v)=>setState(()=>mode=v!)),
  const SizedBox(height:16),
  NgStepper(label:'Publishing progress',items:steps,value:current,onChanged:(v)=>setState(()=>current=v),rtl:rtl,displayMode:mode,
    indicatorBuilder:(_,step)=>Icon(step.current?Icons.star:Icons.circle_outlined,size:20),
    labelBuilder:(_,step)=>Text(step.step.label,style:const TextStyle(fontWeight:FontWeight.bold))),
  Text('Selected step: ${current+1}'),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Progress" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgStep>` | required | Input collection. Replace it when changing records or configuration. |
| `Value` | `int` | 0 | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<int>` | not set | New value for the parent to store and pass back. |
| `Linear` | `bool` | false | Restrict forward navigation to the next enabled step; earlier steps remain accessible. |
| `Vertical` | `bool` | false | Use a vertical root layout; see the component keyboard and layout rules. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Rtl` | `bool` | false | See the behavior rules and model contract above. |
| `DisplayMode` | `string` | "all" | See the behavior rules and model contract above. |
| `IndicatorTemplate` | `RenderFragment<NgStepContext>?` | not set | See the behavior rules and model contract above. |
| `LabelTemplate` | `RenderFragment<NgStepContext>?` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `displayMode` | `String` | See the behavior rules and model contract above. |
| `items` | `List<NgStep>` | Input collection. Replace it when changing records or configuration. |
| `value` | `int` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<int>?` | Store the new value using setState or your state manager. |
| `linear` | `bool` | Restrict forward navigation to the next enabled step; earlier steps remain accessible. |
| `vertical` | `bool` | Use a vertical root layout; see the component keyboard and layout rules. |
| `disabled` | `bool` | Disable user interaction. |
| `rtl` | `bool` | See the behavior rules and model contract above. |
| `indicatorBuilder` | `Widget Function(BuildContext, NgStepContext)?` | See the behavior rules and model contract above. |
| `labelBuilder` | `Widget Function(BuildContext, NgStepContext)?` | See the behavior rules and model contract above. |

```dart
const NgStepper({
    super.key,
    this.label = 'Progress',
    required this.items,
    this.value = 0,
    this.onChanged,
    this.linear = false,
    this.vertical = false,
    this.disabled = false,
    this.rtl = false,
    this.displayMode = 'all',
    this.indicatorBuilder,
    this.labelBuilder,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgStepper.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/steps.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
