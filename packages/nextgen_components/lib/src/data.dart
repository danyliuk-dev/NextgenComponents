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
  final bool disabled;
  const NgTreeNode(
    this.id,
    this.item, {
    this.children = const [],
    this.disabled = false,
  });
}

class NgTreeRow<T> {
  final NgTreeNode<T> node;
  final int depth;
  final String? parentId;
  final bool expanded;
  const NgTreeRow(this.node, this.depth, this.parentId, this.expanded);
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
    final needle = search.trim().toLowerCase();
    final rows = items
        .where(
          (item) =>
              needle.isEmpty ||
              columns.any((c) => c.text(item).toLowerCase().contains(needle)),
        )
        .toList();
    final column = columns
        .where((c) => c.key == sortKey && c.sortable)
        .firstOrNull;
    if (column == null) return rows;
    final indexed = rows.indexed.toList();
    indexed.sort((a, b) {
      final order =
          compare(column.value(a.$2), column.value(b.$2)) *
          (descending ? -1 : 1);
      return order == 0 ? a.$1.compareTo(b.$1) : order;
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
        if (!ids.add(n.id))
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
            : expanded.contains(n.id);
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
  final List<NgDataColumn<T>> columns;
  final String Function(T) rowId;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final Widget Function(BuildContext, T)? rowActions;
  final Widget? toolbar;
  final String label, emptyText;
  final int initialPageSize;
  const NgDataGrid({
    super.key,
    required this.items,
    required this.columns,
    required this.rowId,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActions,
    this.toolbar,
    this.label = 'Records',
    this.emptyText = 'No matching records.',
    this.initialPageSize = 5,
  });
  @override
  State<NgDataGrid<T>> createState() => _NgDataGridState<T>();
}

class _NgDataGridState<T> extends State<NgDataGrid<T>> {
  String search = '';
  String? sortKey;
  bool descending = false;
  int page = 1;
  late int size;
  @override
  void initState() {
    super.initState();
    size = widget.initialPageSize < 1 ? 1 : widget.initialPageSize;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.map(widget.rowId).toSet().length != widget.items.length)
      throw ArgumentError('Grid row IDs must be unique.');
    final rows = NgDataOperations.query(
      widget.items,
      widget.columns,
      search,
      sortKey,
      descending,
    );
    page = NgDataOperations.clampPage(page, rows.length, size);
    final visible = rows.skip((page - 1) * size).take(size).toList();
    final sortIndex = widget.columns.indexWhere((c) => c.key == sortKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                onChanged: (v) => setState(() {
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
                sortColumnIndex: sortIndex < 0 ? null : sortIndex,
                sortAscending: !descending,
                showCheckboxColumn: widget.onSelectionChanged != null,
                columnSpacing: 24,
                onSelectAll: widget.onSelectionChanged == null
                    ? null
                    : (select) {
                        final next = {...widget.selectedIds};
                        for (final row in visible) {
                          if (select == true) {
                            next.add(widget.rowId(row));
                          } else {
                            next.remove(widget.rowId(row));
                          }
                        }
                        widget.onSelectionChanged!(next);
                      },
                columns: [
                  for (final column in widget.columns)
                    DataColumn(
                      label: Text(column.title),
                      onSort: column.sortable
                          ? (i, ascending) => setState(() {
                              descending = sortKey == column.key && !descending;
                              sortKey = column.key;
                            })
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
                      onSelectChanged: widget.onSelectionChanged == null
                          ? null
                          : (v) {
                              final next = {...widget.selectedIds};
                              if (!next.add(widget.rowId(row)))
                                next.remove(widget.rowId(row));
                              widget.onSelectionChanged!(next);
                            },
                      cells: [
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
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(widget.emptyText),
          ),
        NgPager(
          total: rows.length,
          page: page,
          pageSize: size,
          onPageChanged: (v) => setState(() => page = v),
          onPageSizeChanged: (v) => setState(() {
            size = v;
            page = 1;
          }),
        ),
      ],
    );
  }
}

class NgTreeView<T> extends StatefulWidget {
  final List<NgTreeNode<T>> items;
  final String Function(T) text;
  final String label;
  final String? selectedId;
  final Set<String> expandedIds;
  final ValueChanged<String>? onSelected;
  final ValueChanged<Set<String>> onExpandedChanged;
  const NgTreeView({
    super.key,
    required this.items,
    required this.text,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Folders',
  });
  @override
  State<NgTreeView<T>> createState() => _NgTreeViewState<T>();
}

class _NgTreeViewState<T> extends State<NgTreeView<T>> {
  String search = '';
  final nodes = <String, FocusNode>{};
  List<NgTreeRow<T>> get rows => NgDataOperations.flatten<T>(
    widget.items,
    widget.expandedIds,
    widget.text,
    search: search,
  );
  void toggle(String id) {
    final next = {...widget.expandedIds};
    if (!next.add(id)) next.remove(id);
    widget.onExpandedChanged(next);
  }

  @override
  void dispose() {
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
                    row.node.children.isNotEmpty &&
                    search.isEmpty) {
                  toggle(row.node.id);
                } else if (row.expanded && index < enabled.length - 1) {
                  target = enabled[index + 1].node.id;
                }
              }
              if (key == LogicalKeyboardKey.arrowLeft) {
                if (row.expanded && search.isEmpty) {
                  toggle(row.node.id);
                } else {
                  target = row.parentId;
                }
              }
              if (key == LogicalKeyboardKey.enter ||
                  key == LogicalKeyboardKey.space)
                widget.onSelected?.call(row.node.id);
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
                            widget.onSelected?.call(row.node.id);
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
                          if (row.node.children.isNotEmpty)
                            IconButton(
                              tooltip:
                                  '${row.expanded ? 'Collapse' : 'Expand'} ${widget.text(row.node.item)}',
                              onPressed: row.node.disabled || search.isNotEmpty
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
                          Expanded(
                            child: Text(
                              widget.text(row.node.item),
                              style: TextStyle(
                                color: row.node.disabled
                                    ? Theme.of(context).disabledColor
                                    : null,
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No matching items.'),
          ),
      ],
    );
  }
}

class NgTreeList<T> extends StatefulWidget {
  final List<NgTreeNode<T>> items;
  final List<NgDataColumn<T>> columns;
  final Set<String> expandedIds;
  final ValueChanged<Set<String>> onExpandedChanged;
  final ValueChanged<String>? onSelected;
  final String? selectedId;
  final String label;
  const NgTreeList({
    super.key,
    required this.items,
    required this.columns,
    required this.expandedIds,
    required this.onExpandedChanged,
    this.onSelected,
    this.selectedId,
    this.label = 'Hierarchy',
  });
  @override
  State<NgTreeList<T>> createState() => _NgTreeListState<T>();
}

class _NgTreeListState<T> extends State<NgTreeList<T>> {
  String search = '';
  String? sortKey;
  bool descending = false;
  void toggle(String id) {
    final next = {...widget.expandedIds};
    if (!next.add(id)) next.remove(id);
    widget.onExpandedChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final column = widget.columns
        .where((c) => c.key == sortKey && c.sortable)
        .firstOrNull;
    final sortIndex = widget.columns.indexWhere((c) => c.key == sortKey);
    final rows = NgDataOperations.flatten<T>(
      widget.items,
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
                                      if (row.node.children.isNotEmpty)
                                        IconButton(
                                          tooltip:
                                              '${row.expanded ? 'Collapse' : 'Expand'} ${widget.columns[i].text(row.node.item)}',
                                          onPressed:
                                              row.node.disabled ||
                                                  search.isNotEmpty
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
                                      TextButton(
                                        onPressed: row.node.disabled
                                            ? null
                                            : () => widget.onSelected?.call(
                                                row.node.id,
                                              ),
                                        child: Text(
                                          widget.columns[i].text(row.node.item),
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
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No matching items.'),
          ),
      ],
    );
  }
}
