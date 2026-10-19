# Diagram capabilities — 0.42

Reference audit (2026-10-18): [Telerik Diagram overview](https://www.telerik.com/blazor-ui/documentation/components/diagram/overview), [shapes](https://www.telerik.com/blazor-ui/documentation/components/diagram/shapes) and [connections](https://www.telerik.com/blazor-ui/documentation/components/diagram/connections). The reference supports shape and connection configuration, layouts, zoom/pan and interactive connectors. This original implementation covers a bounded graph-editing subset, not API or feature parity; no Telerik source/assets were copied.

| Capability | Blazor | Flutter Web |
|---|---|---|
| Rectangle, ellipse, diamond; label, explicit position and size | Implemented | Implemented |
| Directed/undirected straight edges, boundary anchors, labels | Implemented | Implemented |
| Node/edge selection, controlled callbacks | SVG + keyboard | Canvas hit test + Connections list |
| Pointer drag with cancellable preview; one completed move callback | Implemented | Implemented |
| Arrow keys 10 units / Shift 1 unit; bounded movement | Implemented | Implemented |
| Zoom 25–200%, fit canvas width / occupied node bounds, scroll viewport | Implemented | Implemented |
| CRUD model; node removal cascades incident connections | Implemented | Implemented |
| Validated immutable graph, JSON v1 shared across platforms | Implemented | Implemented |
| Host gallery property forms, import/export, 20-step undo | Implemented | Implemented |
| Read-only, light/dark, compact, narrow web layout | Implemented | Implemented |
| Auto layout, obstacle routing, drag-to-connect, resize handles | Planned | Planned |
| Templates/images, groups/multiselect, image/PDF export, minimap | Planned | Planned |
| Native mobile and screen reader certification | Not verified | Not verified |

[Detailed English manual](manual/NgDiagram.md). Gallery: `/diagram` / Foundation → Diagram. Overlapping nodes and parallel edges are accepted and may visually overlap; this is not a workflow correctness validator. Self links are rejected, general cycles are allowed. No graph data leaves the host application automatically.

## Fit diagram (0.7.1)

Fit diagram uses occupied node bounds, 24px padding and both viewport dimensions, then centers with bounded scrolling. It preserves graph coordinates, selection and JSON; navigation works in read-only mode. Empty graphs disable the action. Zoom remains 25–200%, so very large diagrams can still require scrolling; labels extending beyond node bounds are not included. Fit width continues to fit the canvas width.

## Guarded interactions (0.42)

ReadOnly and a missing movement callback block coordinate changes. SelectionReadOnly independently blocks selection; missing node/edge callbacks disable their own selection action. Zoom and scrolling remain available. Parent updates cancel drag previews and invalidate captured actions; replacements that reuse node IDs cannot receive stale movement. Blazor rechecks graph identity and permissions after asynchronous selection callbacks. The parent accepts or rejects graph proposals, and owns ordering of late asynchronous responses.

NodeLabel and EdgeLabel provide plain-text display/accessibility labels without modifying IDs or exported JSON. EmptyText customizes the empty state. Full labels remain available through accessible names and tooltips/list entries while canvas labels may be shortened.
