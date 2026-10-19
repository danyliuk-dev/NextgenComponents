# NgSpreadsheet — Spreadsheet

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a small local worksheet with formulas and undo/redo.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgSpreadsheet) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgSpreadsheet)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Value/value is controlled. Apply, paste, Undo and Redo propose an immutable NgSheet through ValueChanged/onChanged; display and history change only when the parent returns that exact instance on its next parameter update. Rejection keeps the accepted sheet, history and typed formula draft. A different external replacement clears history and reloads the draft; an out-of-bounds selection resets to A1. No-op edits produce no callback or history entry. Protection applies to user actions; the parent can still replace the whole sheet programmatically. Without a callback, editing is disabled. ReadOnly/readOnly blocks all changes but permits selection and formula inspection. CanEdit/canEdit is a pure predicate receiving uppercase addresses such as A1; false protects the cell, displays a Protected marker and locks its formula input. Protected cells still recalculate when their dependencies change. Paste checks every supplied destination, including unchanged values: any protected or out-of-bounds destination rejects the entire block. TSV rows may have different widths; only supplied cells are targeted. Formulas remain literal, without relative-reference adjustment. Undo/Redo keep up to 50 accepted operations and check current protection for every raw cell value they would change. Changing protection never clears history; lifting protection re-enables eligible history operations. Captured actions cannot modify a replaced sheet or bypass a new lock; callbacks after disposal are ignored. NgSheet.Paste/paste also accepts an optional canEdit predicate for model-level atomic validation; ChangedCells/changedCells compares raw values of equal-sized sheets. Limits: 1–100 rows, 1–26 columns and 1,000 characters per cell. See [models and formulas](models.md) for formula syntax. Single sheet only: no XLSX/CSV, formatting, merges, multi-cell selection, clipboard integration or multi-sheet workbook.

## Blazor example

```razor
<div class="toolbar">
<NgButton OnClick="()=>protect=!protect">Toggle protection</NgButton>
<NgButton OnClick="()=>lockA1=!lockA1">Toggle A1 lock</NgButton>
<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>
<NgButton OnClick="()=>readOnly=!readOnly">Toggle read-only</NgButton>
<NgButton OnClick="()=>sheet=Initial()">Reset sheet</NgButton>
<NgButton OnClick="()=>sheet=new(1,1)">Shrink sheet</NgButton>
</div>
<p>Protection @(protect?"enabled":"disabled") · A1 @(lockA1?"locked":"editable") · Changes @(accept?"accepted":"rejected")</p>
<NgSpreadsheet Value="sheet" ValueChanged="Changed" CanEdit="Editable" ReadOnly="readOnly"/>
<p>Accepted A1: @sheet.Raw("A1") · Proposals: @proposals</p>
@code {
 private NgSheet sheet=Initial();
 private bool protect=true,lockA1,readOnly,accept=true;
 private int proposals;
 private bool Editable(string a)=>(!protect||!a.StartsWith("C"))&&(!lockA1||a!="A1");
 private void Changed(NgSheet next){proposals++;if(accept)sheet=next;}
 private static NgSheet Initial()=>new(4,4,new Dictionary<string,string>{{"A1","10"},{"B1","20"},{"C1","=SUM(A1:B1)"}});
}
```

## Flutter example

```dart
NgSheet sheet=initial();
bool protect=true,lockA1=false,readOnly=false,accept=true;
int proposals=0;
static NgSheet initial()=>NgSheet(rows:4,columns:4,cells:{'A1':'10','B1':'20','C1':'=SUM(A1:B1)'});
bool editable(String a)=>(!protect||!a.startsWith('C'))&&(!lockA1||a!='A1');
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>protect=!protect),child:const Text('Toggle protection')),
  NgButton(onPressed:()=>setState(()=>lockA1=!lockA1),child:const Text('Toggle A1 lock')),
  NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
  NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle read-only')),
  NgButton(onPressed:()=>setState(()=>sheet=initial()),child:const Text('Reset sheet')),
  NgButton(onPressed:()=>setState(()=>sheet=NgSheet(rows:1,columns:1)),child:const Text('Shrink sheet')),
 ]),
 Text('Protection ${protect?"enabled":"disabled"} · A1 ${lockA1?"locked":"editable"} · Changes ${accept?"accepted":"rejected"}'),
 NgSpreadsheet(value:sheet,canEdit:editable,readOnly:readOnly,onChanged:(v)=>setState((){proposals++;if(accept)sheet=v;})),
 Text('Accepted A1: ${sheet.raw("A1")} · Proposals: $proposals'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Spreadsheet" | Visible label or accessible name. |
| `Value` | `NgSheet` | required | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<NgSheet>` | not set | New value for the parent to store and pass back. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `CanEdit` | `Func<string,bool>?` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgSheet` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<NgSheet>?` | Store the new value using setState or your state manager. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `canEdit` | `bool Function(String)?` | See the behavior rules and model contract above. |

```dart
const NgSpreadsheet({
    super.key,
    this.label = 'Spreadsheet',
    required this.value,
    this.onChanged,
    this.readOnly = false,
    this.canEdit,
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
