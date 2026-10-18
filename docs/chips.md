# Chips and tag collections — 0.15

Original implementations with partial feature parity. See the [feature-by-feature reference matrix](parity.md) for source links, verified capabilities and remaining gaps. Availability does not mean completion.

0.15 adds three sizes, four corner treatments, solid/outline fill, five semantic colors, typed per-item appearance overrides, decorative icon/avatar slots, custom content and removal symbols, independent click events and conditional item removal on both Web platforms. Defaults remain compatible with 0.14; they differ from Telerik.

The parent owns selection and removal. A removal callback is a request carrying the stable item ID: accept it by updating items and selected IDs together, or reject it by leaving state unchanged. `CanRemove`/`canRemove` controls whether removal is offered; it does not disable selection or replace request rejection.

The remaining work is substantial: list keyboard navigation and focus management, listbox semantics, generic data binding, the 50-item limit, localization/RTL, public accessibility hooks and screen-reader validation. No full-parity claim is made. Icons are application content, not Telerik icon packages; styling is not a verified pixel match.

See [NgChip](manual/NgChip.md) and [NgChipList](manual/NgChipList.md) for compiled examples and exact API. Templates must contain noninteractive content and retain a meaningful label.
