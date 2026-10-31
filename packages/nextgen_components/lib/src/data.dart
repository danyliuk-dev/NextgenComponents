import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'components.dart';
part 'grouped_data.dart';
part 'grid_editing.dart';
part 'grid_export.dart';
part 'virtual_data.dart';
part 'range_data.dart';
part 'grouped_range.dart';

class NgDataColumn<T> {
  final String key, title;
  final Object? Function(T) value;
  final String Function(T)? format;
  final Widget Function(BuildContext, T)? cellBuilder;
  final bool sortable;
  const NgDataColumn(
    this.key,
    this.title,
    this.value, {
    this.format,
    this.cellBuilder,
    this.sortable = true,
  });
  String text(T item) => format?.call(item) ?? value(item)?.toString() ?? '';
}

/// A full filtered group. IDs encode the complete path, including empty keys.
class NgGridGroup<T> {
  final List<String> path;
  final List<T> items;
  final List<NgGridGroup<T>> children;
  final int? total;
  final List<NgGroupSummary> summaries;
  int get count => total ?? items.length;
  NgGridGroup(
    List<String> path,
    List<T> items,
    List<NgGridGroup<T>> children, {
    this.total,
    List<NgGroupSummary> summaries = const [],
  }) : path = List.unmodifiable(path),
       items = List.unmodifiable(items),
       children = List.unmodifiable(children),
       summaries = List.unmodifiable(summaries);
  String get id => ngGroupId(path);
  String get key => path.last;
  int get depth => path.length - 1;
}

String ngGroupId(Iterable<String> path) =>
    path.map((k) => '${k.length}:$k').join();
List<NgGridGroup<T>> ngGroupTree<T>(
  List<T> source,
  List<String Function(T)> selectors,
) {
  if (selectors.length > 8)
    throw ArgumentError('At most eight group levels are supported.');
  List<NgGridGroup<T>> walk(List<T> rows, int depth, List<String> path) {
    if (depth == selectors.length) return [];
    final buckets = <String, List<T>>{};
    for (final row in rows) {
      buckets.putIfAbsent(selectors[depth](row), () => []).add(row);
    }
    return buckets.entries.map((entry) {
      final next = [...path, entry.key];
      final children = walk(entry.value, depth + 1, next);
      return NgGridGroup<T>(
        next,
        children.isEmpty
            ? entry.value
            : children.expand((g) => g.items).toList(),
        children,
      );
    }).toList();
  }

  return walk(source, 0, []);
}

Iterable<NgGridGroup<T>> ngAllGroups<T>(Iterable<NgGridGroup<T>> groups) sync* {
  for (final group in groups) {
    yield group;
    yield* ngAllGroups(group.children);
  }
}

class NgGroupAggregate<T> {
  final String title, operation;
  final double? Function(T) value;
  final String Function(double?)? format;
  const NgGroupAggregate(
    this.title,
    this.value, {
    this.operation = 'sum',
    this.format,
  });
  double? calculate(Iterable<T> rows) {
    if (!['sum', 'average', 'min', 'max', 'count'].contains(operation))
      throw ArgumentError('Unknown aggregate operation.');
    final values = rows
        .map(value)
        .whereType<double>()
        .where((v) => v.isFinite)
        .toList();
    if (operation == 'count') return values.length.toDouble();
    if (operation == 'sum') return values.fold<double>(0, (a, b) => a + b);
    if (values.isEmpty) return null;
    if (operation == 'average')
      return values.fold<double>(0, (a, b) => a + b) / values.length;
    return values.reduce(
      (a, b) => operation == 'min' ? (a < b ? a : b) : (a > b ? a : b),
    );
  }

  String text(Iterable<T> rows) {
    final result = calculate(rows);
    return '$title: ${format?.call(result) ?? (result == null ? '—' : result.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), ''))}';
  }
}

class NgTreeNode<T> {
  final String id;
  final T item;
  final List<NgTreeNode<T>> children;
  final bool disabled, hasChildren;
  const NgTreeNode(
    this.id,
    this.item, {
    this.children = const [],
    this.disabled = false,
    this.hasChildren = false,
  });
}

// Cascade applies to the parent record and loaded descendants. Protected nodes
// are subtree barriers, irrespective of search and expansion visibility.
List<String> _treeCheckTargets<T>(
  NgTreeNode<T> node,
  bool cascade,
  bool Function(NgTreeNode<T>)? canCheck,
) {
  final ids = [node.id];
  void walk(NgTreeNode<T> parent) {
    for (final child in parent.children) {
      if (child.disabled || !(canCheck?.call(child) ?? true)) continue;
      ids.add(child.id);
      walk(child);
    }
  }

  if (cascade && !node.disabled && (canCheck?.call(node) ?? true)) walk(node);
  return ids;
}

bool? _treeCheckState<T>(
  NgTreeNode<T> node,
  Set<String> checkedIds,
  bool cascade,
  bool Function(NgTreeNode<T>)? canCheck,
) {
  final targets = _treeCheckTargets(node, cascade, canCheck);
  final count = targets.where(checkedIds.contains).length;
  return count == 0
      ? false
      : count == targets.length
      ? true
      : null;
}

Set<String> _toggleTreeCheck<T>(
  NgTreeNode<T> node,
  Set<String> checkedIds,
  bool cascade,
  bool Function(NgTreeNode<T>)? canCheck,
) {
  final next = {...checkedIds};
  final targets = _treeCheckTargets(node, cascade, canCheck);
  if (targets.every(checkedIds.contains)) {
    next.removeAll(targets);
  } else {
    next.addAll(targets);
  }
  return next;
}

class NgTreeRow<T> {
  final NgTreeNode<T> node;
  final int depth;
  final String? parentId;
  final bool expanded;
  const NgTreeRow(this.node, this.depth, this.parentId, this.expanded);
}

class NgSortDescriptor {
  final String key;
  final bool descending;
  const NgSortDescriptor(this.key, {this.descending = false});
}

class NgDataRequest {
  final int page, pageSize;
  final String search;
  final List<NgSortDescriptor> sorts;
  NgDataRequest(
    this.page,
    this.pageSize,
    this.search,
    List<NgSortDescriptor> sorts,
  ) : sorts = List.unmodifiable(sorts);
}

class NgDataResult<T> {
  final List<T> items;
  final int total;
  NgDataResult(List<T> items, this.total) : items = List.unmodifiable(items);
}

// Cache is scoped to immutable root identity, loader identity and dataVersion.
class _LazyTreeCache<T> {
  final cache = <String, List<NgTreeNode<T>>>{};
  final loading = <String>{}, errors = <String>{};
  List<NgTreeNode<T>>? source;
  Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)? loader;
  Object? version;
  int revision = 0;
  void update(
    List<NgTreeNode<T>> items,
    Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)? load,
    Object? value,
  ) {
    NgDataOperations.flatten(items, {}, (_) => '');
    if (!identical(source, items) || loader != load || version != value) {
      revision++;
      cache.clear();
      loading.clear();
      errors.clear();
      source = items;
      loader = load;
      version = value;
    }
  }

  List<NgTreeNode<T>> resolve(List<NgTreeNode<T>> items) => items.map((n) {
    final children = cache[n.id];
    return NgTreeNode(
      n.id,
      n.item,
      children: resolve(children ?? n.children),
      disabled: n.disabled,
      hasChildren: children == null ? n.hasChildren : children.isNotEmpty,
    );
  }).toList();
  Future<bool> ensure(NgTreeNode<T> node) async {
    if (!node.hasChildren ||
        node.children.isNotEmpty ||
        cache.containsKey(node.id))
      return true;
    if (loader == null || loading.contains(node.id)) return false;
    final ticket = revision;
    loading.add(node.id);
    errors.remove(node.id);
    try {
      final children = await loader!(node);
      if (revision != ticket) return false;
      NgDataOperations.flatten(children, {}, (_) => '');
      cache[node.id] = List.unmodifiable(children);
      try {
        NgDataOperations.flatten(resolve(source!), {}, (_) => '');
      } catch (_) {
        cache.remove(node.id);
        rethrow;
      }
      return true;
    } catch (_) {
      if (revision == ticket) errors.add(node.id);
      return false;
    } finally {
      if (revision == ticket) loading.remove(node.id);
    }
  }
}

