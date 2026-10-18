# NgDrawer — Navigation drawer

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Let users switch between application sections while keeping workspace content and navigation state in the parent. Choose a modal overlay or a panel beside the content.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDrawer) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDrawer)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### State and selection

Expanded/expanded and SelectedId/selectedId belong to the parent. Store callback values and pass them back. An expanded Overlay requires ExpandedChanged/onExpandedChanged so it can be dismissed. CloseOnSelect/closeOnSelect defaults to true: an enabled selection requests the selected ID, then requests collapse in Overlay mode. False keeps the drawer open. Push mode stays expanded after selection. A missing selection callback disables destination buttons. Disabled/disabled blocks the toggle and destination selection but leaves an already-open drawer dismissible through Close, Escape and the backdrop.

### Layout and direction

Overlay/overlay defaults to true. Position/position accepts `start` (default) or `end`, relative to Rtl/rtl (default false): end is right in LTR and left in RTL. Push panels stack above content below 600 px; the position setting applies to wide side-by-side layouts and overlays. Width/width is 200–400 pixels (default 260); overlays clamp to the viewport. The Flutter push panel is 420 pixels tall with a scrolling destination list. Mini mode and swipe gestures are not implemented.

### Templates and data

HeaderTemplate/header replaces the title content while keeping the Close control. FooterTemplate/footer adds content below the list. ItemTemplate/itemBuilder and LeadingTemplate/leadingBuilder customize destination text and decorative icons. Item labels remain accessible names. Item and leading templates must be display-only, without nested interactive controls; keep durable state in the parent, not in templates. Header and footer should be compact so the destination list remains usable.

IsVisible/isVisible filters destinations without deleting the selected ID. IsSeparator/isSeparator renders a divider instead of a destination; it never selects. These predicates must be pure. Replace Items/items when data changes. Up to 100 unique NgOption IDs (1–64 ASCII letters/digits/underscore/hyphen) and nonempty labels (up to 120 characters) are supported, including hidden/separator entries. The application owns routing and permissions. An unknown, hidden or separator SelectedId has no visible selected destination. Full template replacement, arbitrary data-model mapping, automatic URL routing and screen-reader certification remain unimplemented.

## Blazor example

```razor
<NgCheckBox Label="Keep drawer open" @bind-Value="keepOpen"/>
<NgCheckBox Label="Right-to-left" @bind-Value="rtl"/>
<NgDrawer Label="Workspace navigation" Items="items" @bind-SelectedId="selected"
          @bind-Expanded="expanded" Position="end" Rtl="rtl" CloseOnSelect="@(!keepOpen)"
          IsVisible="ShowItem" IsSeparator="IsDivider">
  <HeaderTemplate><strong>Project workspace</strong></HeaderTemplate>
  <FooterTemplate><small>Signed in as Morgan</small></FooterTemplate>
  <LeadingTemplate Context="item"><span>◆</span></LeadingTemplate>
  <ItemTemplate Context="item"><strong>@item.Label</strong></ItemTemplate>
  <ChildContent><p>Current section: @selected</p><NgTextBox Label="Draft note" @bind-Value="note"/></ChildContent>
</NgDrawer>
@code {
  private bool expanded,keepOpen,rtl; private string? selected="overview",note;
  private readonly NgOption[] items=[new("overview","Overview"),new("divider","Workspace sections"),
    new("reports","Reports"),new("hidden","Internal"),new("locked","Unavailable",true)];
  private bool ShowItem(NgOption item)=>item.Value!="hidden";
  private bool IsDivider(NgOption item)=>item.Value=="divider";
}

```

## Flutter example

