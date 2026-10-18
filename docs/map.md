# Map capabilities — 0.9.1

Reference audit: [Telerik Map overview](https://www.telerik.com/blazor-ui/documentation/components/map/overview), 2026-10-18. The reference includes tile, marker, shape and bubble layers. Nextgen implements the bounded subset below with its own API; this is not full parity.

| Capability | Blazor | Flutter Web |
|---|---|---|
| Configurable XYZ raster tiles with visible attribution | Implemented | Implemented |
| Markers, polylines, simple polygons and text popups | Implemented | Implemented |
| Drag, wheel/double-click zoom, keyboard, fit data | Implemented | Implemented |
| Selected ID, view and background-click callbacks | Implemented | Implemented |
| Immutable validated models; external updates | Implemented | Implemented |
| Empty/no-basemap/loading/tile-error states | Implemented | Implemented |
| Light/dark interface, narrow layout, accessible object list | Implemented | Implemented |
| Optional marker clustering, zoom-to-group and coincident-point chooser | Implemented | Implemented |
| GeoJSON import, bubble/vector tile layers | Planned | Planned |
| Geocoding, routing, geometry editing, export/offline maps | Planned | Planned |
| Native mobile/desktop Flutter | N/A | Explicit unsupported placeholder |

Limits: 500 markers, 100 paths, 5000 path points; Web Mercator latitude ±85.05112878, longitude ±180, zoom 0–19. Simple lines do not calculate routes or handle dateline crossings. One provider per map. Theme changes affect interface chrome; map imagery stays as supplied by the provider.

[Detailed Russian manual with runnable code and API](manual/NgMap.md). Gallery: Blazor `/map`; Flutter home → Map. The demo offers data reset, empty data, missing tiles, no basemap and background-click marker creation.

Leaflet 1.9.4 is vendored locally under BSD-2-Clause; see `shared/map-viewer/vendor/LICENSE` and `PROVENANCE.md`. Synchronize with `python3 scripts/sync_map_assets.py`; `--check` compares both package copies byte for byte. No third-party component source from Telerik is included.

Tile providers are configured by the application. The gallery uses OpenStreetMap's standard raster endpoint, visible linked attribution, normal browser referrer and caching; no bulk/offline download. Read the [OSM tile policy](https://operations.osmfoundation.org/policies/tiles/) before deploying that source. Public tiles are best-effort and have no SLA. With no provider, map objects remain available over a plain grid without a geographic basemap.

### Clustering in 0.9.1

Opt in with `ClusterMarkers` / `clusterMarkers`; radius defaults to 60 CSS pixels (20–120). Groups are deterministic by ID, use projected world pixels and are stable while panning. Selected markers remain individual. A group click zooms toward its members; coincident points or zoom 19 open a scrollable member chooser. Group activation supports Enter and Space. Paths are unaffected; the model limit remains 500 markers. No new external dependency.

Regression checks: `node tests/map/clusters.test.mjs`. With the galleries running and the coordinated visible Chrome task session on port 9341, run `node scripts/chrome-review.mjs tests/map/blazor-browser-regression.json` and the corresponding `flutter-browser-regression.json`. These verify keyboard activation, narrow layout and that the chooser stays visibly open after automatic panning and the parent view callback. They are not headless tests.
