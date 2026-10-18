# Chips and tag collections — 0.23

Original implementations with partial feature parity. See the [feature-by-feature reference matrix](parity.md) for source links, verified capabilities and remaining gaps. Availability does not mean completion.

0.15 adds three sizes, four corner treatments, solid/outline fill, five semantic colors, typed per-item appearance overrides, decorative icon/avatar slots, custom content and removal symbols, independent click events and conditional item removal on both Web platforms. Defaults remain compatible with 0.14; they differ from Telerik.

The parent owns selection and removal. A removal callback is a request carrying the stable item ID: accept it by updating items and selected IDs together, or reject it by leaving state unchanged. `CanRemove`/`canRemove` controls whether removal is offered; it does not disable selection or replace request rejection.

The remaining work is substantial: removable-list and Flutter listbox/option semantics, broader traversal compatibility and screen-reader validation. No full-parity claim is made. Icons are application content, not Telerik icon packages; styling is not a verified pixel match.

See [NgChip](manual/NgChip.md) and [NgChipList](manual/NgChipList.md) for compiled examples and exact API. Templates must contain noninteractive content and retain a meaningful label.

0.16 adds Left/Right (including RTL), Home/End, Delete/Backspace and focus restoration to the next/previous enabled chip or the list container. Rejected removal keeps focus; delayed updates do not steal focus from outside controls. Blazor has a public FocusAsync method. Full listbox semantics, screen-reader verification remain open. See the manual for callback ownership and exact keyboard rules.

0.17 adds one remembered Tab entry per list on both Web platforms. Initial entry prefers an enabled selected chip; Tab and Shift+Tab exit to neighboring controls. Arrows navigate inside the list and Delete/Backspace request removal. Empty/fully disabled lists do not add a Tab stop. Flutter focus scopes now pass traversal to the parent instead of trapping Tab. Semantic listbox roles remain pending.

0.18 adds application-supplied remove and empty labels for both platforms, plus NgChipListController for Flutter first-action or stable-ID focus. Controller lifecycle, shared-owner rejection, invalid targets and custom labels have regression tests. No locale dictionaries or screen-reader certification are supplied.

0.19 removes the fixed ChipList item-count cap, with 500-tag Web examples and keyboard/selection/removal tests. Validation uses sets and Flutter reveals focused chips in scrollable ancestors. Rendering remains eager; practical capacity depends on templates, device and viewport. ButtonGroup and Drawer limits are unchanged.

0.20 adds NgChipData<T>, a validated snapshot of typed application records. Selectors map IDs, labels, disabled/removable state and appearance; event handlers and templates resolve the original record by ID. Rebuild after model changes. This is typed binding, not string property-name reflection.

0.21 verifies inherited RTL layout for Chip/ChipList, including wrapped rows, leading/removal placement, runtime switching, keyboard movement and removal recovery. The Blazor remove divider uses a logical border edge. Both galleries include an English Reading direction example. Translation, custom directional icons and screen-reader pronunciation remain application/audit responsibilities.

0.22 adds Blazor Id/Class and accessible-name/description references, plus Flutter semanticIdentifier/semanticHint. Metadata updates are demonstrated alongside stable selection. The manual documents platform differences and target elements; no screen-reader certification or configurable TabIndex is implied. The public API review also records ChipList Gap as remaining work.

0.23 adds sm/md/lg ChipList gap presets and TabIndex/tabIndex -1/0 for Chip and ChipList. A skipped list remains pointer- and programmatically accessible; returning to 0 restores its remembered entry. Positive indices are outside this contract. Detailed lifecycle and spacing examples are in the manual.

## 0.24: Blazor selection-only semantics

Selectable lists without an OnRemove callback now expose a horizontal listbox with selected options, including multiple-selection metadata. Removable lists remain groups of buttons so each remove action stays accessible. Changing the callback or Multiple at runtime preserves selection and remembered focus. Standalone Chip is unchanged. See the manual for the exact contract and the Selection semantics demo for interactive comparison.

Flutter retains its existing native chip semantics; its installed SDK has no listbox/option role values. Type-ahead, removable-list parity and screen-reader validation remain open.
