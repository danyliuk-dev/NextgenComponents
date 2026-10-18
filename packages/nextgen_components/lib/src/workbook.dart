import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components.dart';

class NgCellValue {
  final String text;
  final double? number;
  final String? error;
  const NgCellValue(this.text, {this.number, this.error});
}

class NgSheet {
  final int rows, columns;
  final Map<String, String> cells;
  NgSheet({
    this.rows = 8,
    this.columns = 6,
    Map<String, String> cells = const {},
  }) : cells = Map.unmodifiable(
         cells.map((k, v) => MapEntry(k.toUpperCase(), v)),
       ) {
    if (rows < 1 || rows > 100 || columns < 1 || columns > 26)
      throw ArgumentError('Sheet supports 1–100 rows and 1–26 columns.');
    for (final e in this.cells.entries) {
      position(e.key);
      if (e.value.length > 1000)
        throw ArgumentError('Cell text exceeds 1000 characters.');
    }
  }
  static String address(int row, int column) =>
      '${String.fromCharCode(65 + column)}${row + 1}';
  (int, int) position(String a) {
    final m = RegExp(r'^([A-Z])([1-9][0-9]{0,2})$').firstMatch(a.toUpperCase());
    if (m == null) throw ArgumentError('Invalid cell address.');
    final r = int.parse(m[2]!) - 1, c = m[1]!.codeUnitAt(0) - 65;
    if (r >= rows || c >= columns)
      throw ArgumentError('Cell is outside the sheet.');
    return (r, c);
  }

  String raw(String a) => cells[a.toUpperCase()] ?? '';
  NgSheet set(String a, String value) {
    position(a);
    return NgSheet(
      rows: rows,
      columns: columns,
      cells: {...cells, a.toUpperCase(): value},
    );
  }

  NgSheet paste(String origin, String text) {
    final (r, c) = position(origin);
    final matrix = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceFirst(RegExp(r'\n+$'), '')
        .split('\n')
        .map((l) => l.split('\t'))
        .toList();
    if (r + matrix.length > rows || matrix.any((l) => c + l.length > columns))
      throw ArgumentError('Pasted cells exceed sheet bounds.');
    final copy = {...cells};
    for (var y = 0; y < matrix.length; y++) {
      for (var x = 0; x < matrix[y].length; x++) {
        copy[address(r + y, c + x)] = matrix[y][x];
      }
    }
    return NgSheet(rows: rows, columns: columns, cells: copy);
  }

  static String format(double n) {
    if (n == n.roundToDouble() && n.abs() < 1e15) return n.toStringAsFixed(0);
    final parts = n.toStringAsPrecision(10).split('e');
    final mantissa = parts[0].contains('.')
        ? parts[0]
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : parts[0];
    return parts.length == 1 ? mantissa : '${mantissa}e${parts[1]}';
  }

  NgCellValue evaluate(String a) => _evaluate(a.toUpperCase(), {}, {});
  NgCellValue _evaluate(
    String a,
    Set<String> path,
    Map<String, NgCellValue> cache,
  ) {
    if (cache.containsKey(a)) return cache[a]!;
    final value = _calculate(a, path, cache);
    cache[a] = value;
    return value;
  }

  NgCellValue _calculate(
    String a,
    Set<String> path,
    Map<String, NgCellValue> cache,
  ) {
    try {
      position(a);
    } on ArgumentError {
      return const NgCellValue('#REF!', error: '#REF!');
    }
    if (!path.add(a)) return const NgCellValue('#CYCLE!', error: '#CYCLE!');
    try {
      final value = raw(a);
      if (!value.startsWith('=')) {
        final n = double.tryParse(value);
        return n != null && n.isFinite
            ? NgCellValue(format(n), number: n)
            : NgCellValue(value);
      }
      if (path.length > 100) throw const _FormulaError('#LIMIT!');
      final n = _FormulaParser(value.substring(1), this, path, cache).parse();
      if (!n.isFinite) throw const _FormulaError('#NUM!');
      return NgCellValue(format(n), number: n);
    } on _FormulaError catch (e) {
      return NgCellValue(e.message, error: e.message);
    } finally {
      path.remove(a);
    }
  }
}

class _FormulaError implements Exception {
  final String message;
  const _FormulaError(this.message);
}

class _FormulaParser {
  final String text;
  final NgSheet sheet;
  final Set<String> path;
  final Map<String, NgCellValue> cache;
  int at = 0, depth = 0;
  _FormulaParser(this.text, this.sheet, this.path, this.cache);
  void space() {
    while (at < text.length && text[at].trim().isEmpty) {
      at++;
    }
  }

