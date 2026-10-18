import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets(
    'direction mirrors chip content and wrapped rows without losing focus or selection',
    (t) async {
      var rtl = true;
      var selected = <String>['a'];
      var items = const [
        NgOption('a', 'Alpha'),
        NgOption('b', 'Beta', disabled: true),
        NgOption('c', 'Gamma'),
        NgOption('d', 'Delta'),
      ];
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SizedBox(
                  width: 320,
                  child: Directionality(
                    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                    child: NgChipList(
                      items: items,
                      value: selected,
                      multiple: true,
                      leadingBuilder: (_) => const Icon(Icons.star, size: 16),
                      onChanged: (v) => setState(() => selected = v),
                      onRemove: (id) => setState(() {
                        items = items.where((x) => x.value != id).toList();
                        selected = selected.where((x) => x != id).toList();
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      Finder chip(String label) =>
          find.ancestor(of: find.text(label), matching: find.byType(NgChip));
      Offset center(String label) => t.getCenter(chip(label));
      expect(center('Alpha').dx, greaterThan(center('Beta').dx));
      expect(center('Gamma').dy, greaterThan(center('Alpha').dy));
      final alpha = chip('Alpha');
      final icon = find.descendant(
        of: alpha,
        matching: find.byIcon(Icons.star),
      );
      final remove = find.descendant(
        of: alpha,
        matching: find.byTooltip('Remove Alpha'),
      );
      expect(
        t.getCenter(icon).dx,
        greaterThan(t.getCenter(find.text('Alpha')).dx),
      );
      expect(
        t.getCenter(remove).dx,
        lessThan(t.getCenter(find.text('Alpha')).dx),
      );
      await t.tap(find.text('Alpha'));
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect(selected, ['c']);
      update(() => rtl = false);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      expect(selected, ['c']);
      expect(center('Alpha').dx, lessThan(center('Beta').dx));
      expect(
        t.getCenter(icon).dx,
        lessThan(t.getCenter(find.text('Alpha')).dx),
      );
      expect(
        t.getCenter(remove).dx,
        greaterThan(t.getCenter(find.text('Alpha')).dx),
      );
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip d');
      update(() => rtl = true);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.delete);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Chip c');
      expect(selected, ['c']);
      expect(find.text('Delta'), findsNothing);
    },
  );
}
