# NgChipList — Controlled tag collection

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Present filter topics or selected tags with single/multiple selection and application-owned removal.

## Behavior and practical rules

### State and events

The parent owns Value/value and stores selection callbacks. Selectable/selectable defaults to true. Disable it for a display-only label. OnRemove/onRemove is optional: providing it shows a separate, named remove action. Removal never changes selection or data automatically. Reject a request by leaving state unchanged; accept it by removing the ID from both items and selected values in one update. Removal does not fire the selection callback. Keep durable state in the parent.

### Keyboard and accessibility

Selection and removal have separate accessible actions. Tab enters the list once and then leaves; arrows move inside; Enter or Space activates the focused action. Selected state is exposed to assistive technology. Disabled chips cannot be selected or removed. Delete or Backspace requests removal from a focused interactive chip. Holding the key does not repeatedly remove chips. ChipList adds Left/Right and Home/End navigation with focus recovery after removal; see the keyboard rules below. Test screen-reader behavior in your target browser.

### Scope

Labels must be nonblank and at most 120 UTF-16 code units. Labels render as text, never HTML. Light/dark styling and wrapping are supported. Icons and avatars can be supplied as leading content, and custom labels and remove icons are supported. Drag sorting, editable tags and virtualization are not established Telerik Chip/ChipList requirements and remain possible extensions, not parity claims. Web is the verified target; mobile verification is a separate phase.

### Collection contract

Use NgOption IDs, not display labels. IDs must be unique, 1–64 ASCII letters, digits, underscores or hyphens. Since 0.19, ChipList has no fixed item-count cap. Selected IDs must be unique and exist in items; single mode accepts at most one. Multiple/multiple defaults to false. AllowEmpty/allowEmpty defaults to true; false prevents deselecting the last choice, but does not invent an initial selection or block application-owned removal. Callbacks return IDs in item order. No-op selection does not emit a callback. Empty items with empty value displays No tags.

When switching from multiple to single selection, normalize the selection in the same update. Disabled selected items stay visible; another single choice can replace them. The example below removes both the item and its selected ID atomically. For async removal, hold state until success and disable controls while pending.

### Appearance and custom content (0.15)

Size/size accepts sm, md or lg. Rounded/rounded accepts sm, md, lg or full. FillMode/fillMode accepts solid or outline. ThemeColor/themeColor accepts base, info, success, warning or error. Invalid values throw; defaults remain md/full/outline/base for compatibility with 0.14. These defaults differ from Telerik. Colors adapt to light/dark themes; this is not a pixel-match claim.

Leading/leading accepts decorative content such as a small icon or avatar. ChildContent/child replaces the visible label. RemoveContent/removeIcon replaces the removal symbol. Always retain a meaningful Label/label: it supplies the accessible name regardless of the visual template. Do not put buttons, links, text fields or other interactive controls inside these templates. The parent owns image loading and image errors; there is no built-in avatar downloader or Telerik SVG icon registry.

OnClick/onClick is independent of selection: it runs after the selection callback on activation, also when selection is disabled. Removal only invokes the remove callback. Disabled chips invoke neither. A missing selection callback keeps selection unchanged, while an available click callback can still run a command. Blazor awaits the selection handler before invoking click; the next boolean is calculated before either callback. Flutter callbacks are synchronous. Do not use click to toggle selection a second time.


### Per-item presentation

ItemTemplate/itemBuilder and LeadingTemplate/leadingBuilder receive NgOption. ItemAppearance/itemAppearance returns NgChipAppearance: its nullable size, rounded, fill mode and theme color override list defaults independently. CanRemove/canRemove hides the remove action for selected items without disabling selection. It defaults to true and still requires the list removal callback. This predicate controls availability; reject a permitted request by leaving parent state unchanged. Functions should be pure, because rendering can evaluate them again.

This is a typed NgOption adapter contract, not Telerik generic model reflection or property-name binding. Map application data to NgOption and resolve additional fields by stable ID in the template. ChipList no longer has a fixed item-count cap; remaining keyboard/listbox differences are tracked in the feature parity matrix.


### Keyboard and focus (0.16)

Left/Right moves to the adjacent enabled interactive chip, reversing direction in RTL. Home/End focuses the first/last available chip. Navigation clamps at the ends and does not change selection. Enter/Space activates selection and click. Delete/Backspace requests removal if allowed; a nonremovable chip keeps focus. Modified shortcuts (Alt/Ctrl/Meta) are left to the application. Repeated deletion keydown is ignored.

After accepted removal of the focused item, focus moves to the next enabled item at the former position, otherwise the nearest previous enabled item. When none remains, the named list container receives focus. A rejected request keeps focus. Delayed data updates do not pull focus back when the user has moved to another control. Stable IDs preserve focus on reorder. Changing a focused item to disabled uses the same fallback. Do not reuse IDs for unrelated records.

Since 0.17, the list has one Tab stop. On first entry, focus goes to the first selected enabled interactive chip, otherwise the first available chip. Arrows change the remembered entry without changing selection. Tab leaves the list; Shift+Tab returns to that entry. If it disappears or becomes disabled, the entry falls back to a selected enabled chip or the first available chip. Empty and fully disabled lists add no Tab stop. Use Delete/Backspace to request removal; removal icons remain available to pointer and assistive-technology actions. Custom templates should contain display content, not extra interactive controls.