  bool take(String c) {
    space();
    if (at < text.length && text[at] == c) {
      at++;
      return true;
    }
    return false;
  }

  double parse() {
    final v = expression();
    space();
    if (at != text.length) throw const _FormulaError('#FORMULA!');
    return v;
  }

  double expression() {
    var v = product();
    while (true) {
      if (take('+')) {
        v += product();
      } else if (take('-')) {
        v -= product();
      } else {
        return v;
      }
    }
  }

  double product() {
    var v = atom();
    while (true) {
      if (take('*')) {
        v *= atom();
      } else if (take('/')) {
        final d = atom();
        if (d == 0) throw const _FormulaError('#DIV/0!');
        v /= d;
      } else {
        return v;
      }
    }
  }

  double atom() {
    if (++depth > 64) throw const _FormulaError('#LIMIT!');
    try {
      if (take('+')) return atom();
      if (take('-')) return -atom();
      if (take('(')) {
        final v = expression();
        if (!take(')')) throw const _FormulaError('#FORMULA!');
        return v;
      }
      space();
      var m = RegExp(
        r'^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?',
      ).firstMatch(text.substring(at));
      if (m != null) {
        at += m[0]!.length;
        final n = double.tryParse(m[0]!);
        if (n == null || !n.isFinite) throw const _FormulaError('#NUM!');
        return n;
      }
      m = RegExp(r'^[A-Za-z]+[0-9]*').firstMatch(text.substring(at));
      if (m == null) throw const _FormulaError('#FORMULA!');
      final token = m[0]!.toUpperCase();
      at += m[0]!.length;
      if (!take('(')) return cell(token, false) ?? 0;
      if (!['SUM', 'AVERAGE', 'MIN', 'MAX', 'COUNT'].contains(token))
        throw const _FormulaError('#NAME?');
      final values = <double>[];
      if (!take(')')) {
        do {
          space();
          final range = RegExp(
            r'^([A-Za-z][1-9][0-9]{0,2})\s*:\s*([A-Za-z][1-9][0-9]{0,2})',
          ).firstMatch(text.substring(at));
          if (range != null) {
            at += range[0]!.length;
            (int, int) a, b;
            try {
              a = sheet.position(range[1]!);
              b = sheet.position(range[2]!);
            } on ArgumentError {
              throw const _FormulaError('#REF!');
            }
            final top = a.$1 < b.$1 ? a.$1 : b.$1,
                bottom = a.$1 > b.$1 ? a.$1 : b.$1,
                left = a.$2 < b.$2 ? a.$2 : b.$2,
                right = a.$2 > b.$2 ? a.$2 : b.$2;
            for (var r = top; r <= bottom; r++) {
              for (var c = left; c <= right; c++) {
                final n = cell(NgSheet.address(r, c), true);
                if (n != null) values.add(n);
              }
            }
          } else {
            values.add(expression());
          }
        } while (take(','));
        if (!take(')')) throw const _FormulaError('#FORMULA!');
      }
      return switch (token) {
        'SUM' => values.fold(0.0, (a, b) => a + b),
        'COUNT' => values.length.toDouble(),
        'AVERAGE' =>
          values.isEmpty
              ? throw const _FormulaError('#DIV/0!')
              : values.fold(0.0, (a, b) => a + b / values.length),
        'MIN' => values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b),
        'MAX' => values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b),
        _ => 0,
      };
    } finally {
      depth--;
    }
  }

  double? cell(String a, bool aggregate) {
    final v = sheet._evaluate(a, path, cache);
    if (v.error != null) throw _FormulaError(v.error!);
    if (v.number != null) return v.number;
    if (aggregate) return null;
    if (v.text.isEmpty) return 0;
    throw const _FormulaError('#VALUE!');
  }
}

enum NgAggregate { sum, count, average, min, max }

class NgPivotRecord {
  final String id;
  final Map<String, String> dimensions;
  final double? value;
  NgPivotRecord(this.id, Map<String, String> dimensions, this.value)
    : dimensions = Map.unmodifiable(dimensions);
}

class NgPivotSelection {
  final String? row, column;
  final List<NgPivotRecord> records;
  const NgPivotSelection(this.row, this.column, this.records);
}

abstract final class NgPivotMath {
  static void validate(List<NgPivotRecord> items) {
    if (items.map((x) => x.id).toSet().length != items.length ||
        items.any((x) => x.value != null && !x.value!.isFinite))
      throw ArgumentError(
        'Pivot records require unique IDs and finite numeric values or null.',
      );
  }

