import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() {
  testWidgets('Cluster radius is validated even when clustering is disabled', (
    tester,
  ) async {
    for (final radius in [19, 121]) {
      await tester.pumpWidget(
        MaterialApp(
          home: NgMap(value: NgMapModel(), clusterRadius: radius),
        ),
      );
      expect(tester.takeException(), isArgumentError);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NgMap(
            value: NgMapModel(),
            clusterMarkers: true,
            clusterRadius: 120,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Map locks and external updates preserve explicit native placeholder',
    (tester) async {
      for (final locked in [false, true, false]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NgMap(
                value: NgMapModel(),
                view: NgMapView(zoom: 4),
                navigationReadOnly: locked,
                selectionReadOnly: locked,
                mapClickReadOnly: locked,
                emptyText: 'No delivery points',
              ),
            ),
          ),
        );
        expect(find.textContaining('available on Web only'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
  test('Map coordinates and zoom reject unsupported values', () {
    for (final p in [
      () => NgMapPoint(double.nan, 0),
      () => NgMapPoint(86, 0),
      () => NgMapPoint(0, 181),
      () => NgMapView(zoom: 20),
    ]) {
      expect(p, throwsArgumentError);
    }
  });
  test('Map copies collections, enforces geometry and shared ID namespace', () {
    final points = [NgMapPoint(50, 30), NgMapPoint(51, 31), NgMapPoint(52, 32)];
    final path = NgMapPath('area', 'Area', points, closed: true);
    points.clear();
    expect(path.points.length, 3);
    expect(() => path.points.clear(), throwsUnsupportedError);
    expect(
      () => NgMapPath('p', 'Polygon', [
        NgMapPoint(0, 0),
        NgMapPoint(1, 1),
      ], closed: true),
      throwsArgumentError,
    );
    expect(
      () => NgMapModel(
        markers: [NgMapMarker('area', 'Marker', NgMapPoint(0, 0))],
        paths: [path],
      ),
      throwsArgumentError,
    );
    expect(
      () => NgMapMarker('bad id', 'Marker', NgMapPoint(0, 0)),
      throwsArgumentError,
    );
    expect(
      () => NgMapModel(
        markers: List.generate(
          501,
          (i) => NgMapMarker('m$i', 'Marker', NgMapPoint(0, 0)),
        ),
      ),
      throwsArgumentError,
    );
  });
  testWidgets('Native Map explicitly reports Web-only support', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NgMap(value: NgMapModel())),
      ),
    );
    expect(find.textContaining('available on Web only'), findsOneWidget);
  });
  testWidgets('Tile provider requires coordinates and attribution', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NgMap(
          value: NgMapModel(),
          tileUrlTemplate: 'https://tiles.test/{z}/{x}/{y}.png',
        ),
      ),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(
      MaterialApp(
        home: NgMap(
          value: NgMapModel(),
          tileUrlTemplate: 'javascript:alert(1)',
          attribution: 'Example',
        ),
      ),
    );
    expect(tester.takeException(), isArgumentError);
  });
}
