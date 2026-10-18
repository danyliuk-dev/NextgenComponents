# Diagram capabilities — 0.7

Reference audit (2026-10-18): [Telerik Diagram overview](https://www.telerik.com/blazor-ui/documentation/components/diagram/overview), [shapes](https://www.telerik.com/blazor-ui/documentation/components/diagram/shapes) and [connections](https://www.telerik.com/blazor-ui/documentation/components/diagram/connections). The reference supports shape and connection configuration, layouts, zoom/pan and interactive connectors. This original implementation covers a bounded graph-editing subset, not API or feature parity; no Telerik source/assets were copied.

| Capability | Blazor | Flutter Web |
|---|---|---|
| Rectangle, ellipse, diamond; label, explicit position and size | Implemented | Implemented |
| Directed/undirected straight edges, boundary anchors, labels | Implemented | Implemented |
| Node/edge selection, controlled callbacks | SVG + keyboard | Canvas hit test + Connections list |
| Pointer drag with cancellable preview; one completed move callback | Implemented | Implemented |
| Arrow keys 10 units / Shift 1 unit; bounded movement | Implemented | Implemented |
| Zoom 25–200%, fit canvas width, scroll viewport | Implemented | Implemented |
| CRUD model; node removal cascades incident connections | Implemented | Implemented |
| Validated immutable graph, JSON v1 shared across platforms | Implemented | Implemented |
| Host gallery property forms, import/export, 20-step undo | Implemented | Implemented |
| Read-only, light/dark, compact, narrow web layout | Implemented | Implemented |
| Auto layout, obstacle routing, drag-to-connect, resize handles | Planned | Planned |
| Templates/images, groups/multiselect, image/PDF export, minimap | Planned | Planned |
| Native mobile and screen reader certification | Not verified | Not verified |

[Detailed Russian manual](manual/NgDiagram.md). Gallery: `/diagram` / Foundation → Diagram. Overlapping nodes and parallel edges are accepted and may visually overlap; this is not a workflow correctness validator. Self links are rejected, general cycles are allowed. No graph data leaves the host application automatically.

## Proposed follow-up (not implemented)

Add a separate **Fit diagram** action that fits the occupied node bounds instead of the entire canvas. Current Fit width intentionally fits canvas width; a small graph on a large canvas becomes unnecessarily small. The proposal was presented to the user and remains separate from release 0.7 pending agreement.
