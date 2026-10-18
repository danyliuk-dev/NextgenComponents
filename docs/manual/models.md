# Data models and formulas

[Manual](README.md) · [Code examples](code-examples.md)

## Shared models

C# properties generally use PascalCase; Dart uses lowerCamelCase. Replace input collections when changing data.

| Model | Contract |
|---|---|
| NgSelectionRules | Validates ButtonGroup options and selected IDs; Toggle returns a new selection in item order. See [ButtonGroup](NgButtonGroup.md). |
| NgMenuItem | ID, text, disabled and read-only children; max 3 levels / 100 nodes. See [Menu](NgMenu.md). |
| NgStep | Label, Disabled, Optional and nullable Valid; see [Stepper](NgStepper.md) and [Wizard](NgWizard.md). |
| NgPromptResponse | Immutable Id, Prompt, Text; IDs increase within a session. |
| NgPromptFeedback | Response and Helpful: true, false or null to clear a vote. |
| NgPromptSession | Request state and the latest 20 responses; cancellation rejects late results. See [AI Prompt](NgAIPrompt.md). |
| NgOption | Unique key, label, disabled flag. C#: new NgOption(value,label,disabled); Dart: NgOption(value,label,disabled:true). |
| NgTab | Label and RenderFragment (Blazor) or Widget (Flutter) content. |
| NgDateRange | Nullable start/end: DateOnly in Blazor, DateTime in Flutter. Form rules determine whether a partial range can be submitted. |
| NgDataColumn<T> | Key, Title, typed Value accessor, Format and Template/cellBuilder. Sort underlying values, not formatted text. |
| NgTreeNode<T> | Unique Id, Item, Children, Disabled; no cycles. |
| NgBreadcrumbItem | ID and label; the final item is the current location. |
| NgChartSeries | Name and nullable numbers matching category count; null breaks a line. |
| NgChartSelection | Zero-based series/point indices, names, numeric value and display label. |
| NgScheduleEvent | Unique Id, nonempty Title, Start and End with End > Start. |
| NgSheet | Immutable single-sheet dimensions and address-to-raw-text dictionary. |
| NgCellValue | Text, nullable Number and nullable Error code. |
| NgPivotRecord | Unique ID, string dimensions and one nullable numeric measure. |
| NgPivotSelection | Row/column dimensions and source records; null identifies a total, empty string a blank dimension. |

## NgSheet

Addresses A1–Z100 are case-insensitive. A sheet has 1–100 rows and 1–26 columns. Each cell contains up to 1,000 characters; an absent in-bounds address is empty.

```csharp
var sheet = new NgSheet(8, 5, new Dictionary<string,string> {
    ["A1"] = "10", ["B1"] = "=A1*2"
});
var next = sheet.Set("A1", "25");
var raw = next.Raw("B1");             // =A1*2
var result = next.Evaluate("B1");     // Number = 50
var pasted = next.Paste("A2", "3\t4\n=SUM(A2:B2)");
```

```dart
final sheet = NgSheet(rows: 8, columns: 5,
  cells: {'A1':'10', 'B1':'=A1*2'});
final next = sheet.set('A1','25');
final raw = next.raw('B1');           // =A1*2
final result = next.evaluate('B1');  // number = 50
final pasted = next.paste('A2','3\t4\n=SUM(A2:B2)');
```

Set and Paste return a new sheet. Rectangular TSV paste preserves formula references literally: `=A1` remains `=A1`. Out-of-bounds or oversized cells reject the whole operation. This is text paste, not XLSX/CSV import.

## Formula language

Formulas start with `=`. Supported syntax: dot-decimal/exponent numbers, `+ - * /`, unary signs, parentheses, cell references, ranges in function arguments and the functions below. Precedence is parentheses/unary, multiplication/division, addition/subtraction. Names and addresses are case-insensitive; arguments use commas.

| Formula | Meaning |
|---|---|
| `=2+3*4` | 14 |
| `=(2+3)*4` | 20 |
| `=A1*B1` | Multiply numeric cells |
| `=SUM(A1:A5)` | Sum numbers, ignoring text/empty cells |
| `=AVERAGE(A1:A5)` | Mean of numbers; no numbers produces #DIV/0! |
| `=MIN(A1:A5)` / `=MAX(A1:A5)` | Extremum; an empty range returns 0 |
| `=COUNT(A1:A5)` | Count numeric cells |
| `=SUM(A1:B2,10)` | Sum a rectangle and 10 |

An empty direct reference evaluates to 0 in arithmetic; text produces #VALUE!. Range arguments skip text/empty cells. Scalar arguments evaluate expressions: COUNT(A1) counts computed zero for empty A1, while COUNT(A1:A1) skips it. This is a limited language, not full Excel semantics. No string/logical formulas, IF, dates, sheet/absolute references, named ranges or external code.

