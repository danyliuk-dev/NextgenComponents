# NgButtonGroup — Single and multiple choice buttons

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Present a small set of related settings as visible buttons. Use single selection for alignment or a view mode, and multiple selection for independent styles or filters.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgButtonGroup) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgButtonGroup)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules


### Mix choices with commands

Items/items contains NgOption records with stable IDs. IsCommand/isCommand is an optional predicate: false means toggle (the default), true means ordinary command. Commands invoke OnClick/onClick with their ID and never enter Value/value. Passing a command ID as selected throws, including when the command is hidden. If an item changes type at runtime, normalize selected IDs in the same parent update. Predicates and builders should be pure.

OnClick/onClick receives activations of both kinds. A toggle first requests a changed selection, then invokes click; a command invokes only click. A no-op selection, such as rejecting the last deselection with AllowEmpty=false, still produces click. Blazor awaits ValueChanged before OnClick; Flutter callbacks run synchronously. The group never performs command side effects. In the example, the parent handles Clear formatting by clearing its own value.

Toggles need either ValueChanged/onChanged or OnClick/onClick to be interactive. Click-only toggles retain controlled state. Commands need OnClick/onClick. Disabled/disabled and NgOption.disabled suppress both actions. Async work, busy-state locking and error reporting belong to the application.

### Selection, validation and visibility

Value/value is a list of selected toggle IDs even in single mode. Multiple/multiple=false accepts at most one selected ID; true toggles independently. AllowEmpty/allowEmpty=true permits removing the last selection; false prevents that user action but does not invent an initial value or reject an application-supplied empty list. Selection callbacks return new lists in item order; the input is not mutated.

Use at most 50 records, unique IDs of 1–64 ASCII letters/digits/underscores/hyphens and nonblank labels up to 120 UTF-16 code units. Selected IDs must be unique and present in Items/items. Removing records or switching to single mode requires normalizing the value in the same update. Disabled selected items remain valid.

IsVisible/isVisible=false hides a record from rendering, focus and accessibility without removing it from Items or Value. Hidden selections still participate in selection rules; selecting another toggle in single mode replaces a hidden selection. When all items are hidden, the empty message is No options even if the parent retains hidden selection. Restore visibility to show the selected state again. The application owns focus recovery when hiding the focused button.

### Content, naming and layout

ItemTemplate/itemBuilder replaces visible item content; LeadingTemplate/leadingBuilder supplies a decorative icon/avatar. Both use NgOption and must remain display-only. The accessible item name remains its label, even if the template uses abbreviated text. Command buttons have no pressed/checked state. Toggle buttons keep the existing selected semantics on each platform.

Label/label names the group. Blazor offers Id/Class, AriaLabelledBy and AriaDescribedBy; Flutter offers semanticIdentifier/semanticHint. Horizontal groups wrap; Vertical/vertical stacks. Control width through the containing CSS/widget layout. Tab/Shift+Tab visit enabled visible actions and Enter/Space activates them; arrows are not managed as a composite widget. The data-driven NgOption model differs from Telerik's declarative child-button API. Routes, native form submission/reset button types and content panels are not implemented by this group.


### Shared appearance and per-item overrides

Size/size accepts sm, md, lg. Rounded/rounded accepts sm, md, lg, full. FillMode/fillMode accepts solid, outline, flat, link, clear. ThemeColor/themeColor accepts base, primary, secondary, tertiary, info, success, warning, error, dark, light, inverse. Invalid tokens throw. Defaults are md/md/outline/primary, preserving Nextgen's selection emphasis rather than copying Telerik defaults. Colors adapt to the active theme; dark/light are readable theme tokens, not fixed black/white swatches. Exact theme pixels and ThemeBuilder compatibility are not claimed.

Solid fills the button, outline outlines it, flat omits the resting border/background, link adds underlined text, and clear uses neutral text. Selected toggles retain a distinct filled state in every mode; Flutter also shows a check mark so custom bold content cannot hide selection, while Blazor adds an inset selected outline. Hover and focus remain separate from selection. Disabled styles indicate non-interactivity. A link fill is visual styling and does not turn a button into a navigation link.

ButtonGroup applies these settings to every item. ItemAppearance/itemAppearance may return NgButtonAppearance with nullable fields; null fields inherit group values. Use this for a command's accent without changing other items. Tokens apply to commands and toggles equally. The Formatting commands and choices demo combines all appearance controls, per-item accents, icons, mixed actions, hidden selection, disabled controls and vertical layout.


## Blazor example

```razor
<NgCheckBox Label="Hide Emphasis" @bind-Value="hideEmphasis" />
<NgButtonGroup Label="Formatting actions" Items="actions" Value="selected" ValueChanged="Change" Multiple
    IsCommand="IsCommand" IsVisible="ShowItem" OnClick="Activate"
    Size="md" Rounded="lg" FillMode="outline" ItemAppearance="Appearance">
  <LeadingTemplate><span>★</span></LeadingTemplate>
  <ItemTemplate Context="item"><strong>@item.Label</strong></ItemTemplate>
</NgButtonGroup>
<p>Selected: @string.Join(",",selected). @log</p>
@code {
    private bool hideEmphasis;
    private IReadOnlyList<string> selected = ["strong"];
    private string log = "Ready";
    private readonly NgOption[] actions = [new("strong","Strong"),new("emphasis","Emphasis"),new("clear","Clear formatting")];
    private static bool IsCommand(NgOption item) => item.Value=="clear";
    private bool ShowItem(NgOption item) => !hideEmphasis || item.Value!="emphasis";
    private static NgButtonAppearance Appearance(NgOption item) => new(ThemeColor:IsCommand(item)?"info":null);
    private void Change(IReadOnlyList<string> value) { selected=value; log="changed:"+string.Join(",",value); }
    private void Activate(string id) { log+=" | clicked:"+id; if(id=="clear")selected=[]; }
}

```

