# NgChip — Compact selectable or removable tag

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Show a short status, toggle a tag, or offer an explicit remove action.

## Behavior and practical rules

### State and events

The parent owns Value/value and stores selection callbacks. Selectable/selectable defaults to true. Disable it for a display-only label. OnRemove/onRemove is optional: providing it shows a separate, named remove action. Removal never changes selection or data automatically. Reject a request by leaving state unchanged; accept it by removing the ID from both items and selected values in one update. Removal does not fire the selection callback. Keep durable state in the parent.

### Keyboard and accessibility

Selection and removal have separate accessible actions. Tab moves through enabled actions; Enter or Space activates the focused action. Selected state is exposed to assistive technology. Disabled chips cannot be selected or removed. Delete or Backspace requests removal from a focused interactive chip. Holding the key does not repeatedly remove chips. ChipList adds Left/Right and Home/End navigation with focus recovery after removal; see the keyboard rules below. Test screen-reader behavior in your target browser.

### Scope

Labels must be nonblank and at most 120 UTF-16 code units. Labels render as text, never HTML. Light/dark styling and wrapping are supported. Icons and avatars can be supplied as leading content, and custom labels and remove icons are supported. Drag sorting, editable tags and virtualization are not established Telerik Chip/ChipList requirements and remain possible extensions, not parity claims. Web is the verified target; mobile verification is a separate phase.

A missing selection callback prevents selection. Removal remains independently available when supplied. For a static status, set Selectable/selectable to false. Removing a standalone chip means the parent stops rendering it.

### Appearance and custom content (0.15)

Size/size accepts sm, md or lg. Rounded/rounded accepts sm, md, lg or full. FillMode/fillMode accepts solid or outline. ThemeColor/themeColor accepts base, info, success, warning or error. Invalid values throw; defaults remain md/full/outline/base for compatibility with 0.14. These defaults differ from Telerik. Colors adapt to light/dark themes; this is not a pixel-match claim.

Leading/leading accepts decorative content such as a small icon or avatar. ChildContent/child replaces the visible label. RemoveContent/removeIcon replaces the removal symbol. Always retain a meaningful Label/label: it supplies the accessible name regardless of the visual template. Do not put buttons, links, text fields or other interactive controls inside these templates. The parent owns image loading and image errors; there is no built-in avatar downloader or Telerik SVG icon registry.

OnClick/onClick is independent of selection: it runs after the selection callback on activation, also when selection is disabled. Removal only invokes the remove callback. Disabled chips invoke neither. A missing selection callback keeps selection unchanged, while an available click callback can still run a command. Blazor awaits the selection handler before invoking click; the next boolean is calculated before either callback. Flutter callbacks are synchronous. Do not use click to toggle selection a second time.


### Action labels (0.18)

NgChip.RemoveLabel / removeLabel overrides the complete accessible removal name and Flutter delete tooltip. Null keeps "Remove {label}". Supply a nonblank phrase including the item name, such as "Dismiss Design"; a visual remove icon alone is not an accessible name. Text is escaped, not treated as markup. Obtain translations from your application's localization resources; the library does not select a locale or ship translation dictionaries.


### Right-to-left layout (0.21)

Blazor inherits the nearest HTML dir attribute. Wrap a component or a group in a div with dir="rtl" (or dir="ltr"). Flutter inherits Directionality: wrap a component or group with Directionality(textDirection: TextDirection.rtl, child: ...). Keep the direction wrapper outside NgChipList so layout and keyboard handling read the same direction. No data reversal is required. Mixed LTR/RTL regions may coexist; omit the wrapper to inherit the application setting.

Chips start at the reading edge and wrap in source order. Leading content appears at the reading start, removal at the reading end, and the Blazor separator follows that edge. Changing direction at runtime preserves stable IDs, selection and the remembered keyboard entry. In RTL, Left moves to the next enabled record and Right to the previous; Home/End still target the first/last enabled record in data order. Removal keeps the existing next/previous focus policy, including wrapped rows. Up/Down spatial navigation is not provided.

Direction changes layout; it does not translate labels or reverse application strings. Supply translated labels and RemoveLabel/removeLabel (or the list callback) and EmptyText/emptyText yourself. Use bdi/dir on a Blazor template or a nested Directionality/Text.textDirection in Flutter to isolate mixed-direction identifiers when appropriate. Directional custom icons are application-owned; they are not automatically mirrored. Keep templates noninteractive.

