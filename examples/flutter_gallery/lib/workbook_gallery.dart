import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class WorkbookGallery extends StatefulWidget {
  final bool dark, compact;
  final ValueChanged<bool> onDark, onCompact;
  final VoidCallback onBack;
  const WorkbookGallery({
    super.key,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
    required this.onBack,
  });
  @override
  State<WorkbookGallery> createState() => _WorkbookGalleryState();
}

class _WorkbookGalleryState extends State<WorkbookGallery> {
  late NgSheet sheet;
  List<NgPivotRecord> records = [];
  int excluded = 0;
  String rowField = 'Team', columnField = 'Quarter', filter = '';
  NgAggregate aggregation = NgAggregate.sum;
  NgPivotSelection? selection;
  @override
  void initState() {
    super.initState();
    final cells = <String, String>{
      'A1': 'Team',
      'B1': 'Quarter',
      'C1': 'Hours',
      'D1': 'Rate',
      'E1': 'Cost',
      'A7': 'Total',
      'E7': '=SUM(E2:E6)',
    };
    const teams = ['Design', 'Design', 'Design', 'Engineering', 'Engineering'],
        quarters = ['Q1', 'Q1', 'Q2', 'Q1', 'Q2'],
        hours = ['10', '20', '15', '30', '25'],
        rates = ['100', '100', '120', '150', '150'];
    for (var i = 0; i < 5; i++) {
      final r = i + 2;
      cells.addAll({
        'A$r': teams[i],
        'B$r': quarters[i],
        'C$r': hours[i],
        'D$r': rates[i],
        'E$r': '=C$r*D$r',
      });
    }
    sheet = NgSheet(rows: 8, columns: 5, cells: cells);
    rebuild();
  }

  void rebuild() {
    records = [];
    excluded = 0;
    selection = null;
    for (var r = 1; r <= 5; r++) {
      final cost = sheet.evaluate(NgSheet.address(r, 4));
      if (cost.number == null) {
        excluded++;
        continue;
      }
      records.add(
        NgPivotRecord('${r + 1}', {
          'Team': sheet.evaluate(NgSheet.address(r, 0)).text,
          'Quarter': sheet.evaluate(NgSheet.address(r, 1)).text,
        }, cost.number),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget panel(Widget child) => Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
    Widget option(
      String label,
      String value,
      List<NgOption> items,
      ValueChanged<String> changed,
    ) => SizedBox(
      width: 220,
      child: NgDropDownList(
        label: label,
        value: value,
        items: items,
        onChanged: (v) {
          if (v != null)
            setState(() {
              changed(v);
              selection = null;
            });
        },
      ),
    );
    const dimensions = [
      NgOption('Team', 'Team'),
      NgOption('Quarter', 'Quarter'),
    ];
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'N / NEXTGEN COMPONENTS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: widget.onBack,
                      child: const Text('Foundation'),
                    ),
                    NgSwitch(
                      label: 'Dark theme',
                      value: widget.dark,
                      onChanged: widget.onDark,
                    ),
                    NgCheckBox(
                      label: 'Compact',
                      value: widget.compact,
                      onChanged: widget.onCompact,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  'FLUTTER / WORKBOOK 0.59',
                  style: TextStyle(color: colors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Edit the numbers.\nExplore the result.',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Change hours or rates, calculate delivery costs and inspect the records behind each summary.',
                ),
                const SizedBox(height: 32),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NgSpreadsheet(
                        label: 'Delivery workbook',
                        canEdit: (a) {
                          final (r, c) = sheet.position(a);
                          return r >= 1 && r <= 5 && c < 4;
                        },
                        value: sheet,
                        onChanged: (v) => setState(() {
                          sheet = v;
                          rebuild();
                        }),
                      ),
                      const Text(
                        'Headers and calculated costs are protected. Rows 2–6 feed the pivot below. Select a cell, edit its value or formula, then Apply cell. Arrow keys move the selection.',
                      ),
                    ],
                  ),
                ),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          option(
                            'Rows',
                            rowField,
                            dimensions,
                            (v) => rowField = v,
                          ),
                          option(
                            'Columns',
                            columnField,
                            dimensions,
                            (v) => columnField = v,
                          ),
                          option('Aggregate', aggregation.name, [
                            for (final a in NgAggregate.values)
                              NgOption(a.name, a.name),
                          ], (v) => aggregation = NgAggregate.values.byName(v)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      NgTextBox(
                        label: 'Filter team',
                        onChanged: (v) => setState(() {
                          filter = v;
                          selection = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${records.length} source rows · $excluded invalid cost rows excluded',
                      ),
                      NgPivotGrid(
                        label: 'Delivery costs',
                        valueFormatter: (v) => v == null
                            ? 'No value'
                            : '${v.toStringAsFixed(2)} ${aggregation == NgAggregate.count ? "records" : "credits"}',
                        items: records
                            .where(
                              (r) => r.dimensions['Team']!
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()),
                            )
                            .toList(),
                        rowField: rowField,
                        columnField: columnField,
                        aggregate: aggregation,
                        onCellSelected: (p) => setState(() => selection = p),
                      ),
                    ],
                  ),
                ),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Source records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selection == null)
                        const Text(
                          'Select any pivot value or total to inspect its records.',
                        )
                      else ...[
                        Text(
                          '${selection!.row ?? 'Total'} / ${selection!.column ?? 'Total'} · ${selection!.records.length} records',
                        ),
                        NgDataGrid<NgPivotRecord>(
                          items: selection!.records,
                          columns: [
                            NgDataColumn('id', 'Row', (r) => r.id),
                            NgDataColumn(
                              'team',
                              'Team',
                              (r) => r.dimensions['Team'],
                            ),
                            NgDataColumn(
                              'quarter',
                              'Quarter',
                              (r) => r.dimensions['Quarter'],
                            ),
                            NgDataColumn('cost', 'Cost', (r) => r.value),
                          ],
                          rowId: (r) => r.id,
                        ),
                      ],
                    ],
                  ),
                ),
                const Text('47 CONTROLS / 53 CATALOGUE ENTRIES · WEB FIRST'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
