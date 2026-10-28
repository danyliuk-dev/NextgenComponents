import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class RemoteRangeGallery extends StatefulWidget {
  const RemoteRangeGallery({super.key});
  @override
  State<RemoteRangeGallery> createState() => _RemoteRangeGalleryState();
}

class _RemoteRangeGalleryState extends State<RemoteRangeGallery> {
  bool fail = false,
      malformed = false,
      slow = false,
      small = false,
      locked = false;
  int version = 0, reads = 0;
  String lastRequest = 'none';
  Set<String> selected = {};
  NgGridExportFile? exported;
  static String id(int i) => 'R${i.toString().padLeft(6, '0')}';
  final columns = <NgDataColumn<int>>[
    NgDataColumn('id', 'Record', (i) => i, format: id),
    NgDataColumn(
      'name',
      'Name',
      (i) => 'Inventory ${i.toString().padLeft(6, '0')}',
    ),
  ];
  Future<NgDataRangeResult<int>> read(NgDataRangeRequest request) async {
    final url =
        'http://127.0.0.1:5180/api/range-inventory?fail=$fail&malformed=$malformed&slow=$slow&small=$small';
    reads++;
    lastRequest = '${request.startIndex} + ${request.count}';
    try {
      final response = await web.window
          .fetch(
            url.toJS,
            web.RequestInit(
              method: 'POST',
              headers:
                  {'Content-Type': 'application/json'}.jsify()! as JSObject,
              body: jsonEncode({
                'startIndex': request.startIndex,
                'count': request.count,
                'search': request.search,
                'sorts': [
                  for (final sort in request.sorts)
                    {'key': sort.key, 'descending': sort.descending},
                ],
              }).toJS,
            ),
          )
          .toDart;
      if (!response.ok) throw StateError('Range request failed');
      final json =
          jsonDecode((await response.text().toDart).toDart)
              as Map<String, dynamic>;
      return NgDataRangeResult(
        json['startIndex'] as int,
        (json['items'] as List).cast<int>(),
        json['total'] as int,
      );
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Remote ranges')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Scroll the server result',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text(
            '100,000 synthetic records over HTTP. The client retains one bounded window. Ctrl+End jumps to the end without downloading preceding records.',
          ),
          Wrap(
            spacing: 16,
            children: [
              NgCheckBox(
                label: 'Fail reads',
                value: fail,
                onChanged: (v) => setState(() => fail = v),
              ),
              NgCheckBox(
                label: 'Malformed response',
                value: malformed,
                onChanged: (v) => setState(() => malformed = v),
              ),
              NgCheckBox(
                label: 'Slow reads',
                value: slow,
                onChanged: (v) => setState(() => slow = v),
              ),
              NgCheckBox(
                label: 'Server has 12 records',
                value: small,
                onChanged: (v) => setState(() => small = v),
              ),
              NgCheckBox(
                label: 'Lock selection',
                value: locked,
                onChanged: (v) => setState(() => locked = v),
              ),
              TextButton(
                onPressed: () => setState(() => version++),
                child: const Text('Refresh query'),
              ),
            ],
          ),
          Text(
            'HTTP requests: $reads. Requested: $lastRequest. Selection: ${selected.take(8).join(', ')}.',
          ),
          const Text(
            'Flags affect the next read. After a failure, clear its flag and use Retry. Refresh query resets the window; scrolling observes live server shrinkage.',
          ),
          NgDataGrid<int>(
            readRange: read,
            virtualize: true,
            dataVersion: version,
            rowId: id,
            columns: columns,
            label: 'Remote inventory',
            multiSort: true,
            selectedIds: selected,
            onSelectionChanged: (v) => setState(() => selected = v),
            selectionReadOnly: locked,
            canSelect: (i) => i % 100 != 0,
            export: NgGridExport(
              onExport: (file) async {
                if (mounted) setState(() => exported = file);
              },
            ),
          ),
          if (exported case final file?) ...[
            Text('Exported ${file.rowCount} loaded records.'),
            TextButton(
              onPressed: () {
                final anchor = web.HTMLAnchorElement()
                  ..href =
                      'data:${file.mimeType};base64,${base64Encode(file.bytes)}'
                  ..download = file.fileName;
                anchor.click();
              },
              child: const Text('Download loaded window'),
            ),
          ],
        ],
      ),
    ),
  );
}
