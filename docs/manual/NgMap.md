# NgMap — Interactive map

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display geographic markers, paths and polygons over an optional raster basemap.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgMap) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgMap)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Hosting and tiles
Blazor requires interactive rendering and static assets. With UseStaticFiles map .mjs to text/javascript for the clustering module (gallery Program.cs). Leaflet 1.9.4 is packaged in map-viewer and Flutter assets; no CDN/script tags are needed. Flutter implements Web; native shows an unsupported-platform message.

TileUrlTemplate must contain {z}, {x}, {y}; relative and HTTP(S) URLs are supported. Empty source shows a grid and your objects without a basemap. Attribution is required for a configured provider; AttributionUrl adds a link. Attribution/object labels are plain text. Choose a provider supporting zoom 0–19 and your usage terms. Custom headers, bearer tokens, TMS and vector tiles are not supported.

For OpenStreetMap keep attribution, normal Referrer and browser cache; do not bulk-prefetch or download offline. The public service has no SLA; review the provider terms and [tile policy](https://operations.osmfoundation.org/policies/tiles/). Object labels are not sent to the provider, but IP, Referrer and tile coordinates are. Host CSP must permit local frames/scripts/styles, Leaflet inline styles and provider images.

### Data model
NgMapPoint accepts latitude first, longitude second: finite latitude ±85.05112878, longitude ±180. NgMapMarker has ID, label and position. NgMapPath is a straight polyline with at least 2 points, or a closed polygon with at least 3; closing is automatic. These are geographic lines, not road routing. No date-line crossing, holes or multipolygons.

NgMapModel copies collections and exposes read-only data. IDs are unique across markers and paths: 1–64 ASCII letters/digits/_/-. Labels: 1–200 characters, not only whitespace. Limits: 500 markers, 100 paths/polygons, 5,000 total path points. Invalid input raises ArgumentException/ArgumentError. Replace the model to update; there is no automatic persistence/loading.

### View and events
View defines center and integer zoom 0–19 (initial 0,0,2). Drag pans; wheel/double-click/+/- zoom. Focused maps accept arrows and +/-. Fit data fits all objects with padding and zoom at most 14; empty models disable it. Data changes do not auto-fit. The center is limited to world bounds.

Store ViewChanged/onViewChanged after movement, zoom, fit or programmatic changes. SelectedId is one object ID or null; selection callbacks report marker/path IDs or null after Clear selection. Unknown IDs appear unselected without correcting parent state. Objects buttons are keyboard accessible and open object popups; objects are also clickable directly. OnMapClick reports a coordinate only for free background, not object clicks. To add a marker, build a new NgMapModel with the old items and a uniquely identified marker. No address/geocoding is returned.

Height: 400–1200, default 520. Below 540 px the Objects list moves under the map and scrolls horizontally. Label also names the iframe. Blazor Dark is explicit; Flutter reads Theme. Theme/model updates preserve the iframe/view when View is unchanged; provider imagery is not inverted.

### Clustering
ClusterMarkers defaults to false. ClusterRadius is an integer 20–120 CSS px, default 60, validated even when clustering is off. Distance is screen distance at the current zoom, not meters. Markers sort by ID and group around the first point; neighbor chains do not merge indefinitely. Input ordering and panning do not change membership; zoom recalculates groups. Date-line points are not clustered together.

Activating a cluster zooms at least one level, up to 19. Coincident points or maximum zoom open a scrollable member chooser. Choosing a member triggers normal selection and displays its individual marker/popup. Clusters have no public object ID and do not trigger background clicks. A selected marker stays outside clusters; Clear selection rejoins it, so a cluster count excludes the selected marker while the total includes every marker. Objects selection behaves the same way.

Clusters support Tab/Enter and popup buttons. Data/clustering updates preserve the view but may close a regrouped popup; theme changes retain groups. Paths are not clustered. The 500-marker model limit still applies: this is not server aggregation. Dense markers and Same location gallery scenarios demonstrate it without external tiles.

### Status and omissions
No objects, No basemap configured, Loading tiles, Tiles loaded and Some map tiles unavailable distinguish data and provider states. Objects/selection still work when tiles fail. Navigation/source changes request new tiles. One raster basemap only; no geocoding, routing, GeoJSON import, bubble layers, geometry editing, export or offline mode. Filter large datasets in the application before supplying them.

## Blazor example

```razor
<NgMap Label="Objects" Value="map" ClusterMarkers="true" ClusterRadius="60" @bind-View="view" @bind-SelectedId="selected"
    OnMapClick="Clicked" TileUrlTemplate="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
    Attribution="© OpenStreetMap contributors" AttributionUrl="https://www.openstreetmap.org/copyright"/>
<p>Selected: @selected; last point: @last</p>
@code {
 private string? selected; private string last="";
 private NgMapView view=new(50.4501,30.5234,13);
 private NgMapModel map=new(
   [new("office","Office",new(50.4501,30.5234)),new("park","Park",new(50.4466,30.5410))],
   [new("line","Line",[new(50.4501,30.5234),new(50.4466,30.5410)])]);
 private void Clicked(NgMapPoint p){last=$"{p.Latitude:F4}, {p.Longitude:F4}";}
}
```

## Flutter example

```dart
String? selected;
String last = '';
NgMapView view = NgMapView(latitude: 50.4501, longitude: 30.5234, zoom: 13);
final map = NgMapModel(markers: [
  NgMapMarker('office', 'Office', NgMapPoint(50.4501, 30.5234)),
  NgMapMarker('park', 'Park', NgMapPoint(50.4466, 30.5410)),
], paths: [NgMapPath('line', 'Line', [
  NgMapPoint(50.4501, 30.5234), NgMapPoint(50.4466, 30.5410),
])]);
Widget build(BuildContext context) => NgMap(label: 'Objects', value: map,
  view: view, selectedId: selected, clusterMarkers: true, clusterRadius: 60,
  onViewChanged: (v) => setState(() => view = v),
  onSelectedIdChanged: (id) => setState(() => selected = id),
  onMapClick: (p) => setState(() => last = '${p.latitude}, ${p.longitude}'),
  tileUrlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  attribution: '© OpenStreetMap contributors',
  attributionUrl: 'https://www.openstreetmap.org/copyright');
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Map" | Visible label or accessible name. |
| `Value` | `NgMapModel` | new() | Current value; see state ownership and model rules above. |
| `View` | `NgMapView` | new() | See the behavior rules and model contract above. |
| `ViewChanged` | `EventCallback<NgMapView>` | not set | See the behavior rules and model contract above. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string?>` | not set | Selected item ID for the parent to store. |
| `OnMapClick` | `EventCallback<NgMapPoint>` | not set | See the behavior rules and model contract above. |
| `TileUrlTemplate` | `string?` | not set | See the behavior rules and model contract above. |
| `Attribution` | `string` | "" | See the behavior rules and model contract above. |
| `AttributionUrl` | `string?` | not set | See the behavior rules and model contract above. |
| `ClusterMarkers` | `bool` | false | See the behavior rules and model contract above. |
| `ClusterRadius` | `int` | 60 | See the behavior rules and model contract above. |
| `Dark` | `bool` | false | See the behavior rules and model contract above. |
| `Height` | `int` | 520 | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgMapModel` | Current value; see state ownership and model rules above. |
| `view` | `NgMapView?` | See the behavior rules and model contract above. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `tileUrlTemplate` | `String?` | See the behavior rules and model contract above. |
| `attributionUrl` | `String?` | See the behavior rules and model contract above. |
| `attribution` | `String` | See the behavior rules and model contract above. |
| `height` | `double` | See the behavior rules and model contract above. |
| `clusterMarkers` | `bool` | See the behavior rules and model contract above. |
| `clusterRadius` | `int` | See the behavior rules and model contract above. |
| `onViewChanged` | `ValueChanged<NgMapView>?` | See the behavior rules and model contract above. |
| `onSelectedIdChanged` | `ValueChanged<String?>?` | Selected item ID for the parent to store. |
| `onMapClick` | `ValueChanged<NgMapPoint>?` | See the behavior rules and model contract above. |

```dart
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
    this.clusterMarkers = false,
    this.clusterRadius = 60,
    this.onViewChanged,
    this.onSelectedIdChanged,
    this.onMapClick,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgMap.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/map.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
