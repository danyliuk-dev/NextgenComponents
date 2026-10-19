# NgPivotGrid — Pivot grid

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Aggregate records by row and column dimensions.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgPivotGrid) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgPivotGrid)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgPivotRecord contains a unique nonblank ID, string dimensions and one nullable finite numeric value. RowField/ColumnField must be nonblank. Raw dimension keys sort lexically; a missing key is the blank string. Sum/Average/Min/Max use numeric values; Count includes records with null values. Totals always aggregate original records, so an average is not an average of averages.

ShowRowTotals/showRowTotals controls the last column of per-row totals. ShowColumnTotals/showColumnTotals controls the bottom row of per-column totals. Both default true; the grand total is visible only when both are true. Visibility changes presentation, not aggregation. ValueFormatter/valueFormatter receives the nullable aggregate and returns plain text for visible and accessible values; null means no numeric result or overflow. RowLabel/rowLabel and ColumnLabel/columnLabel format raw keys, including the blank string, without changing sorting or callback keys. TotalText/totalText labels totals independently of ordinary keys; EmptyText/emptyText replaces the no-data message. These are plain-text formatters, not arbitrary widget/HTML templates.

SelectionReadOnly/selectionReadOnly blocks cell and total actions while keeping values readable. Missing callbacks also disable these actions. Input updates still work while locked. Stale callbacks after parent updates or disposal cannot emit old data. Cell callbacks contain original records in a read-only collection; null Row/Column denotes a total, while an empty string denotes a blank dimension. Replace input lists and dimension dictionaries instead of mutating them. This component emits drilldown requests and does not own current selection; the example retains Last drilldown as application history after data changes. Filter Items/items before passing them in. Multiple grouping levels, measures, OLAP, export, virtualization and a drag/drop configurator remain unimplemented.

## Blazor example

```razor
<div class="toolbar">
<NgButton OnClick="()=>rowTotals=!rowTotals">Toggle row totals</NgButton>
<NgButton OnClick="()=>columnTotals=!columnTotals">Toggle column totals</NgButton>
<NgButton OnClick="()=>locked=!locked">Toggle selection lock</NgButton>
<NgButton OnClick="()=>average=!average">Toggle average</NgButton>
<NgButton OnClick="()=>empty=!empty">Toggle empty data</NgButton>
<NgButton OnClick="()=>records=Data(2)">Update values</NgButton>
</div>
<p>Row totals @(rowTotals?"shown":"hidden") · Column totals @(columnTotals?"shown":"hidden") · Selection @(locked?"locked":"enabled")</p>
<NgPivotGrid Items="@(empty?[]:records)" Aggregate="@(average?NgAggregate.Average:NgAggregate.Sum)" ShowRowTotals="rowTotals" ShowColumnTotals="columnTotals" SelectionReadOnly="locked" ValueFormatter="Format" RowLabel="RowText" ColumnLabel="ColumnText" TotalText="All" EmptyText="No matching deliveries" OnCellSelected="Selected"/>
<p role="status">Last drilldown: @message</p>
@code {
 private bool rowTotals=true,columnTotals=true,locked,average,empty;
 private string message="none";
 private NgPivotRecord[] records=Data(1);
 private string Format(double? v)=>v.HasValue?v.Value.ToString("F1",System.Globalization.CultureInfo.InvariantCulture)+" credits":"No value";
 private string RowText(string v)=>v==""?"Unassigned":"Team "+v;
 private string ColumnText(string v)=>"Period "+v;
 private void Selected(NgPivotSelection p)=>message=$"{p.Row??"(total)"} / {p.Column??"(total)"} · {p.Records.Count} records · IDs: {string.Join(",",p.Records.Select(r=>r.Id))}";
 private static NgPivotRecord[] Data(int factor)=>[new("a",new Dictionary<string,string>{{"Team","A"},{"Quarter","Q1"}},10*factor),new("b",new Dictionary<string,string>{{"Team","A"},{"Quarter","Q1"}},30*factor),new("c",new Dictionary<string,string>{{"Team","B"},{"Quarter","Q2"}},90*factor),new("d",new Dictionary<string,string>{{"Team",""},{"Quarter","Q1"}},null)];
}
```

## Flutter example

