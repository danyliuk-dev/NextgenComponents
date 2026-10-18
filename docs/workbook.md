# Workbook (0.5)

Two new controls on both platforms: `NgSpreadsheet` and `NgPivotGrid`. Total: **33 public controls / 39 catalogue entries**. Full user manual: [Spreadsheet](manual/NgSpreadsheet.md), [PivotGrid](manual/NgPivotGrid.md), [formulas and data models](manual/models.md).

Reference audit: [Telerik Spreadsheet](https://www.telerik.com/blazor-ui/spreadsheet) and [Telerik PivotGrid](https://www.telerik.com/blazor-ui/pivotgrid). The implementation is original and bounded; these products have broader capabilities.

| Area | Implemented | Remaining |
|---|---|---|
| Spreadsheet | Immutable single sheet; named cells; formula bar; selection and arrows; Apply/Enter; 50-operation undo/redo; read-only; atomic TSV paste | Multiple sheets, XLSX/CSV files, formatting, merged cells, fill/relative-reference adjustment, multi-cell selection, clipboard API, virtual scrolling |
| Calculation | Numbers, cell references, arithmetic with precedence, parentheses, SUM/AVERAGE/MIN/MAX/COUNT, range arguments, dependency recalculation and caching | Excel-compatible full formula language, dates, text/logic functions, named/absolute/cross-sheet references, decimal financial precision |
| Errors | Syntax, missing reference, cycle, divide-by-zero, bad numeric type, overflow and nesting limits | Excel error-code equivalence for every case |
| Pivot | One row and one column dimension; one numeric measure; Sum/Count/Average/Min/Max; row/column/grand totals; callback with source records | Nested dimensions, multiple measures, OLAP/server binding, drag/drop configurator, export, virtualization |
| Gallery | Delivery costs derived from hours × rate; changing sheet values refreshes pivot; dimension/aggregate controls, team filter, invalid cost rows excluded with notice, source-record drilldown | Persistent backend, file storage, concurrent edits |

Models validate dimensions, bounds, unique pivot IDs and finite measures. Sheet limits: 100 rows, 26 columns, 1000 characters/cell, 64 parser nesting levels, 100 reference depth. Designed for small local workbooks. Unknown text is displayed as text, never evaluated as JavaScript or HTML.

Pivot averages aggregate original records, not already aggregated cells. Count includes null measures; the other aggregates ignore them. Blank dimensions are distinct from total selections. Double arithmetic applies; numeric overflow of a pivot aggregate displays an em dash. See manual for scalar-vs-range COUNT behavior and detailed error codes.

Blazor gallery: `/workbook`; Flutter: Foundation → Workbook. Native mobile validation remains deferred. [Verification and screenshots](verification.md#workbook-and-manual-05).
