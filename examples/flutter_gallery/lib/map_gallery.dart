import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class MapGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const MapGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<MapGallery> createState() => _MapGalleryState();
}

class _MapGalleryState extends State<MapGallery> {
  static NgMapModel sample() => NgMapModel(
    markers: [
      NgMapMarker(
        'square',
        'Independence Square',
        NgMapPoint(50.4501, 30.5234),
      ),
      NgMapMarker('gate', 'Golden Gate', NgMapPoint(50.4488, 30.5133)),
      NgMapMarker('park', 'Mariinsky Park', NgMapPoint(50.4466, 30.5410)),
    ],
    paths: [
      NgMapPath('walk', 'City walk', [
        NgMapPoint(50.4488, 30.5133),
        NgMapPoint(50.4501, 30.5234),
        NgMapPoint(50.4466, 30.5410),
      ]),
      NgMapPath('area', 'Park area', [
        NgMapPoint(50.449, 30.537),
        NgMapPoint(50.447, 30.545),
        NgMapPoint(50.443, 30.541),
      ], closed: true),
    ],
  );
  NgMapModel model = sample();
  NgMapView view = NgMapView(latitude: 50.4501, longitude: 30.5234, zoom: 13);
  String? selected;
  String provider = 'osm', lastClick = 'none';
  bool addMarker = false, clusterMarkers = true;
  int sequence = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'NEXTGEN COMPONENTS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Foundation'),
              ),
              NgSwitch(
                label: 'Dark theme',
                value: widget.dark,
                onChanged: widget.onDark,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Places in context.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'FLUTTER WEB / MAP 0.9 · Explore locations and connect the map to your application.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NgCheckBox(
                label: 'Cluster markers',
                value: clusterMarkers,
                onChanged: (v) => setState(() => clusterMarkers = v),
              ),
              NgButton(
                child: const Text('Dense markers'),
                onPressed: () => setState(() {
                  model = NgMapModel(
                    markers: List.generate(
                      60,
                      (i) => NgMapMarker(
                        'dense_$i',
                        'Location ${i + 1}',
                        NgMapPoint(
                          50.4501 + (i ~/ 10) * .0007,
                          30.5234 + (i % 10) * .0007,
                        ),
                      ),
                    ),
                  );
                  selected = null;
                  clusterMarkers = true;
                  provider = 'none';
                  view = NgMapView(
                    latitude: 50.452,
                    longitude: 30.526,
                    zoom: 13,
                  );
                }),
              ),
              NgButton(
                child: const Text('Same location'),
                onPressed: () => setState(() {
                  model = NgMapModel(
                    markers: List.generate(
                      3,
                      (i) => NgMapMarker(
                        'same_$i',
                        'Office ${i + 1}',
                        NgMapPoint(50.4501, 30.5234),
                      ),
                    ),
                  );
                  selected = null;
                  clusterMarkers = true;
                  provider = 'none';
                  view = NgMapView(
                    latitude: 50.4501,
                    longitude: 30.5234,
                    zoom: 19,
                  );
                }),
              ),
              NgButton(
                child: const Text('Reset data'),
                onPressed: () => setState(() {
                  model = sample();
                  selected = null;
                  sequence = 0;
                  view = NgMapView(
                    latitude: 50.4501,
                    longitude: 30.5234,
                    zoom: 13,
                  );
                }),
              ),
              NgButton(
                child: const Text('Empty data'),
                onPressed: () => setState(() {
                  model = NgMapModel();
                  selected = null;
                }),
              ),
              NgButton(
                child: const Text('OpenStreetMap'),
                onPressed: () => setState(() => provider = 'osm'),
              ),
              NgButton(
                child: const Text('No basemap'),
                onPressed: () => setState(() => provider = 'none'),
              ),
              NgButton(
                child: const Text('Broken tiles'),
                onPressed: () => setState(() => provider = 'broken'),
              ),
              NgCheckBox(
                label: 'Add marker on map click',
                value: addMarker,
                onChanged: (v) => setState(() => addMarker = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NgMap(
            label: 'Kyiv places',
            value: model,
            clusterMarkers: clusterMarkers,
            view: view,
            selectedId: selected,
            onSelectedIdChanged: (id) => setState(() => selected = id),
            onViewChanged: (v) => setState(() => view = v),
            onMapClick: (p) => setState(() {
              lastClick =
                  '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
              if (addMarker && model.markers.length < 500) {
                sequence++;
                model = NgMapModel(
                  markers: [
                    ...model.markers,
                    NgMapMarker('added_$sequence', 'Added marker $sequence', p),
                  ],
                  paths: model.paths,
                );
              }
            }),
            tileUrlTemplate: provider == 'none'
                ? null
                : provider == 'osm'
                ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                : 'missing-tiles/{z}/{x}/{y}.png',
            attribution: '© OpenStreetMap contributors',
            attributionUrl: 'https://www.openstreetmap.org/copyright',
            height: 560,
          ),
          const SizedBox(height: 12),
          Text(
            'Selected: ${selected ?? 'none'} · Center: ${view.latitude.toStringAsFixed(4)}, ${view.longitude.toStringAsFixed(4)} · Zoom: ${view.zoom} · Last click: $lastClick',
          ),
          const SizedBox(height: 12),
          const Text(
            'Lines are geographic overlays, not calculated routes. OpenStreetMap is an external, best-effort tile service.',
          ),
          const SizedBox(height: 24),
          const Text('37 CONTROLS / 43 CATALOGUE ENTRIES · WEB FIRST'),
        ],
      ),
    ),
  );
}
