import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class PdfGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const PdfGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<PdfGallery> createState() => _PdfGalleryState();
}

class _PdfGalleryState extends State<PdfGallery> {
  String? source = 'samples/nextgen-guide.pdf';
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
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
            ],
          ),
          const SizedBox(height: 28),
          const Text('FLUTTER / PDF VIEWER 0.8'),
          Text(
            'A clear view. Every page.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Text(
            'Open, navigate, search and download documents in your browser.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NgButton(
                onPressed: () =>
                    setState(() => source = 'samples/nextgen-guide.pdf'),
                child: const Text('Sample PDF'),
              ),
              NgButton(
                onPressed: () => setState(() => source = null),
                child: const Text('Empty viewer'),
              ),
              NgButton(
                onPressed: () => setState(() => source = 'samples/missing.pdf'),
                child: const Text('Missing document'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NgPdfViewer(label: 'Document preview', source: source, height: 720),
          const SizedBox(height: 12),
          const Text(
            'Open PDF stays on your device. Up to 20 MiB / 200 pages. Use Page text to select and copy extracted text.',
          ),
          const SizedBox(height: 20),
          const Text('36 CONTROLS / 42 CATALOGUE ENTRIES · WEB FIRST'),
        ],
      ),
    ),
  );
}
