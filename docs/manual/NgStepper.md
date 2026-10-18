# NgStepper — Step progress

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display progress through a sequence and request a different active step.

## Behavior and practical rules

Items/items contains 1–30 NgStep values. Labels must contain 1–120 UTF-16 units and cannot be whitespace-only. Value/value is a zero-based enabled index. Invalid configuration throws ArgumentException/ArgumentError instead of silently selecting another step. Replace lists when updating them.

NgStep contains Label/label, Disabled/disabled, Optional/optional and nullable Valid/valid. Optional is an annotation, not an automatic skip. Valid is presentation only: true shows a check mark, false shows Needs attention, null shows the step number. It never performs validation. Disabled steps cannot be selected. NgStepRules.Adjacent/adjacent finds the next enabled index in direction -1 or 1, returning -1 at the boundary.

Without Linear/linear, any enabled step can be selected. Linear permits any earlier enabled step or the next enabled step, skipping disabled entries. It does not remember the furthest visited step. Clicking the current step does nothing. Store ValueChanged/onChanged in the parent; without updating Value the active marker stays unchanged. Disabled disables all interaction. Vertical stacks the steps; horizontal layout wraps on narrow screens.

Use Tab to reach enabled buttons and Enter/Space to activate them. Blazor marks the current step with aria-current=step; Flutter exposes selected semantics. Arrow-key roving focus and full screen-reader certification are not implemented. Use NgWizard to add content, validation and finish actions; this component itself does not mount pages, validate fields or save data.

## Blazor example

```razor
<NgStepper Items="steps" @bind-Value="current" Linear />
<p>Current index: @current</p>
@code {
 private int current;
 private NgStep[] steps=[new("Contact"),new("Preferences",Optional:true),new("Review")];
}
```

## Flutter example

```dart
int current = 0;
final steps = const [NgStep('Contact'), NgStep('Preferences', optional: true), NgStep('Review')];
Widget build(BuildContext context) => NgStepper(items: steps, value: current, linear: true,
  onChanged: (v) => setState(() => current = v));
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
| `Vertical` | `bool` | false | Stack step headers vertically instead of wrapping them horizontally. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgStep>` | Input collection. Replace it when changing records or configuration. |
| `value` | `int` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<int>?` | Store the new value using setState or your state manager. |
| `linear` | `bool` | Restrict forward navigation to the next enabled step; earlier steps remain accessible. |
| `vertical` | `bool` | Stack step headers vertically instead of wrapping them horizontally. |
| `disabled` | `bool` | Disable user interaction. |

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
