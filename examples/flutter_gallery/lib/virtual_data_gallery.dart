import 'remote_range_gallery.dart';
import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class VirtualDataGallery extends StatefulWidget {
  const VirtualDataGallery({super.key});
  @override
  State<VirtualDataGallery> createState() => _VirtualDataGalleryState();
}

class _VirtualDataGalleryState extends State<VirtualDataGallery> {
  bool variable = true, remote = false, grouped = false, locked = false, shortData = false;
  int reads = 0;
  Set<String> selected = {}, collapsed = {}, expanded = {}, checked = {};
  String? treeSelected;
  final records = List.generate(10000, (i) => i + 1);
  List<int> get data => shortData ? records.take(12).toList() : records;
  static String id(int i) => 'R${i.toString().padLeft(5, '0')}';
  static String group(int i) => 'Block ${(i - 1) ~/ 1000 + 1}';
  List<NgDataColumn<int>> get columns => <NgDataColumn<int>>[
    NgDataColumn('id', 'Record', (i) => i, format: id),
    NgDataColumn(
      'name',
      'Name',
      (i) => variable ? List.filled(i%5+1, 'Inventory ${i.toString().padLeft(5, '0')}. Multiline description.').join(' ') : 'Inventory ${i.toString().padLeft(5, '0')}',
    ),
  ];
  final trees = List.generate(
    100,
    (i) => NgTreeNode<String>(
      'B${i + 1}',
      'Branch ${(i + 1).toString().padLeft(3, '0')}',
      children: List.generate(
        100,
        (j) => NgTreeNode<String>(
          'B${i + 1}-${j + 1}',
          'Item ${(i + 1).toString().padLeft(3, '0')}-${(j + 1).toString().padLeft(3, '0')}',
        ),
      ),
    ),
  );
  Future<NgDataResult<int>> read(NgDataRequest request) async {
    reads++;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final rows = NgDataOperations.queryMany(
      data,
      columns,
      request.search,
      request.sorts,
    );
    if (mounted) setState(() {});
    return NgDataResult(
      rows
          .skip((request.page - 1) * request.pageSize)
          .take(request.pageSize)
          .toList(),
      rows.length,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const RemoteRangeGallery()),
      ),
      label: const Text('Remote ranges'),
    ),
    appBar: AppBar(title: const Text('Virtual data')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Large data, bounded rendering',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
            '10,000 synthetic records. Switch between fixed and measured row heights. Selection stays with this page.',
          ),
          Wrap(
            spacing: 16,
            children: [
              NgCheckBox(label:'Variable row height',value:variable,onChanged:(v)=>setState(()=>variable=v)),
              NgCheckBox(
                label: 'Server pages',
                value: remote,
                onChanged: (v) => setState(() => remote = v),
              ),
              NgCheckBox(
                label: 'Group by thousand',
                value: grouped,
                onChanged: (v) => setState(() => grouped = v),
              ),
              NgCheckBox(
                label: 'Lock selection',
                value: locked,
                onChanged: (v) => setState(() => locked = v),
              ),
              TextButton(
                onPressed: () => setState(() => shortData = !shortData),
                child: const Text('Toggle 12 / 10,000 records'),
              ),
            ],
          ),
          Text(
            'Server reads: $reads. ${selected.length} selected. ${remote ? "Remote pages contain at most 500 records. Scroll does not fetch the next page." : "Local scrolling covers all matching records."}',
          ),
          NgDataGrid<int>(
            key: ValueKey((remote, grouped)),
            items: remote ? const [] : data,
            readData: remote ? read : null,
            rowId: id,
            columns: columns,
            virtualize: true,
            variableRowHeight: variable,
            initialPageSize: 500,
            pageSizes: const [100, 500],
            dataVersion: shortData,
            label: 'Virtual inventory',
            selectedIds: selected,
            onSelectionChanged: (v) => setState(() => selected = v),
            selectionReadOnly: locked,
            canSelect: (i) => i % 100 != 0,
            groupBy: !remote && grouped ? group : null,
            collapsibleGroups: true,
            collapsedGroups: collapsed,
            onCollapsedGroupsChanged: (v) => setState(() => collapsed = v),
          ),
          const SizedBox(height: 24),
          Text('TreeView', style: Theme.of(context).textTheme.headlineSmall),
          const Text(
            '100 branches × 100 children. Arrow keys, Home and End move across virtual windows.',
          ),
          TextButton(
            onPressed: () => setState(
              () => expanded = expanded.isEmpty
                  ? trees.map((n) => n.id).toSet()
                  : {},
            ),
            child: const Text('Expand / collapse all branches'),
          ),
          NgTreeView<String>(
            items: trees,
            text: (x) => x,
            label: 'Virtual folders',
            virtualize: true,
            expandedIds: expanded,
            onExpandedChanged: (v) => setState(() => expanded = v),
            selectedId: treeSelected,
            onSelected: (v) => setState(() => treeSelected = v),
            checkboxes: true,
            checkedIds: checked,
            onCheckedChanged: (v) => setState(() => checked = v),
            selectionReadOnly: locked,
          ),
          const SizedBox(height: 24),
          Text('TreeList', style: Theme.of(context).textTheme.headlineSmall),
          NgTreeList<String>(
            items: trees,
            columns: [NgDataColumn('name', 'Folder', (x) => x)],
            virtualize: true,
            label: 'Virtual hierarchy',
            expandedIds: expanded,
            onExpandedChanged: (v) => setState(() => expanded = v),
            selectedId: treeSelected,
            onSelected: (v) => setState(() => treeSelected = v),
            checkboxes: true,
            checkedIds: checked,
            onCheckedChanged: (v) => setState(() => checked = v),
            selectionReadOnly: locked,
          ),
          Text(
            'Selected node: $treeSelected. Checked nodes: ${checked.length}.',
          ),
        ],
      ),
    ),
  );
}
