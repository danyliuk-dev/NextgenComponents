import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class Project {
  final String id, name, team, owner, status;
  final double budget;
  const Project(
    this.id,
    this.name,
    this.team,
    this.owner,
    this.budget,
    this.status,
  );
}

class DataGallery extends StatefulWidget {
  final bool dark, compact;
  final ValueChanged<bool> onDark, onCompact;
  final VoidCallback onBack;
  const DataGallery({
    super.key,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
    required this.onBack,
  });
  @override
  State<DataGallery> createState() => _DataGalleryState();
}

class _DataGalleryState extends State<DataGallery> {
  String folder = 'all';
  bool selectionReadOnly = false,
      treeSelectionReadOnly = false,
      treeExpansionReadOnly = false;
  String? saved, portfolioSelection;
  Set<String> selected = {}, expanded = {'all'}, portfolioExpanded = {'design'};
  List<Project> projects = List.generate(18, (index) {
    final i = index + 1;
    return Project(
      'P${i.toString().padLeft(3, '0')}',
      '${['Design system', 'Web portal', 'Mobile shell', 'Research hub', 'Release tools', 'Client workspace'][index % 6]} ${i.toString().padLeft(2, '0')}',
      ['design', 'platform', 'operations'][index % 3],
      ['Alex Morgan', 'Jamie Chen', 'Sam Rivera'][index % 3],
      [120, 9000, 450, 12000, 75, 2400][index % 6].toDouble(),
      i % 4 == 0 ? 'Paused' : 'Active',
    );
  });
  static const folders = [
    NgTreeNode(
      'all',
      'All projects',
      children: [
        NgTreeNode('design', 'Design'),
        NgTreeNode('platform', 'Platform'),
        NgTreeNode('operations', 'Operations'),
        NgTreeNode('archive', 'Archive', disabled: true),
      ],
    ),
  ];
  String get folderName => switch (folder) {
    'design' => 'Design',
    'platform' => 'Platform',
    'operations' => 'Operations',
    _ => 'All projects',
  };
  List<NgDataColumn<Project>> get columns => [
    NgDataColumn('id', 'ID', (p) => p.id),
    NgDataColumn('name', 'Project', (p) => p.name),
    NgDataColumn('owner', 'Owner', (p) => p.owner),
    NgDataColumn(
      'budget',
      'Budget',
      (p) => p.budget,
      format: (p) => '\$${p.budget.toStringAsFixed(0)}',
    ),
    NgDataColumn('status', 'Status', (p) => p.status),
  ];
  List<NgTreeNode<Project>> get hierarchy =>
      ['design', 'platform', 'operations'].map((team) {
        final children = projects.where((p) => p.team == team).toList();
        return NgTreeNode(
          team,
          Project(
            team,
            '${team[0].toUpperCase()}${team.substring(1)}',
            team,
            'Team',
            children.fold(0.0, (sum, p) => sum + p.budget),
            'Portfolio',
          ),
          children: children.map((p) => NgTreeNode(p.id, p)).toList(),
        );
      }).toList();
  void choose(String id) {
    if (id == 'archive') return;
    setState(() {
      folder = id;
      selected = {};
    });
  }

