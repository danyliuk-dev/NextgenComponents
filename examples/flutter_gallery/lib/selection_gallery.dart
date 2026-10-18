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
  String buttonSize = 'md',
      buttonRounded = 'md',
      buttonFill = 'outline',
      buttonTone = 'primary',
      mixedLog = 'Ready';
  bool hideEmphasis = false, mixedDisabled = false, mixedVertical = false;
  List<String> mixedValue = ['strong'];
  final mixedItems = const [
    NgOption('strong', 'Strong'),
    NgOption('emphasis', 'Emphasis'),
    NgOption('clear', 'Clear formatting'),
    NgOption('export', 'Export (unavailable)', disabled: true),
  ];
  bool isCommand(NgOption item) => ['clear', 'export'].contains(item.value);
  Widget setting(
    String label,
    List<String> values,
    String value,
    ValueChanged<String> change,
  ) => SizedBox(
    width: 180,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => change(v!)),
    ),
  );
  Widget mixedExample() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Formatting commands and choices',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const Text(
        'Strong and Emphasis retain selection. Clear formatting is a command; the application handles its effect. Export is disabled. Templates keep stable accessible names.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          setting(
            'Button size',
            ['sm', 'md', 'lg'],
            buttonSize,
            (v) => buttonSize = v,
          ),
          setting(
            'Button corners',
            ['sm', 'md', 'lg', 'full'],
            buttonRounded,
            (v) => buttonRounded = v,
          ),
          setting(
            'Button fill',
            ['solid', 'outline', 'flat', 'link', 'clear'],
            buttonFill,
            (v) => buttonFill = v,
          ),
          setting(
            'Button color',
            [
              'base',
              'primary',
              'secondary',
              'tertiary',
              'info',
              'success',
              'warning',
              'error',
              'dark',
              'light',
              'inverse',
            ],
            buttonTone,
            (v) => buttonTone = v,
          ),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        children: [
          NgCheckBox(
            label: 'Hide Emphasis',
            value: hideEmphasis,
            onChanged: (v) => setState(() => hideEmphasis = v),
          ),
          NgCheckBox(
            label: 'Disable formatting',
            value: mixedDisabled,
            onChanged: (v) => setState(() => mixedDisabled = v),
          ),
          NgCheckBox(
            label: 'Vertical formatting',
            value: mixedVertical,
            onChanged: (v) => setState(() => mixedVertical = v),
          ),
        ],
      ),
      const Text('Choose text styles or run an available command.'),
      const SizedBox(height: 8),
      NgButtonGroup(
        label: 'Formatting actions',
        semanticIdentifier: 'format-actions',
        semanticHint: 'Choose text styles or run an available command.',
        items: mixedItems,
        value: mixedValue,
        multiple: true,
        isCommand: isCommand,
        isVisible: (item) => !hideEmphasis || item.value != 'emphasis',
        onChanged: (v) => setState(() {
          mixedValue = v;
          mixedLog = 'changed:${v.join(",")}';
        }),
        onClick: (id) => setState(() {
          mixedLog += ' | clicked:$id';
          if (id == 'clear') mixedValue = [];
        }),
        disabled: mixedDisabled,
        vertical: mixedVertical,
        size: buttonSize,
        rounded: buttonRounded,
        fillMode: buttonFill,
        themeColor: buttonTone,
        itemAppearance: (item) => NgButtonAppearance(
          themeColor: item.value == 'clear'
              ? 'info'
              : item.value == 'export'
              ? 'error'
              : null,
        ),
        leadingBuilder: (item) =>
            Icon(isCommand(item) ? Icons.north_east : Icons.star, size: 16),
        itemBuilder: (item) => Text(
          item.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 12),
      Semantics(
        liveRegion: true,
        child: Text(
          'Selected: ${mixedValue.isEmpty ? "none" : mixedValue.join(",")} · $mixedLog',
        ),
      ),
    ],
  );

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
                'FLUTTER WEB / SELECTION 0.26 · Use a toggle for one setting, a single-choice group for alignment, and multiple choices for text styles.',
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
              mixedExample(),
              const SizedBox(height: 32),
              const Text('47 CONTROLS / 53 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
