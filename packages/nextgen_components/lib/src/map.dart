import 'dart:convert';
import 'package:flutter/material.dart';
import 'map_frame_stub.dart'
    if (dart.library.js_interop) 'map_frame_web.dart'
    as platform;

class NgMapPoint {
  final double latitude, longitude;
  NgMapPoint(this.latitude, this.longitude) {
    if (!latitude.isFinite ||
        latitude.abs() > 85.05112878 ||
        !longitude.isFinite ||
        longitude.abs() > 180) {
      throw ArgumentError(
        'Use Web Mercator latitude ±85.05112878 and longitude ±180.',
      );
    }
  }
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class NgMapView extends NgMapPoint {
  final int zoom;
  NgMapView({double latitude = 0, double longitude = 0, this.zoom = 2})
    : super(latitude, longitude) {
    if (zoom < 0 || zoom > 19) throw ArgumentError('Zoom must be 0–19.');
  }
  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'zoom': zoom};
}

void _label(String id, String text) {
  if (!RegExp(r'^[a-zA-Z0-9_-]{1,64}$').hasMatch(id) ||
      text.trim().isEmpty ||
      text.length > 200) {
    throw ArgumentError(
      'Use an ASCII ID (1–64 letters, digits, - or _) and text (1–200 characters).',
    );
  }
}

class NgMapMarker {
  final String id, text;
  final NgMapPoint position;
  NgMapMarker(this.id, this.text, this.position) {
    _label(id, text);
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'position': position.toJson(),
  };
}

class NgMapPath {
  final String id, text;
  final List<NgMapPoint> points;
  final bool closed;
  NgMapPath(
    this.id,
    this.text,
    Iterable<NgMapPoint> points, {
    this.closed = false,
  }) : points = List.unmodifiable(points) {
    _label(id, text);
    if (this.points.length < (closed ? 3 : 2) || this.points.length > 5000)
      throw ArgumentError(
        'Paths need 2 points; polygons need 3. Maximum 5000 points.',
      );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'points': points.map((p) => p.toJson()).toList(),
    'closed': closed,
  };
}

class NgMapModel {
  final List<NgMapMarker> markers;
  final List<NgMapPath> paths;
  NgMapModel({
    Iterable<NgMapMarker> markers = const [],
    Iterable<NgMapPath> paths = const [],
  }) : markers = List.unmodifiable(markers),
       paths = List.unmodifiable(paths) {
    if (this.markers.length > 500 ||
        this.paths.length > 100 ||
        this.paths.fold<int>(0, (n, p) => n + p.points.length) > 5000)
      throw ArgumentError(
        'Map supports 500 markers, 100 paths and 5000 path points.',
      );
    if ({
          ...this.markers.map((m) => m.id),
          ...this.paths.map((p) => p.id),
        }.length !=
        this.markers.length + this.paths.length)
      throw ArgumentError('Map IDs must be unique across markers and paths.');
  }
  Map<String, dynamic> toJson() => {
    'markers': markers.map((m) => m.toJson()).toList(),
    'paths': paths.map((p) => p.toJson()).toList(),
  };
}

/// Interactive map for Web. Native platforms show an explicit placeholder.
class NgMap extends StatelessWidget {
  final String label;
  final NgMapModel value;
  final NgMapView? view;
  final String? selectedId, tileUrlTemplate, attributionUrl;
  final String attribution;
  final double height;
  final ValueChanged<NgMapView>? onViewChanged;
  final ValueChanged<String?>? onSelectedIdChanged;
  final ValueChanged<NgMapPoint>? onMapClick;
  const NgMap({
    super.key,
    this.label = 'Map',
    required this.value,
    this.view,
    this.selectedId,
    this.tileUrlTemplate,
    this.attribution = '',
    this.attributionUrl,
    this.height = 520,
    this.onViewChanged,
    this.onSelectedIdChanged,
    this.onMapClick,
  });
  @override
  Widget build(BuildContext context) {
    if (!height.isFinite || height < 400 || height > 1200)
      throw ArgumentError('Use a height from 400 to 1200 pixels.');
    for (final url in [tileUrlTemplate, attributionUrl]) {
      if (url != null && url.trim().isNotEmpty) {
        final uri = Uri.parse(url);
        if (uri.hasScheme && !['http', 'https'].contains(uri.scheme))
          throw ArgumentError('Map URLs must be relative or HTTP(S).');
      }
    }
    if (tileUrlTemplate != null &&
        tileUrlTemplate!.trim().isNotEmpty &&
        (!['{z}', '{x}', '{y}'].every(tileUrlTemplate!.contains) ||
            attribution.trim().isEmpty))
      throw ArgumentError(
        'Tile URL needs {z}, {x}, {y} and visible attribution.',
      );
    final config = jsonEncode({
      'model': value.toJson(),
      'view': (view ?? NgMapView()).toJson(),
      'selectedId': selectedId,
      'tileUrlTemplate': tileUrlTemplate,
      'attribution': attribution,
      'attributionUrl': attributionUrl,
      'dark': Theme.of(context).brightness == Brightness.dark,
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: platform.mapFrame(config, label, (json) {
            final e = jsonDecode(json) as Map<String, dynamic>;
            switch (e['kind']) {
              case 'selection':
                final id = e['id'] as String?;
                if (id == null ||
                    value.markers.any((m) => m.id == id) ||
                    value.paths.any((p) => p.id == id))
                  onSelectedIdChanged?.call(id);
                break;
              case 'view':
                onViewChanged?.call(
                  NgMapView(
                    latitude: (e['latitude'] as num).toDouble(),
                    longitude: (e['longitude'] as num).toDouble(),
                    zoom: e['zoom'] as int,
                  ),
                );
                break;
              case 'click':
                final lat = (e['latitude'] as num).toDouble();
                if (lat.abs() <= 85.05112878)
                  onMapClick?.call(
                    NgMapPoint(lat, (e['longitude'] as num).toDouble()),
                  );
                break;
            }
          }),
        ),
      ],
    );
  }
}
