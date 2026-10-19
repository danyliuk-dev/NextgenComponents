import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components.dart';

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
  final List<T> items;
  final Future<NgDataResult<T>> Function(NgDataRequest)? readData;
  final Object? dataVersion;
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
    this.items = const [],
    this.readData,
    this.dataVersion,
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
  String search = '';
  final sorts = <NgSortDescriptor>[];
  String? get sortKey => sorts.firstOrNull?.key;
  bool get descending => sorts.firstOrNull?.descending ?? false;
  bool loading = false, error = false;
  int total = 0, revision = 0;
  List<T> remote = [];
  List<T> get rows => widget.readData == null
      ? NgDataOperations.queryMany(widget.items, widget.columns, search, sorts)
      : remote;
  List<T> get visible => widget.readData == null
      ? rows.skip((page - 1) * size).take(size).toList()
      : remote;
  int get count => widget.readData == null ? rows.length : total;
  void validate(List<T> values) {
    if (values.any((r) => widget.rowId(r).trim().isEmpty) ||
        values.map(widget.rowId).toSet().length != values.length) {
      throw ArgumentError('Grid row IDs must be nonempty and unique.');
    }
  }

  Future<void> reload() async {
    final ticket = ++revision;
    if (widget.readData == null) {
      loading = error = false;
      return;
    }
    loading = true;
    error = false;
    remote = [];
    try {
      final result = await widget.readData!(
        NgDataRequest(page, size, search, sorts),
      );
      if (!mounted || ticket != revision) return;
      if (result.total < 0 ||
          result.items.length > size ||
          result.items.length > result.total) {
        throw ArgumentError('Invalid server page.');
      }
      validate(result.items);
      total = result.total;
      final clamped = NgDataOperations.clampPage(page, total, size);
      if (clamped != page) {
        page = clamped;
        await reload();
        return;
      }
      remote = List.of(result.items);
    } catch (_) {
      if (mounted && ticket == revision) {
        error = true;
        remote = [];
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
    final before = sorts.length;
    sorts.removeWhere(
      (s) => !widget.columns.any((c) => c.key == s.key && c.sortable),
    );
    if (!widget.multiSort && sorts.length > 1)
      sorts.removeRange(1, sorts.length);
    if (oldWidget.readData != widget.readData ||
        oldWidget.dataVersion != widget.dataVersion ||
        before != sorts.length) {
      page = 1;
      reload();
    }
  }

  @override
  void dispose() {
    revision++;
    super.dispose();
  }

  int page = 1;
  late int size;
  @override
  void initState() {
    super.initState();
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
    final matches = (widget.readData == null ? widget.items : remote).where(
      (item) => widget.rowId(item) == widget.rowId(row),
    );
    if (matches.isEmpty || !canChange(matches.first)) return;
    final next = {...widget.selectedIds};
    if (!next.add(widget.rowId(row))) next.remove(widget.rowId(row));
    widget.onSelectionChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
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
    final eligible = visible
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
              TextButton(
                onPressed: () => change(() {}),
                child: Text(widget.retryText),
              ),
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
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: DataTable(
                // Flutter Web can retain stale row semantics after keyed reordering.
                // Refresh the view identity; selection stays in caller-owned IDs.
                key: ValueKey(
                  '$sortKey:$descending:$page:$search:${visible.map(widget.rowId).join(',')}',
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
                            ? 'Select page (partially selected)'
                            : 'Select page',
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
                                  final current = visible
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
                  if (widget.rowActions != null)
                    const DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final row in visible)
                    DataRow(
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
                            column.cellBuilder?.call(context, row) ??
                                Text(column.text(row)),
                          ),
                        if (widget.rowActions != null)
                          DataCell(widget.rowActions!(context, row)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!loading && !error && rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: widget.emptyBuilder ?? Text(widget.emptyText),
          ),
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
  final Widget Function(BuildContext, T)? itemBuilder;
  final List<NgTreeNode<T>> items;
  final Future<List<NgTreeNode<T>>> Function(NgTreeNode<T>)? loadChildren;
  final Object? dataVersion;
  final String loadingText, errorText;
  final String Function(T) text;
  final String label, emptyText;
  final bool selectionReadOnly, expansionReadOnly;
  final Widget? emptyBuilder;
  final String? selectedId;
  final Set<String> expandedIds;
  final ValueChanged<String>? onSelected;
  final ValueChanged<Set<String>> onExpandedChanged;
  const NgTreeView({
    super.key,
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
    for (final n in nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Search ${widget.label}'),
          onChanged: (v) => setState(() => search = v),
        ),
        const SizedBox(height: 12),
        for (final row in visible)
          Focus(
            key: ValueKey(row.node.id),
            focusNode: nodes.putIfAbsent(row.node.id, () => FocusNode()),
            canRequestFocus: !row.node.disabled,
            onKeyEvent: (focus, e) {
              if (e is! KeyDownEvent || row.node.disabled)
                return KeyEventResult.ignored;
              final key = e.logicalKey;
              final enabled = visible.where((r) => !r.node.disabled).toList();
              final index = enabled.indexOf(row);
              String? target;
              if (key == LogicalKeyboardKey.arrowDown &&
                  index < enabled.length - 1)
                target = enabled[index + 1].node.id;
              if (key == LogicalKeyboardKey.arrowUp && index > 0)
                target = enabled[index - 1].node.id;
              if (key == LogicalKeyboardKey.home)
                target = enabled.first.node.id;
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
              if (key == LogicalKeyboardKey.enter ||
                  key == LogicalKeyboardKey.space)
                select(row.node.id);
              if (target != null) nodes[target]?.requestFocus();
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
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .12)
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
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      padding: EdgeInsets.only(left: row.depth * 20),
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Row(
                        children: [
                          if ((row.node.children.isNotEmpty ||
                              row.node.hasChildren))
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
          ),
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
  final Widget? emptyBuilder;
  const NgTreeList({
    super.key,
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
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: DataTable(
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
                rows: [
                  for (final row in rows)
                    DataRow(
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
                                              widget.columns[i].cellBuilder
                                                  ?.call(
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
                                      Text(
                                        widget.columns[i].text(row.node.item),
                                      ),
                          ),
                      ],
                    ),
                ],
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
