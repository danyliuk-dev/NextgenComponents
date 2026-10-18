import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  test(
    'document roundtrip, safe HTML, list boundaries and immutable operations',
    () {
      final d = NgDocument(
        blocks: const [
          NgDocumentBlock(text: 'Title', kind: NgBlockKind.heading1),
          NgDocumentBlock(
            text: '<script>\n&',
            kind: NgBlockKind.bullet,
            bold: true,
          ),
          NgDocumentBlock(text: 'Two', kind: NgBlockKind.bullet),
          NgDocumentBlock(text: 'Three', kind: NgBlockKind.numbered),
        ],
      );
      expect(NgDocument.fromJson(d.toJson()).toJson(), d.toJson());
      expect(d.toHtml(), contains('&lt;script&gt;<br>&amp;'));
      expect(d.toHtml(), isNot(contains('<script>')));
      expect(d.toHtml(), contains('</li></ul><ol>'));
      expect(d.move(0, 3).blocks.last.text, 'Title');
      expect(d.blocks.first.text, 'Title');
      expect(d.insertAfter(0).blocks[1].text, '');
      expect(NgDocument().remove(0).blocks.length, 1);
    },
  );
  test('limits and invalid document formats reject atomically', () {
    for (final source in [
      'null',
      '{}',
      '{"version":2,"blocks":[{}]}',
      '{"version":1,"blocks":[{"kind":99}]}',
      '{"version":1,"blocks":[{"html":"unsafe"}]}',
      '{"version":1,"blocks":[{"text":null}]}',
    ]) {
      expect(() => NgDocument.fromJson(source), throwsArgumentError);
    }
    expect(() => NgDocument(blocks: []), throwsArgumentError);
    expect(
      () => NgDocument(blocks: List.filled(101, const NgDocumentBlock())),
      throwsArgumentError,
    );
    expect(
      () => NgDocument(blocks: [NgDocumentBlock(text: 'x' * 10001)]),
      throwsArgumentError,
    );
    expect(
      () => NgDocument(
        blocks: List.filled(11, NgDocumentBlock(text: 'x' * 10000)),
      ),
      throwsArgumentError,
    );
  });
  testWidgets(
    'apply, format, undo, redo, reorder, external reset and read only',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var doc = NgDocument(
        blocks: const [
          NgDocumentBlock(text: 'First'),
          NgDocumentBlock(text: 'Second'),
        ],
      );
      var readOnly = false;
      late StateSetter parent;
      await tester.pumpWidget(
        MaterialApp(
          theme: NgTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, set) {
                  parent = set;
                  return NgEditor(
                    value: doc,
                    onChanged: (v) => set(() => doc = v),
                    readOnly: readOnly,
                  );
                },
              ),
            ),
          ),
        ),
      );
      Future<void> tap(String text) async {
        await tester.ensureVisible(find.text(text));
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      await tester.enterText(find.byType(TextField), 'Changed');
      await tester.pump();
      expect(doc.blocks.first.text, 'First');
      await tap('Bold');
      expect(doc.blocks.first.text, 'Changed');
      expect(doc.blocks.first.bold, true);
      await tap('Undo');
      expect(doc.blocks.first.text, 'First');
      expect(doc.blocks.first.bold, false);
      await tap('Redo');
      expect(doc.blocks.first.text, 'Changed');
      await tester.tap(find.byType(DropdownButtonFormField<NgBlockKind>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('heading2').last);
      await tester.pumpAndSettle();
      expect(doc.blocks.first.kind, NgBlockKind.heading2);
      await tester.tap(find.byType(DropdownButtonFormField<NgTextAlign>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('center').last);
      await tester.pumpAndSettle();
      expect(doc.blocks.first.align, NgTextAlign.center);
      await tap('Move down');
      expect(doc.blocks.last.text, 'Changed');
      await tap('Add block');
      expect(doc.blocks.length, 3);
      await tap('Delete block');
      expect(doc.blocks.length, 2);
      parent(
        () =>
            doc = NgDocument(blocks: const [NgDocumentBlock(text: 'External')]),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<NgButton>(
              find.ancestor(
                of: find.text('Undo'),
                matching: find.byType(NgButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'External',
      );
      parent(() => readOnly = true);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, true);
      expect(
        tester
            .widget<NgButton>(
              find.ancestor(
                of: find.text('Add block'),
                matching: find.byType(NgButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
