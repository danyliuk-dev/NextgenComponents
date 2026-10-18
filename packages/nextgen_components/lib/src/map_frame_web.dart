import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget mapFrame(String config, String label, ValueChanged<String> onEvent) =>
    _MapFrame(config: config, label: label, onEvent: onEvent);

class _MapFrame extends StatefulWidget {
  final String config, label;
  final ValueChanged<String> onEvent;
  const _MapFrame({
    required this.config,
    required this.label,
    required this.onEvent,
  });
  @override
  State<_MapFrame> createState() => _MapFrameState();
}

class _MapFrameState extends State<_MapFrame> {
  web.HTMLIFrameElement? frame;
  late final JSFunction listener;
  @override
  void initState() {
    super.initState();
    listener = ((web.MessageEvent event) {
      if (frame == null ||
          event.source != frame!.contentWindow ||
          event.origin != web.window.location.origin)
        return;
      final data = event.data.dartify();
      if (data is! Map) return;
      if (data['type'] == 'ng-map-ready') send();
      if (data['type'] == 'ng-map-event' && data['payload'] is String)
        widget.onEvent(data['payload'] as String);
    }).toJS;
    web.window.addEventListener('message', listener);
  }

  void send() {
    final c = jsonDecode(widget.config) as Map<String, dynamic>;
    final base = Uri.parse(web.document.baseURI);
    for (final key in ['tileUrlTemplate', 'attributionUrl']) {
      final url = c[key] as String?;
      c[key] = url == null || url.trim().isEmpty
          ? null
          : base
                .resolve(url)
                .toString()
                .replaceAll('%7B', '{')
                .replaceAll('%7D', '}');
    }
    frame?.title = widget.label;
    frame?.contentWindow?.postMessage(
      {'type': 'ng-map-config', 'payload': jsonEncode(c)}.jsify(),
      web.window.location.origin.toJS,
    );
  }

  @override
  void didUpdateWidget(covariant _MapFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config || oldWidget.label != widget.label)
      send();
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView.fromTagName(
    tagName: 'iframe',
    onElementCreated: (element) {
      frame = element as web.HTMLIFrameElement;
      frame!.src = Uri.parse(web.document.baseURI)
          .resolve(
            'assets/packages/nextgen_components/assets/map-viewer/index.html',
          )
          .toString();
      frame!.title = widget.label;
      frame!.style.width = '100%';
      frame!.style.height = '100%';
      frame!.style.border = '1px solid #888';
      frame!.style.borderRadius = '4px';
    },
  );
}
