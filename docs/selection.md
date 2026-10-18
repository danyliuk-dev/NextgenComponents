# ToggleButton and ButtonGroup — 0.13.0

[ToggleButton manual](manual/NgToggleButton.md) · [ButtonGroup manual](manual/NgButtonGroup.md) · [Code examples](manual/code-examples.md)

Open **Toggle buttons** in either demo (Blazor route `/selection`). The complete preview combines a border toggle, exclusive alignment, multiple text styles, disabled options and external reset. State remains in the host application.

| Capability | Both Web implementations |
|---|---|
| Standalone toggle | Controlled Boolean value and one change callback |
| Single choice group | Zero or one selected ID; selecting another replaces it |
| Multiple choice group | Independent toggles; new selected list in item order |
| Last-choice protection | AllowEmpty=false prevents user deselection of the final item |
| External state | Reset and replacement without mutating input collections |
| Disabled state | Whole group, individual options, or missing callback |
| Layout | Wrapping horizontal buttons or a vertical stack |
| Keyboard | Tab / Shift+Tab, Enter / Space; retained focus on state changes |
| Limits | 50 options; unique IDs and validated labels / selected IDs |

This is an original subset, audited against the official [ToggleButton overview](https://www.telerik.com/blazor-ui/documentation/components/togglebutton/overview), [ButtonGroup overview](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/overview) and [selection rules](https://www.telerik.com/blazor-ui/documentation/components/buttongroup/selection).

The current API uses data-bound plain-text options and a single controlled selection callback. Mixed command/toggle child components, icons, arbitrary templates, separate click events and appearance variants are not implemented. SegmentedControl remains a separate planned component. The group uses toggle-button semantics, not an arrow-key radio group. Native mobile testing remains deferred.

## 0.26: selection-button component block

ToggleButton and ButtonGroup now support independent click events, mixed command/toggle groups, display templates and decorative icons, visibility without discarding selection, size/corner/fill/color settings and per-item appearance, plus platform-specific identity/help/focus hooks. The parent owns command effects and all selected state. Commands cannot be selected. Detailed compiled examples and event ordering are in the two component manuals.

The demo combines these capabilities in one formatting panel. Original tokens and a data-driven model differ from Telerik; inherited APIs, native form button types, width API and screen-reader certification remain in the parity matrix. This is a component-block delivery, not a full-parity claim.
