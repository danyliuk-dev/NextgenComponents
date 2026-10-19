# NgArcGauge — Arc gauge

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display a value within a numeric range.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgArcGauge) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgArcGauge)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Min must be less than Max; all numbers must be finite. Even finite bounds whose difference overflows are supported. Drawing clamps outside values; the displayed original value and Above maximum/Below minimum status preserve the supplied reading. Ranges/ranges accepts NgGaugeRange(From, To, Color, Label), lowercase fields in Flutter. Colors must be six-digit hex (#RRGGBB), labels nonblank, ranges inside the scale with From < To and no overlap. Input order is immaterial; validation sorts a copy. Gaps are allowed and use the theme primary color. Shared endpoints belong to the next range; Max belongs to the range ending at Max. Active color uses the clamped value. Stripes/arcs and a text legend show all ranges. ValueFormatter/valueFormatter formats current value, bounds and legend as plain text; Unit is appended only to the current value. Defaults preserve six significant digits, including fractional values. Replace lists when updating Flutter inputs. This is a read-only single-scale indicator; pointers, ticks, animation and export are not implemented.

## Blazor example

```razor
<div class="toolbar">
<NgButton OnClick="()=>value=42.5">Normal</NgButton>
<NgButton OnClick="()=>value=72.5">Elevated</NgButton>
<NgButton OnClick="()=>value=95">High</NgButton>
<NgButton OnClick="()=>value=125">Above maximum</NgButton>
<NgButton OnClick="()=>value=-10">Below minimum</NgButton>
<NgButton OnClick="()=>showRanges=!showRanges">Toggle ranges</NgButton>
</div>
<NgArcGauge Label="Load" Value="value" Ranges="@(showRanges?ranges:[])" ValueFormatter="Format"/>
@code {
 private double value=72.5;
 private bool showRanges=true;
 private string Format(double v)=>v.ToString("F1",System.Globalization.CultureInfo.InvariantCulture);
 private NgGaugeRange[] ranges=[new(0,60,"#187444","Normal"),new(60,85,"#b66d16","Elevated"),new(85,100,"#b42318","High")];
}
```

## Flutter example

```dart
double value = 72.5;
bool showRanges = true;
final ranges = const [NgGaugeRange(0,60,'#187444','Normal'), NgGaugeRange(60,85,'#b66d16','Elevated'), NgGaugeRange(85,100,'#b42318','High')];
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
 Wrap(spacing: 8, runSpacing: 8, children: [
  for (final entry in {'Normal':42.5, 'Elevated':72.5, 'High':95.0, 'Above maximum':125.0, 'Below minimum':-10.0}.entries)
   NgButton(onPressed:()=>setState(()=>value=entry.value), child:Text(entry.key)),
  NgButton(onPressed:()=>setState(()=>showRanges=!showRanges), child:const Text('Toggle ranges')),
 ]),
 const SizedBox(height:16),
 NgArcGauge(label:'Load',value:value,ranges:showRanges?ranges:const [],valueFormatter:(v)=>v.toStringAsFixed(1)),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Ranges` | `IReadOnlyList<NgGaugeRange>` | [] | See the behavior rules and model contract above. |
| `ValueFormatter` | `Func<double,string>?` | not set | See the behavior rules and model contract above. |
| `Label` | `string` | "Progress" | Visible label or accessible name. |
| `Value` | `double` | 0 | Current value; see state ownership and model rules above. |
| `Min` | `double` | 0 | Inclusive minimum. |
| `Max` | `double` | 100 | Inclusive maximum. |
| `Unit` | `string` | "%" | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `unit` | `String` | See the behavior rules and model contract above. |
| `value` | `double` | Current value; see state ownership and model rules above. |
| `min` | `double` | Inclusive minimum. |
| `max` | `double` | Inclusive maximum. |
| `ranges` | `List<NgGaugeRange>` | See the behavior rules and model contract above. |
| `valueFormatter` | `String Function(double)?` | See the behavior rules and model contract above. |

```dart
const NgArcGauge({
    super.key,
    this.label = 'Progress',
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '%',
    this.ranges = const [],
    this.valueFormatter,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgArcGauge.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/visualization.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
