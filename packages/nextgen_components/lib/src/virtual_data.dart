part of 'data.dart';

void _checkVirtual(bool enabled, double rowHeight, double viewportHeight) {
  if (enabled &&
      (!rowHeight.isFinite ||
          rowHeight < 40 ||
          !viewportHeight.isFinite ||
          viewportHeight < rowHeight)) {
    throw ArgumentError(
      'Virtual rows require a finite height of at least 40 and a viewport at least one row high.',
    );
  }
}

/// Internal table renderer. Virtual rows have stable column widths and never
/// construct offscreen DataRows. The ordinary table retains intrinsic sizing.
class _NgDataTable extends StatefulWidget {
  final bool virtualize,
      variableRowHeight,
      showCheckboxColumn,
      sortAscending,
      selectionColumn;
  final double rowHeight, viewportHeight, width, columnSpacing;
  final int? sortColumnIndex;
  final List<DataColumn> columns;
  final int rowCount;
  final ValueChanged<int>? onWindowChanged;
  final DataRow Function(int) rowBuilder;
  const _NgDataTable({
    super.key,
    required this.virtualize,
    this.variableRowHeight = false,
    required this.rowHeight,
    required this.viewportHeight,
    required this.width,
    required this.columns,
    required this.rowCount,
    this.onWindowChanged,
    required this.rowBuilder,
    this.showCheckboxColumn = false,
    this.selectionColumn = false,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.columnSpacing = 56,
  });

  @override
  State<_NgDataTable> createState() => _NgDataTableState();
}