abstract final class NgDataOperations {
  static int pageCount(int total, int size) =>
      ((total < 0 ? 0 : total) / (size < 1 ? 1 : size)).ceil().clamp(
        1,
        2147483647,
      );
  static int clampPage(int page, int total, int size) =>
      page.clamp(1, pageCount(total, size));
  static int compare(Object? a, Object? b) {
    if (a == null) return b == null ? 0 : -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  static List<T> query<T>(
    List<T> items,
    List<NgDataColumn<T>> columns,
    String search,
    String? sortKey,
    bool descending,
  ) {
    return queryMany(
      items,
      columns,
      search,
      sortKey == null
          ? []
          : [NgSortDescriptor(sortKey, descending: descending)],
    );
  }

  static List<T> queryMany<T>(
    List<T> items,
    List<NgDataColumn<T>> columns,
    String search,
    List<NgSortDescriptor> sorts,
  ) {
    final needle = search.trim().toLowerCase();
    final rows = items
        .where(
          (item) =>
              needle.isEmpty ||
              columns.any((c) => c.text(item).toLowerCase().contains(needle)),
        )
        .toList();
    final indexed = rows.indexed.toList();
    indexed.sort((a, b) {
      for (final sort in sorts) {
        final column = columns
            .where((c) => c.key == sort.key && c.sortable)
            .firstOrNull;
        if (column == null) continue;
        final result =
            compare(column.value(a.$2), column.value(b.$2)) *
            (sort.descending ? -1 : 1);
        if (result != 0) return result;
      }
      return a.$1.compareTo(b.$1);
    });
    return indexed.map((e) => e.$2).toList();
  }

  static List<NgTreeRow<T>> flatten<T>(
    List<NgTreeNode<T>> roots,
    Set<String> expanded,
    String Function(T) label, {
    String search = '',
    int Function(NgTreeNode<T>, NgTreeNode<T>)? compareNodes,
  }) {
    final ids = <String>{};
    void validate(List<NgTreeNode<T>> nodes) {
      for (final n in nodes) {
        if (n.id.trim().isEmpty || !ids.add(n.id))
          throw ArgumentError('Duplicate or cyclic tree ID: ${n.id}');
        validate(n.children);
      }
    }

    validate(roots);
    final needle = search.trim().toLowerCase();
    List<NgTreeRow<T>> walk(
      List<NgTreeNode<T>> nodes,
      int depth,
      String? parent,
    ) {
      final ordered = nodes.indexed.toList();
      if (compareNodes != null)
        ordered.sort((a, b) {
          final c = compareNodes(a.$2, b.$2);
          return c == 0 ? a.$1.compareTo(b.$1) : c;
        });
      final result = <NgTreeRow<T>>[];
      for (final entry in ordered) {
        final n = entry.$2;
        final children = walk(n.children, depth + 1, n.id);
        if (needle.isNotEmpty &&
            !label(n.item).toLowerCase().contains(needle) &&
            children.isEmpty)
          continue;
        final open = needle.isNotEmpty
            ? children.isNotEmpty
            : (n.children.isNotEmpty || n.hasChildren) &&
                  expanded.contains(n.id);
        result.add(NgTreeRow(n, depth, parent, open));
        if (open) result.addAll(children);
      }
      return result;
    }

    return walk(roots, 0, null);
  }
}

class NgPager extends StatelessWidget {
  final int total, page, pageSize;
  final List<int> sizes;
  final ValueChanged<int> onPageChanged, onPageSizeChanged;
  final bool enabled;
  const NgPager({
    super.key,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.sizes = const [5, 10, 25, 50],
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    final size = pageSize < 1 ? 1 : pageSize;
    final current = NgDataOperations.clampPage(page, total, size);
    final count = NgDataOperations.pageCount(total, size);
    final choices = ({...sizes.where((s) => s > 0), size}.toList()..sort());
    Widget button(String label, Widget icon, int target, bool active) {
      final canTap = enabled && target >= 1 && target <= count;
      void activate() => onPageChanged(target);
      return Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Semantics(
          label: label,
          button: true,
          enabled: canTap,
          excludeSemantics: true,
          onTap: canTap ? activate : null,
          child: NgButton(
            primary: active,
            onPressed: canTap ? activate : null,
            child: icon,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              '${total <= 0 ? 0 : (current - 1) * size + 1}–${(current * size).clamp(0, total < 0 ? 0 : total)} of ${total < 0 ? 0 : total}',
            ),
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              button(
                'First page',
                const Text('«'),
                current == 1 ? 0 : 1,
                false,
              ),
              button('Previous page', const Text('‹'), current - 1, false),
              for (
                var i = (current - 2).clamp(1, count);
                i <= (current + 2).clamp(1, count);
                i++
              )
                button('Page $i', Text('$i'), i, i == current),
              button('Next page', const Text('›'), current + 1, false),
              button(
                'Last page',
                const Text('»'),
                current == count ? count + 1 : count,
                false,
              ),
            ],
          ),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<int>(
              initialValue: size,
              key: ValueKey(size),
              decoration: const InputDecoration(labelText: 'Rows per page'),
              items: choices
                  .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                  .toList(),
              onChanged: enabled
                  ? (v) {
                      if (v != null) {
                        onPageSizeChanged(v);
                        onPageChanged(1);
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class NgBreadcrumbItem {
  final String id, label;
  const NgBreadcrumbItem(this.id, this.label);
}

class NgBreadcrumb extends StatelessWidget {
  final List<NgBreadcrumbItem> items;
  final ValueChanged<String> onNavigate;
  const NgBreadcrumb({
    super.key,
    required this.items,
    required this.onNavigate,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Breadcrumb',
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const ExcludeSemantics(child: Text('›')),
          if (i == items.length - 1)
            Semantics(selected: true, child: Text(items[i].label))
          else
            TextButton(
              onPressed: () => onNavigate(items[i].id),
              child: Text(items[i].label),
            ),
        ],
      ],
    ),
  );
}

class NgDataGrid<T> extends StatefulWidget {
  final Future<NgGroupedRangeResult<T>> Function(NgGroupedRangeRequest)?
  readGroupedRange;
  final Future<NgDataRangeResult<T>> Function(NgDataRangeRequest)? readRange;
  final String loadedWindowText, selectWindowText;
  final String expandWindowGroupsText,collapseWindowGroupsText;
  final bool virtualize, variableRowHeight;
  final double rowHeight, viewportHeight;
  final NgGridExport<T>? export;
  final NgGridEditing<T>? editing;
  final List<T> items;
  final Future<NgDataResult<T>> Function(NgDataRequest)? readData;
  final Future<NgGroupedDataResult<T>> Function(NgGroupedDataRequest)?
  readGroupedData;
  final List<String> remoteGroupKeys;
  final String Function(String, double?)? remoteSummaryText;
  final String expandPageGroupsText, collapsePageGroupsText;
  final Object? dataVersion;
  final String Function(T)? groupBy;
  final String Function(String, int)? groupText;
  final List<String Function(T)> groupSelectors;
  final List<NgGroupAggregate<T>> groupAggregates;
  final bool collapsibleGroups, groupExpansionReadOnly;
  final Set<String> collapsedGroups;
  final ValueChanged<Set<String>>? onCollapsedGroupsChanged;
  final String Function(List<String>, bool)? groupToggleLabel;
  final String expandGroupsText, collapseGroupsText;
  final bool multiSort;
  final String loadingText, errorText, retryText;
  final List<NgDataColumn<T>> columns;
  final String Function(T) rowId;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final Widget Function(BuildContext, T)? rowActions;
  final Widget? toolbar, emptyBuilder;
  final bool selectionReadOnly;
  final bool Function(T)? canSelect;
  final List<int> pageSizes;
  final String label, emptyText;
  final int initialPageSize;
  const NgDataGrid({
    super.key,
    this.readRange,
    this.readGroupedRange,
    this.expandWindowGroupsText = 'Expand loaded groups',
    this.collapseWindowGroupsText = 'Collapse loaded groups',
    this.loadedWindowText = 'Loaded window',
    this.selectWindowText = 'Select loaded window',
    this.virtualize = false,
    this.variableRowHeight = false,
    this.rowHeight = 48,
    this.viewportHeight = 384,
    this.items = const [],
    this.editing,
    this.export,
    this.readData,
    this.readGroupedData,
    this.remoteGroupKeys = const [],
    this.remoteSummaryText,
    this.expandPageGroupsText = 'Expand page groups',
    this.collapsePageGroupsText = 'Collapse page groups',
    this.dataVersion,
    this.groupBy,
    this.groupText,
    this.groupSelectors = const [],
    this.groupAggregates = const [],
    this.collapsibleGroups = false,
    this.groupExpansionReadOnly = false,
    this.collapsedGroups = const {},
    this.onCollapsedGroupsChanged,
    this.groupToggleLabel,
    this.expandGroupsText = 'Expand all groups',
    this.collapseGroupsText = 'Collapse all groups',
    this.multiSort = false,
    this.loadingText = 'Loading records…',
    this.errorText = 'Unable to load records.',
    this.retryText = 'Retry',
    required this.columns,
    required this.rowId,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActions,
    this.toolbar,
    this.emptyBuilder,
    this.selectionReadOnly = false,
    this.canSelect,
    this.pageSizes = const [5, 10, 25, 50],
    this.label = 'Records',
    this.emptyText = 'No matching records.',
    this.initialPageSize = 5,
  });
  @override
  State<NgDataGrid<T>> createState() => _NgDataGridState<T>();
}

class _NgDataGridState<T> extends State<NgDataGrid<T>> {
  int rangeStart = 0, rangeEpoch = 0, desiredFirst = 0;
  bool rangeKnown = false;
  Timer? rangeTimer;
  bool get isRange =>
      widget.readRange != null || widget.readGroupedRange != null;
  List<(NgGridGroup<T>?, T?)> groupedRangeEntries = [];
  int get loadedSlotCount => widget.readGroupedRange != null
      ? groupedRangeEntries.length
      : remote.length;
  String previousCollapsed = '';
  String get collapseSignature {
    final ids = widget.collapsibleGroups
        ? widget.collapsedGroups.toList()
        : <String>[];
    ids.sort();
    return ngGroupId(ids);
  }

  int get rangeCount => (widget.viewportHeight / widget.rowHeight).ceil() + 96;
  void rangeViewport(int first) {
    desiredFirst = first;
    final end = (first + (widget.viewportHeight / widget.rowHeight).ceil() + 8)
        .clamp(0, total);
    if (rangeKnown &&
        !error &&
        first >= rangeStart &&
        end <= rangeStart + loadedSlotCount)
      return;
    rangeTimer?.cancel();
    cancelExport();
    // Invalidate stale success immediately, before the scroll debounce fires.
    ++revision;
    setState(() {
      loading = true;
      error = false;
      remote = [];
    });
    rangeTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted && isRange) loadRange(first);
    });
  }

  Future<void> loadRange(int first) async {
    final reader = widget.readRange;
    final groupedReader = widget.readGroupedRange;
    if (!isRange || !mounted) return;
    final ticket = ++revision, epoch = rangeEpoch;
    final start = ((first ~/ 32) * 32 - 32).clamp(0, NgDataRange.maxTotal);
    final request = NgDataRangeRequest(start, rangeCount, search, sorts);
    rangeStart = start;
    loading = true;
    error = false;
    remote = [];
    groupedRangeEntries = [];
    remoteGroups = [];
    cancelExport();
    try {
      NgDataRange.validateRequest(request);
      if (groupedReader != null) {
        final groupedRequest = NgGroupedRangeRequest(
          start,
          rangeCount,
          search,
          sorts,
          widget.remoteGroupKeys,
          widget.collapsibleGroups ? widget.collapsedGroups.toList() : [],
        );
        NgGroupedRange.validateRequest(groupedRequest);
        final answer = await groupedReader(groupedRequest);
        if (!mounted || ticket != revision || epoch != rangeEpoch) return;
        final window = NgGroupedRange.validate(
          answer,
          groupedRequest,
          widget.rowId,
        );
        total = window.total;
        rangeKnown = true;
        if (start >= total && total > 0) {
          await loadRange((total - rangeCount).clamp(0, total - 1));
          return;
        }
        final metadata = {for (final g in window.groups) ngGroupId(g.path): g};
        groupedRangeEntries = [
          for (final e in window.entries)
            e.isGroup
                ? (
                    NgGridGroup<T>(
                      e.path,
                      [],
                      [],
                      total: metadata[ngGroupId(e.path)]!.count,
                      summaries: metadata[ngGroupId(e.path)]!.summaries,
                    ),
                    null,
                  )
                : (null, e.item),
        ];
        remote = [
          for (final e in window.entries)
            if (!e.isGroup) e.item as T,
        ];
        remoteGroups = [
          for (final e in groupedRangeEntries)
            if (e.$1 != null) e.$1!,
        ];
        return;
      }
      final result = await reader!(request);
      if (!mounted || ticket != revision || epoch != rangeEpoch) return;
      final rows = NgDataRange.validate(result, request, widget.rowId);
      total = result.total;
      rangeKnown = true;
      if (start >= total && total > 0) {
        await loadRange((total - rangeCount).clamp(0, total - 1));
        return;
      }
      remote = rows;
    } catch (_) {
      if (mounted && ticket == revision && epoch == rangeEpoch) {
        error = true;
        remote = [];
      }
    } finally {
      if (mounted && ticket == revision && epoch == rangeEpoch)
        setState(() => loading = false);
    }
  }

  void retryRead() {
    if (!isRange) {
      change(() {});
      return;
    }
    rangeTimer?.cancel();
    setState(() {
      loading = true;
      error = false;
    });
    loadRange(desiredFirst);
  }

  NgGridExportScope exportScope = NgGridExportScope.page;
  bool exporting = false, exportError = false, exportReady = false;
  int exportRevision = 0;
  bool get canExport =>
      mounted &&
      !loading &&
      !error &&
      !saving &&
      !exporting &&
      widget.export != null &&
      !widget.export!.readOnly &&
      (exportScope == NgGridExportScope.page ||
          !isRemote ||
          widget.export!.readExportData != null);
  void cancelExport() {
    exportRevision++;
    exporting = exportError = exportReady = false;
  }

  Future<void> exportData() async {
    if (!canExport) return;
    final config = widget.export!,
        scope = exportScope,
        ticket = ++exportRevision;
    setState(() {
      exporting = true;
      exportError = exportReady = false;
    });
    try {
      final columns = config.resolve(widget.columns);
      final selected = Set<String>.of(widget.selectedIds);
      List<T> source;
      if (isRemote && scope != NgGridExportScope.page) {
        final request = NgGridExportRequest(
          scope,
          search,
          List.of(sorts),
          List.of(widget.remoteGroupKeys),
          selected.toList()..sort(),
          config.maxRows,
        );
        source = List.of(await config.readExportData!(request));
      } else {
        source = (scope == NgGridExportScope.page ? displayRows : rows)
            .where(
              (r) =>
                  scope != NgGridExportScope.selected ||
                  selected.contains(widget.rowId(r)),
            )
            .toList();
      }
      if (!mounted ||
          ticket != exportRevision ||
          widget.export == null ||
          widget.export!.readOnly)
        return;
      validate(source);
      if (scope == NgGridExportScope.selected &&
          source.any((r) => !selected.contains(widget.rowId(r))))
        throw ArgumentError('Export returned unselected records.');
      final file = NgGridCsv.create(source, columns, config);
      await config.onExport(file);
      if (mounted &&
          ticket == exportRevision &&
          widget.export != null &&
          !widget.export!.readOnly)
        setState(() => exportReady = true);
    } catch (_) {
      if (mounted && ticket == exportRevision)
        setState(() => exportError = true);
    } finally {
      if (mounted && ticket == exportRevision)
        setState(() => exporting = false);
    }
  }

  Widget exportToolbar() {
    final config = widget.export!;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          label: config.scopeText,
          child: DropdownButton<NgGridExportScope>(
            value: exportScope,
            onChanged: exporting
                ? null
                : (v) {
                    if (v != null)
                      setState(() {
                        exportScope = v;
                        exportReady = exportError = false;
                      });
                  },
            items: [
              DropdownMenuItem(
                value: NgGridExportScope.page,
                child: Text(
                  isRange ? widget.loadedWindowText : config.pageText,
                ),
              ),
              DropdownMenuItem(
                value: NgGridExportScope.filtered,
                enabled: !isRemote || config.readExportData != null,
                child: Text(config.filteredText),
              ),
              DropdownMenuItem(
                value: NgGridExportScope.selected,
                enabled: !isRemote || config.readExportData != null,
                child: Text(config.selectedText),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: canExport ? exportData : null,
          child: Text(config.exportText),
        ),
        if (exporting) ...[
          Semantics(liveRegion: true, child: Text(config.busyText)),
          TextButton(
            onPressed: () => setState(cancelExport),
            child: Text(config.cancelText),
          ),
        ],
        if (exportError)
          Semantics(liveRegion: true, child: Text(config.errorText))
        else if (exportReady)
          Semantics(liveRegion: true, child: Text(config.readyText)),
      ],
    );
  }

  final batchChanges = <_NgPendingChange<T>>[];
  String? editKey;
  T? editRecord;
  int batchSequence = 0;
  bool get isBatch => widget.editing?.commitBatch != null;
  bool get canReviewBatch => mounted && !saving && editOperation == null;
  bool get canSaveBatch => canReviewBatch && !loading && !error && widget.editing?.readOnly == false && isBatch && batchChanges.isNotEmpty;
  NgGridEditOperation? editOperation;
  String? editId, editError, editCell;
  Map<String, String> draft = {};
  bool saving = false;
  int editRevision = 0;
  bool get hasActions => widget.rowActions != null || widget.editing != null;
  bool get canCreate =>
      mounted && !saving &&
      !loading &&
      !error &&
      editOperation == null &&
      widget.editing != null &&
      !widget.editing!.readOnly &&
      widget.editing!.allowCreate;
  bool allowed(T row, bool delete) =>
      widget.editing != null &&
      !widget.editing!.readOnly &&
      ((delete ? widget.editing!.canDelete : widget.editing!.canUpdate)?.call(
            row,
          ) ??
          true);
  bool canEditRow(T row, bool delete) =>
      mounted && !saving && !batchChanges.any((e)=>e.change.id==widget.rowId(row) && e.change.operation==NgGridEditOperation.delete) &&
      !loading &&
      !error &&
      editOperation == null &&
      displayRows.any(
        (r) => widget.rowId(r) == widget.rowId(row) && allowed(r, delete),
      );
  List<T> get editRows {
    final rows = (isRemote ? remote : widget.items).where((r) => widget.rowId(r) == editId).toList();
    return rows.isEmpty && isRemote && editKey != null && editRecord != null ? [editRecord as T] : rows;
  }
  bool get canCommit =>
      mounted &&
      !saving &&
      !loading &&
      !error &&
      widget.editing != null &&
      !widget.editing!.readOnly &&
      (editOperation == NgGridEditOperation.create
          ? widget.editing!.allowCreate
          : editOperation != null &&
                editRows.length == 1 &&
                allowed(
                  editRows.single,
                  editOperation == NgGridEditOperation.delete,
                ));
  void closeEdit() {
    if (saving) return;
    editRevision++;
    editCell = null;
    editKey = null;
    editRecord = null;
    editOperation = null;
    editId = null;
    editError = null;
    draft = {};
  }

  void invalidateEdit() {
    editRevision++;
    saving = false;
    closeEdit();
    batchChanges.clear();
  }

  void beginEdit(NgGridEditOperation operation, T? row) {
    if (operation == NgGridEditOperation.create
        ? !canCreate
        : row == null ||
              !canEditRow(row, operation == NgGridEditOperation.delete))
      return;
    if (operation != NgGridEditOperation.create)
      row = displayRows.firstWhere(
        (r) => widget.rowId(r) == widget.rowId(row as T),
      );
    setState(() {
      editRevision++;
      editCell = null;
      editError = null;
      editKey = null;
      editRecord = row;
      try {
        draft = operation == NgGridEditOperation.delete
            ? {}
            : Map.of(widget.editing!.draft(row));
        editId = operation == NgGridEditOperation.create
            ? null
            : widget.rowId(row as T);
        editOperation = operation;
        final queued = operation == NgGridEditOperation.create ? null : batchChanges.where((e)=>e.change.id==editId).firstOrNull;
        if (queued != null) {editKey=queued.change.key;if(operation==NgGridEditOperation.update) draft=Map.of(queued.change.values);}

      } catch (_) {
        editError = widget.editing!.errorText;
      }
    });
  }

  Future<void> commitEdit() async {
    if (!canCommit) return;
    final config = widget.editing!, operation = editOperation!;
    final values = Map<String, String>.unmodifiable(draft);
    try {
      editError = operation == NgGridEditOperation.delete
          ? null
          : config.fields.any(
              (f) => f.required && (values[f.key] ?? '').trim().isEmpty,
            )
          ? config.requiredText
          : config.validate?.call(values);
    } catch (_) {
      editError = config.errorText;
    }
    if (editError != null) {
      setState(() {});
      return;
    }
    if (isBatch) {setState(()=>stageChange(operation,values));return;}
    final ticket = ++editRevision;
    setState(() => saving = true);
    try {
      final message = await config.commit(operation, editId, values);
      if (!mounted || ticket != editRevision) return;
      setState(() {
        saving = false;
        editError = message;
        if (message == null) closeEdit();
      });
      if (message == null) {
        await reload();
        if (mounted) setState(() {});
      }
    } catch (_) {
      if (mounted && ticket == editRevision)
        setState(() {
          saving = false;
          editError = config.errorText;
        });
    }
  }

  bool pendingAllowed(_NgPendingChange<T> entry) {
    final config=widget.editing;
    if(config==null || config.readOnly)return false;
    if(entry.change.operation==NgGridEditOperation.create)return config.allowCreate;
    final rows=(isRemote?remote:widget.items).where((r)=>widget.rowId(r)==entry.change.id).toList();
    final row=rows.length==1?rows.single:isRemote && rows.isEmpty?entry.original:null;
    return row!=null && allowed(row,entry.change.operation==NgGridEditOperation.delete);
  }
  void stageChange(NgGridEditOperation operation,Map<String,String> values) {
    final index=batchChanges.indexWhere((e)=>e.change.key==editKey);
    if(index<0 && batchChanges.length>=widget.editing!.maxPendingChanges){editError=widget.editing!.batchLimitText;return;}
    final entry=_NgPendingChange(NgGridChange(editKey??'change-${++batchSequence}',operation,editId,values),editRecord);
    if(index<0){batchChanges.add(entry);}else{batchChanges[index]=entry;}
    closeEdit();
  }
  void beginQueued(String key) {
    if(!canReviewBatch || !isBatch || loading || error)return;
    final entry=batchChanges.where((e)=>e.change.key==key).firstOrNull;
    if(entry==null || entry.change.operation==NgGridEditOperation.delete)return;
    setState(() {
      try {if(!pendingAllowed(entry)){editError=widget.editing!.batchConflictText;return;}}
      catch(_){editError=widget.editing!.errorText;return;}
      editRevision++;editKey=key;editRecord=entry.original;editId=entry.change.id;
      editOperation=entry.change.operation;editCell=null;editError=null;draft=Map.of(entry.change.values);
    });
  }
  void undoChange(String key){if(!canReviewBatch)return;setState((){batchChanges.removeWhere((e)=>e.change.key==key);editError=null;});}
  void discardBatch(){if(!canReviewBatch)return;setState((){batchChanges.clear();editError=null;});}
  Future<void> saveBatch() async {
    if(!canSaveBatch)return;
    final config=widget.editing!;
    setState(() {
      editError=null;
      try {
        if(batchChanges.length>config.maxPendingChanges){editError=config.batchLimitText;return;}
        for(final entry in batchChanges){
          if(!pendingAllowed(entry)){editError=config.batchConflictText;return;}
          if(entry.change.operation==NgGridEditOperation.delete)continue;
          final values=entry.change.values;
          editError=config.fields.any((f)=>f.required && (values[f.key]??'').trim().isEmpty)?config.requiredText:config.validate?.call(values);
          if(editError!=null)return;
        }
      } catch(_){editError=config.errorText;}
    });
    if(editError!=null)return;
    final changes=List<NgGridChange>.unmodifiable(batchChanges.map((e)=>e.change));
    final ticket=++editRevision;
    setState(()=>saving=true);
    try {
      final message=await config.commitBatch!(changes);
      if(!mounted || ticket!=editRevision)return;
      setState((){saving=false;editError=message;if(message==null)batchChanges.clear();});
      if(message==null){await reload();if(mounted)setState((){});}
    }catch(_){if(mounted && ticket==editRevision)setState((){saving=false;editError=config.errorText;});}
  }
  Widget batchPanel() {
    final config=widget.editing!;
    String label(NgGridChange c)=>switch(c.operation){NgGridEditOperation.create=>config.createText,NgGridEditOperation.update=>config.updateText,NgGridEditOperation.delete=>config.deleteText};
    return Semantics(container:true,label:config.pendingText,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${config.pendingText} (${batchChanges.length})',style:Theme.of(context).textTheme.titleMedium),
      if(saving) Semantics(liveRegion:true,child:Text(config.savingText)),
      for(final entry in batchChanges) Padding(key:ValueKey(entry.change.key),padding:const EdgeInsets.symmetric(vertical:8),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('${label(entry.change)} ${entry.change.id??entry.change.key}'),
        if(entry.change.operation!=NgGridEditOperation.delete) for(final field in config.fields) Text('${field.label}: ${entry.change.values[field.key]??""}'),
        Wrap(children:[
          if(entry.change.operation!=NgGridEditOperation.delete) TextButton(onPressed:canReviewBatch?()=>beginQueued(entry.change.key):null,child:Text(config.updateText)),
          TextButton(onPressed:canReviewBatch?()=>undoChange(entry.change.key):null,child:Text(config.undoText)),
        ]),
      ])),
      Wrap(children:[TextButton(onPressed:canSaveBatch?saveBatch:null,child:Text(config.saveBatchText)),TextButton(onPressed:canReviewBatch?discardBatch:null,child:Text(config.discardText))]),
    ])));
  }

  NgGridEditField? cellField(String key) => widget.editing?.fields.where((f) => f.key == key).firstOrNull;
  void beginCell(T row, String key) {
    if (widget.editing?.cellEditing != true || cellField(key) == null || !canEditRow(row, false)) return;
    beginEdit(NgGridEditOperation.update, row);
    if (editOperation == NgGridEditOperation.update) setState(() => editCell = key);
  }
  Widget fieldEditor(NgGridEditField field) {
    final ticket = editRevision;
    final editor = NgGridEditorContext(field, draft[field.key] ?? '', !canCommit, (value) {
      if (!mounted || ticket != editRevision || !canCommit || editOperation == NgGridEditOperation.delete || (editCell != null && editCell != field.key) || cellField(field.key) == null) return;
      setState(() => draft[field.key] = value);
    });
    return widget.editing!.editorBuilder?.call(context, editor) ?? TextFormField(
      key: ValueKey((editRevision, field.key)),
      initialValue: editor.value,
      decoration: InputDecoration(labelText: field.label, helperText: field.required ? '*' : null),
      enabled: !editor.disabled,
      onChanged: editor.setValue,
    );
  }
  Widget gridCell(T row, NgDataColumn<T> column) {
    final field = cellField(column.key);
    if (editCell == column.key && editId == widget.rowId(row) && field != null) {
      return SizedBox(width: 180, child: fieldEditor(field));
    }
    final content = column.cellBuilder?.call(context, row) ?? Text(column.text(row));
    if (widget.editing?.cellEditing != true || field == null) return content;
    return Row(mainAxisSize: MainAxisSize.min, children: [content,
      Semantics(label: '${widget.editing!.updateText} ${column.title} ${widget.rowId(row)}', child: TextButton(
        onPressed: canEditRow(row, false) ? () => beginCell(row, column.key) : null,
        child: Text(widget.editing!.updateText),
      )),
    ]);
  }

  Widget editorPanel() {
    final config = widget.editing!, operation = editOperation!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        container: true,
        label: operation == NgGridEditOperation.create
            ? config.createText
            : operation == NgGridEditOperation.delete
            ? config.deleteText
            : config.updateText,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640),
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${operation == NgGridEditOperation.create
                    ? config.createText
                    : operation == NgGridEditOperation.delete
                    ? config.confirmDeleteText
                    : config.updateText} ${editId ?? ""}',
              ),
              if (editError != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    editError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (saving)
                Semantics(liveRegion: true, child: Text(config.savingText)),
              if (operation != NgGridEditOperation.delete && editCell == null)
                for (final field in config.fields) fieldEditor(field),
              Wrap(
                children: [
                  TextButton(
                    onPressed: canCommit ? commitEdit : null,
                    child: Text(
                      isBatch ? config.stageText : operation == NgGridEditOperation.delete
                          ? config.deleteText
                          : config.saveText,
                    ),
                  ),
                  TextButton(
                    onPressed: saving ? null : () => setState(closeEdit),
                    child: Text(config.cancelText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String search = '';
  final sorts = <NgSortDescriptor>[];
  String? get sortKey => sorts.firstOrNull?.key;
  bool get descending => sorts.firstOrNull?.descending ?? false;
  bool loading = false, error = false;
  int total = 0, revision = 0;
  List<T> remote = [];
  List<NgGridGroup<T>> remoteGroups = [];
  List<String> previousGroupKeys = [];
  bool get isRemote =>
      isRange || widget.readData != null || widget.readGroupedData != null;
  bool get isGrouped =>
      selectors.isNotEmpty ||
      widget.readGroupedData != null ||
      widget.readGroupedRange != null;
  String summaryText(NgGroupSummary s) =>
      widget.remoteSummaryText?.call(s.title, s.value) ??
      '${s.title}: ${s.value == null ? "—" : s.value!.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '')}';
  List<String Function(T)> get selectors =>
      widget.groupBy == null ? widget.groupSelectors : [widget.groupBy!];
  List<T> get queried =>
      NgDataOperations.queryMany(widget.items, widget.columns, search, sorts);
  List<NgGridGroup<T>> get groups =>
      widget.readGroupedData != null || widget.readGroupedRange != null
      ? remoteGroups
      : ngGroupTree(queried, selectors);
  List<T> get rows => isRemote
      ? remote
      : selectors.isEmpty
      ? queried
      : groups.expand((g) => g.items).toList();
  bool isCollapsed(String id) =>
      widget.collapsibleGroups && widget.collapsedGroups.contains(id);
  bool get canToggleGroups =>
      mounted &&
      !loading &&
      !error &&
      widget.collapsibleGroups &&
      !widget.groupExpansionReadOnly &&
      widget.onCollapsedGroupsChanged != null &&
      isGrouped;
  bool canBulk(bool collapse) =>
      canToggleGroups &&
      ngAllGroups(
        groups,
      ).any((g) => widget.collapsedGroups.contains(g.id) != collapse);
  List<(NgGridGroup<T>?, List<T>)> get sections {
    if (widget.readGroupedRange != null)
      return [
        for (final e in groupedRangeEntries)
          (e.$1, e.$1 == null ? [e.$2 as T] : <T>[]),
      ];
    if (!isGrouped) return [(null, visible)];
    final ids = visible.map(widget.rowId).toSet();
    final result = <(NgGridGroup<T>?, List<T>)>[];
    void walk(List<NgGridGroup<T>> nodes) {
      for (final g in nodes) {
        final pageRows = g.items
            .where((r) => ids.contains(widget.rowId(r)))
            .toList();
        if (pageRows.isEmpty) continue;
        result.add((
          g,
          !isCollapsed(g.id) && g.children.isEmpty ? pageRows : <T>[],
        ));
        if (!isCollapsed(g.id)) walk(g.children);
      }
    }

    walk(groups);
    return result;
  }

  List<T> get displayRows => sections.expand((s) => s.$2).toList();
  void toggleGroup(String id) {
    if (!canToggleGroups || !sections.any((s) => s.$1?.id == id)) return;
    final next = {...widget.collapsedGroups};
    if (!next.add(id)) next.remove(id);
    widget.onCollapsedGroupsChanged!(next);
  }

  void bulkGroups(bool collapse) {
    if (!canBulk(collapse)) return;
    final next = {...widget.collapsedGroups};
    for (final g in ngAllGroups(groups)) {
      if (collapse) {
        next.add(g.id);
      } else {
        next.remove(g.id);
      }
    }
    widget.onCollapsedGroupsChanged!(next);
  }

  Widget groupHeader(NgGridGroup<T> group) {
    final expanded = !isCollapsed(group.id);
    final caption = groupTitle(group.key, group.count);
    final label =
        widget.groupToggleLabel?.call(group.path, expanded) ??
        '${expanded ? "Collapse" : "Expand"} ${group.path.map((k) => k.isEmpty ? "(empty)" : k).join(" / ")}';
    return Padding(
      padding: EdgeInsetsDirectional.only(start: group.depth * 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.collapsibleGroups)
            TextButton(
              onPressed: canToggleGroups ? () => toggleGroup(group.id) : null,
              child: Semantics(
                label: label,
                expanded: expanded,
                excludeSemantics: true,
                child: Text('${expanded ? "▾" : "▸"} $caption'),
              ),
            )
          else
            Semantics(
              header: true,
              child: Text(
                caption,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          for (final summary in group.summaries)
            Text(' · ${summaryText(summary)}'),
          for (final aggregate in widget.groupAggregates)
            Text(' · ${aggregate.text(group.items)}'),
        ],
      ),
    );
  }

  String groupTitle(String key, int count) {
    return widget.groupText?.call(key, count) ??
        '${key.isEmpty ? "(empty)" : key} ($count)';
  }

  List<T> get visible => !isRemote
      ? (widget.virtualize
            ? rows
            : rows.skip((page - 1) * size).take(size).toList())
      : remote;
  int get count => !isRemote ? rows.length : total;
  void validate(List<T> values) {
    if (values.any((r) => widget.rowId(r).trim().isEmpty) ||
        values.map(widget.rowId).toSet().length != values.length) {
      throw ArgumentError('Grid row IDs must be nonempty and unique.');
    }
  }

  Future<void> reload() async {
    validateGrouping();
    final ticket = ++revision;
    if (isRange) {
      rangeTimer?.cancel();
      rangeEpoch++;
      rangeKnown = false;
      desiredFirst = rangeStart = total = 0;
      remote = [];
      groupedRangeEntries = [];
      remoteGroups = [];
      cancelExport();
      invalidateEdit();
      await loadRange(0);
      return;
    }
    if (!isRemote) {
      loading = error = false;
      return;
    }
    loading = true;
    error = false;
    remote = [];
    remoteGroups = [];
    try {
      List<T> nextRows;
      List<NgGridGroup<T>> nextGroups = [];
      int nextTotal;
      final groupedReader = widget.readGroupedData;
      if (groupedReader != null) {
        final request = NgGroupedDataRequest(
          page,
          size,
          search,
          sorts,
          widget.remoteGroupKeys,
        );
        final result = await groupedReader(request);
        if (!mounted || ticket != revision) return;
        nextGroups = NgGroupedData.validate(result, request, widget.rowId);
        nextRows = nextGroups.expand((g) => g.items).toList();
        nextTotal = result.total;
      } else {
        final result = await widget.readData!(
          NgDataRequest(page, size, search, sorts),
        );
        if (!mounted || ticket != revision) return;
        if (result.total < 0 ||
            result.items.length > size ||
            result.items.length > result.total)
          throw ArgumentError('Invalid server page.');
        validate(result.items);
        nextRows = List.of(result.items);
        nextTotal = result.total;
      }
      total = nextTotal;
      final clamped = NgDataOperations.clampPage(page, total, size);
      if (clamped != page) {
        page = clamped;
        await reload();
        return;
      }
      remote = nextRows;
      remoteGroups = nextGroups;
    } catch (_) {
      if (mounted && ticket == revision) {
        error = true;
        remote = [];
        remoteGroups = [];
      }
    } finally {
      if (mounted && ticket == revision) setState(() => loading = false);
    }
  }

  void change(VoidCallback action) {
    setState(action);
    reload();
  }

  void sort(String key) {
    if (!widget.columns.any((c) => c.key == key && c.sortable)) return;
    change(() {
      final index = sorts.indexWhere((s) => s.key == key);
      final old = index < 0 ? null : sorts[index];
      if (!widget.multiSort) {
        sorts.clear();
      } else if (index >= 0) {
        sorts.removeAt(index);
      }
      final next = NgSortDescriptor(
        key,
        descending: old != null && !old.descending,
      );
      sorts.insert(widget.multiSort && index >= 0 ? index : sorts.length, next);
      page = 1;
    });
  }

  @override
  void didUpdateWidget(covariant NgDataGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataVersion != widget.dataVersion ||
        oldWidget.readGroupedRange != widget.readGroupedRange ||
        oldWidget.readRange != widget.readRange ||
        oldWidget.readData != widget.readData ||
        oldWidget.readGroupedData != widget.readGroupedData ||
        widget.export == null ||
        widget.export!.readOnly)
      cancelExport();
    if (oldWidget.dataVersion != widget.dataVersion ||
        oldWidget.readGroupedRange != widget.readGroupedRange ||
        oldWidget.readRange != widget.readRange ||
        oldWidget.readData != widget.readData ||
        oldWidget.readGroupedData != widget.readGroupedData ||
        ((oldWidget.editing?.commitBatch != null) != isBatch) ||
        (oldWidget.editing != null && widget.editing == null))
      invalidateEdit();
    validateGrouping();
    final before = sorts.length;
    sorts.removeWhere(
      (s) => !widget.columns.any((c) => c.key == s.key && c.sortable),
    );
    if (!widget.multiSort && sorts.length > 1)
      sorts.removeRange(1, sorts.length);
    if ((oldWidget.groupBy == null && oldWidget.groupSelectors.isEmpty) !=
        (selectors.isEmpty))
      page = 1;
    if (oldWidget.readGroupedRange != widget.readGroupedRange ||
        oldWidget.readRange != widget.readRange ||
        isRange &&
            (oldWidget.rowHeight != widget.rowHeight ||
                oldWidget.viewportHeight != widget.viewportHeight ||
                oldWidget.columns
                        .map((c) => '${c.key}:${c.sortable}')
                        .join('|') !=
                    widget.columns
                        .map((c) => '${c.key}:${c.sortable}')
                        .join('|')) ||
        oldWidget.readData != widget.readData ||
        oldWidget.readGroupedData != widget.readGroupedData ||
        ngGroupId(previousGroupKeys) != ngGroupId(widget.remoteGroupKeys) ||
        oldWidget.dataVersion != widget.dataVersion ||
        before != sorts.length ||
        widget.readGroupedRange != null &&
            previousCollapsed != collapseSignature) {
      page = 1;
      previousCollapsed = collapseSignature;
      previousGroupKeys = List.of(widget.remoteGroupKeys);
      reload();
    }
  }

  @override
  void dispose() {
    rangeTimer?.cancel();
    cancelExport();
    revision++;
    super.dispose();
  }

  int page = 1;
  late int size;
  @override
  void initState() {
    super.initState();
    validateGrouping();
    previousCollapsed = collapseSignature;
    previousGroupKeys = List.of(widget.remoteGroupKeys);
    size = widget.initialPageSize < 1 ? 1 : widget.initialPageSize;
    reload();
  }

  bool canChange(T row) =>
      !loading &&
      !error &&
      !widget.selectionReadOnly &&
      widget.onSelectionChanged != null &&
      (widget.canSelect?.call(row) ?? true);
  void selectRow(T row) {
    if (!mounted) return;
    final matches = (!isRemote ? widget.items : remote).where(
      (item) => widget.rowId(item) == widget.rowId(row),
    );
    if (matches.isEmpty ||
        !canChange(matches.first) ||
        !displayRows.any((r) => widget.rowId(r) == widget.rowId(row)))
      return;
    final next = {...widget.selectedIds};
    if (!next.add(widget.rowId(row))) next.remove(widget.rowId(row));
    widget.onSelectionChanged!(next);
  }

  void validateGrouping() {
    if (widget.variableRowHeight && (!widget.virtualize || isRange)) {
      throw ArgumentError("variableRowHeight requires virtual local data or server pages; continuous range readers require fixed heights.");
    }
    if (isRange) {
      _checkVirtual(true, widget.rowHeight, widget.viewportHeight);
      if (!widget.virtualize ||
          widget.readData != null ||
          widget.readGroupedData != null ||
          widget.items.isNotEmpty ||
          selectors.isNotEmpty ||
          widget.groupAggregates.isNotEmpty ||
          widget.readRange != null &&
              (widget.readGroupedRange != null ||
                  widget.remoteGroupKeys.isNotEmpty)) {
        throw ArgumentError(
          'readRange requires virtualize and cannot be combined with items, page readers or grouping.',
        );
      }
      if (widget.rowHeight > 128 ||
          (widget.viewportHeight / widget.rowHeight).ceil() > 128)
        throw ArgumentError(
          'Range mode supports rows up to 128px and at most 128 visible rows.',
        );
    }

    widget.export?.resolve(widget.columns);
    widget.editing?.check();
    if (widget.groupBy != null && widget.groupSelectors.isNotEmpty)
      throw ArgumentError('Use groupBy or groupSelectors, not both.');
    if (selectors.length > 8)
      throw ArgumentError('At most eight group levels are supported.');
    for (final aggregate in widget.groupAggregates) {
      aggregate.calculate(<T>[]);
    }
    if (widget.readGroupedRange != null)
      NgGroupedData.validateKeys(widget.remoteGroupKeys);
    if (widget.readGroupedData != null) {
      NgGroupedData.validateKeys(widget.remoteGroupKeys);
      if (widget.readData != null ||
          selectors.isNotEmpty ||
          widget.groupAggregates.isNotEmpty)
        throw ArgumentError(
          'Grouped remote mode cannot use readData or local grouping/aggregates.',
        );
    } else if (widget.readGroupedRange == null &&
        widget.remoteGroupKeys.isNotEmpty) {
      throw ArgumentError('Remote group keys require readGroupedData.');
    }
    if (selectors.isNotEmpty && widget.readData != null)
      throw ArgumentError('Local grouping requires items, not readData.');
  }

  @override
  Widget build(BuildContext context) {
    _checkVirtual(widget.virtualize, widget.rowHeight, widget.viewportHeight);
    validateGrouping();
    if (widget.items.any((row) => widget.rowId(row).trim().isEmpty) ||
        widget.items.map(widget.rowId).toSet().length != widget.items.length)
      throw ArgumentError('Grid row IDs must be nonempty and unique.');
    if (widget.columns.isEmpty ||
        widget.columns.any((c) => c.key.trim().isEmpty) ||
        widget.columns.map((c) => c.key).toSet().length !=
            widget.columns.length)
      throw ArgumentError(
        'Grid column keys must be nonempty and unique, with at least one column.',
      );
    if (!loading) page = NgDataOperations.clampPage(page, count, size);
    final displaySections = sections;
    final entries = <(NgGridGroup<T>?, T?)>[
      for (final section in displaySections) ...[
        if (section.$1 != null) (section.$1, null),
        for (final row in section.$2) (null, row),
      ],
    ];
    final eligible = displaySections
        .expand((s) => s.$2)
        .where((row) => widget.canSelect?.call(row) ?? true)
        .toList();
    final selectionVisible = widget.onSelectionChanged != null;
    final selectedCount = eligible
        .where((row) => widget.selectedIds.contains(widget.rowId(row)))
        .length;
    final sortIndex = widget.columns.indexWhere((c) => c.key == sortKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loading)
          Semantics(liveRegion: true, child: Text(widget.loadingText)),
        if (error)
          Row(
            children: [
              Text(widget.errorText),
              TextButton(onPressed: retryRead, child: Text(widget.retryText)),
            ],
          ),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search ${widget.label}',
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => change(() {
                  search = v;
                  page = 1;
                }),
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Text('${widget.selectedIds.length} selected'),
            ),
            ?widget.toolbar,
            if (widget.multiSort)
              TextButton(
                onPressed: sorts.isEmpty
                    ? null
                    : () => change(() {
                        sorts.clear();
                        page = 1;
                      }),
                child: const Text('Clear sorting'),
              ),
          ],
        ),
        if (widget.editing case final config?)
          TextButton(
            onPressed: canCreate
                ? () => beginEdit(NgGridEditOperation.create, null)
                : null,
            child: Text(config.createText),
          ),
        const SizedBox(height: 16),
        if (widget.collapsibleGroups && isGrouped)
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: canBulk(false) ? () => bulkGroups(false) : null,
                child: Text(
                  widget.readGroupedRange != null
                      ? widget.expandWindowGroupsText
                      : widget.readGroupedData == null
                      ? widget.expandGroupsText
                      : widget.expandPageGroupsText,
                ),
              ),
              TextButton(
                onPressed: canBulk(true) ? () => bulkGroups(true) : null,
                child: Text(
                  widget.readGroupedRange != null
                      ? widget.collapseWindowGroupsText
                      : widget.readGroupedData == null
                      ? widget.collapseGroupsText
                      : widget.collapsePageGroupsText,
                ),
              ),
            ],
          ),
        if (widget.export != null) exportToolbar(),
        LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: _NgDataTable(
                selectionColumn: selectionVisible,
                virtualize: widget.virtualize,
                variableRowHeight: widget.variableRowHeight,
                rowHeight: widget.rowHeight,
                viewportHeight: widget.viewportHeight,
                width: c.maxWidth,
                // Flutter Web can retain stale row semantics after keyed reordering.
                // Refresh the view identity; selection stays in caller-owned IDs.
                onWindowChanged: isRange ? rangeViewport : null,
                key: ValueKey(
                  isRange
                      ? rangeEpoch
                      : jsonEncode([widget.variableRowHeight,sortKey,descending,page,search,entries.map((e)=>e.$1==null?['row',widget.rowId(e.$2 as T)]:['group',e.$1!.id]).toList()]),
                ),
                sortColumnIndex: sortIndex < 0
                    ? null
                    : sortIndex + (selectionVisible ? 1 : 0),
                sortAscending: !descending,
                showCheckboxColumn: false,
                columnSpacing: 24,
                columns: [
                  if (selectionVisible)
                    DataColumn(
                      label: Semantics(
                        label:
                            selectedCount > 0 && selectedCount < eligible.length
                            ? '${isRange
                                  ? widget.selectWindowText
                                  : widget.virtualize && !isRemote
                                  ? 'Select results'
                                  : 'Select page'} (partially selected)'
                            : (isRange
                                  ? widget.selectWindowText
                                  : widget.virtualize && !isRemote
                                  ? 'Select results'
                                  : 'Select page'),
                        container: true,
                        child: Checkbox(
                          tristate: true,
                          value: selectedCount == 0
                              ? false
                              : selectedCount == eligible.length
                              ? true
                              : null,
                          onChanged:
                              loading ||
                                  error ||
                                  widget.selectionReadOnly ||
                                  eligible.isEmpty
                              ? null
                              : (_) {
                                  if (!mounted ||
                                      widget.selectionReadOnly ||
                                      widget.onSelectionChanged == null)
                                    return;
                                  final current = displayRows
                                      .where(canChange)
                                      .toList();
                                  if (current.isEmpty) return;
                                  final remove = current.every(
                                    (row) => widget.selectedIds.contains(
                                      widget.rowId(row),
                                    ),
                                  );
                                  final next = {...widget.selectedIds};
                                  for (final row in current) {
                                    if (remove) {
                                      next.remove(widget.rowId(row));
                                    } else {
                                      next.add(widget.rowId(row));
                                    }
                                  }
                                  widget.onSelectionChanged!(next);
                                },
                        ),
                      ),
                    ),
                  for (final column in widget.columns)
                    DataColumn(
                      label: Text(
                        widget.multiSort &&
                                sorts.any((s) => s.key == column.key)
                            ? '${column.title} ${sorts.indexWhere((s) => s.key == column.key) + 1}${sorts.firstWhere((s) => s.key == column.key).descending ? "↓" : "↑"}'
                            : column.title,
                      ),
                      onSort: column.sortable
                          ? (i, ascending) => sort(column.key)
                          : null,
                    ),
                  if (hasActions) const DataColumn(label: Text('Actions')),
                ],
                rowCount: isRange ? total : entries.length,
                rowBuilder: (index) {
                  final offset = isRange ? index - rangeStart : index;
                  if (isRange &&
                      (loading ||
                          error ||
                          offset < 0 ||
                          offset >= loadedSlotCount)) {
                    return DataRow(
                      key: ValueKey(('placeholder', index)),
                      cells: [
                        if (selectionVisible) const DataCell(SizedBox.shrink()),
                        for (var c = 0; c < widget.columns.length; c++)
                          DataCell(
                            Text(
                              c == 0
                                  ? (error
                                        ? widget.errorText
                                        : widget.loadingText)
                                  : '',
                            ),
                          ),
                        if (hasActions) const DataCell(SizedBox.shrink()),
                      ],
                    );
                  }
                  final entry = entries[offset];
                  if (entry.$1 case final group?)
                    return DataRow(
                      key: ValueKey(('group', group.id)),
                      color: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      cells: [
                        if (selectionVisible) const DataCell(SizedBox.shrink()),
                        for (var i = 0; i < widget.columns.length; i++)
                          DataCell(
                            i == 0
                                ? groupHeader(group)
                                : const SizedBox.shrink(),
                          ),
                        if (hasActions) const DataCell(SizedBox.shrink()),
                      ],
                    );
                  final row = entry.$2 as T;
                  return DataRow(
                    key: ValueKey(widget.rowId(row)),
                    selected: widget.selectedIds.contains(widget.rowId(row)),
                    onSelectChanged: canChange(row)
                        ? (_) => selectRow(row)
                        : null,
                    cells: [
                      if (selectionVisible)
                        DataCell(
                          Semantics(
                            label: 'Select ${widget.rowId(row)}',
                            child: Checkbox(
                              value: widget.selectedIds.contains(
                                widget.rowId(row),
                              ),
                              onChanged: canChange(row)
                                  ? (_) => selectRow(row)
                                  : null,
                            ),
                          ),
                        ),
                      for (final column in widget.columns)
                        DataCell(
                          gridCell(row, column),
                        ),
                      if (hasActions)
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.rowActions != null)
                                widget.rowActions!(context, row),
                              if (widget.editing case final config?) ...[
                                TextButton(
                                  onPressed: canEditRow(row, false)
                                      ? () => beginEdit(
                                          NgGridEditOperation.update,
                                          row,
                                        )
                                      : null,
                                  child: Semantics(
                                    label:
                                        '${config.updateText} ${widget.rowId(row)}',
                                    excludeSemantics: true,
                                    child: Text(config.updateText),
                                  ),
                                ),
                                TextButton(
                                  onPressed: canEditRow(row, true)
                                      ? () => beginEdit(
                                          NgGridEditOperation.delete,
                                          row,
                                        )
                                      : null,
                                  child: Semantics(
                                    label:
                                        '${config.deleteText} ${widget.rowId(row)}',
                                    excludeSemantics: true,
                                    child: Text(config.deleteText),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (!loading &&
            !error &&
            rows.isEmpty &&
            (!isRange || rangeKnown && total == 0))
          Padding(
            padding: const EdgeInsets.all(24),
            child: widget.emptyBuilder ?? Text(widget.emptyText),
          ),
        if (editOperation == null && editError != null)
          Semantics(liveRegion: true, child: Text(editError!)),
        if (editOperation != null && widget.editing != null) editorPanel(),
        if (isBatch && batchChanges.isNotEmpty) batchPanel(),
        if (isRange)
          Semantics(
            liveRegion: true,
            child: Text(
              '${widget.loadedWindowText}: ${remote.isEmpty ? "0" : "${rangeStart + 1}–${rangeStart + loadedSlotCount}"} / $total',
            ),
          ),
        if (!isRange && (!widget.virtualize || isRemote))
          NgPager(
            total: count,
            page: page,
            pageSize: size,
            sizes: widget.pageSizes,
            onPageChanged: (v) => change(() => page = v),
            onPageSizeChanged: (v) => change(() {
              size = v;
              page = 1;
            }),
          ),
      ],
    );
  }
}

class NgTreeView<T> extends StatefulWidget {
  final bool virtualize;
  final double rowHeight, viewportHeight;
  final Widget Function(BuildContext, T)? itemBuilder;
  final List<NgTreeNode<T>> items;
  final Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)? loadChildren;
  final Object? dataVersion;
  final String loadingText, errorText;
  final String Function(T) text;
  final String label, emptyText;
  final bool selectionReadOnly, expansionReadOnly;
  final bool checkboxes, checkingReadOnly, checkChildren;
  final String partialCheckText;
  final bool showCheckActions;
  final String checkLoadedText, clearLoadedText;
  final Set<String> checkedIds;
  final ValueChanged<Set<String>>? onCheckedChanged;
  final bool Function(NgTreeNode<T>)? canCheck;
  final String Function(T)? checkLabel;
  final Widget? emptyBuilder;
  final String? selectedId;
  final Set<String> expandedIds;
  final ValueChanged<String>? onSelected;
  final ValueChanged<Set<String>> onExpandedChanged;
  const NgTreeView({
    super.key,
    this.virtualize = false,
    this.rowHeight = 48,
    this.viewportHeight = 384,
    required this.items,
    this.loadChildren,
    this.dataVersion,
    this.loadingText = 'Loading children…',
    this.errorText = 'Unable to load children. Expand to retry.',
    required this.text,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Folders',
    this.showCheckActions = false,
    this.checkLoadedText = 'Check loaded nodes',
    this.clearLoadedText = 'Clear loaded checks',
    this.partialCheckText = 'Partially checked',
    this.checkChildren = false,
    this.checkboxes = false,
    this.checkingReadOnly = false,
    this.checkedIds = const {},
    this.onCheckedChanged,
    this.canCheck,
    this.checkLabel,
    this.selectionReadOnly = false,
    this.expansionReadOnly = false,
    this.emptyBuilder,
    this.emptyText = 'No matching items.',
    this.itemBuilder,
  });
  @override
  State<NgTreeView<T>> createState() => _NgTreeViewState<T>();
}

