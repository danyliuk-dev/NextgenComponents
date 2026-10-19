import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  late NgDocument doc;
  late StateSetter parent;
  bool accept = true, locked = false, callback = true;
  int proposals = 0;
  Future<void> mount(WidgetTester t) async {
    await t.binding.setSurfaceSize(const Size(1200, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    doc = NgDocument(
      blocks: const [
        NgDocumentBlock(text: 'First'),
        NgDocumentBlock(text: 'Second'),
      ],
    );
    accept = true;
    locked = false;
    callback = true;
    proposals = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, set) {
                parent = set;
                return NgEditor(
                  value: doc,
                  readOnly: locked,
                  onChanged: callback
                      ? (v) {
                          proposals++;
                          set(() {
                            if (accept) doc = v;
                          });
                        }
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  NgButton button(WidgetTester t, String label) => t.widget<NgButton>(
    find.ancestor(of: find.text(label), matching: find.byType(NgButton)),
  );
  Future<void> tap(WidgetTester t, String label) async {
    await t.ensureVisible(find.text(label));
    await t.tap(find.text(label));
    await t.pumpAndSettle();
  }

  String text(WidgetTester t) =>
      t.widget<TextField>(find.byType(TextField)).controller!.text;
  Future<void> type(WidgetTester t, String v) async {
    await t.enterText(find.byType(TextField), v);
    await t.pump();
  }

  testWidgets('rejected formatting retains draft and creates no history', (
    t,
  ) async {
    await mount(t);
    parent(() => accept = false);
    await t.pump();
    await type(t, 'Draft');
    await tap(t, 'Bold');
    expect(doc.blocks.first.text, 'First');
    expect(doc.blocks.first.bold, false);
    expect(text(t), 'Draft');
    expect(button(t, 'Undo').onPressed, isNull);
    parent(() => accept = true);
    await t.pump();
    await tap(t, 'Bold');
    expect(doc.blocks.first.text, 'Draft');
    expect(doc.blocks.first.bold, true);
    await tap(t, 'Undo');
    expect(doc.blocks.first.text, 'First');
    expect(text(t), 'First');
    await tap(t, 'Redo');
    expect(text(t), 'Draft');
  });
  testWidgets('rejected selection and insertion retain block and draft', (
    t,
  ) async {
    await mount(t);
    parent(() => accept = false);
    await t.pump();
    await type(t, 'Draft');
    await tap(t, '2. paragraph: Second');
    expect(text(t), 'Draft');
    expect(
      find.text('Block 1 of 2 · Formatting applies to the whole block.'),
      findsOneWidget,
    );
    await tap(t, 'Add block');
    expect(doc.blocks.length, 2);
    expect(text(t), 'Draft');
    parent(() => accept = true);
    await t.pump();
    await tap(t, 'Add block');
    expect(doc.blocks.length, 3);
    expect(doc.blocks.first.text, 'Draft');
    expect(text(t), '');
    await type(t, 'New');
    await tap(t, 'Move down');
    expect(doc.blocks.last.text, 'New');
    expect(text(t), 'New');
  });
  testWidgets('rejected history preserves stacks; discard is local', (t) async {
    await mount(t);
    await type(t, 'Accepted');
    await tap(t, 'Apply text');
    parent(() => accept = false);
    await t.pump();
    await type(t, 'Pending');
    await tap(t, 'Undo');
    expect(doc.blocks.first.text, 'Accepted');
    expect(text(t), 'Pending');
    expect(button(t, 'Redo').onPressed, isNull);
    final before = proposals;
    await tap(t, 'Discard draft');
    expect(text(t), 'Accepted');
    expect(proposals, before);
    parent(() => accept = true);
    await t.pump();
    await tap(t, 'Undo');
    expect(doc.blocks.first.text, 'First');
    await tap(t, 'Redo');
    expect(doc.blocks.first.text, 'Accepted');
  });
  testWidgets('readonly and missing callback allow inspection and discard', (
    t,
  ) async {
    await mount(t);
    await type(t, 'Pending');
    parent(() => locked = true);
    await t.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Pending'), findsOneWidget);
    await tap(t, 'Discard draft');
    expect(proposals, 0);
    await tap(t, '2. paragraph: Second');
    expect(
      find.text('Block 2 of 2 · Formatting applies to the whole block.'),
      findsOneWidget,
    );
    parent(() {
      locked = false;
      callback = false;
    });
    await t.pump();
    expect(find.byType(TextField), findsNothing);
    expect(button(t, 'Add block').onPressed, isNull);
  });
  testWidgets('stale callbacks ignore selection replacement lock disposal', (
    t,
  ) async {
    await mount(t);
    final add = button(t, 'Add block').onPressed!;
    await tap(t, '2. paragraph: Second');
    add();
    await t.pump();
    expect(proposals, 0);
    final bold = button(t, 'Bold').onPressed!;
    parent(() => doc = NgDocument());
    await t.pump();
    bold();
    await t.pump();
    expect(proposals, 0);
    expect(text(t), '');
    final remove = button(t, 'Delete block').onPressed!;
    parent(() => locked = true);
    await t.pump();
    remove();
    expect(proposals, 0);
    parent(() => locked = false);
    await t.pump();
    final after = button(t, 'Add block').onPressed!;
    await t.pumpWidget(const SizedBox());
    after();
    expect(proposals, 0);
    expect(t.takeException(), isNull);
  });
  testWidgets('replacement clears history and draft; no-op emits nothing', (
    t,
  ) async {
    await mount(t);
    await type(t, 'Applied');
    await tap(t, 'Apply text');
    await type(t, 'Pending');
    parent(
      () => doc = NgDocument(blocks: const [NgDocumentBlock(text: 'Imported')]),
    );
    await t.pump();
    expect(text(t), 'Imported');
    expect(button(t, 'Undo').onPressed, isNull);
    expect(button(t, 'Redo').onPressed, isNull);
    final before = proposals;
    await tap(t, '1. paragraph: Imported');
    expect(proposals, before);
  });
  testWidgets(
    'deleting the final empty block discards draft without a proposal',
    (t) async {
      await mount(t);
      parent(() => doc = NgDocument());
      await t.pump();
      await type(t, 'Unapplied');
      await tap(t, 'Delete block');
      expect(text(t), '');
      expect(proposals, 0);
      expect(doc.blocks.length, 1);
      expect(button(t, 'Undo').onPressed, isNull);
    },
  );
}
