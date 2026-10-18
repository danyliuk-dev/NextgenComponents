# Menu and Drawer capabilities — 0.12.0

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

This release is an original implementation of a bounded subset. It does not include Telerik-compatible APIs, flat-to-tree data binding, arbitrary item templates, item icons, automatic URL navigation, mini Drawer mode, Context Menu or swipe gestures. Native mobile platforms remain a later validation phase. Blazor relies on modern browser Popover and dialog APIs; this release is verified in Chrome Web.
