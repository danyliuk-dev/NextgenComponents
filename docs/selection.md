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