Single Tab entry does not imply full listbox semantics: Blazor still exposes a group of pressed buttons, Flutter its native chip semantics. Flutter SDK used for this release lacks listbox/option roles. Those roles, public accessibility hooks and screen-reader validation remain explicit gaps in the parity matrix.

Blazor exposes FocusAsync() on NgChipList via @ref after interactive rendering. It focuses the first available action or the list container. The JS module is initialized automatically and disposed with the component. Flutter owns and disposes internal focus nodes; use the public NgChipListController described below.

Blazor serializes pending remove callbacks. Flutter removal callbacks remain synchronous requests: if the application performs async deletion, it must handle duplicate requests, errors and cancellation, then update items and selected IDs together. Focus restoration tracks that later state update; it does not await network operations. Removing a standalone chip requires the application to move focus explicitly.


### Action labels (0.18)

NgChip.RemoveLabel / removeLabel overrides the complete accessible removal name and Flutter delete tooltip. Null keeps "Remove {label}". Supply a nonblank phrase including the item name, such as "Dismiss Design"; a visual remove icon alone is not an accessible name. Text is escaped, not treated as markup. Obtain translations from your application's localization resources; the library does not select a locale or ship translation dictionaries.


For lists, RemoveLabel (Blazor) / removeLabelBuilder (Flutter) receives each NgOption and supplies that chip's removal phrase. Keep the callback pure. EmptyText / emptyText changes the empty collection message; the default remains "No tags" and blank text is rejected. Label / label still supplies the list name. Changing these strings does not change IDs, selection or removal permissions. Changing the application locale must trigger a normal parent rerender/rebuild. RTL direction is inherited from the surrounding HTML direction or Flutter Directionality; these label hooks do not set direction.

### Focus from application code (0.18)

Blazor: keep an @ref and await FocusAsync() after interactive rendering. It focuses the first enabled action, or the list container when none exists. Calling before initialization is a no-op.

Flutter: create one NgChipListController in the owning State, pass it as focusController, and dispose it in that State's dispose(). Never create a controller inside build or share one between simultaneous lists. A shared or previously disposed controller throws StateError on attachment. Changing focusController detaches the old handle; removing the list detaches it automatically. The list continues to own its internal FocusNodes.

focus() requests the first enabled interactive chip, or the container for an empty/all-disabled list. The Flutter container shows a focus outline when it receives primary focus. focus(itemId: 'web') targets an enabled interactive chip by stable ID. It returns false without moving focus if detached, disposed, not yet laid out, or if the explicit ID is missing/disabled. A true return means a focus request was issued; Flutter applies it on the next frame. isAttached reports attachment, not layout readiness. Call from an event callback or a post-frame callback after mounting. Focus never changes selection or invokes click/removal callbacks. The example intentionally uses English custom labels; substitute application translations as needed.


### Larger collections (0.19)

The Web demo and interaction tests cover 500 tags, including disabled items, selection, Home/End and removal with focus recovery. Data-rule tests additionally cover 5,000 records in Flutter; that is not a rendering or performance guarantee. All chips are rendered eagerly and retain their own focus state. There is no virtualization, lazy fetching or automatic paging. For thousands of visible records, filter the application data or use a data-oriented control and measure on your target device. The limit removal does not imply unlimited practical capacity.

IDs still must be unique and valid, labels must be nonblank and at most 120 UTF-16 code units, and selected IDs must exist in the current items. Update items and value together when filtering/removing records; do not leave selected IDs outside the supplied collection. Selection validation and membership checks use sets rather than rescanning the entire list per selected ID. ButtonGroup retains its 50-option limit and Drawer its 100-item limit.

Flutter scrolls focused chips into ancestor scrollable viewports when keyboard or application focus moves. Put the list inside a bounded scrollable page, as in the gallery. Blazor uses native browser scrolling on focus. Keep templates display-only and prefer short labels. The Load 500 tags example resets selection deliberately; adapt this policy to your application.


## Blazor example

```razor
<NgChipList @ref="topics" Label="Topics" Items="items" @bind-Value="selected"
    Multiple OnRemove="Remove" RemoveLabel="RemoveLabel" EmptyText="No topics available" />
<NgButton OnClick="FocusTopics">Focus topics</NgButton>
<NgButton OnClick="LoadTags">Load 500 tags</NgButton>
@code {
    private NgChipList? topics;
    private void LoadTags() {
        items = Enumerable.Range(1, 500).Select(i => new NgOption($"tag{i}", $"Topic {i}", i % 10 == 0)).ToArray();
        selected = ["tag1"];
    }
    private IReadOnlyList<NgOption> items = [new("design", "Design"), new("web", "Web"), new("locked", "Locked", true)];
    private IReadOnlyList<string> selected = ["design"];
    private string RemoveLabel(NgOption item) => $"Dismiss {item.Label}";
    private async Task FocusTopics() { if (topics is not null) await topics.FocusAsync(); }
    private void Remove(string id) {
        items = items.Where(item => item.Value != id).ToArray();
        selected = selected.Where(value => value != id).ToArray();
    }
}
```

