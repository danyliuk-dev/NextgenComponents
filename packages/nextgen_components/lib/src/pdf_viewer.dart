import 'package:flutter/material.dart';
import 'pdf_frame_stub.dart'
    if (dart.library.js_interop) 'pdf_frame_web.dart'
    as platform;

/// Web PDF viewer. Native platforms display an explicit unsupported message.
class NgPdfViewer extends StatelessWidget {
  final String label;
  final String? source;
  final double height;
  const NgPdfViewer({
    super.key,
    this.label = 'PDF viewer',
    this.source,
    this.height = 640,
  });
  @override
  Widget build(BuildContext context) {
    if (!height.isFinite || height < 400 || height > 1600) {
      throw ArgumentError('Use a height from 400 to 1600 pixels.');
    }
    final uri = source == null || source!.trim().isEmpty
        ? null
        : Uri.parse(source!);
    if (uri != null &&
        uri.hasScheme &&
        !['http', 'https'].contains(uri.scheme)) {
      throw ArgumentError('Source must be a relative or HTTP(S) URL.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: platform.pdfFrame(
            uri?.toString(),
            label,
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ],
    );
  }
}