class _NgTreeViewState<T> extends State<NgTreeView<T>> {
  String search = '';
  final virtualScroll = ScrollController();
  final lazy = _LazyTreeCache<T>();
  @override
  void initState() {
    super.initState();
    lazy.update(widget.items, widget.loadChildren, widget.dataVersion);
  }

  @override
  void didUpdateWidget(covariant NgTreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    lazy.update(widget.items, widget.loadChildren, widget.dataVersion);
  }

  final nodes = <String, FocusNode>{};
  List<NgTreeRow<T>> get rows => NgDataOperations.flatten<T>(
    lazy.resolve(widget.items),
    widget.expandedIds,
    widget.text,
    search: search,
  );
  NgTreeNode<T>? currentNode(String id) => NgDataOperations.flatten(
    lazy.resolve(widget.items),
    widget.expandedIds,
    widget.text,
    search: search,
  ).where((r) => r.node.id == id).firstOrNull?.node;
  void select(String id) {
    if (!mounted || widget.selectionReadOnly) return;
    final node = currentNode(id);
    if (node == null || node.disabled) return;
    widget.onSelected?.call(id);
  }

  List<String> get checkTargets => lazy
      .resolve(widget.items)
      .where((n) => !n.disabled && (widget.canCheck?.call(n) ?? true))
      .expand((n) => _treeCheckTargets(n, true, widget.canCheck))
      .toList();
  bool canCheckLoaded(bool value) =>
      mounted &&
      widget.checkboxes &&
      widget.showCheckActions &&
      !widget.checkingReadOnly &&
      widget.onCheckedChanged != null &&
      checkTargets.any((id) => widget.checkedIds.contains(id) != value);
  void checkLoaded(bool value) {
    if (!canCheckLoaded(value)) return;
    final next = {...widget.checkedIds};
    if (value) {
      next.addAll(checkTargets);
    } else {
      next.removeAll(checkTargets);
    }
    widget.onCheckedChanged!(next);
  }

