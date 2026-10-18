import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextgen_components/nextgen_components.dart';
import 'open_docs_stub.dart' if (dart.library.js_interop) 'open_docs_web.dart';

class CodeGallery extends StatefulWidget {
  final VoidCallback onBack;
  const CodeGallery({super.key, required this.onBack});
  @override
  State<CodeGallery> createState() => _CodeGalleryState();
}

class _CodeGalleryState extends State<CodeGallery> {
  Map<String, dynamic>? examples;
  String selected = 'NgWizard', framework = 'flutter', notice = '';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final text = await rootBundle.loadString(
        'assets/component-examples.json',
      );
      if (mounted)
        setState(() => examples = jsonDecode(text) as Map<String, dynamic>);
    } catch (_) {
      if (mounted)
        setState(
          () => notice = 'Unable to load examples. Rebuild the gallery assets.',
        );
    }
  }

  String get code => examples?[selected]?[framework] as String? ?? '';
  Future<void> copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (mounted) setState(() => notice = 'Code copied.');
    } catch (_) {
      if (mounted)
        setState(() => notice = 'Select the code and copy it manually.');
    }
  }

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
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Foundation'),
                  ),
                  TextButton(
                    onPressed: () => openDocs('getting-started.md'),
                    child: const Text('Getting started'),
                  ),
                  TextButton(
                    onPressed: () => openDocs('README.md'),
                    child: const Text('Documentation'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Code examples',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Text(
                'Working snippets for every component. Getting started provides installation and a complete application shell.',
              ),
              const SizedBox(height: 24),
              if (examples != null) ...[
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Component'),
                  items: examples!.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            '${e.key} — ${e.value['title']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selected = v!),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: [
                    TextButton(
                      onPressed: () => openDocs('$selected.md'),
                      child: const Text('Full component manual'),
                    ),
                    NgButton(onPressed: copy, child: const Text('Copy code')),
                  ],
                ),
                NgRadioGroup(
                  label: 'Framework',
                  items: const [
                    NgOption('blazor', 'Blazor'),
                    NgOption('flutter', 'Flutter'),
                  ],
                  value: framework,
                  onChanged: (v) => setState(() => framework = v!),
                ),
                Text(
                  framework == 'blazor'
                      ? 'Place in an interactive Razor page with @using NextgenComponents.Blazor.'
                      : 'Place fields and build method inside a State class with the Material and Nextgen imports.',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ] else
                const LinearProgressIndicator(),
              Semantics(liveRegion: true, child: Text(notice)),
            ],
          ),
        ),
      ),
    ),
  );
}