The English Reading direction demo includes a constrained wrapping region, decorative leading stars, a disabled record, a static status chip and a runtime direction switch. The rest of the demo remains LTR. Verification covers Chip/ChipList layout and keyboard behavior on Web, not every component or screen-reader pronunciation.


### Identity, accessible names and contextual help (0.22)

Blazor Id identifies the outer component element, and Class appends application CSS classes while preserving built-in classes. Neither creates a focus target or changes keyboard behavior. Supply unique IDs per rendered instance; Id must be nonblank and contain no whitespace. Classes can affect layout and contrast, so review custom styles in both themes.

AriaLabelledBy accepts one or more space-separated IDs of existing elements. Browser accessible-name computation gives these references priority over Label. Keep Label meaningful as the visible text/fallback, and ensure every referenced element exists. AriaDescribedBy accepts a similar list for contextual instructions. On ChipList, naming and description apply to the group; they are not duplicated on every item. On a standalone Chip, references apply to its label element/action, and the description also applies to removal. The remove action retains its own RemoveLabel; it never borrows the selection action's name. Static text chips remain noninteractive; when a Blazor static chip has naming/description references, its label becomes a named group without a Tab stop so the references have a semantic target. Null omits a hook; blank reference lists are rejected. The library cannot validate DOM existence or global ID uniqueness during server rendering.

Flutter semanticIdentifier identifies a semantics node for automation; it is not a widget Key, HTML id, user-facing label or selection ID. semanticHint provides contextual guidance in that node's semantics. Both are optional nonblank strings. On Web, the installed Flutter engine exports identifiers as flt-semantics-identifier attributes when semantics are enabled; this is an engine detail, not a CSS styling API. Metadata is additive: it must not replace the child selection/removal actions.

Flutter has no DOM Class or aria-labelledby relationship in this API. Use the existing theme/appearance parameters for styling. For a shared heading, keep one application string and pass it to Text and the list's label; update both together. Use semanticHint for concise guidance and show the same text visibly when it helps users. A hint is not an exact aria-describedby equivalent; assistive-technology announcement varies by platform. Application code owns translations. Do not include secrets or personal data in automation identifiers.

The examples wire contextual help to the list and a standalone command. The Business records demo can update its heading and guidance at runtime while retaining selection and identity. Browser accessibility-tree inspection and widget tests verify the exported information and actions; screen-reader testing/certification remains separate. TabIndex supports -1 and 0 since 0.23; listbox/option roles remain open.


### Participation in Tab navigation (0.23)

TabIndex/tabIndex defaults to 0. Set -1 to skip the component during forward and reverse Tab traversal. Only -1 and 0 are accepted; positive indices and other negative values throw. This deliberately limited cross-platform contract does not reproduce every integer value of Telerik Chip.TabIndex. Use the application's layout/traversal policy to establish logical order instead of positive indices.

For a standalone Chip, the setting applies to both its main action and removal action. Static labels and disabled actions never acquire a Tab stop. For ChipList, 0 retains one remembered enabled entry; -1 excludes the entire collection from Tab traversal. The list container remains a programmatic fallback, not an additional Tab stop. Individual items inside a list do not expose independent traversal indices.

Exclusion does not disable the control: mouse/touch, accessibility activation, application focus, arrow navigation and removal continue to work. A focused item is not blurred when the setting changes. FocusAsync()/NgChipListController.focus() can still enter a skipped list, and Tab then leaves it. Returning the setting to 0 restores its remembered enabled entry. Selection and collection state remain parent-owned. Provide another accessible way to enter a list when excluding it; the demo includes a Focus directional topics button.


## Blazor example

```razor
<p id="build-help">Opens the build activity summary.</p>
<NgChip TabIndex="0" Id="build-status" Class="build-status" AriaDescribedBy="build-help" Label="Build succeeded" Selectable="false" ThemeColor="success" FillMode="solid" Size="lg" Rounded="md" OnClick="()=>clicks++">
    <Leading><span>✓</span></Leading>
    <ChildContent><strong>Build succeeded</strong></ChildContent>
</NgChip>
@if (visible) {
    <NgChip Label="Favourite" @bind-Value="selected" OnRemove="()=>visible=false">
        <RemoveContent>−</RemoveContent>
    </NgChip>
}
<p>Activity opened @clicks times</p>
@code {
    private bool selected, visible = true;
    private int clicks;
}
```