## Flutter example

```dart
final topics = NgChipListController();
List<NgOption> items = const [NgOption('design', 'Design'), NgOption('web', 'Web'), NgOption('locked', 'Locked', disabled: true)];
List<String> selected = ['design'];
@override
void dispose() { topics.dispose(); super.dispose(); }
void loadTags() => setState(() {
  items = List.generate(500, (i) => NgOption('tag${i + 1}', 'Topic ${i + 1}', disabled: (i + 1) % 10 == 0));
  selected = ['tag1'];
});
Widget build(BuildContext context) => SingleChildScrollView(child: Column(children: [
  NgChipList(label: 'Topics', focusController: topics, items: items,
    value: selected, multiple: true, emptyText: 'No topics available',
    removeLabelBuilder: (item) => 'Dismiss ${item.label}',
    onChanged: (v) => setState(() => selected = v),
    onRemove: (id) => setState(() {
      items = items.where((item) => item.value != id).toList();
      selected = selected.where((value) => value != id).toList();
    })),
  NgButton(onPressed: loadTags, child: const Text('Load 500 tags')),
  NgButton(onPressed: () => topics.focus(), child: const Text('Focus topics')),
  NgButton(onPressed: () => topics.focus(itemId: 'web'), child: const Text('Focus Web')),
]));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `EmptyText` | `string` | "No tags" | See the behavior rules and model contract above. |
| `RemoveLabel` | `Func<NgOption,string>?` | not set | Complete nonblank accessible removal name; for ChipList, a callback receiving NgOption. |
| `Label` | `string` | "Tags" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | required | Input collection. Replace it when changing records or configuration. |
| `Value` | `IReadOnlyList<string>` | [] | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<IReadOnlyList<string>>` | not set | New value for the parent to store and pass back. |
| `OnRemove` | `EventCallback<string>` | not set | See the behavior rules and model contract above. |
| `OnClick` | `EventCallback<string>` | not set | Application click handler. |
| `Selectable` | `bool` | true | See the behavior rules and model contract above. |
| `Multiple` | `bool` | false | Allow multiple selected IDs instead of a single choice. |
| `AllowEmpty` | `bool` | true | Allow the user to clear the last selection; does not create an initial value. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Size` | `string` | "md" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "full" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "outline" | Chip fill: solid or outline; see the documented defaults. |
| `ThemeColor` | `string` | "base" | Chip semantic color: base, info, success, warning or error. |
| `ItemAppearance` | `Func<NgOption,NgChipAppearance>?` | not set | Per-item nullable presentation overrides; unspecified values inherit list defaults. |
| `CanRemove` | `Func<NgOption,bool>?` | not set | Pure predicate controlling whether an item offers a remove action. |
| `ItemTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
| `LeadingTemplate` | `RenderFragment<NgOption>?` | not set | Decorative leading content for an item; no nested interactive elements. |
| `RemoveContent` | `RenderFragment?` | not set | Decorative replacement for the remove symbol; accessible action label is retained. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `removeLabelBuilder` | `String Function(NgOption)?` | Pure callback supplying a complete accessible removal name for each NgOption. |
| `focusController` | `NgChipListController?` | Application-owned NgChipListController; one list per controller. See lifecycle and focus rules. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `value` | `List<String>` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<List<String>>?` | Store the new value using setState or your state manager. |
| `onRemove` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `onClick` | `ValueChanged<String>?` | Application click handler. |
| `size` | `String` | See the behavior rules and model contract above. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `themeColor` | `String` | Chip semantic color: base, info, success, warning or error. |
| `itemAppearance` | `NgChipAppearance Function(NgOption)?` | Per-item nullable presentation overrides; unspecified values inherit list defaults. |
| `canRemove` | `bool Function(NgOption)?` | Pure predicate controlling whether an item offers a remove action. |
| `itemBuilder` | `Widget Function(NgOption)?` | See the behavior rules and model contract above. |
| `leadingBuilder` | `Widget Function(NgOption)?` | Decorative leading widget for an item; no nested interactive controls. |
| `removeIcon` | `Widget?` | Replacement widget for the remove symbol; accessible action label is retained. |
| `selectable` | `bool` | See the behavior rules and model contract above. |
| `multiple` | `bool` | Allow multiple selected IDs instead of a single choice. |
| `allowEmpty` | `bool` | Allow the user to clear the last selection; does not create an initial value. |
| `disabled` | `bool` | Disable user interaction. |

```dart
const NgChipList({
    super.key,
    this.label = 'Tags',
    this.emptyText = 'No tags',
    this.removeLabelBuilder,
    this.focusController,
    this.onClick,
    this.size = 'md',
    this.rounded = 'full',
    this.fillMode = 'outline',
    this.themeColor = 'base',
    this.itemAppearance,
    this.canRemove,
    this.itemBuilder,
    this.leadingBuilder,
    this.removeIcon,
    required this.items,
    this.value = const [],
    this.onChanged,
    this.onRemove,
    this.selectable = true,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgChipList.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/chips.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