| Error | Cause |
|---|---|
| #FORMULA! | Invalid syntax/operators/parentheses/separators |
| #NAME? | Unsupported function |
| #REF! | Invalid or out-of-bounds address |
| #VALUE! | Text used as a number |
| #DIV/0! | Division by zero or average of no numbers |
| #CYCLE! | Direct/indirect circular reference |
| #NUM! | Nonfinite result/overflow |
| #LIMIT! | More than 64 expression levels or 100 dependent cells along a path |

Errors propagate. Dependencies are cached within an evaluation. Numbers use double floating point; exact decimal financial rules need a separate business layer. Raw text is stored separately from G10/10-significant-digit display.

## Pivot totals

Sum/Average/Min/Max ignore null; no numbers displays `—`. Count includes records with null values. Totals aggregate original values: groups 10/20 and 90 produce Average 40, not (15+90)/2. NaN/Infinity and duplicate IDs are rejected. Missing dimensions equal an empty string. Selecting a total returns matching source records, or all records for the grand total. Aggregate overflow yields null displayed as `—`; normalize input if this must be distinguished from missing data.

## NgDocument

Immutable Blocks contain Text, Kind, Bold, Italic, Underline and Align. Kinds: paragraph, heading1, heading2, bullet, numbered, quote. Alignment: left, center, right; C# enum names use PascalCase.

Replace(index,block), InsertAfter(index), Remove(index) and Move(index,target) return a new document, using zero-based indices. Removing the last block leaves one empty paragraph. Invalid indices/limits leave the original unchanged. Update a block with C# `block with { Text = "New text" }` or Dart `block.copyWith(text: 'New text')`.

ToJson/fromJson interchange:

```json
{"version":1,"blocks":[{"text":"Title","kind":"heading1","bold":false,"italic":false,"underline":false,"align":"left"}]}
```

Version and blocks are required; unknown fields are rejected. Missing optional block fields use empty-paragraph defaults; null text/type/flags are invalid. Use exact camelCase enum names. Limits: 100 blocks, 10,000 UTF-16 units per block, 100,000 total, 1,000,000 input JSON units. CRLF/CR normalize to LF. HTML remains text and ToHtml escapes it. See [Editor](NgEditor.md) for draft/history rules.

## NgDiagramModel

Immutable Nodes/Edges describe ID/text/geometry/shapes and ID/from/to/text/directed connections. Coordinates identify the top-left corner and are independent of zoom.

```json
{"version":1,"width":1000,"height":600,"nodes":[{"id":"a","text":"Start","x":40,"y":100,"width":160,"height":80,"shape":"ellipse"},{"id":"b","text":"Step","x":360,"y":100,"width":160,"height":80,"shape":"rectangle"}],"edges":[{"id":"next","from":"a","to":"b","text":"Next","directed":true}]}
```

Required JSON fields: version/width/height/nodes/edges; nodes require id/text/x/y; edges require id/from/to. Omitted optional fields use constructor defaults. Unknown fields, invalid types/enums/IDs/geometry and JSON over 1,000,000 UTF-16 units are rejected. Empty arrays are allowed. Use the exported camelCase schema.

UpsertNode/UpsertEdge/RemoveNode/RemoveEdge/Move return a validated new graph. Canvas: 200–5000 per dimension; nodes: 60–400 × 40–240, inside the canvas. At most 100 nodes/200 edges, IDs at most 64 ASCII characters, labels at most 100 UTF-16 units. Move clamps coordinates; UpsertNode rejects out-of-bounds geometry. RemoveNode removes incident edges. See [Diagram](NgDiagram.md) for interactions and limitations.

## Geographic models

NgMapPoint stores latitude/longitude; NgMapView adds zoom. NgMapMarker contains ID/text/position. NgMapPath contains ID/text/copied points and a closed-polygon flag. NgMapModel copies collections and validates shared IDs and bounds. See [Map](NgMap.md) for limits, signatures, clustering and update examples.

## ChipList application records

`NgChipData<T>` maps your records to a read-only list of `NgOption` values. Required selectors provide the stable ID and accessible text; optional selectors provide disabled state, removal permission and `NgChipAppearance`. Pass these mappings explicitly to ChipList. Resolve the original record with `GetItem(id)` (Blazor) or `getItem(id)` (Flutter) in event handlers or templates.

This is a snapshot of mapped fields, not a deep copy of application records. Rebuild after edits or collection changes and update selected IDs together with removed records. Unknown lookup IDs throw; malformed mappings fail during construction. See [ChipList](NgChipList.md) for complete, compiled examples on both platforms.
