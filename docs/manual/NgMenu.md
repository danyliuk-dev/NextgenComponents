# NgMenu — Command menu

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Group related application commands in a horizontal toolbar or a vertical navigation area. Open nested groups to choose a leaf action.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgMenu) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgMenu)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Commands and data

The parent owns SelectedId/selectedId and dispatches enabled leaf IDs from OnInvoke/onInvoke. Opening a group is not a command. A missing handler disables leaf buttons. Models copy their child collections; replace records to change Visible/visible, Disabled/disabled or Separator/separator. Hidden ancestors suppress their entire subtree. Separators have a unique ID and nonempty descriptive Text/text, never invoke, and cannot have children. Validation includes hidden items: at most 100 unique IDs, three levels, IDs of 1–64 ASCII letters/digits/underscore/hyphen and labels of 1–120 characters.

### Appearance and accessible templates

ItemTemplate/itemBuilder replaces display content; LeadingTemplate/leadingBuilder supplies a decorative icon or image. Text/text remains the accessible name and leading content is excluded from that name. Templates must contain display content only: no buttons, links, inputs or focusable descendants. Automatic URL routing is not provided; handle the leaf callback in the application.

### Opening, closing and direction

CloseOnClick/closeOnClick defaults to true. Set false to keep a menu open after choosing an enabled leaf (for repeated commands). Escape, outside clicks and focus traversal still dismiss. Blazor opens on click or keyboard; Flutter uses Material submenu behavior, including pointer hover. Rtl/rtl reverses horizontal keyboard direction and submenu direction; vertical menus retain Up/Down navigation. Blazor provides one root Tab stop and Home/End; Flutter delegates keyboard handling to Material menus. Removing a focused item is an application-level focus concern. Popup animation, hover delay configuration, arbitrary-model field mapping and full screen-reader certification remain outside this implementation.

## Blazor example

```razor
<NgCheckBox Label="Keep menu open" @bind-Value="keepOpen"/>
<NgCheckBox Label="Right-to-left" @bind-Value="rtl"/>
<NgMenu Label="Document commands" Items="commands" SelectedId="@selected"
        OnInvoke="Run" Rtl="rtl" CloseOnClick="@(!keepOpen)">
  <LeadingTemplate Context="item"><span>◆</span></LeadingTemplate>
  <ItemTemplate Context="item"><strong>@item.Text</strong></ItemTemplate>
</NgMenu>
<p>Last command: @selected · Invocations: @count</p>
@code {
  private bool keepOpen, rtl;
  private string selected="none"; private int count;
  private readonly NgMenuItem[] commands=[
    new("file","File",children:[new("new","New document"),
      new("exports","Export formats",separator:true),
      new("export","Export",children:[new("pdf","PDF"),new("csv","CSV")]),
      new("secret","Internal command",visible:false),new("delete","Delete",disabled:true)]),
    new("help","Help")];
  private void Run(string id){selected=id;count++;}
}

```

## Flutter example

```dart
bool keepOpen = false, rtl = false; String selected = 'none'; int count = 0;
final commands = [NgMenuItem('file','File',children:[
  NgMenuItem('new','New document'),NgMenuItem('exports','Export formats',separator:true),
  NgMenuItem('export','Export',children:[NgMenuItem('pdf','PDF'),NgMenuItem('csv','CSV')]),
  NgMenuItem('secret','Internal command',visible:false),NgMenuItem('delete','Delete',disabled:true)]),
  NgMenuItem('help','Help')];
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
  NgCheckBox(label:'Keep menu open',value:keepOpen,onChanged:(v)=>setState(()=>keepOpen=v)),
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  NgMenu(label:'Document commands',items:commands,selectedId:selected,rtl:rtl,closeOnClick:!keepOpen,
    leadingBuilder:(_,item)=>const Icon(Icons.description_outlined,size:18),
    itemBuilder:(_,item)=>Text(item.text,style:const TextStyle(fontWeight:FontWeight.bold)),
    onInvoke:(id)=>setState((){selected=id;count++;})),
  Text('Last command: $selected · Invocations: $count'),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Commands" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgMenuItem>` | required | Input collection. Replace it when changing records or configuration. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `OnInvoke` | `EventCallback<string>` | not set | Enabled leaf command ID; dispatch the application action in this handler. |
| `Vertical` | `bool` | false | Use a vertical root layout; see the component keyboard and layout rules. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Rtl` | `bool` | false | See the behavior rules and model contract above. |
| `CloseOnClick` | `bool` | true | See the behavior rules and model contract above. |
| `ItemTemplate` | `RenderFragment<NgMenuItem>?` | not set | See the behavior rules and model contract above. |
| `LeadingTemplate` | `RenderFragment<NgMenuItem>?` | not set | Decorative leading content for an item; no nested interactive elements. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgMenuItem>` | Input collection. Replace it when changing records or configuration. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `onInvoke` | `ValueChanged<String>?` | Enabled leaf command ID; dispatch the application action in this handler. |
| `vertical` | `bool` | Use a vertical root layout; see the component keyboard and layout rules. |
| `disabled` | `bool` | Disable user interaction. |
| `rtl` | `bool` | See the behavior rules and model contract above. |
| `closeOnClick` | `bool` | See the behavior rules and model contract above. |
| `itemBuilder` | `Widget Function(BuildContext, NgMenuItem)?` | See the behavior rules and model contract above. |
| `leadingBuilder` | `Widget Function(BuildContext, NgMenuItem)?` | Decorative leading widget for an item; no nested interactive controls. |

```dart
const NgMenu({
    super.key,
    this.label = 'Commands',
    required this.items,
    this.selectedId,
    this.onInvoke,
    this.vertical = false,
    this.disabled = false,
    this.rtl = false,
    this.closeOnClick = true,
    this.itemBuilder,
    this.leadingBuilder,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgMenu.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/navigation.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
