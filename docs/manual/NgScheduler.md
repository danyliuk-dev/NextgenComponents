# NgScheduler — Weekly scheduler

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Show a week of application events and request create/edit actions.

## Behavior and practical rules

NgScheduleEvent requires a unique ID, nonempty title and End > Start. Date chooses the displayed week. Store DateChanged/onDateChanged; OnCreate/onCreate identifies a day, while OnEdit/onEdit identifies an event. The application opens its editor and replaces the event collection after saving. Times are local wall-clock values; timezone conversion belongs to the host. Recurrence, drag/resize, resources and multiple calendar views are not implemented.

## Blazor example

```razor
<NgScheduler @bind-Date="week" Items="events" OnCreate="day=>message=day.ToShortDateString()" OnEdit="item=>message=item.Title"/>
<p>@message</p>
@code { private DateTime week=new(2026,10,19); private string? message; private NgScheduleEvent[] events=[new("a","Meeting",new(2026,10,19,10,0,0),new(2026,10,19,11,0,0))]; }
```

## Flutter example

```dart
DateTime week = DateTime(2026,10,19);
Widget build(BuildContext context) => NgScheduler(date: week,
  items: [NgScheduleEvent('a','Meeting',DateTime(2026,10,19,10),DateTime(2026,10,19,11))],
  onDateChanged: (v) => setState(() => week = v),
  onCreate: (day) => debugPrint('Add $day'),
  onEdit: (item) => debugPrint(item.title));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Schedule" | Visible label or accessible name. |
| `Date` | `DateTime` | DateTime.Today | See the behavior rules and model contract above. |
| `DateChanged` | `EventCallback<DateTime>` | not set | See the behavior rules and model contract above. |
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
| `onDateChanged` | `ValueChanged<DateTime>` | See the behavior rules and model contract above. |
| `onCreate` | `ValueChanged<DateTime>` | See the behavior rules and model contract above. |
| `onEdit` | `ValueChanged<NgScheduleEvent>` | See the behavior rules and model contract above. |

```dart
const NgScheduler({
    super.key,
    this.label = 'Schedule',
    required this.date,
    required this.items,
    required this.onDateChanged,
    required this.onCreate,
    required this.onEdit,
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
