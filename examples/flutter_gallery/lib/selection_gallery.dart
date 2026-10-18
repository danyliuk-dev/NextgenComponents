import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class SelectionGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const SelectionGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<SelectionGallery> createState() => _SelectionGalleryState();
}

class _SelectionGalleryState extends State<SelectionGallery> {
  bool disabled = false,
      vertical = false,
      allowEmpty = false,
      empty = false,
      border = false;
  int changes = 0;
  List<String> alignment = ['left'], format = [];
  final alignments = const [
    NgOption('left', 'Left'),
    NgOption('center', 'Center'),
    NgOption('right', 'Right'),
    NgOption('justify', 'Justify (unavailable)', disabled: true),
  ];
  final styles = const [
    NgOption('bold', 'Bold'),
    NgOption('italic', 'Italic'),
    NgOption('underline', 'Underline (unavailable)', disabled: true),
  ];
  void reset() => setState(() {
    border = false;
    alignment = ['left'];
    format = [];
    changes = 0;
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
                'Make a choice. See the change.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              const Text(
                'FLUTTER WEB / SELECTION 0.13 · Use a toggle for one setting, a single-choice group for alignment, and multiple choices for text styles.',
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
                    label: 'Vertical groups',
                    value: vertical,
                    onChanged: (v) => setState(() => vertical = v),
                  ),
                  NgCheckBox(
                    label: 'Allow empty alignment',
                    value: allowEmpty,
                    onChanged: (v) => setState(() => allowEmpty = v),
                  ),
                  NgCheckBox(
                    label: 'Empty options',
                    value: empty,
                    onChanged: (v) => setState(() => empty = v),
                  ),
                  NgButton(
                    onPressed: reset,
                    child: const Text('Reset settings'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Preview settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: NgToggleButton(
                  label: 'Show border',
                  value: border,
                  disabled: disabled,
                  onChanged: (v) => setState(() {
                    border = v;
                    changes++;
                  }),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Alignment · choose one'),
              const SizedBox(height: 8),
              NgButtonGroup(
                label: 'Text alignment',
                items: empty ? [] : alignments,
                value: empty ? [] : alignment,
                allowEmpty: allowEmpty,
                disabled: disabled,
                vertical: vertical,
                onChanged: (v) => setState(() {
                  alignment = v;
                  changes++;
                }),
              ),
              const SizedBox(height: 20),
              const Text('Text styles · choose several'),
              const SizedBox(height: 8),
              NgButtonGroup(
                label: 'Text styles',
                items: empty ? [] : styles,
                value: empty ? [] : format,
                multiple: true,
                disabled: disabled,
                vertical: vertical,
                onChanged: (v) => setState(() {
                  format = v;
                  changes++;
                }),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: border
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  'Build something clear and useful.',
                  textAlign: alignment.contains('center')
                      ? TextAlign.center
                      : alignment.contains('right')
                      ? TextAlign.right
                      : TextAlign.left,
                  style: TextStyle(
                    fontWeight: format.contains('bold')
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontStyle: format.contains('italic')
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  'Alignment: ${alignment.isEmpty ? "none" : alignment.first} · Styles: ${format.isEmpty ? "none" : format.join(", ")} · Border: ${border ? "on" : "off"} · Changes: $changes',
                ),
              ),
              const SizedBox(height: 32),
              const Text('45 CONTROLS / 51 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
