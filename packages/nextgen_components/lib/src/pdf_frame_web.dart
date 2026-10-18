import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget pdfFrame(String? source, String label, bool dark) {
  final base = Uri.parse(web.document.baseURI);
  final url = base
      .resolve(
        'assets/packages/nextgen_components/assets/pdf-viewer/index.html',
      )
      .replace(
        queryParameters: {
          'source': source == null ? '' : base.resolve(source).toString(),
          'theme': dark ? 'dark' : 'light',
        },
      )
      .toString();
  return HtmlElementView.fromTagName(
    key: ValueKey('$url|$label'),
    tagName: 'iframe',
    onElementCreated: (element) {
      final frame = element as web.HTMLIFrameElement;
      frame.src = url;
      frame.title = label;
      frame.style.width = '100%';
      frame.style.height = '100%';
      frame.style.border = '1px solid #888';
      frame.style.borderRadius = '4px';
    },
  );
}