  bool canToggleCheck(NgTreeNode<T> node) =>
      mounted &&
      widget.checkboxes &&
      !widget.checkingReadOnly &&
      widget.onCheckedChanged != null &&
      !node.disabled &&
      (widget.canCheck?.call(node) ?? true);
  void toggleCheck(String id) {
    if (!mounted) return;
    final node = currentNode(id);
    if (node == null || !canToggleCheck(node)) return;
    final next = _toggleTreeCheck(
      node,
      widget.checkedIds,
      widget.checkChildren,
      widget.canCheck,
    );
    widget.onCheckedChanged!(next);
  }

  Future<void> toggle(String id) async {
    if (!mounted || widget.expansionReadOnly || search.trim().isNotEmpty)
      return;
    final node = currentNode(id);
    if (node == null ||
        node.disabled ||
        (node.children.isEmpty && !node.hasChildren))
      return;
    if (!widget.expandedIds.contains(id)) {
      final pending = lazy.ensure(node);
      setState(() {});
      final accepted = await pending;
      if (!mounted) return;
      setState(() {});
      if (!accepted) return;
    }
    if (!mounted || widget.expansionReadOnly || search.trim().isNotEmpty)
      return;
    final latest = currentNode(id);
    if (latest == null || latest.disabled) return;
    final next = {...widget.expandedIds};
    if (!next.add(id)) next.remove(id);
    widget.onExpandedChanged(next);
  }

