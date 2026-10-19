import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  testWidgets(
    'Automatic height grows, caps and shrinks without change callbacks',
    (t) async {
      final controller = TextEditingController(text: 'One');
      var changes = 0;
      await t.pumpWidget(
        host(
          NgTextArea(
            controller: controller,
            rows: 2,
            maxRows: 5,
            autoSize: true,
            showClearButton: true,
            onChanged: (_) => changes++,
          ),
        ),
      );
      double height() => t.getSize(find.byType(EditableText)).height;
      final minimum = height();
      controller.text = 'One\nTwo\nThree\nFour';
      await t.pump();
      final four = height();
      expect(four, greaterThan(minimum));
      controller.text = List.filled(20, 'Line').join('\n');
      await t.pump();
      final capped = height();
      expect(capped, greaterThan(four));
      controller.text = List.filled(40, 'Line').join('\n');
      await t.pump();
      expect(height(), capped);
      expect(changes, 0);
      await t.tap(find.byTooltip('Clear Notes'));
      await t.pump();
      expect(height(), minimum);
      expect(changes, 1);
      await t.pumpWidget(host(const SizedBox()));
      controller.dispose();
    },
  );
  testWidgets(
    'Readonly autosize follows external text; fixed mode keeps row count',
    (t) async {
      final controller = TextEditingController(text: 'One');
      Widget page(bool automatic) => host(
        NgTextArea(
          controller: controller,
          readOnly: true,
          rows: 2,
          maxRows: 5,
          autoSize: automatic,
        ),
      );
      await t.pumpWidget(page(true));
      final small = t.getSize(find.byType(EditableText)).height;
      controller.text = List.filled(10, 'Line').join('\n');
      await t.pump();
      expect(t.getSize(find.byType(EditableText)).height, greaterThan(small));
      await t.pumpWidget(page(false));
      expect(t.getSize(find.byType(EditableText)).height, small);
      expect(controller.text.split('\n').length, 10);
      await t.pumpWidget(host(const SizedBox()));
      controller.dispose();
    },
  );
  testWidgets('Automatic size rejects inconsistent row bounds', (t) async {
    for (final widget in [
      const NgTextArea(rows: 4, maxRows: 2, autoSize: true),
      const NgTextArea(maxRows: 0),
      const NgTextArea(maxRows: 31),
    ]) {
      await t.pumpWidget(host(widget));
      expect(t.takeException(), isArgumentError);
    }
    await t.pumpWidget(host(const NgTextArea(rows: 5, maxRows: 2)));
    expect(t.takeException(), isNull);
  });
}
