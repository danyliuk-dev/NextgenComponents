import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class _BusinessTopic {
  final String id, name, owner, tone;
  final bool disabled, pinned;
  const _BusinessTopic(
    this.id,
    this.name,
    this.owner, {
    this.disabled = false,
    this.pinned = false,
    this.tone = 'base',
  });
}

class ChipsGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const ChipsGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<ChipsGallery> createState() => _ChipsGalleryState();
}

class _ChipsGalleryState extends State<ChipsGallery> {
  static List<_BusinessTopic> initialRecords() => const [
    _BusinessTopic('ops', 'Operations', 'Morgan', tone: 'warning'),
    _BusinessTopic('finance', 'Finance', 'Alex', pinned: true, tone: 'success'),
    _BusinessTopic('archive', 'Archive', 'Sam', disabled: true),
  ];
  List<_BusinessTopic> records = initialRecords();
  List<String> businessSelected = ['finance'];
  late NgChipData<_BusinessTopic> businessData = bindRecords(records);
  String businessMessage = '3 model records · Finance selected';
  static NgChipData<_BusinessTopic> bindRecords(List<_BusinessTopic> source) =>
      NgChipData(
        source,
        value: (x) => x.id,
        text: (x) => x.name,
        disabled: (x) => x.disabled,
        removable: (x) => !x.pinned,
        appearance: (x) => NgChipAppearance(themeColor: x.tone),
      );
  void removeBusiness(String id) => setState(() {
    final item = businessData.getItem(id);
    records = records.where((x) => x.id != id).toList();
    businessSelected = businessSelected.where((x) => x != id).toList();
    businessData = bindRecords(records);
    businessMessage =
        'Removed ${item.name} · owner ${item.owner} · ${records.length} records';
  });
  Widget businessExample() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 28),
      Text('Business records', style: Theme.of(context).textTheme.titleLarge),
      const Text(
        'Bind model fields with typed selectors. Templates and events resolve the original record by its stable ID. Finance is pinned; Archive is disabled.',
      ),
      NgChipList(
        label: 'Business topics',
        items: businessData.items,
        value: businessSelected,
        multiple: true,
        onChanged: (v) => setState(() => businessSelected = v),
        canRemove: businessData.canRemove,
        itemAppearance: businessData.getAppearance,
        itemBuilder: (option) {
          final record = businessData.getItem(option.value);
          return Text('${record.name} · ${record.owner}');
        },
        onClick: (id) => setState(() {
          final record = businessData.getItem(id);
          businessMessage = 'Opened ${record.name} · owner ${record.owner}';
        }),
        onRemove: removeBusiness,
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          NgButton(
            onPressed: !records.any((x) => x.id == 'ops')
                ? null
                : () => setState(() {
                    records = records
                        .map(
                          (x) => x.id == 'ops'
                              ? _BusinessTopic(
                                  x.id,
                                  'Operations revised',
                                  x.owner,
                                  disabled: x.disabled,
                                  pinned: x.pinned,
                                  tone: x.tone,
                                )
                              : x,
                        )
                        .toList();
                    businessData = bindRecords(records);
                    businessMessage =
                        'Model updated; IDs and selection retained';
                  }),
            child: const Text('Rename Operations'),
          ),
          NgButton(
            onPressed: () => setState(() {
              records = records.reversed.toList();
              businessData = bindRecords(records);
              businessMessage =
                  'Model order reversed; IDs and selection retained';
            }),
            child: const Text('Reverse records'),
          ),
          NgButton(
            onPressed: () => setState(() {
              records = initialRecords();
              businessSelected = ['finance'];
              businessData = bindRecords(records);
              businessMessage = '3 model records · Finance selected';
            }),
            child: const Text('Reset records'),
          ),
        ],
      ),
      Semantics(liveRegion: true, child: Text(businessMessage)),
    ],
  );

  bool rtl = true;
  static List<NgOption> directionOptions() => const [
    NgOption('design', 'Design systems'),
    NgOption('locked', 'Locked topic', disabled: true),
    NgOption('web', 'Web components'),
    NgOption('docs', 'Documentation'),
  ];
  List<NgOption> directionItems = directionOptions();
  List<String> directionSelected = ['design'];
  Widget directionExample() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 28),
      Text('Reading direction', style: Theme.of(context).textTheme.titleLarge),
      const Text(
        'The same collection inherits direction from its container. Start/end, icons and removal mirror together; Left/Right follow the reading direction. Home/End keep data order.',
      ),
      Wrap(
        spacing: 12,
        children: [
          NgCheckBox(
            label: 'Right-to-left layout',
            value: rtl,
            onChanged: (v) => setState(() => rtl = v),
          ),
          NgButton(
            onPressed: () => setState(() {
              rtl = true;
              directionItems = directionOptions();
              directionSelected = ['design'];
            }),
            child: const Text('Reset direction example'),
          ),
        ],
      ),
      SizedBox(
        width: 420,
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NgChipList(
                label: 'Directional topics',
                items: directionItems,
                value: directionSelected,
                multiple: true,
                leadingBuilder: (_) => const Icon(Icons.star, size: 16),
                removeLabelBuilder: (x) => 'Dismiss ${x.label}',
                onChanged: (v) => setState(() => directionSelected = v),
                onRemove: (id) => setState(() {
                  directionItems = directionItems
                      .where((x) => x.value != id)
                      .toList();
                  directionSelected = directionSelected
                      .where((x) => x != id)
                      .toList();
                }),
              ),
              const NgChip(
                label: 'Pinned status',
                selectable: false,
                leading: Icon(Icons.star, size: 16),
              ),
            ],
          ),
        ),
      ),
      Semantics(
        liveRegion: true,
        child: Text(
          'Direction: ${rtl ? "RTL" : "LTR"} · Selected: ${directionSelected.join(", ")} · Tags: ${directionItems.length}',
        ),
      ),
    ],
  );

  bool disabled = false,
      protect = false,
      favourite = false,
      multiple = true,
      selectable = true;
  String message = 'Ready';
  String size = 'md', rounded = 'full', fill = 'outline', lastClick = 'none';
  bool custom = false, customLabels = false;
  final chipFocus = NgChipListController();
  @override
  void dispose() {
    chipFocus.dispose();
    super.dispose();
  }

  Widget choice(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      DropdownButton<String>(
        value: value,
        items: [
          for (final v in values) DropdownMenuItem(value: v, child: Text(v)),
        ],
        onChanged: (v) => setState(() => update(v!)),
      ),
    ],
  );
  static List<NgOption> initial() => const [
    NgOption('design', 'Design'),
    NgOption('web', 'Web'),
    NgOption('flutter', 'Flutter'),
    NgOption('locked', 'Locked', disabled: true),
  ];
  List<NgOption> items = initial();
  List<String> selected = ['design'];
  void remove(String id) => setState(() {
    if (protect && id == 'design') {
      message = 'Design is protected';
      return;
    }
    items = items.where((x) => x.value != id).toList();
    selected = selected.where((x) => x != id).toList();
    message = 'Removed $id';
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('NEXTGEN COMPONENTS'),
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Foundation'),
                  ),
                  NgSwitch(
                    label: 'Dark theme',
                    value: widget.dark,
                    onChanged: widget.onDark,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Small tags. Clear choices.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              const Text(
                'FLUTTER WEB / CHIPS 0.21 · Select topics, remove a tag, or show a compact status. Your application owns every change.',
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  NgCheckBox(
                    label: 'Disable controls',
                    value: disabled,
                    onChanged: (v) => setState(() => disabled = v),
                  ),
                  NgCheckBox(
                    label: 'Multiple selection',
                    value: multiple,
                    onChanged: (v) => setState(() {
                      multiple = v;
                      if (!v) selected = selected.take(1).toList();
                    }),
                  ),
                  NgCheckBox(
                    label: 'Enable selection',
                    value: selectable,
                    onChanged: (v) => setState(() => selectable = v),
                  ),
                  NgCheckBox(
                    label: 'Protect Design from removal',
                    value: protect,
                    onChanged: (v) => setState(() => protect = v),
                  ),
                  NgButton(
                    onPressed: () => setState(() {
                      items = List.generate(
                        500,
                        (index) => NgOption(
                          'tag${index + 1}',
                          'Topic ${(index + 1).toString().padLeft(3, '0')}',
                          disabled: (index + 1) % 10 == 0,
                        ),
                      );
                      selected = ['tag1'];
                      multiple = true;
                      message = '500 tags loaded; every tenth tag is disabled';
                    }),
                    child: const Text('Load 500 tags'),
                  ),
                  NgButton(
                    onPressed: () => setState(() {
                      items = initial();
                      selected = ['design'];
                      favourite = false;
                      message = 'Tags restored';
                    }),
                    child: const Text('Reset tags'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Appearance and content',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                children: [
                  choice('Size', size, ['sm', 'md', 'lg'], (v) => size = v),
                  choice('Rounded', rounded, [
                    'sm',
                    'md',
                    'lg',
                    'full',
                  ], (v) => rounded = v),
                  choice('Fill mode', fill, [
                    'solid',
                    'outline',
                  ], (v) => fill = v),
                  NgCheckBox(
                    label: 'Custom content',
                    value: custom,
                    onChanged: (v) => setState(() => custom = v),
                  ),
                ],
              ),
              const Text(
                'Templates can show an icon, avatar or custom text. The accessible name always comes from the label.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tone in [
                    'base',
                    'info',
                    'success',
                    'warning',
                    'error',
                  ])
                    NgChip(
                      label: tone,
                      selectable: false,
                      size: size,
                      rounded: rounded,
                      fillMode: fill,
                      themeColor: tone,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Topics', style: Theme.of(context).textTheme.titleLarge),
              const Text(
                'Keyboard: Tab enters once and leaves the list. Shift+Tab returns to the remembered chip. Left/Right, Home/End move focus. Enter/Space activates. Delete/Backspace requests removal. Disabled tags are skipped.',
              ),
              const SizedBox(height: 12),
              NgCheckBox(
                label: 'Custom action labels',
                value: customLabels,
                onChanged: (v) => setState(() => customLabels = v),
              ),
              NgChipList(
                focusController: chipFocus,
                emptyText: customLabels ? 'No topics available' : 'No tags',
                removeLabelBuilder: customLabels
                    ? (item) => 'Dismiss ${item.label}'
                    : null,
                label: 'Topics',
                size: size,
                rounded: rounded,
                fillMode: fill,
                canRemove: (item) => item.value != 'flutter',
                itemAppearance: (item) => NgChipAppearance(
                  themeColor: item.value == 'design' ? 'info' : 'base',
                ),
                itemBuilder: custom
                    ? (item) => Text(
                        '${item.label} · ${item.label.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
                leadingBuilder: custom
                    ? (_) => const Icon(Icons.star, size: 18)
                    : null,
                removeIcon: const Icon(Icons.remove, size: 18),
                onClick: (id) => setState(() => lastClick = id),
                items: items,
                value: selected,
                multiple: multiple,
                selectable: selectable,
                disabled: disabled,
                onChanged: (v) => setState(() {
                  selected = v;
                  message = 'Selection updated';
                }),
                onRemove: remove,
              ),
              Wrap(
                spacing: 12,
                children: [
                  NgButton(
                    onPressed: () => chipFocus.focus(),
                    child: const Text('Focus topics'),
                  ),
                  NgButton(
                    onPressed: () => setState(() {
                      items = [];
                      selected = [];
                      message = 'Topics cleared';
                    }),
                    child: const Text('Clear topics'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  'Selected: ${selected.isEmpty ? "none" : selected.join(", ")} · Tags: ${items.length} · $message',
                ),
              ),
              Text('Flutter is not removable. Last click: $lastClick'),
              const SizedBox(height: 28),
              Text(
                'Status and standalone selection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  const NgChip(label: 'Published', selectable: false),
                  NgChip(
                    label: 'Favourite',
                    value: favourite,
                    disabled: disabled,
                    onChanged: (v) => setState(() => favourite = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: NgChip(
                  label: 'Open activity',
                  selectable: false,
                  disabled: disabled,
                  onClick: () => setState(() => lastClick = 'activity'),
                ),
              ),
              const Text(
                'Removal is a request. Enable protection to reject removal of Design without changing the list.',
              ),
              const SizedBox(height: 32),
              businessExample(),
              directionExample(),
              const Text('47 CONTROLS / 53 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