## Flutter example

```dart
bool selected = false, visible = true;
int clicks = 0;
Widget build(BuildContext context) => Wrap(spacing: 8, children: [
  NgChip(tabIndex: 0, semanticIdentifier: 'build-status', semanticHint: 'Opens the build activity summary.', label: 'Build succeeded', selectable: false, themeColor: 'success',
    fillMode: 'solid', size: 'lg', rounded: 'md', leading: const Icon(Icons.check, size: 18),
    child: const Text('Build succeeded'), onClick: () => setState(() => clicks++)),
  if (visible) NgChip(label: 'Favourite', value: selected,
    onChanged: (v) => setState(() => selected = v),
    removeIcon: const Icon(Icons.remove, size: 18),
    onRemove: () => setState(() => visible = false)),
  Text('Activity opened $clicks times'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `TabIndex` | `int` | 0 | 0 keeps normal Tab participation; -1 skips forward/reverse Tab while preserving pointer/application focus. Other values are rejected. |
| `Id` | `string?` | not set | See the behavior rules and model contract above. |
| `Class` | `string?` | not set | See the behavior rules and model contract above. |
| `AriaLabelledBy` | `string?` | not set | Space-separated existing DOM IDs for the accessible name; takes precedence over Label. |
| `AriaDescribedBy` | `string?` | not set | Space-separated existing DOM IDs for contextual guidance; see target-element rules. |
| `Label` | `string` | required | Visible label or accessible name. |
| `RemoveLabel` | `string?` | not set | Complete nonblank accessible removal name; for ChipList, a callback receiving NgOption. |
| `Value` | `bool` | false | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<bool>` | not set | New value for the parent to store and pass back. |
| `Selectable` | `bool` | true | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `OnRemove` | `EventCallback` | not set | See the behavior rules and model contract above. |
| `OnClick` | `EventCallback` | not set | Application click handler. |
| `Size` | `string` | "md" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "full" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "outline" | Chip fill: solid or outline; see the documented defaults. |
| `ThemeColor` | `string` | "base" | Chip semantic color: base, info, success, warning or error. |
| `Leading` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `RemoveContent` | `RenderFragment?` | not set | Decorative replacement for the remove symbol; accessible action label is retained. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `semanticIdentifier` | `String?` | Optional nonblank automation identifier in the Flutter semantics tree; not a widget Key or DOM id. |
| `semanticHint` | `String?` | Optional nonblank contextual guidance in the semantics tree; not a visible tooltip. |
| `tabIndex` | `int` | 0 keeps normal Tab participation; -1 skips forward/reverse Tab while preserving pointer/application focus. Other values are rejected. |
| `removeLabel` | `String?` | Complete nonblank accessible removal name; for ChipList, a callback receiving NgOption. |
| `value` | `bool` | Current value; see state ownership and model rules above. |
| `selectable` | `bool` | See the behavior rules and model contract above. |
| `disabled` | `bool` | Disable user interaction. |
| `onChanged` | `ValueChanged<bool>?` | Store the new value using setState or your state manager. |
| `onRemove` | `VoidCallback?` | See the behavior rules and model contract above. |
| `onClick` | `VoidCallback?` | Application click handler. |
| `size` | `String` | See the behavior rules and model contract above. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `themeColor` | `String` | Chip semantic color: base, info, success, warning or error. |
| `leading` | `Widget?` | See the behavior rules and model contract above. |
| `child` | `Widget?` | See the behavior rules and model contract above. |
| `removeIcon` | `Widget?` | Replacement widget for the remove symbol; accessible action label is retained. |

```dart
const NgChip({
    super.key,
    required this.label,
    this.tabIndex = 0,
    this.semanticIdentifier,
    this.semanticHint,
    this.removeLabel,
    this.value = false,
    this.selectable = true,
    this.disabled = false,
    this.onChanged,
    this.onRemove,
    this.onClick,
    this.size = 'md',
    this.rounded = 'full',
    this.fillMode = 'outline',
    this.themeColor = 'base',
    this.leading,
    this.child,
    this.removeIcon,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgChip.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/chips.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