```dart
bool rowTotals=true,columnTotals=true,locked=false,average=false,empty=false;
String message='none';
List<NgPivotRecord> records=data(1);
static List<NgPivotRecord> data(int factor)=>[NgPivotRecord('a',{'Team':'A','Quarter':'Q1'},10.0*factor),NgPivotRecord('b',{'Team':'A','Quarter':'Q1'},30.0*factor),NgPivotRecord('c',{'Team':'B','Quarter':'Q2'},90.0*factor),NgPivotRecord('d',{'Team':'','Quarter':'Q1'},null)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>rowTotals=!rowTotals),child:const Text('Toggle row totals')),
  NgButton(onPressed:()=>setState(()=>columnTotals=!columnTotals),child:const Text('Toggle column totals')),
  NgButton(onPressed:()=>setState(()=>locked=!locked),child:const Text('Toggle selection lock')),
  NgButton(onPressed:()=>setState(()=>average=!average),child:const Text('Toggle average')),
  NgButton(onPressed:()=>setState(()=>empty=!empty),child:const Text('Toggle empty data')),
  NgButton(onPressed:()=>setState(()=>records=data(2)),child:const Text('Update values')),
 ]),
 Text('Row totals ${rowTotals?"shown":"hidden"} · Column totals ${columnTotals?"shown":"hidden"} · Selection ${locked?"locked":"enabled"}'),
 NgPivotGrid(items:empty?const []:records,aggregate:average?NgAggregate.average:NgAggregate.sum,showRowTotals:rowTotals,showColumnTotals:columnTotals,selectionReadOnly:locked,
  valueFormatter:(v)=>v==null?'No value':'${v.toStringAsFixed(1)} credits',rowLabel:(v)=>v.isEmpty?'Unassigned':'Team $v',columnLabel:(v)=>'Period $v',totalText:'All',emptyText:'No matching deliveries',
  onCellSelected:(p)=>setState(()=>message='${p.row??"(total)"} / ${p.column??"(total)"} · ${p.records.length} records · IDs: ${p.records.map((r)=>r.id).join(",")}')),
 Text('Last drilldown: $message'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Pivot table" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgPivotRecord>` | [] | Input collection. Replace it when changing records or configuration. |
| `RowField` | `string` | "Team" | See the behavior rules and model contract above. |
| `ColumnField` | `string` | "Quarter" | See the behavior rules and model contract above. |
| `Aggregate` | `NgAggregate` | NgAggregate.Sum | See the behavior rules and model contract above. |
| `ShowRowTotals` | `bool` | true | See the behavior rules and model contract above. |
| `ShowColumnTotals` | `bool` | true | See the behavior rules and model contract above. |
| `SelectionReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `ValueFormatter` | `Func<double?,string>?` | not set | See the behavior rules and model contract above. |
| `RowLabel` | `Func<string,string>?` | not set | See the behavior rules and model contract above. |
| `ColumnLabel` | `Func<string,string>?` | not set | See the behavior rules and model contract above. |
| `TotalText` | `string` | "Total" | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No pivot data." | See the behavior rules and model contract above. |
| `OnCellSelected` | `EventCallback<NgPivotSelection>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `rowField` | `String` | See the behavior rules and model contract above. |
| `columnField` | `String` | See the behavior rules and model contract above. |
| `items` | `List<NgPivotRecord>` | Input collection. Replace it when changing records or configuration. |
| `aggregate` | `NgAggregate` | See the behavior rules and model contract above. |
| `showRowTotals` | `bool` | See the behavior rules and model contract above. |
| `showColumnTotals` | `bool` | See the behavior rules and model contract above. |
| `selectionReadOnly` | `bool` | See the behavior rules and model contract above. |
| `totalText` | `String` | See the behavior rules and model contract above. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `valueFormatter` | `String Function(double?)?` | See the behavior rules and model contract above. |
| `rowLabel` | `String Function(String)?` | See the behavior rules and model contract above. |
| `columnLabel` | `String Function(String)?` | See the behavior rules and model contract above. |
| `onCellSelected` | `ValueChanged<NgPivotSelection>?` | See the behavior rules and model contract above. |

```dart
const NgPivotGrid({
    super.key,
    this.label = 'Pivot table',
    required this.items,
    this.rowField = 'Team',
    this.columnField = 'Quarter',
    this.aggregate = NgAggregate.sum,
    this.onCellSelected,
    this.showRowTotals = true,
    this.showColumnTotals = true,
    this.selectionReadOnly = false,
    this.totalText = 'Total',
    this.emptyText = 'No pivot data.',
    this.valueFormatter,
    this.rowLabel,
    this.columnLabel,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgPivotGrid.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/workbook.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
