# NgChart — Chart

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Visualize local series as column, bar, line, area, pie or donut charts.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgChart) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgChart)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Categories define the shared domain; every series must have the same number of nullable numeric values. Null breaks a line instead of becoming zero. Point selection returns NgChartSelection with zero-based series/point indices, their names, the number and a ready-to-use label. The application chooses what to do with a point. Keep units explicit. See [analytics and scheduling](../analytics-and-schedule.md) for mode-specific constraints; advanced axes, export, remote aggregation and broad chart-type parity are not implemented.

## Blazor example

```razor
<NgChart Title="Sales" Kind="NgChartKind.Line" Categories="categories" Series="series" OnPointSelected="p=>selected=p.Label"/>
<p>@selected</p>
@code { private string? selected; private string[] categories=["Mon","Tue","Wed"]; private NgChartSeries[] series=[new("Orders",[10,null,25])]; }
```

## Flutter example

```dart
String? selected;
Widget build(BuildContext context) => NgChart(title: 'Sales', kind: NgChartKind.line,
  categories: const ['Mon','Tue','Wed'], series: const [NgChartSeries('Orders',[10,null,25])],
  onPointSelected: (p) => setState(() => selected = p.label));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Title` | `string` | "Chart" | Heading for the section or dialog. |
| `Kind` | `NgChartKind` | NgChartKind.Column | See the behavior rules and model contract above. |
| `Categories` | `IReadOnlyList<string>` | [] | See the behavior rules and model contract above. |
| `Series` | `IReadOnlyList<NgChartSeries>` | [] | See the behavior rules and model contract above. |
| `OnPointSelected` | `EventCallback<NgChartSelection>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `title` | `String` | Heading for the section or dialog. |
| `kind` | `NgChartKind` | See the behavior rules and model contract above. |
| `categories` | `List<String>` | See the behavior rules and model contract above. |
| `series` | `List<NgChartSeries>` | See the behavior rules and model contract above. |
| `onPointSelected` | `ValueChanged<NgChartSelection>?` | See the behavior rules and model contract above. |

```dart
const NgChart({
    super.key,
    this.title = 'Chart',
    this.kind = NgChartKind.column,
    required this.categories,
    required this.series,
    this.onPointSelected,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgChart.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/visualization.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
