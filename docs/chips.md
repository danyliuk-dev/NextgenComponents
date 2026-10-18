# Chips and tag collections — 0.16

Original implementations with partial feature parity. See the [feature-by-feature reference matrix](parity.md) for source links, verified capabilities and remaining gaps. Availability does not mean completion.

0.15 adds three sizes, four corner treatments, solid/outline fill, five semantic colors, typed per-item appearance overrides, decorative icon/avatar slots, custom content and removal symbols, independent click events and conditional item removal on both Web platforms. Defaults remain compatible with 0.14; they differ from Telerik.

The parent owns selection and removal. A removal callback is a request carrying the stable item ID: accept it by updating items and selected IDs together, or reject it by leaving state unchanged. `CanRemove`/`canRemove` controls whether removal is offered; it does not disable selection or replace request rejection.

The remaining work is substantial: listbox/option semantics, generic data binding, localization/RTL, public accessibility hooks and screen-reader validation. No full-parity claim is made. Icons are application content, not Telerik icon packages; styling is not a verified pixel match.

See [NgChip](manual/NgChip.md) and [NgChipList](manual/NgChipList.md) for compiled examples and exact API. Templates must contain noninteractive content and retain a meaningful label.

0.16 adds Left/Right (including RTL), Home/End, Delete/Backspace and focus restoration to the next/previous enabled chip or the list container. Rejected removal keeps focus; delayed updates do not steal focus from outside controls. Blazor has a public FocusAsync method. Full listbox semantics, screen-reader verification remain open. See the manual for callback ownership and exact keyboard rules.

0.17 adds one remembered Tab entry per list on both Web platforms. Initial entry prefers an enabled selected chip; Tab and Shift+Tab exit to neighboring controls. Arrows navigate inside the list and Delete/Backspace request removal. Empty/fully disabled lists do not add a Tab stop. Flutter focus scopes now pass traversal to the parent instead of trapping Tab. Semantic listbox roles remain pending.

0.18 adds application-supplied remove and empty labels for both platforms, plus NgChipListController for Flutter first-action or stable-ID focus. Controller lifecycle, shared-owner rejection, invalid targets and custom labels have regression tests. No locale dictionaries or screen-reader certification are supplied.

0.19 removes the fixed ChipList item-count cap, with 500-tag Web examples and keyboard/selection/removal tests. Validation uses sets and Flutter reveals focused chips in scrollable ancestors. Rendering remains eager; practical capacity depends on templates, device and viewport. ButtonGroup and Drawer limits are unchanged.
