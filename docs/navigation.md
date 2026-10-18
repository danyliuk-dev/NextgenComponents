# Menu and Drawer capabilities — 0.27.0

[Menu manual and code](manual/NgMenu.md) · [Drawer manual and code](manual/NgDrawer.md) · [Coverage](catalog.md)

The navigation gallery combines nested workspace commands, a selected section, a persistent draft note, disabled destinations and switchable Push/Overlay modes. Open `/navigation` in Blazor or **Menu and drawer** in Flutter. Both code browsers include runnable examples.

| Capability | Blazor Web | Flutter Web |
|---|---|---|
| Horizontal / vertical command menu | Native HTML popovers | Material menu widgets |
| Nested groups, disabled ancestors, leaf callbacks | Up to 3 levels / 100 nodes | Same model limits |
| Keyboard opening, navigation, dismissal | Roving focus and arrow keys | Material menu focus handling |
| Flat selected / disabled drawer destinations | Up to 100 items | Same model limits |
| Push panel / modal Overlay | Native dialog | Owned root Navigator dialog route |
| Narrow viewport | Push stacks; overlay width clamps | Push stacks; overlay width clamps |
| Theme and controlled state | Shared CSS tokens | Shared Material theme |

The app owns command dispatch, URL routing, permissions and draft storage. Menu IDs and Drawer IDs are deliberately explicit: selecting an entry never executes arbitrary URLs or clears application state. Modal dismissal requires a parent visibility callback.

## Reference audit and remaining scope

Reviewed against official Telerik [Menu overview](https://www.telerik.com/blazor-ui/documentation/components/menu/overview), [navigation](https://www.telerik.com/blazor-ui/documentation/components/menu/navigation), [orientation](https://www.telerik.com/blazor-ui/documentation/components/menu/orientation), [Drawer overview](https://www.telerik.com/blazor-ui/documentation/components/drawer/overview) and [modes](https://www.telerik.com/blazor-ui/documentation/components/drawer/modes).

This release is an original implementation of a bounded subset. It does not include Telerik-compatible APIs, flat-to-tree data binding, automatic URL navigation, mini Drawer mode, Context Menu or swipe gestures. Native mobile platforms remain a later validation phase. Blazor relies on modern browser Popover and dialog APIs; this release is verified in Chrome Web.

## Navigation workbench (0.27)

Both platforms now support Menu item/leading templates, visible and separator model flags, CloseOnClick, and RTL. Drawer adds header/footer/item/leading content, pure visibility/separator predicates, logical start/end positioning, RTL, CloseOnSelect and a global disabled state that keeps an already-open overlay dismissible. A destination without a selection callback is disabled. Text labels remain accessible names even when display content is replaced.

The Menu and Drawer manuals contain detailed contracts and runnable live examples. The navigation gallery combines every new setting with disabled ancestors, nested commands, Push/Overlay switching, a selected section and a persistent draft note. Template content is display-only for item/leading slots. Hidden items remain validated and do not silently clear the controlled selection.

Reference audit: [Menu templates](https://www.telerik.com/blazor-ui/documentation/components/menu/templates), [Menu binding](https://www.telerik.com/blazor-ui/documentation/components/menu/data-binding/overview), [Drawer templates](https://www.telerik.com/blazor-ui/documentation/components/drawer/templates), [Drawer mini view](https://www.telerik.com/blazor-ui/documentation/components/drawer/mini-view). Remaining differences include hover/open-delay configuration, popup animation/settings, automatic URL handling, arbitrary-model and flat-to-tree binding, full drawer-template replacement, mini mode, swipe gestures and full screen-reader verification. These differences have not been accepted as full parity.
