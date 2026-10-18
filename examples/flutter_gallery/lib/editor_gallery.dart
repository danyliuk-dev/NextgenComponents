import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class EditorGallery extends StatefulWidget {
  final bool dark, compact;
  final ValueChanged<bool> onDark, onCompact;
  final VoidCallback onBack;
  const EditorGallery({
    super.key,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
    required this.onBack,
  });
  @override
  State<EditorGallery> createState() => _EditorGalleryState();
}

class _EditorGalleryState extends State<EditorGallery> {
  static NgDocument sample() => NgDocument(
    blocks: const [
      NgDocumentBlock(text: 'Project brief', kind: NgBlockKind.heading1),
      NgDocumentBlock(
        text: 'Build a shared component library for Blazor and Flutter Web.',
      ),
      NgDocumentBlock(
        text: 'Accessible controls and consistent themes',
        kind: NgBlockKind.bullet,
      ),
      NgDocumentBlock(
        text: 'Detailed manuals with working examples',
        kind: NgBlockKind.bullet,
      ),
      NgDocumentBlock(
        text: 'Ship a coherent, tested experience.',
        kind: NgBlockKind.quote,
        italic: true,
      ),
    ],
  );
  NgDocument document = sample();
  final source = TextEditingController();
  bool readOnly = false;
  String status = '';
  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  void import() {
    if (readOnly) return;
    try {
      final next = NgDocument.fromJson(source.text);
      setState(() {
        document = next;
        status = 'Document imported.';
      });
    } on ArgumentError catch (e) {
      setState(() => status = e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'NEXTGEN COMPONENTS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  NgButton(
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
              const SizedBox(height: 28),
              const Text('FLUTTER / DOCUMENTS 0.6'),
              Text(
                'Write clearly.\nKeep the structure.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Text(
                'A structured document editor with block formatting, history and portable JSON. Preview and export contain applied changes.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  NgCheckBox(
                    label: 'Read only',
                    value: readOnly,
                    onChanged: (v) => setState(() => readOnly = v),
                  ),
                  NgButton(
                    onPressed: () => setState(() {
                      document = sample();
                      source.clear();
                      status = 'Sample restored.';
                    }),
                    child: const Text('Reset sample'),
                  ),
                ],
              ),
              NgEditor(
                label: 'Project brief',
                value: document,
                onChanged: (v) => setState(() => document = v),
                readOnly: readOnly,
              ),
              const SizedBox(height: 24),
              Text(
                'Save and restore',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'JSON stores the editable document. HTML is an export for your application. Paste JSON below and import; errors leave the current document intact.',
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  NgButton(
                    onPressed: () => source.text = document.toJson(),
                    child: const Text('Export JSON'),
                  ),
                  NgButton(
                    onPressed: () => source.text = document.toHtml(),
                    child: const Text('Export HTML'),
                  ),
                  NgButton(
                    onPressed: readOnly ? null : import,
                    child: const Text('Import JSON'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: source,
                maxLines: 7,
                maxLength: 1000000,
                decoration: const InputDecoration(labelText: 'Document source'),
              ),
              Semantics(liveRegion: true, child: Text(status)),
              const SizedBox(height: 24),
              const Text('35 CONTROLS / 41 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