class _NgDataTableState extends State<_NgDataTable> {
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    scroll.addListener(_scrollChanged);
  }

  final Map<int, double> measured = {};
  final Map<int, double> pendingHeights = {};
  bool measureScheduled = false;
  double? measuredWidth;
  double extent(int index) => measured[index] ?? widget.rowHeight;
  double offsetOf(int index) {
    double value = 0;
    for (var i = 0; i < index; i++) {
      value += extent(i);
    }
    return value;
  }

  int indexAt(double offset) {
    var i = 0;
    while (i < widget.rowCount - 1 && offset >= extent(i)) {
      offset -= extent(i++);
    }
    return i;
  }

  void measure(int index, double height) {
    if (!mounted || !height.isFinite || height <= 0) return;
    height = height < widget.rowHeight ? widget.rowHeight : height;
    if ((extent(index) - height).abs() < 0.5) return;
    pendingHeights[index] = height;
    if (measureScheduled) return;
    measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      measureScheduled = false;
      if (!mounted) return;
      final oldOffset = scroll.hasClients ? scroll.offset : 0.0;
      final anchor = indexAt(oldOffset), before = offsetOf(indexAt(oldOffset));
      final end =
          pinnedEnd ||
          scroll.hasClients &&
              oldOffset > 0 &&
              (scroll.position.maxScrollExtent - oldOffset).abs() < 2;
      setState(() {
        measured.addAll(pendingHeights);
        pendingHeights.clear();
      });
      final correction = offsetOf(anchor) - before;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !scroll.hasClients) return;
        // Keep the visible anchor, unless the user scrolled in the meantime.
        if (!end && (scroll.offset - oldOffset).abs() > 2) return;
        final target = end
            ? scroll.position.maxScrollExtent
            : oldOffset + correction;
        if ((scroll.offset - target).abs() > 0.5)
          scroll.jumpTo(target.clamp(0.0, scroll.position.maxScrollExtent));
      });
    });
  }

  bool pinnedEnd = false;
  @override
  void didUpdateWidget(covariant _NgDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowHeight != widget.rowHeight ||
        oldWidget.variableRowHeight != widget.variableRowHeight) {
      measured.clear();
      pendingHeights.clear();
    }
  }

  int? lastFirst;
  void _scrollChanged() {
    if (!scroll.hasClients) return;
    pinnedEnd =
        scroll.offset > 0 &&
        (scroll.position.maxScrollExtent - scroll.offset).abs() < 2;
    if (widget.onWindowChanged == null) return;
    final first = (scroll.offset / widget.rowHeight).floor().clamp(
      0,
      widget.rowCount > 0 ? widget.rowCount - 1 : 0,
    );
    if (lastFirst == first) return;
    lastFirst = first;
    // Scroll notifications can occur during layout, defer the parent's mutation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && lastFirst == first) widget.onWindowChanged?.call(first);
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final virtualize = widget.virtualize,
        showCheckboxColumn = widget.showCheckboxColumn,
        sortAscending = widget.sortAscending;
    final rowHeight = widget.rowHeight,
        viewportHeight = widget.viewportHeight,
        width = widget.width,
        columnSpacing = widget.columnSpacing;
    final sortColumnIndex = widget.sortColumnIndex,
        columns = widget.columns,
        rowCount = widget.rowCount,
        rowBuilder = widget.rowBuilder;
    if (!virtualize)
      return DataTable(
        columns: columns,
        rows: List.generate(rowCount, rowBuilder),
        showCheckboxColumn: showCheckboxColumn,
        sortAscending: sortAscending,
        sortColumnIndex: sortColumnIndex,
        columnSpacing: columnSpacing,
      );
    if (widget.variableRowHeight && measuredWidth != width) {
      measuredWidth = width;
      measured.clear();
      pendingHeights.clear();
    }
    final selectionWidth = widget.selectionColumn ? 48.0 : 0.0;
    final dataColumns = columns.length - (widget.selectionColumn ? 1 : 0);
    final minimumWidth = dataColumns * 200.0 + selectionWidth;
    final tableWidth = width.isFinite && width > minimumWidth
        ? width
        : minimumWidth;
    Widget cells(List<Widget> children) => Row(
      children: [
        for (var i = 0; i < children.length; i++)
          SizedBox(
            width: widget.selectionColumn && i == 0
                ? selectionWidth
                : (tableWidth - selectionWidth) / dataColumns,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRect(child: children[i]),
            ),
          ),
      ],
    );
    return SizedBox(
      width: tableWidth,
      height: viewportHeight + rowHeight,
      child: Column(
        children: [
          SizedBox(
            height: rowHeight,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: cells([
                for (var i = 0; i < columns.length; i++)
                  columns[i].onSort == null
                      ? columns[i].label
                      : TextButton(
                          onPressed: () => columns[i].onSort!(
                            i,
                            sortColumnIndex == i ? !sortAscending : true,
                          ),
                          child: Row(
                            children: [
                              Flexible(child: columns[i].label),
                              if (sortColumnIndex == i)
                                Text(sortAscending ? ' ↑' : ' ↓'),
                            ],
                          ),
                        ),
              ]),
            ),
          ),
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is! KeyDownEvent || !scroll.hasClients)
                  return KeyEventResult.ignored;
                double? target;
                if (event.logicalKey == LogicalKeyboardKey.pageDown)
                  target = scroll.offset + viewportHeight;
                if (event.logicalKey == LogicalKeyboardKey.pageUp)
                  target = scroll.offset - viewportHeight;
                if (HardwareKeyboard.instance.isControlPressed &&
                    event.logicalKey == LogicalKeyboardKey.end)
                  target = scroll.position.maxScrollExtent;
                if (HardwareKeyboard.instance.isControlPressed &&
                    event.logicalKey == LogicalKeyboardKey.home)
                  target = 0;
                if (target == null) return KeyEventResult.ignored;
                scroll.jumpTo(target.clamp(0, scroll.position.maxScrollExtent));
                return KeyEventResult.handled;
              },
              child: Scrollbar(
                controller: scroll,
                thumbVisibility: true,
                child: ListView.custom(
                  controller: scroll,
                  itemExtent: widget.variableRowHeight ? null : rowHeight,
                  itemExtentBuilder: widget.variableRowHeight
                      ? (index, dimensions) =>
                            index >= rowCount ? null : extent(index)
                      : null,
                  childrenDelegate: _NgExtentDelegate(
                    (context, index) {
                      final row = rowBuilder(index);
                      final content = Semantics(
                        key: row.key,
                        selected: row.selected,
                        child: Material(
                          color: row.selected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .12)
                              : row.color?.resolve({}) ?? Colors.transparent,
                          child: InkWell(
                            onTap: row.onSelectChanged == null
                                ? null
                                : () => row.onSelectChanged!(!row.selected),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: rowHeight),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: widget.variableRowHeight ? 8 : 0,
                                ),
                                child: cells(
                                  row.cells.map((cell) => cell.child).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                      if (!widget.variableRowHeight) return content;
                      return ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          child: _NgRowMeasure(
                            onHeight: (height) => measure(index, height),
                            child: content,
                          ),
                        ),
                      );
                    },
                    childCount: rowCount,
                    totalExtent: () => widget.variableRowHeight
                        ? offsetOf(rowCount)
                        : rowCount * rowHeight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Measures only built rows; the extent list can jump across unbuilt records.
class _NgRowMeasure extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onHeight;
  const _NgRowMeasure({required this.onHeight, required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _NgRowMeasureRender(onHeight);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _NgRowMeasureRender object,
  ) {
    object.onHeight = onHeight;
  }
}

class _NgRowMeasureRender extends RenderProxyBox {
  ValueChanged<double> onHeight;
  _NgRowMeasureRender(this.onHeight);
  @override
  void performLayout() {
    super.performLayout();
    onHeight(size.height);
  }
}

class _NgExtentDelegate extends SliverChildBuilderDelegate {
  final double Function() totalExtent;
  _NgExtentDelegate(
    super.builder, {
    required int childCount,
    required this.totalExtent,
  }) : super(childCount: childCount);
  @override
  double estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) => totalExtent();
}
