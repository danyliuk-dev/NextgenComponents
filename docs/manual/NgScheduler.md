# NgScheduler — Day and week scheduler

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Browse daily or weekly agendas with controlled navigation and guarded edit requests.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgScheduler) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgScheduler)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Date/date and View/view are controlled; accept DateChanged/onDateChanged and ViewChanged/onViewChanged to apply proposals. Week is the default, Day shows one agenda. Previous/Next move by seven or one calendar days; Today proposes local midnight. A rejected proposal keeps the current display. FirstDayOfWeek/firstDayOfWeek uses ISO 1–7 (Monday–Sunday), default 1, and only changes weekly alignment. All displayed days must fall in years 2–9998; invalid configuration is rejected and navigation across the boundary is disabled. ReadOnly/readOnly disables create/edit; NavigationReadOnly/navigationReadOnly independently disables date/view actions. Programmatic date/view updates still work. Missing callbacks disable the related actions. Stale callbacks after date/view changes, editing locks, event removal/change or disposal cannot edit old data. NgScheduleEvent requires a unique nonblank ID, nonblank title and End > Start. Events intersect days using [Start, End), so an event ending at midnight is excluded from the next day; overnight events appear on every intersected day. EventLabel/eventLabel formats plain text without changing callback data; EmptyText/emptyText replaces the empty-day message. Replace input lists instead of mutating them. Times are local wall-clock values; callers normalize zones before passing data. The application owns the editor and persistence. This is an agenda layout, not a time-slot grid; month/year views, recurrence, resources, drag/resize and timezone conversion remain open.

## Blazor example

```razor
<div class="toolbar">
<NgButton OnClick="()=>readOnly=!readOnly">Toggle editing lock</NgButton>
<NgButton OnClick="()=>navigationReadOnly=!navigationReadOnly">Toggle navigation lock</NgButton>
<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>
<NgButton OnClick="()=>firstDay=firstDay==1?7:1">Toggle week start</NgButton>
<NgButton OnClick="()=>empty=!empty">Toggle events</NgButton>
<NgButton OnClick="Reset">Reset date</NgButton>
</div>
<p>Editing @(readOnly?"locked":"enabled") · Navigation @(navigationReadOnly?"locked":"enabled") · Proposals @(accept?"accepted":"rejected") · Week starts @(firstDay==1?"Monday":"Sunday")</p>
<NgScheduler Date="date" DateChanged="d=>{if(accept)date=d;}" View="view" ViewChanged="v=>{if(accept)view=v;}" FirstDayOfWeek="firstDay" ReadOnly="readOnly" NavigationReadOnly="navigationReadOnly" Items="@(empty?[]:events)" EventLabel="EventText" EmptyText="No shifts planned" OnCreate="Create" OnEdit="Edit"/>
<p role="status">Last action: @message</p>
@code {
 private DateTime date=new(2026,10,19);
 private NgScheduleView view=NgScheduleView.Week;
 private bool readOnly,navigationReadOnly,empty,accept=true;
 private int firstDay=1;
 private string message="none";
 private NgScheduleEvent[] events=[new("review","Review",new(2026,10,19,10,0,0),new(2026,10,19,11,0,0)),new("night","Overnight",new(2026,10,19,23,0,0),new(2026,10,20,1,0,0))];
 private string EventText(NgScheduleEvent e)=>$"Shift: {e.Title}";
 private void Create(DateTime d)=>message=$"Create: {d:yyyy-MM-dd}";
 private void Edit(NgScheduleEvent e)=>message=$"Edit: {e.Title}";
 private void Reset(){date=new(2026,10,19);view=NgScheduleView.Week;}
}
```

## Flutter example