  static String dimension(NgPivotRecord r, String field) =>
      r.dimensions[field] ?? '';
  static List<NgPivotRecord> filter(
    List<NgPivotRecord> items,
    String rowField,
    String columnField,
    String? row,
    String? column,
  ) => items
      .where(
        (x) =>
            (row == null || dimension(x, rowField) == row) &&
            (column == null || dimension(x, columnField) == column),
      )
      .toList();
  static double? aggregate(
    Iterable<NgPivotRecord> items,
    NgAggregate aggregate,
  ) {
    final records = items.toList();
    if (aggregate == NgAggregate.count) return records.length.toDouble();
    final values = records.map((x) => x.value).whereType<double>().toList();
    if (values.isEmpty) return null;
    final v = switch (aggregate) {
      NgAggregate.sum => values.fold(0.0, (a, b) => a + b),
      NgAggregate.average => values.fold(0.0, (a, b) => a + b / values.length),
      NgAggregate.min => values.reduce((a, b) => a < b ? a : b),
      NgAggregate.max => values.reduce((a, b) => a > b ? a : b),
      _ => 0.0,
    };
    return v.isFinite ? v : null;
  }
}

class NgSpreadsheet extends StatefulWidget {
  final String label;
  final NgSheet value;
  final ValueChanged<NgSheet>? onChanged;
  final bool readOnly;
  const NgSpreadsheet({
    super.key,
    this.label = 'Spreadsheet',
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });
  @override
  State<NgSpreadsheet> createState() => _NgSpreadsheetState();
}

class _NgSpreadsheetState extends State<NgSpreadsheet> {
  late NgSheet current;
  final undo = <NgSheet>[], redo = <NgSheet>[];
  final formula = TextEditingController(), paste = TextEditingController();
  final nodes = <String, FocusNode>{};
  String address = 'A1', message = '';
  bool showPaste = false;
  @override
  void initState() {
    super.initState();
    current = widget.value;
    formula.text = current.raw(address);
  }

  @override
  void didUpdateWidget(covariant NgSpreadsheet old) {
    super.didUpdateWidget(old);
    if (!identical(current, widget.value)) {
      current = widget.value;
      undo.clear();
      redo.clear();
      try {
        current.position(address);
      } on ArgumentError {
        address = 'A1';
      }
      formula.text = current.raw(address);
    }
  }

