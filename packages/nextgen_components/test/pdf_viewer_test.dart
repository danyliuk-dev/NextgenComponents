import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets('native fallback is explicit and relative source is accepted', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SingleChildScrollView(
          child: NgPdfViewer(label: 'Document', source: 'samples/test.pdf'),
        ),
      ),
    );
    expect(find.text('Document'), findsOneWidget);
    expect(find.textContaining('Native support is planned'), findsOneWidget);
  });
  testWidgets('active content URL is rejected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NgPdfViewer(source: 'javascript:alert(1)')),
    );
    expect(tester.takeException(), isArgumentError);
  });
  testWidgets('invalid height is rejected', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NgPdfViewer(height: 10)));
    expect(tester.takeException(), isArgumentError);
  });
}
