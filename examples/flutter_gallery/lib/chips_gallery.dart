import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

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
  bool disabled = false,
      protect = false,
      favourite = false,
      multiple = true,
      selectable = true;
  String message = 'Ready';
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
                'FLUTTER WEB / CHIPS 0.14 · Select topics, remove a tag, or show a compact status. Your application owns every change.',
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
              Text('Topics', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              NgChipList(
                label: 'Topics',
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
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  'Selected: ${selected.isEmpty ? "none" : selected.join(", ")} · Tags: ${items.length} · $message',
                ),
              ),
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
              const Text(
                'Removal is a request. Enable protection to reject removal of Design without changing the list.',
              ),
              const SizedBox(height: 32),
              const Text('47 CONTROLS / 53 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
