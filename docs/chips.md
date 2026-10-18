# Chips and tag collections — 0.14

Original implementations, not Telerik source or API compatibility. Reference audit: 2026-10-18.

References: [Chip overview](https://www.telerik.com/blazor-ui/documentation/components/chip/overview), [ChipList overview](https://www.telerik.com/blazor-ui/documentation/components/chiplist/overview), [selection](https://www.telerik.com/blazor-ui/documentation/components/chiplist/selection), [events](https://www.telerik.com/blazor-ui/documentation/components/chiplist/events).

| Capability | Blazor / Flutter Web |
|---|---|
| Text chip, controlled selection, disabled state | Implemented |
| Collection, single/multiple selection, optional empty choice | Implemented; max 50 NgOption items |
| Independent removal action | Request callback; parent accepts/rejects and updates items + selected IDs |
| Nonselectable display labels | Implemented |
| Native keyboard activation, selected semantics | Implemented; screen-reader certification deferred |
| Wrapping, light/dark | Implemented |
| Icons, avatars, templates, size/fill variants | Deferred |
| Drag sorting, editable tags, virtualization | Deferred |
| Arrow list navigation / focus transfer after removal | Deferred |
| Native mobile verification | Deferred |

Improvement in our contract: removal is explicitly a request carrying the stable item ID. The parent can reject it without restoring a mutated collection, and updates selection and items together. The demo includes protected removal and a reset, so both acceptance and rejection are visible.

See [NgChip](manual/NgChip.md) and [NgChipList](manual/NgChipList.md) for compiled code examples and full public API.
