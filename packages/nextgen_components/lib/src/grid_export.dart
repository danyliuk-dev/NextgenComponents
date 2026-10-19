part of 'data.dart';

enum NgGridExportScope { page, filtered, selected }

class NgGridExportRequest {
  final NgGridExportScope scope;
  final String search;
  final List<NgSortDescriptor> sorts;
  final List<String> groupKeys, selectedIds;
  final int maxRows;
  NgGridExportRequest(
    this.scope,
    this.search,
    List<NgSortDescriptor> sorts,
    List<String> groupKeys,
    List<String> selectedIds,
    this.maxRows,
  ) : sorts = List.unmodifiable(sorts),
      groupKeys = List.unmodifiable(groupKeys),
      selectedIds = List.unmodifiable(selectedIds);
}

class NgGridExportFile {
  final String fileName, content, mimeType;
  final int rowCount;
  final List<String> columnKeys;
  NgGridExportFile(
    this.fileName,
    this.content,
    this.mimeType,
    this.rowCount,
    List<String> columnKeys,
  ) : columnKeys = List.unmodifiable(columnKeys);
  List<int> get bytes => utf8.encode(content);
}

class NgGridExport<T> {
  final Future<void> Function(NgGridExportFile) onExport;
  final Future<List<T>> Function(NgGridExportRequest)? readExportData;
  final List<String> columnKeys;
  final String Function(String, T)? format;
  final String fileName, delimiter;
  final bool includeHeaders, includeBom, readOnly;
  final int maxRows, maxCharacters;
  final String scopeText,
      pageText,
      filteredText,
      selectedText,
      exportText,
      cancelText,
      busyText,
      readyText,
      errorText;
  NgGridExport({
    required this.onExport,
    this.readExportData,
    List<String> columnKeys = const [],
    this.format,
    this.fileName = 'records.csv',
    this.delimiter = ',',
    this.includeHeaders = true,
    this.includeBom = true,
    this.readOnly = false,
    this.maxRows = 10000,
    this.maxCharacters = 5000000,
    this.scopeText = 'Export scope',
    this.pageText = 'Current page',
    this.filteredText = 'Filtered records',
    this.selectedText = 'Selected filtered records',
    this.exportText = 'Prepare export',
    this.cancelText = 'Cancel export',
    this.busyText = 'Preparing export…',
    this.readyText = 'Export ready.',
    this.errorText = 'Unable to export records. Check limits and retry.',
  }) : columnKeys = List.unmodifiable(columnKeys);
  List<NgDataColumn<T>> resolve(List<NgDataColumn<T>> columns) {
    if (maxRows < 1 ||
        maxCharacters < 1 ||
        ![',', ';', '\t'].contains(delimiter))
      throw ArgumentError('Invalid export limits or delimiter.');
    if (fileName.trim().isEmpty || RegExp(r'[/\\\r\n\x00]').hasMatch(fileName))
      throw ArgumentError('Export requires a plain file name.');
    final keys = columnKeys.isEmpty
        ? columns.map((c) => c.key).toList()
        : columnKeys;
    if (keys.isEmpty ||
        keys.toSet().length != keys.length ||
        keys.any((k) => columns.where((c) => c.key == k).length != 1))
      throw ArgumentError('Export column keys must exist and be unique.');
    return keys.map((k) => columns.singleWhere((c) => c.key == k)).toList();
  }
}

class NgGridCsv {
  static String cell(String value) {
    final trimmed = value.replaceFirst(
      RegExp(
        r'^[\u0009-\u000D\u0020\u0085\u00A0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF]+',
      ),
      '',
    );
    if ((trimmed.isNotEmpty && '=+-@'.contains(trimmed[0])) ||
        (value.isNotEmpty && '\t\r\n'.contains(value[0])))
      value = "'$value";
    return '"${value.replaceAll('"', '""')}"';
  }

  static NgGridExportFile create<T>(
    List<T> rows,
    List<NgDataColumn<T>> columns,
    NgGridExport<T> options,
  ) {
    final selected = options.resolve(columns);
    if (rows.length > options.maxRows)
      throw ArgumentError('Export row limit exceeded.');
    final content = StringBuffer(options.includeBom ? '\uFEFF' : '');
    void line(Iterable<String> cells) {
      var index = 0;
      for (final value in cells) {
        if (index++ > 0) content.write(options.delimiter);
        if (value.length > options.maxCharacters)
          throw ArgumentError('Export character limit exceeded.');
        content.write(cell(value));
        if (content.length > options.maxCharacters)
          throw ArgumentError('Export character limit exceeded.');
      }
      content.write('\r\n');
      if (content.length > options.maxCharacters)
        throw ArgumentError('Export character limit exceeded.');
    }

    if (options.includeHeaders) line(selected.map((c) => c.title));
    for (final row in rows) {
      line(
        selected.map((c) => options.format?.call(c.key, row) ?? c.text(row)),
      );
    }
    return NgGridExportFile(
      options.fileName,
      content.toString(),
      options.delimiter == '\t'
          ? 'text/tab-separated-values;charset=utf-8'
          : 'text/csv;charset=utf-8',
      rows.length,
      selected.map((c) => c.key).toList(),
    );
  }
}