```dart
bool expanded = false, keepOpen = false, rtl = false; String? selected = 'overview';
final note = TextEditingController();
final items = const [NgOption('overview','Overview'),NgOption('divider','Workspace sections'),
  NgOption('reports','Reports'),NgOption('hidden','Internal'),NgOption('locked','Unavailable',disabled:true)];
@override void dispose(){note.dispose();super.dispose();}
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Keep drawer open',value:keepOpen,onChanged:(v)=>setState(()=>keepOpen=v)),
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  NgDrawer(label:'Workspace navigation',items:items,selectedId:selected,
    onSelectedIdChanged:(id)=>setState(()=>selected=id),expanded:expanded,
    onExpandedChanged:(v)=>setState(()=>expanded=v),position:'end',rtl:rtl,closeOnSelect:!keepOpen,
    isVisible:(item)=>item.value!='hidden',isSeparator:(item)=>item.value=='divider',
    header:const Text('Project workspace'),footer:const Text('Signed in as Morgan'),
    leadingBuilder:(_,item)=>const Icon(Icons.folder_outlined,size:18),
    itemBuilder:(_,item)=>Text(item.label,style:const TextStyle(fontWeight:FontWeight.bold)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text('Current section: $selected'),NgTextBox(label:'Draft note',controller:note)])),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Navigation" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | required | Input collection. Replace it when changing records or configuration. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string>` | not set | Selected item ID for the parent to store. |
| `Expanded` | `bool` | false | Whether the drawer is open; controlled by the parent. |
| `ExpandedChanged` | `EventCallback<bool>` | not set | Requested open state; store it in the parent. |
| `Overlay` | `bool` | true | Use a modal overlay instead of a Push panel. |
| `Width` | `int` | 260 | See the behavior rules and model contract above. |
| `Rtl` | `bool` | false | See the behavior rules and model contract above. |
| `Position` | `string` | "start" | See the behavior rules and model contract above. |
| `CloseOnSelect` | `bool` | true | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `IsVisible` | `Func<NgOption,bool>?` | not set | See the behavior rules and model contract above. |
| `IsSeparator` | `Func<NgOption,bool>?` | not set | See the behavior rules and model contract above. |
| `ItemTemplate` | `RenderFragment<NgOption>?` | not set | See the behavior rules and model contract above. |
| `LeadingTemplate` | `RenderFragment<NgOption>?` | not set | Decorative leading content for an item; no nested interactive elements. |
| `HeaderTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `FooterTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `onSelectedIdChanged` | `ValueChanged<String>?` | Selected item ID for the parent to store. |
| `expanded` | `bool` | Whether the drawer is open; controlled by the parent. |
| `overlay` | `bool` | Use a modal overlay instead of a Push panel. |
| `rtl` | `bool` | See the behavior rules and model contract above. |
| `disabled` | `bool` | Disable user interaction. |
| `closeOnSelect` | `bool` | See the behavior rules and model contract above. |
| `position` | `String` | See the behavior rules and model contract above. |
| `isVisible` | `bool Function(NgOption)?` | See the behavior rules and model contract above. |
| `isSeparator` | `bool Function(NgOption)?` | See the behavior rules and model contract above. |
| `itemBuilder` | `Widget Function(BuildContext, NgOption)?` | See the behavior rules and model contract above. |
| `leadingBuilder` | `Widget Function(BuildContext, NgOption)?` | Decorative leading widget for an item; no nested interactive controls. |
| `header` | `Widget?` | See the behavior rules and model contract above. |
| `footer` | `Widget?` | See the behavior rules and model contract above. |
| `onExpandedChanged` | `ValueChanged<bool>?` | Requested open state; store it with setState or your state manager. |
| `width` | `int` | See the behavior rules and model contract above. |
| `child` | `Widget` | See the behavior rules and model contract above. |

```dart
const NgDrawer({
    super.key,
    this.label = 'Navigation',
    required this.items,
    this.selectedId,
    this.onSelectedIdChanged,
    this.expanded = false,
    this.onExpandedChanged,
    this.overlay = true,
    this.rtl = false,
    this.disabled = false,
    this.closeOnSelect = true,
    this.position = 'start',
    this.isVisible,
    this.isSeparator,
    this.itemBuilder,
    this.leadingBuilder,
    this.header,
    this.footer,
    this.width = 260,
    required this.child,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDrawer.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/navigation.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