  @override
  void dispose() {
    virtualScroll.dispose();
    lazy.revision++;
    for (final n in nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkVirtual(widget.virtualize, widget.rowHeight, widget.viewportHeight);
    final visible = rows;
    Widget buildRow(NgTreeRow<T> row) => Focus(
      key: ValueKey(row.node.id),
      focusNode: nodes.putIfAbsent(row.node.id, () => FocusNode()),
      canRequestFocus: !row.node.disabled,
      onKeyEvent: (focus, e) {
        if (e is! KeyDownEvent || row.node.disabled || !focus.hasPrimaryFocus)
          return KeyEventResult.ignored;
        final key = e.logicalKey;
        final enabled = visible.where((r) => !r.node.disabled).toList();
        final index = enabled.indexOf(row);
        String? target;
        if (key == LogicalKeyboardKey.arrowDown && index < enabled.length - 1)
          target = enabled[index + 1].node.id;
        if (key == LogicalKeyboardKey.arrowUp && index > 0)
          target = enabled[index - 1].node.id;
        if (key == LogicalKeyboardKey.home) target = enabled.first.node.id;
        if (key == LogicalKeyboardKey.end) target = enabled.last.node.id;
        if (key == LogicalKeyboardKey.arrowRight) {
          if (!row.expanded &&
              (row.node.children.isNotEmpty || row.node.hasChildren) &&
              search.trim().isEmpty) {
            toggle(row.node.id);
          } else if (row.expanded && index < enabled.length - 1) {
            target = enabled
                .skip(index + 1)
                .where((r) => r.parentId == row.node.id)
                .firstOrNull
                ?.node
                .id;
          }
        }
        if (key == LogicalKeyboardKey.arrowLeft) {
          if (row.expanded &&
              (row.node.children.isNotEmpty || row.node.hasChildren) &&
              search.trim().isEmpty) {
            toggle(row.node.id);
          } else {
            target = enabled
                .where((r) => r.node.id == row.parentId)
                .firstOrNull
                ?.node
                .id;
          }
        }
        if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space)
          select(row.node.id);
        if (target != null) {
          final id = target;
          if (widget.virtualize && virtualScroll.hasClients) {
            final offset =
                visible.indexWhere((r) => r.node.id == id) * widget.rowHeight;
            if (offset < virtualScroll.offset ||
                offset + widget.rowHeight >
                    virtualScroll.offset + widget.viewportHeight) {
              virtualScroll.jumpTo(
                offset.clamp(0, virtualScroll.position.maxScrollExtent),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) nodes[id]?.requestFocus();
            });
          } else {
            nodes[id]?.requestFocus();
          }
        }
        return [
              LogicalKeyboardKey.arrowDown,
              LogicalKeyboardKey.arrowUp,
              LogicalKeyboardKey.arrowLeft,
              LogicalKeyboardKey.arrowRight,
              LogicalKeyboardKey.home,
              LogicalKeyboardKey.end,
              LogicalKeyboardKey.enter,
              LogicalKeyboardKey.space,
            ].contains(key)
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: Builder(
        builder: (ctx) => Semantics(
          selected: widget.selectedId == row.node.id,
          enabled: !row.node.disabled,
          child: Material(
            color: widget.selectedId == row.node.id
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
                : Colors.transparent,
            child: InkWell(
              canRequestFocus: false,
              onTap: row.node.disabled
                  ? null
                  : () {
                      nodes[row.node.id]?.requestFocus();
                      select(row.node.id);
                    },
              child: Container(
                decoration: BoxDecoration(
                  border: Focus.of(ctx).hasFocus
                      ? Border.all(color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                padding: EdgeInsets.only(left: row.depth * 20),
                constraints: const BoxConstraints(minHeight: 40),
                child: Row(
                  children: [
                    if ((row.node.children.isNotEmpty || row.node.hasChildren))
                      IconButton(
                        tooltip:
                            '${row.expanded ? 'Collapse' : 'Expand'} ${widget.text(row.node.item)}',
                        onPressed:
                            row.node.disabled ||
                                lazy.loading.contains(row.node.id) ||
                                widget.expansionReadOnly ||
                                search.trim().isNotEmpty
                            ? null
                            : () => toggle(row.node.id),
                        icon: Icon(
                          row.expanded
                              ? Icons.expand_more
                              : Icons.chevron_right,
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                    if (widget.checkboxes)
                      Semantics(
                        container: true,
                        value:
                            _treeCheckState(
                                  row.node,
                                  widget.checkedIds,
                                  widget.checkChildren,
                                  widget.canCheck,
                                ) ==
                                null
                            ? widget.partialCheckText
                            : null,
                        label:
                            widget.checkLabel?.call(row.node.item) ??
                            'Check ${widget.text(row.node.item)}',
                        child: Checkbox(
                          tristate: widget.checkChildren,
                          value: _treeCheckState(
                            row.node,
                            widget.checkedIds,
                            widget.checkChildren,
                            widget.canCheck,
                          ),
                          onChanged: canToggleCheck(row.node)
                              ? (_) => toggleCheck(row.node.id)
                              : null,
                        ),
                      ),
                    if (lazy.loading.contains(row.node.id))
                      Text(widget.loadingText),
                    if (lazy.errors.contains(row.node.id))
                      Text(widget.errorText),
                    Expanded(
                      child: widget.itemBuilder == null
                          ? Text(
                              widget.text(row.node.item),
                              style: TextStyle(
                                color: row.node.disabled
                                    ? Theme.of(context).disabledColor
                                    : null,
                              ),
                            )
                          : Semantics(
                              label: widget.text(row.node.item),
                              excludeSemantics: true,
                              child: widget.itemBuilder!(
                                context,
                                row.node.item,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Search ${widget.label}'),
          onChanged: (v) => setState(() => search = v),
        ),
        if (widget.checkboxes && widget.showCheckActions)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: canCheckLoaded(true)
                    ? () => checkLoaded(true)
                    : null,
                child: Text(widget.checkLoadedText),
              ),
              TextButton(
                onPressed: canCheckLoaded(false)
                    ? () => checkLoaded(false)
                    : null,
                child: Text(widget.clearLoadedText),
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (widget.virtualize)
          SizedBox(
            height: widget.viewportHeight,
            child: ListView.builder(
              controller: virtualScroll,
              itemExtent: widget.rowHeight,
              itemCount: visible.length,
              itemBuilder: (context, index) => buildRow(visible[index]),
            ),
          )
        else
          for (final row in visible) buildRow(row),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: widget.emptyBuilder ?? Text(widget.emptyText),
          ),
      ],
    );
  }
}

class NgTreeList<T> extends StatefulWidget {
  final bool virtualize;
  final double rowHeight, viewportHeight;
  final List<NgTreeNode<T>> items;
  final Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)? loadChildren;
  final Object? dataVersion;
  final String loadingText, errorText;
  final List<NgDataColumn<T>> columns;
  final Set<String> expandedIds;
  final ValueChanged<Set<String>> onExpandedChanged;
  final ValueChanged<String>? onSelected;
  final String? selectedId;
  final String label, emptyText;
  final bool selectionReadOnly, expansionReadOnly;
  final bool checkboxes, checkingReadOnly, checkChildren;
  final String partialCheckText;
  final bool showCheckActions;
  final String checkLoadedText, clearLoadedText;
  final Set<String> checkedIds;
  final ValueChanged<Set<String>>? onCheckedChanged;
  final bool Function(NgTreeNode<T>)? canCheck;
  final String Function(T)? checkLabel;
  final Widget? emptyBuilder;
  const NgTreeList({
    super.key,
    this.virtualize = false,
    this.rowHeight = 48,
    this.viewportHeight = 384,
    required this.items,
    this.loadChildren,
    this.dataVersion,
    this.loadingText = 'Loading children…',
    this.errorText = 'Unable to load children. Expand to retry.',
    required this.columns,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Hierarchy',
    this.showCheckActions = false,
    this.checkLoadedText = 'Check loaded nodes',
    this.clearLoadedText = 'Clear loaded checks',
    this.partialCheckText = 'Partially checked',
    this.checkChildren = false,
    this.checkboxes = false,
    this.checkingReadOnly = false,
    this.checkedIds = const {},
    this.onCheckedChanged,
    this.canCheck,
    this.checkLabel,
    this.selectionReadOnly = false,
    this.expansionReadOnly = false,
    this.emptyBuilder,
    this.emptyText = 'No matching items.',
  });
  @override
  State<NgTreeList<T>> createState() => _NgTreeListState<T>();
}

class _NgTreeListState<T> extends State<NgTreeList<T>> {
  String search = '';
  final lazy = _LazyTreeCache<T>();
  @override
  void initState() {
    super.initState();
    lazy.update(widget.items, widget.loadChildren, widget.dataVersion);
  }

  @override
  void didUpdateWidget(covariant NgTreeList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    lazy.update(widget.items, widget.loadChildren, widget.dataVersion);
  }

  String? sortKey;
  bool descending = false;
  NgTreeNode<T>? currentNode(String id) => NgDataOperations.flatten(
    lazy.resolve(widget.items),
    widget.expandedIds,
    (item) => widget.columns.map((c) => c.text(item)).join(' '),
    search: search,
  ).where((r) => r.node.id == id).firstOrNull?.node;
  void select(String id) {
    if (!mounted || widget.selectionReadOnly) return;
    final node = currentNode(id);
    if (node == null || node.disabled) return;
    widget.onSelected?.call(id);
  }

  List<String> get checkTargets => lazy
      .resolve(widget.items)
      .where((n) => !n.disabled && (widget.canCheck?.call(n) ?? true))
      .expand((n) => _treeCheckTargets(n, true, widget.canCheck))
      .toList();
  bool canCheckLoaded(bool value) =>
      mounted &&
      widget.checkboxes &&
      widget.showCheckActions &&
      !widget.checkingReadOnly &&
      widget.onCheckedChanged != null &&
      checkTargets.any((id) => widget.checkedIds.contains(id) != value);
  void checkLoaded(bool value) {
    if (!canCheckLoaded(value)) return;
    final next = {...widget.checkedIds};
    if (value) {
      next.addAll(checkTargets);
    } else {
      next.removeAll(checkTargets);
    }
    widget.onCheckedChanged!(next);
  }

  bool canToggleCheck(NgTreeNode<T> node) =>
      mounted &&
      widget.checkboxes &&
      !widget.checkingReadOnly &&
      widget.onCheckedChanged != null &&
      !node.disabled &&
      (widget.canCheck?.call(node) ?? true);
  void toggleCheck(String id) {
    if (!mounted) return;
    final node = currentNode(id);
    if (node == null || !canToggleCheck(node)) return;
    final next = _toggleTreeCheck(
      node,
      widget.checkedIds,
      widget.checkChildren,
      widget.canCheck,
    );
    widget.onCheckedChanged!(next);
  }

  Future<void> toggle(String id) async {
    if (!mounted || widget.expansionReadOnly || search.trim().isNotEmpty)
      return;
    final node = currentNode(id);
    if (node == null ||
        node.disabled ||
        (node.children.isEmpty && !node.hasChildren))
      return;
    if (!widget.expandedIds.contains(id)) {
      final pending = lazy.ensure(node);
      setState(() {});
      final accepted = await pending;
      if (!mounted) return;
      setState(() {});
      if (!accepted) return;
    }
    if (!mounted || widget.expansionReadOnly || search.trim().isNotEmpty)
      return;
    final latest = currentNode(id);
    if (latest == null || latest.disabled) return;
    final next = {...widget.expandedIds};
    if (!next.add(id)) next.remove(id);
    widget.onExpandedChanged(next);
  }

  @override
  void dispose() {
    lazy.revision++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkVirtual(widget.virtualize, widget.rowHeight, widget.viewportHeight);
    if (widget.columns.isEmpty ||
        widget.columns.any((c) => c.key.trim().isEmpty) ||
        widget.columns.map((c) => c.key).toSet().length !=
            widget.columns.length)
      throw ArgumentError(
        'TreeList needs nonempty unique column keys and at least one column.',
      );
    if (!widget.columns.any((c) => c.key == sortKey && c.sortable))
      sortKey = null;
    final column = widget.columns
        .where((c) => c.key == sortKey && c.sortable)
        .firstOrNull;
    final sortIndex = widget.columns.indexWhere((c) => c.key == sortKey);
    final rows = NgDataOperations.flatten<T>(
      lazy.resolve(widget.items),
      widget.expandedIds,
      (item) => widget.columns.map((c) => c.text(item)).join(' '),
      search: search,
      compareNodes: column == null
          ? null
          : (a, b) =>
                NgDataOperations.compare(
                  column.value(a.item),
                  column.value(b.item),
                ) *
                (descending ? -1 : 1),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Search ${widget.label}'),
          onChanged: (v) => setState(() => search = v),
        ),
        if (widget.checkboxes && widget.showCheckActions)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: canCheckLoaded(true)
                    ? () => checkLoaded(true)
                    : null,
                child: Text(widget.checkLoadedText),
              ),
              TextButton(
                onPressed: canCheckLoaded(false)
                    ? () => checkLoaded(false)
                    : null,
                child: Text(widget.clearLoadedText),
              ),
            ],
          ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: _NgDataTable(
                virtualize: widget.virtualize,
                rowHeight: widget.rowHeight,
                viewportHeight: widget.viewportHeight,
                width: c.maxWidth,
                // Flutter Web can retain stale row semantics after keyed reordering.
                // Refresh the view identity; selection stays in caller-owned IDs.
                key: ValueKey(
                  '$sortKey:$descending:$search:${rows.map((r) => r.node.id).join(',')}',
                ),
                showCheckboxColumn: false,
                sortColumnIndex: sortIndex < 0 ? null : sortIndex,
                sortAscending: !descending,
                columns: [
                  for (final col in widget.columns)
                    DataColumn(
                      label: Text(col.title),
                      onSort: col.sortable
                          ? (i, a) => setState(() {
                              descending = sortKey == col.key && !descending;
                              sortKey = col.key;
                            })
                          : null,
                    ),
                ],
                rowCount: rows.length,
                rowBuilder: (index) {
                  final row = rows[index];
                  return DataRow(
                    key: ValueKey(row.node.id),
                    selected: widget.selectedId == row.node.id,
                    cells: [
                      for (var i = 0; i < widget.columns.length; i++)
                        DataCell(
                          i == 0
                              ? Row(
                                  children: [
                                    SizedBox(width: row.depth * 20),
                                    if ((row.node.children.isNotEmpty ||
                                        row.node.hasChildren))
                                      IconButton(
                                        tooltip:
                                            '${row.expanded ? 'Collapse' : 'Expand'} ${widget.columns[i].text(row.node.item)}',
                                        onPressed:
                                            row.node.disabled ||
                                                lazy.loading.contains(
                                                  row.node.id,
                                                ) ||
                                                widget.expansionReadOnly ||
                                                search.trim().isNotEmpty
                                            ? null
                                            : () => toggle(row.node.id),
                                        icon: Icon(
                                          row.expanded
                                              ? Icons.expand_more
                                              : Icons.chevron_right,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 40),
                                    if (widget.checkboxes)
                                      Semantics(
                                        container: true,
                                        value:
                                            _treeCheckState(
                                                  row.node,
                                                  widget.checkedIds,
                                                  widget.checkChildren,
                                                  widget.canCheck,
                                                ) ==
                                                null
                                            ? widget.partialCheckText
                                            : null,
                                        label:
                                            widget.checkLabel?.call(
                                              row.node.item,
                                            ) ??
                                            'Check ${widget.columns.first.text(row.node.item)}',
                                        child: Checkbox(
                                          tristate: widget.checkChildren,
                                          value: _treeCheckState(
                                            row.node,
                                            widget.checkedIds,
                                            widget.checkChildren,
                                            widget.canCheck,
                                          ),
                                          onChanged: canToggleCheck(row.node)
                                              ? (_) => toggleCheck(row.node.id)
                                              : null,
                                        ),
                                      ),
                                    if (lazy.loading.contains(row.node.id))
                                      Text(widget.loadingText),
                                    if (lazy.errors.contains(row.node.id))
                                      Text(widget.errorText),
                                    TextButton(
                                      onPressed:
                                          row.node.disabled ||
                                              lazy.loading.contains(
                                                row.node.id,
                                              ) ||
                                              widget.selectionReadOnly ||
                                              widget.onSelected == null
                                          ? null
                                          : () => select(row.node.id),
                                      child: Semantics(
                                        label: widget.columns[i].text(
                                          row.node.item,
                                        ),
                                        excludeSemantics: true,
                                        child:
                                            widget.columns[i].cellBuilder?.call(
                                              context,
                                              row.node.item,
                                            ) ??
                                            Text(
                                              widget.columns[i].text(
                                                row.node.item,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                )
                              : widget.columns[i].cellBuilder?.call(
                                      context,
                                      row.node.item,
                                    ) ??
                                    Text(widget.columns[i].text(row.node.item)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: widget.emptyBuilder ?? Text(widget.emptyText),
          ),
      ],
    );
  }
}