  Future<void> edit(Project project) async {
    var name = project.name, owner = project.owner, status = project.status;
    double? budget = project.budget;
    final result = await showDialog<Project>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit project'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, set) => NgForm(
                submitLabel: 'Save project',
                onValidSubmit: () => Navigator.pop(
                  ctx,
                  Project(
                    project.id,
                    name,
                    project.team,
                    owner,
                    budget!,
                    status,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NgTextBox(
                      label: 'Project name',
                      initialValue: name,
                      onChanged: (v) => name = v,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Project name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    NgTextBox(
                      label: 'Owner',
                      initialValue: owner,
                      onChanged: (v) => owner = v,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Owner is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    NgNumericTextBox(
                      label: 'Budget',
                      required: true,
                      value: budget,
                      min: 0,
                      max: 1000000,
                      onChanged: (v) => budget = v,
                    ),
                    const SizedBox(height: 16),
                    NgDropDownList(
                      label: 'Status',
                      value: status,
                      items: const [
                        NgOption('Active', 'Active'),
                        NgOption('Paused', 'Paused'),
                        NgOption('Completed', 'Completed'),
                      ],
                      onChanged: (v) => set(() => status = v!),
                    ),
                    const SizedBox(height: 16),
                    NgButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted)
      setState(() {
        projects = projects.map((p) => p.id == result.id ? result : p).toList();
        saved =
            'Saved ${result.id}: ${result.name} · \$${result.budget.toStringAsFixed(0)} · ${result.status}';
      });
  }

  Widget panel(Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(6),
    ),
    child: child,
  );
  @override
  Widget build(BuildContext context) {
    final filtered = projects
        .where((p) => folder == 'all' || p.team == folder)
        .toList();
    final tree = panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teams',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          NgTreeView<String>(
            items: folders,
            text: (s) => s,
            expandedIds: expanded,
            onExpandedChanged: (v) => setState(() => expanded = v),
            selectedId: folder,
            onSelected: choose,
          ),
        ],
      ),
    );
    final grid = panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$folderName · ${filtered.length} projects',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          if (saved != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  saved!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          NgDataGrid<Project>(
            key: ValueKey(folder),
            items: filtered,
            columns: columns,
            rowId: (p) => p.id,
            label: 'Projects',
            canSelect: (p) => p.status != 'Paused',
            selectionReadOnly: selectionReadOnly,
            pageSizes: const [5, 10, 18],
            emptyBuilder: const Text('No projects found. Try another search.'),
            selectedIds: selected,
            onSelectionChanged: (v) => setState(() => selected = v),
            toolbar: Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                NgCheckBox(
                  label: 'Selection read-only',
                  value: selectionReadOnly,
                  onChanged: (v) =>
                      setState(() => selectionReadOnly = v ?? false),
                ),
                NgButton(
                  onPressed:
                      selectionReadOnly ||
                          selected.every(
                            (id) => projects.any(
                              (p) => p.id == id && p.status == 'Paused',
                            ),
                          )
                      ? null
                      : () => setState(
                          () => selected = selected
                              .where(
                                (id) => projects.any(
                                  (p) => p.id == id && p.status == 'Paused',
                                ),
                              )
                              .toSet(),
                        ),
                  child: const Text('Clear selectable'),
                ),
              ],
            ),
            rowActions: (context, p) => Tooltip(
              message: 'Edit ${p.name}',
              child: NgButton(
                onPressed: () => edit(p),
                child: const Text('Edit'),
              ),
            ),
          ),
          const Text(
            'Paused projects are protected. Selection follows IDs across pages.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
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
                const SizedBox(height: 40),
                Text(
                  'FLUTTER / DATA WORKSPACE 0.53',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Find the detail.\nKeep the context.',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Explore projects by team, sort budgets, select across pages and edit a project. All changes stay in this example.',
                ),
                const SizedBox(height: 24),
                NgBreadcrumb(
                  items: [
                    const NgBreadcrumbItem('all', 'All projects'),
                    if (folder != 'all') NgBreadcrumbItem(folder, folderName),
                  ],
                  onNavigate: choose,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, c) => c.maxWidth > 1000
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 230, child: tree),
                            const SizedBox(width: 20),
                            Expanded(child: grid),
                          ],
                        )
                      : Column(
                          children: [tree, const SizedBox(height: 20), grid],
                        ),
                ),
                const SizedBox(height: 24),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Portfolio hierarchy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      NgCheckBox(
                        label: 'Tree selection read-only',
                        value: treeSelectionReadOnly,
                        onChanged: (v) =>
                            setState(() => treeSelectionReadOnly = v ?? false),
                      ),
                      NgCheckBox(
                        label: 'Tree expansion read-only',
                        value: treeExpansionReadOnly,
                        onChanged: (v) =>
                            setState(() => treeExpansionReadOnly = v ?? false),
                      ),
                      NgTreeList<Project>(
                        selectionReadOnly: treeSelectionReadOnly,
                        expansionReadOnly: treeExpansionReadOnly,
                        items: hierarchy,
                        columns: columns.skip(1).toList(),
                        expandedIds: portfolioExpanded,
                        onExpandedChanged: (v) =>
                            setState(() => portfolioExpanded = v),
                        selectedId: portfolioSelection,
                        onSelected: (v) =>
                            setState(() => portfolioSelection = v),
                        label: 'Portfolio',
                      ),
                      Text('Selected node: ${portfolioSelection ?? 'none'}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('27 COMPONENTS · WEB FIRST / BLAZOR + FLUTTER'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
