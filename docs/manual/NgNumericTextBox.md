# NgNumericTextBox — Numeric input

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit bounded numbers with explicit increment controls, retained invalid drafts and read-only review.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgNumericTextBox) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgNumericTextBox)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Value/value is nullable and controlled by the parent. Blazor uses decimal; Flutter uses finite double, so binary floating-point rounding can appear. Use a dot decimal separator and optional leading sign. Grouping separators, exponent notation, NaN and infinity are rejected. Empty input emits null (Flutter required can reject it; Blazor use model validation attributes).

Min/min and Max/max are inclusive edit constraints. Invalid or out-of-range drafts remain visible, do not replace the last valid model and block form validation. Bounds must be ordered; Step/step must be positive (and finite in Flutter). These constraints validate user edits, not arbitrary values supplied by the parent; validate application models independently.

ShowSpinButtons/showSpinButtons defaults to true. Increase and Decrease add/subtract Step from the last valid model, using zero for null, then clamp to bounds. A spin deliberately replaces an invalid draft. Step does not restrict typed decimal precision or require multiples. Blazor also handles ArrowUp/ArrowDown; Flutter exposes labelled focusable buttons. Native browser number controls are replaced by a text editor so invalid drafts are preserved consistently.

ReadOnly/readOnly permits copying but blocks editing and spin actions; Disabled/enabled=false blocks interaction. Missing change callbacks disable spin buttons. HelperText/helperText explains the field. Flutter replaces the draft when the parent supplies a changed value. In Blazor, InputBase retains parsing-failed text until correction. Use a new component key to discard an invalid draft reliably on either platform.

Currency/percent formats, custom culture, precision rounding, acceleration and full screen-reader certification remain out of scope.

## Blazor example

```razor
<NgForm Model="model" OnValidSubmit="Save">
<NgNumericTextBox Label="Amount" @bind-Value="model.Amount" Min="0" Max="10" Step="0.5m" ReadOnly="readOnly" HelperText="0 to 10; buttons change by 0.5." />
<NgButton Type="submit" Primary>Save amount</NgButton>
</NgForm>
<NgButton OnClick="Toggle">Read only</NgButton>
<p>Accepted amount: @model.Amount</p><p>@status</p>
@code {
 private Draft model=new(); private bool readOnly; private string status="";
 private void Toggle()=>readOnly=!readOnly;
 private void Save()=>status="Saved amount: "+model.Amount;
 private sealed class Draft { public decimal? Amount {get;set;}=2; }
}
```

## Flutter example

```dart
double? amount=2; bool readOnly=false; String status='';
@override
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 NgForm(submitLabel:'Save amount',onValidSubmit:()=>setState(()=>status='Saved amount: $amount'),child:
  NgNumericTextBox(label:'Amount',value:amount,min:0,max:10,step:0.5,readOnly:readOnly,
   helperText:'0 to 10; buttons change by 0.5.',onChanged:(v)=>setState(()=>amount=v))),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted amount: $amount'),Text(status),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Number" | Visible label or accessible name. |
| `Min` | `decimal?` | not set | Inclusive minimum. |
| `Max` | `decimal?` | not set | Inclusive maximum. |
| `Step` | `decimal` | 1 | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `ShowSpinButtons` | `bool` | true | See the behavior rules and model contract above. |
| `HelperText` | `string?` | not set | See the behavior rules and model contract above. |
| `Value` | `decimal?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<decimal?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<decimal?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `double?` | Current value; see state ownership and model rules above. |
| `min` | `double?` | Inclusive minimum. |
| `max` | `double?` | Inclusive maximum. |
| `onChanged` | `ValueChanged<double?>?` | Store the new value using setState or your state manager. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `showSpinButtons` | `bool` | See the behavior rules and model contract above. |
| `step` | `double` | See the behavior rules and model contract above. |
| `helperText` | `String?` | See the behavior rules and model contract above. |

```dart
const NgNumericTextBox({
    super.key,
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.showSpinButtons = true,
    this.step = 1,
    this.helperText,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgNumericTextBox.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
