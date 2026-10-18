# NgSpreadsheet — Spreadsheet

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a small local worksheet with formulas and undo/redo.

## Behavior and practical rules

Select a cell, edit Cell value or formula, then press Apply cell or Enter. Arrow keys move selection. NgSheet is immutable; save the entire new sheet from the callback. Undo/Redo keeps up to 50 operations; an independent parent Value replacement clears local history. ReadOnly disables edits. Paste cells accepts rectangular TSV from the selected address, preserves formula text literally and rejects an out-of-bounds paste as a whole. Limits: 1–100 rows, 1–26 columns, 1,000 characters per cell. See [models and formulas](models.md) for operators/functions/errors. One sheet only: no XLSX/CSV files, formatting, merges, relative formula adjustment or multi-sheet workbook.

## Blazor example

```razor
<NgSpreadsheet @bind-Value="sheet"/>
@code { private NgSheet sheet=new(8,5,new Dictionary<string,string>{{"A1","10"},{"B1","20"},{"C1","=SUM(A1:B1)"}}); }
```

## Flutter example

```dart
NgSheet sheet = NgSheet(rows: 8, columns: 5, cells: {'A1':'10','B1':'20','C1':'=SUM(A1:B1)'});
Widget build(BuildContext context) => NgSpreadsheet(value: sheet,
  onChanged: (v) => setState(() => sheet = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Spreadsheet" | Visible label or accessible name. |
| `Value` | `NgSheet` | required | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<NgSheet>` | not set | New value for the parent to store and pass back. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgSheet` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<NgSheet>?` | Store the new value using setState or your state manager. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |

```dart
const NgSpreadsheet({
    super.key,
    this.label = 'Spreadsheet',
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgSpreadsheet.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/workbook.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