## Flutter example

```dart
bool hideEmphasis = false;
List<String> selected = ['strong'];
String log = 'Ready';
final actions = const [NgOption('strong','Strong'),NgOption('emphasis','Emphasis'),NgOption('clear','Clear formatting')];
Widget build(BuildContext context) => Column(children: [
  NgCheckBox(label: 'Hide Emphasis', value: hideEmphasis, onChanged: (v) => setState(() => hideEmphasis=v)),
  NgButtonGroup(label: 'Formatting actions', items: actions, value: selected, multiple: true,
    isCommand: (item) => item.value=='clear', isVisible: (item) => !hideEmphasis || item.value!='emphasis',
    onChanged: (v) => setState(() { selected=v; log='changed:${v.join(",")}'; }),
    onClick: (id) => setState(() { log+=' | clicked:$id'; if(id=='clear')selected=[]; }),
    size: 'md', rounded: 'lg', fillMode: 'outline',
    itemAppearance: (item) => NgButtonAppearance(themeColor: item.value=='clear'?'info':null),
    leadingBuilder: (_) => const Icon(Icons.star, size:16), itemBuilder: (item) => Text(item.label)),
  Text('Selected: ${selected.join(",")}. $log'),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string?` | not set | See the behavior rules and model contract above. |
| `Class` | `string?` | not set | See the behavior rules and model contract above. |
| `AriaLabelledBy` | `string?` | not set | Space-separated existing DOM IDs for the accessible name; takes precedence over Label. |
| `AriaDescribedBy` | `string?` | not set | Space-separated existing DOM IDs for contextual guidance; see target-element rules. |
| `Size` | `string` | "md" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "md" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "outline" | Chip fill: solid or outline; see the documented defaults. |
| `ThemeColor` | `string` | "primary" | Chip semantic color: base, info, success, warning or error. |
| `ItemAppearance` | `Func<NgOption,NgButtonAppearance>?` | not set | Per-item nullable presentation overrides; unspecified values inherit list defaults. |
| `IsVisible` | `Func<NgOption,bool>?` | not set | See the behavior rules and model contract above. |
| `ItemTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
| `LeadingTemplate` | `RenderFragment<NgOption>?` | not set | Decorative leading content for an item; no nested interactive elements. |
| `Label` | `string` | "Options" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | required | Input collection. Replace it when changing records or configuration. |
| `Value` | `IReadOnlyList<string>` | [] | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<IReadOnlyList<string>>` | not set | New value for the parent to store and pass back. |
| `IsCommand` | `Func<NgOption,bool>?` | not set | See the behavior rules and model contract above. |
| `OnClick` | `EventCallback<string>` | not set | Application click handler. |
| `Multiple` | `bool` | false | Allow multiple selected IDs instead of a single choice. |
| `AllowEmpty` | `bool` | true | Allow the user to clear the last selection; does not create an initial value. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Vertical` | `bool` | false | Use a vertical root layout; see the component keyboard and layout rules. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `value` | `List<String>` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<List<String>>?` | Store the new value using setState or your state manager. |
| `onClick` | `ValueChanged<String>?` | Application click handler. |
| `isCommand` | `bool Function(NgOption)?` | See the behavior rules and model contract above. |
| `multiple` | `bool` | Allow multiple selected IDs instead of a single choice. |
| `allowEmpty` | `bool` | Allow the user to clear the last selection; does not create an initial value. |
| `disabled` | `bool` | Disable user interaction. |
| `vertical` | `bool` | Use a vertical root layout; see the component keyboard and layout rules. |
| `size` | `String` | See the behavior rules and model contract above. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `themeColor` | `String` | Chip semantic color: base, info, success, warning or error. |
| `semanticIdentifier` | `String?` | Optional nonblank automation identifier in the Flutter semantics tree; not a widget Key or DOM id. |
| `semanticHint` | `String?` | Optional nonblank contextual guidance in the semantics tree; not a visible tooltip. |
| `itemAppearance` | `NgButtonAppearance Function(NgOption)?` | Per-item nullable presentation overrides; unspecified values inherit list defaults. |
| `isVisible` | `bool Function(NgOption)?` | See the behavior rules and model contract above. |
| `itemBuilder` | `Widget Function(NgOption)?` | See the behavior rules and model contract above. |
| `leadingBuilder` | `Widget Function(NgOption)?` | Decorative leading widget for an item; no nested interactive controls. |

```dart
const NgButtonGroup({
    super.key,
    this.label = 'Options',
    this.size = 'md',
    this.rounded = 'md',
    this.fillMode = 'outline',
    this.themeColor = 'primary',
    this.semanticIdentifier,
    this.semanticHint,
    this.itemAppearance,
    this.isVisible,
    this.itemBuilder,
    this.leadingBuilder,
    required this.items,
    this.value = const [],
    this.onClick,
    this.isCommand,
    this.onChanged,
    this.multiple = false,
    this.allowEmpty = true,
    this.disabled = false,
    this.vertical = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgButtonGroup.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/selection.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
