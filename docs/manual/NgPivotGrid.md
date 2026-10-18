# NgPivotGrid — Pivot grid

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Aggregate records by row and column dimensions.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgPivotGrid) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgPivotGrid)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgPivotRecord contains a unique ID, string dimensions and one nullable numeric value. Dimensions sort by string keys; a missing key appears as (blank). Sum/Average/Min/Max use numeric values; Count includes source records with null values. Totals are recalculated from source records, so an average is not an average of averages. Cell/total callbacks return the original records; null Row/Column denotes a total, while an empty string denotes a blank dimension. Filter Items/items before passing them in. Multiple grouping levels, measures, OLAP and a drag/drop configurator are not implemented.

## Blazor example

```razor
<NgPivotGrid Items="records" RowField="Team" ColumnField="Quarter" Aggregate="NgAggregate.Average" OnCellSelected="p=>count=p.Records.Count"/>
<p>Source records: @count</p>
@code { private int count; private NgPivotRecord[] records=[new("a",new Dictionary<string,string>{{"Team","Design"},{"Quarter","Q1"}},100),new("b",new Dictionary<string,string>{{"Team","Design"},{"Quarter","Q1"}},200)]; }
```

## Flutter example

```dart
int count = 0;
Widget build(BuildContext context) => NgPivotGrid(rowField: 'Team', columnField: 'Quarter',
  aggregate: NgAggregate.average, items: [
    NgPivotRecord('a', {'Team':'Design','Quarter':'Q1'},100),
    NgPivotRecord('b', {'Team':'Design','Quarter':'Q1'},200)],
  onCellSelected: (p) => setState(() => count = p.records.length));
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