  @override
  void dispose() {
    formula.dispose();
    paste.dispose();
    for (final node in nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void select(int r, int c) {
    setState(() {
      address = NgSheet.address(
        r.clamp(0, current.rows - 1),
        c.clamp(0, current.columns - 1),
      );
      formula.text = current.raw(address);
      message = '';
    });
    nodes[address]?.requestFocus();
  }

  void commit(NgSheet next) {
    setState(() {
      undo.add(current);
      if (undo.length > 50) undo.removeAt(0);
      redo.clear();
      current = next;
      formula.text = current.raw(address);
      message = 'Updated $address';
    });
    widget.onChanged?.call(current);
  }

  void apply({bool block = false}) {
    if (widget.readOnly) return;
    try {
      commit(
        block
            ? current.paste(address, paste.text)
            : current.set(address, formula.text),
      );
    } on ArgumentError catch (e) {
      setState(() => message = e.message.toString());
    }
  }

  void history(bool forward) {
    if (widget.readOnly) return;
    final from = forward ? redo : undo, to = forward ? undo : redo;
    if (from.isEmpty) return;
    setState(() {
      to.add(current);
      current = from.removeLast();
      formula.text = current.raw(address);
      message = forward ? 'Redone' : 'Undone';
    });
    widget.onChanged?.call(current);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget cell(int r, int c) {
      final a = NgSheet.address(r, c), v = current.evaluate(a);
      final node = nodes.putIfAbsent(a, () => FocusNode());
      return Focus(
        onKeyEvent: (_, e) {
          if (e is! KeyDownEvent) return KeyEventResult.ignored;
          final (rr, cc) = current.position(address);
          final k = e.logicalKey;
          if (k == LogicalKeyboardKey.arrowLeft) {
            select(rr, cc - 1);
          } else if (k == LogicalKeyboardKey.arrowRight) {
            select(rr, cc + 1);
          } else if (k == LogicalKeyboardKey.arrowUp) {
            select(rr - 1, cc);
          } else if (k == LogicalKeyboardKey.arrowDown) {
            select(rr + 1, cc);
          } else {
            return KeyEventResult.ignored;
          }
          nodes[address]?.requestFocus();
          return KeyEventResult.handled;
        },
        child: Semantics(
          selected: address == a,
          label: '$a: ${v.text.isEmpty ? 'Empty' : v.text}',
          excludeSemantics: true,
          button: true,
          onTap: () => select(r, c),
          child: Container(
            decoration: BoxDecoration(
              color: address == a ? colors.primary.withValues(alpha: .1) : null,
              border: address == a
                  ? Border.all(color: colors.primary, width: 2)
                  : null,
            ),
            child: TextButton(
              focusNode: node,
              onPressed: () => select(r, c),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: v.error != null
                    ? colors.error
                    : colors.onSurface,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              child: Text(
                v.text.isEmpty ? ' ' : v.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }

    Widget header(String text) => Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(address),
            SizedBox(
              width: 260,
              child: TextField(
                controller: formula,
                enabled: !widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Cell value or formula',
                ),
                onSubmitted: (_) => apply(),
              ),
            ),
            NgButton(
              primary: true,
              onPressed: widget.readOnly ? null : () => apply(),
              child: const Text('Apply cell'),
            ),
            NgButton(
              onPressed: widget.readOnly || undo.isEmpty
                  ? null
                  : () => history(false),
              child: const Text('Undo'),
            ),
            NgButton(
              onPressed: widget.readOnly || redo.isEmpty
                  ? null
                  : () => history(true),
              child: const Text('Redo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 50 + current.columns * 130.0,
            child: Table(
              border: TableBorder.all(color: colors.outline),
              columnWidths: const {0: FixedColumnWidth(50)},
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                  ),
                  children: [
                    header('Cell'),
                    for (var c = 0; c < current.columns; c++)
                      header(String.fromCharCode(65 + c)),
                  ],
                ),
                for (var r = 0; r < current.rows; r++)
                  TableRow(
                    children: [
                      header('${r + 1}'),
                      for (var c = 0; c < current.columns; c++) cell(r, c),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (!widget.readOnly) ...[
          TextButton(
            onPressed: () => setState(() => showPaste = !showPaste),
            child: Text(showPaste ? 'Hide paste cells' : 'Paste cells'),
          ),
          if (showPaste) ...[
            TextField(
              controller: paste,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tab-separated values',
              ),
            ),
            const SizedBox(height: 8),
            NgButton(
              onPressed: () => apply(block: true),
              child: Text('Paste at $address'),
            ),
            const Text(
              'Tabs separate columns; new lines separate rows. Formulas are kept as entered.',
            ),
          ],
        ],
        Semantics(liveRegion: true, child: Text(message)),
      ],
    );
  }
}

class NgPivotGrid extends StatelessWidget {
  final String label, rowField, columnField;
  final List<NgPivotRecord> items;
  final NgAggregate aggregate;
  final ValueChanged<NgPivotSelection>? onCellSelected;
  const NgPivotGrid({
    super.key,
    this.label = 'Pivot table',
    required this.items,
    this.rowField = 'Team',
    this.columnField = 'Quarter',
    this.aggregate = NgAggregate.sum,
    this.onCellSelected,
  });
  @override
  Widget build(BuildContext context) {
    NgPivotMath.validate(items);
    final rows =
            items
                .map((x) => NgPivotMath.dimension(x, rowField))
                .toSet()
                .toList()
              ..sort(),
        columns =
            items
                .map((x) => NgPivotMath.dimension(x, columnField))
                .toSet()
                .toList()
              ..sort();
    String display(String? s) => s == null
        ? 'Total'
        : s.isEmpty
        ? '(blank)'
        : s;
    Widget cell(String? row, String? col) {
      final records = NgPivotMath.filter(
            items,
            rowField,
            columnField,
            row,
            col,
          ),
          value = NgPivotMath.aggregate(records, aggregate);
      final text = value == null ? '—' : NgSheet.format(value);
      return Semantics(
        label: '${display(row)} / ${display(col)}: $text',
        button: true,
        excludeSemantics: true,
        onTap: () => onCellSelected?.call(NgPivotSelection(row, col, records)),
        child: TextButton(
          onPressed: () =>
              onCellSelected?.call(NgPivotSelection(row, col, records)),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: row == null || col == null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    Widget header(String value) => Padding(
      padding: const EdgeInsets.all(12),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text('${aggregate.name} · $rowField × $columnField'),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Text('No pivot data.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (columns.length + 2) * 150.0,
              child: Table(
                border: TableBorder.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                children: [
                  TableRow(
                    children: [
                      header('$rowField / $columnField'),
                      for (final col in columns) header(display(col)),
                      header('Total'),
                    ],
                  ),
                  for (final row in rows)
                    TableRow(
                      children: [
                        header(display(row)),
                        for (final col in columns) cell(row, col),
                        cell(row, null),
                      ],
                    ),
                  TableRow(
                    children: [
                      header('Total'),
                      for (final col in columns) cell(null, col),
                      cell(null, null),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