```dart
DateTime date=DateTime(2026,10,19);
NgScheduleView view=NgScheduleView.week;
bool readOnly=false,navigationReadOnly=false,empty=false,accept=true;
int firstDay=1;
String message='none';
final events=[NgScheduleEvent('review','Review',DateTime(2026,10,19,10),DateTime(2026,10,19,11)),NgScheduleEvent('night','Overnight',DateTime(2026,10,19,23),DateTime(2026,10,20,1))];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle editing lock')),
  NgButton(onPressed:()=>setState(()=>navigationReadOnly=!navigationReadOnly),child:const Text('Toggle navigation lock')),
  NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle acceptance')),
  NgButton(onPressed:()=>setState(()=>firstDay=firstDay==1?7:1),child:const Text('Toggle week start')),
  NgButton(onPressed:()=>setState(()=>empty=!empty),child:const Text('Toggle events')),
  NgButton(onPressed:()=>setState((){date=DateTime(2026,10,19);view=NgScheduleView.week;}),child:const Text('Reset date')),
 ]),
 Text('Editing ${readOnly?"locked":"enabled"} · Navigation ${navigationReadOnly?"locked":"enabled"} · Proposals ${accept?"accepted":"rejected"} · Week starts ${firstDay==1?"Monday":"Sunday"}'),
 NgScheduler(date:date,view:view,firstDayOfWeek:firstDay,readOnly:readOnly,navigationReadOnly:navigationReadOnly,items:empty?const []:events,
  onDateChanged:(d){if(accept)setState(()=>date=d);},onViewChanged:(v){if(accept)setState(()=>view=v);},
  eventLabel:(e)=>'Shift: ${e.title}',emptyText:'No shifts planned',
  onCreate:(d)=>setState(()=>message='Create: ${NgScheduler.dayText(d)}'),onEdit:(e)=>setState(()=>message='Edit: ${e.title}')),
 Text('Last action: $message'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Schedule" | Visible label or accessible name. |
| `Date` | `DateTime` | DateTime.Today | See the behavior rules and model contract above. |
| `DateChanged` | `EventCallback<DateTime>` | not set | See the behavior rules and model contract above. |
| `View` | `NgScheduleView` | NgScheduleView.Week | See the behavior rules and model contract above. |
| `ViewChanged` | `EventCallback<NgScheduleView>` | not set | See the behavior rules and model contract above. |
| `FirstDayOfWeek` | `int` | 1 | See the behavior rules and model contract above. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `NavigationReadOnly` | `bool` | false | See the behavior rules and model contract above. |
| `EmptyText` | `string` | "No events" | See the behavior rules and model contract above. |
| `EventLabel` | `Func<NgScheduleEvent,string>?` | not set | See the behavior rules and model contract above. |
| `Items` | `IReadOnlyList<NgScheduleEvent>` | [] | Input collection. Replace it when changing records or configuration. |
| `OnCreate` | `EventCallback<DateTime>` | not set | See the behavior rules and model contract above. |
| `OnEdit` | `EventCallback<NgScheduleEvent>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `date` | `DateTime` | See the behavior rules and model contract above. |
| `items` | `List<NgScheduleEvent>` | Input collection. Replace it when changing records or configuration. |
| `onDateChanged` | `ValueChanged<DateTime>?` | See the behavior rules and model contract above. |
| `onCreate` | `ValueChanged<DateTime>?` | See the behavior rules and model contract above. |
| `onEdit` | `ValueChanged<NgScheduleEvent>?` | See the behavior rules and model contract above. |
| `view` | `NgScheduleView` | See the behavior rules and model contract above. |
| `onViewChanged` | `ValueChanged<NgScheduleView>?` | See the behavior rules and model contract above. |
| `firstDayOfWeek` | `int` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `navigationReadOnly` | `bool` | See the behavior rules and model contract above. |
| `emptyText` | `String` | See the behavior rules and model contract above. |
| `eventLabel` | `String Function(NgScheduleEvent)?` | See the behavior rules and model contract above. |

```dart
const NgScheduler({
    super.key,
    this.label = 'Schedule',
    required this.date,
    required this.items,
    this.onDateChanged,
    this.onCreate,
    this.onEdit,
    this.view = NgScheduleView.week,
    this.onViewChanged,
    this.firstDayOfWeek = 1,
    this.readOnly = false,
    this.navigationReadOnly = false,
    this.emptyText = 'No events',
    this.eventLabel,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgScheduler.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/visualization.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
