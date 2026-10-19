# NgChart — Chart

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Visualize local series as column, bar, line, area, pie or donut charts.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgChart) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgChart)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Categories define the shared domain; every series must have the same number of nullable numeric values. Null breaks a line instead of becoming zero. Point selection returns NgChartSelection with zero-based series/point indices, their names, the number and a ready-to-use label. The application chooses what to do with a point. Keep units explicit. See [analytics and scheduling](../analytics-and-schedule.md) for mode-specific constraints; advanced axes, export, remote aggregation and broad chart-type parity are not implemented. HiddenSeries/hiddenSeries is optional: null keeps internal legend state, a set enables controlled visibility. HiddenSeriesChanged/onHiddenSeriesChanged proposes a fresh set; the parent must accept it. A controlled set without a callback is noninteractive. Unknown indices are ignored by drawing and retained in controlled proposals; the parent owns pruning and reordering. Series identity is its zero-based index. Keep the same ownership mode for the lifetime of a chart; returning to internal mode resumes its prior internal state. LegendReadOnly/legendReadOnly freezes user legend changes, while SelectionReadOnly/selectionReadOnly blocks point actions without hiding their data or tooltips. Programmatic visibility updates still work. PointLabel/pointLabel returns plain text for tooltips, point actions, accessible names and selected-point status; it does not change numeric values or axes. EmptyText/emptyText customizes the empty chart message. Selection survives equivalent data replacement, but clears when the selected point is hidden, removed, renamed or changes value, or when data becomes invalid. Invalid data recovery does not restore stale selection. Captured point callbacks are rejected if they no longer match a visible current point. This is chart-owned selection, not a controlled selection API.

## Blazor example

```razor
<div class="row"><NgCheckBox Label="Selection read-only" @bind-Value="readOnly"/><NgCheckBox Label="Legend read-only" @bind-Value="legendReadOnly"/><NgCheckBox Label="Accept legend changes" @bind-Value="accept"/></div>
<NgButton OnClick="()=>hidden=[]">Show all series</NgButton><NgButton OnClick="()=>revised=!revised">Update values</NgButton><NgButton OnClick="()=>invalid=!invalid">Toggle invalid data</NgButton>
<NgChart Title="Weekly orders" Kind="NgChartKind.Column" Categories="categories" Series="Series" HiddenSeries="hidden" HiddenSeriesChanged="ChangeHidden" SelectionReadOnly="readOnly" LegendReadOnly="legendReadOnly" PointLabel="Label" EmptyText="All series hidden." OnPointSelected="p=>last=Label(p)"/>
<p>Last callback: @last</p>
@code {
 private bool readOnly,legendReadOnly,revised,invalid; private bool accept=true;
 private HashSet<int> hidden=[]; private string last="none";
 private string[] categories=["Mon","Tue","Wed"];
 private NgChartSeries[] Series=>invalid?[new("Orders",[1])]:[new("Orders",[revised?40:10,20,25]),new("Target",[15,25,30])];
 private void ChangeHidden(HashSet<int> value){if(accept)hidden=value;}
 private static string Label(NgChartSelection p)=>$"{p.Series} / {p.Category}: {p.Value:0} orders";
}
```

## Flutter example

```dart
bool readOnly=false, legendReadOnly=false, revised=false, invalid=false, accept=true;
Set<int> hidden={}; String last='none';
String pointText(NgChartSelection p) => '${p.series} / ${p.category}: ${p.value.toStringAsFixed(0)} orders';
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  NgCheckBox(label: 'Selection read-only', value: readOnly, onChanged: (v)=>setState(()=>readOnly=v)),
  NgCheckBox(label: 'Legend read-only', value: legendReadOnly, onChanged: (v)=>setState(()=>legendReadOnly=v)),
  NgCheckBox(label: 'Accept legend changes', value: accept, onChanged: (v)=>setState(()=>accept=v)),
  Wrap(spacing: 8, runSpacing: 8, children: [
    NgButton(onPressed: ()=>setState(()=>hidden={}), child: const Text('Show all series')),
    NgButton(onPressed: ()=>setState(()=>revised=!revised), child: const Text('Update values')),
    NgButton(onPressed: ()=>setState(()=>invalid=!invalid), child: const Text('Toggle invalid data')),
  ]),
  NgChart(title: 'Weekly orders', categories: const ['Mon','Tue','Wed'],
    series: invalid ? const [NgChartSeries('Orders',[1])] : [NgChartSeries('Orders',[revised?40:10,20,25]), const NgChartSeries('Target',[15,25,30])],
    hiddenSeries: hidden, onHiddenSeriesChanged: (v){if(accept)setState(()=>hidden=v);},
    selectionReadOnly: readOnly, legendReadOnly: legendReadOnly, pointLabel: pointText,
    emptyText: 'All series hidden.', onPointSelected: (p)=>setState(()=>last=pointText(p))),
  Text('Last callback: $last'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `HiddenSeries` | `HashSet<int>?` | not set | See the behavior rules and model contract above. |
| `HiddenSeriesChanged` | `EventCallback<HashSet<int>>` | not set | See the behavior rules and model contract above. |
| `LegendReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `PointLabel` | `Func<NgChartSelection,string>?` | not set | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No chart data." | See the behavior rules and model contract above. |
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
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `hiddenSeries` | `Set<int>?` | See the behavior rules and model contract above. |
| `onHiddenSeriesChanged` | `ValueChanged<Set<int>>?` | See the behavior rules and model contract above. |
| `legendReadOnly` | `bool` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `pointLabel` | `String Function(NgChartSelection)?` | See the behavior rules and model contract above. |
| `kind` | `NgChartKind` | See the behavior rules and model contract above. |
| `categories` | `List<String>` | See the behavior rules and model contract above. |
| `series` | `List<NgChartSeries>` | See the behavior rules and model contract above. |
| `onPointSelected` | `ValueChanged<NgChartSelection>?` | See the behavior rules and model contract above. |

```dart
const NgChart({
    super.key,
    this.title = 'Chart',
    this.emptyText = 'No chart data.',
    this.hiddenSeries,
    this.onHiddenSeriesChanged,
    this.legendReadOnly = false,
    this.selectionReadOnly = false,
    this.pointLabel,
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
