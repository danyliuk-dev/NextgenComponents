# NgDateRangePicker — Date range

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a linked start and end date.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDateRangePicker) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDateRangePicker)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgDateRange contains nullable Start/End (Blazor DateOnly, Flutter DateTime). An end before the start is invalid. Min/Max constrain both endpoints. Callbacks replace the whole range. A partially filled draft may exist; the form determines whether it is valid for submission. Do not save the last valid model while an invalid draft is visible: submit through NgForm. This is a calendar-date range, not a timezone-aware interval.

ReadOnly/readOnly prevents user changes. Disabled/enabled also disables interaction. Date editors keep readable, focusable text in read-only mode and disable their picker action; Calendar blocks selection and navigation (Flutter also excludes keyboard focus). Bounds must be ordered; invalid configuration throws. Values are Gregorian calendar dates; date text is ISO yyyy-MM-dd, independent of Blazor's current culture. Empty optional input clears to null.

DisabledDate/disabledDate applies to typing and calendar selection. In a range it checks both endpoints, not every date between them. Partial and reversed ranges fail form validation. Flutter range validation reads the current parent value after replacement. Applications own validation of external single-date values. Replace the form key to discard an invalid draft when the model value is unchanged.

Flutter calendars use Material locale/week-start and default bounds 1900–2100; Blazor uses Culture/FirstDayOfWeek and DateOnly bounds. Supply explicit bounds for matching domains. Calendar selection is single-date only. Shared range highlighting, multiple calendar views, cell templates, week numbers, segmented/custom-format input and complete keyboard/screen-reader parity remain open. Flutter popup results are ignored after a parent rebuild, edit or disposal.

### Presets and clearing (0.58)
Presets/presets is an optional ordered list of NgDateRangePreset descriptors. Each has a nonblank unique Id/id, nonblank Label/label, Start/start, End/end and optional Disabled/disabled (false). Dates must be ordered; malformed descriptors fail early. Flutter uses the calendar-date portions and accepts years 1–9999. Compute relative periods in the application using its chosen clock/time zone; the component never evaluates labels such as Today automatically.

A preset is unavailable if explicitly disabled or either endpoint violates Min/Max/DisabledDate. Interior days are not checked: Across weekend remains valid even though Sunday is unavailable as an endpoint. Read-only, disabled and missing change callbacks block preset/clear actions. Current descriptors and constraints are checked again at activation; removed/replaced preset callbacks cannot apply a stale range.

Applying a preset emits one complete range through ValueChanged/onChanged, with no intermediate half-range. Selecting the same preset again still emits once and repairs invalid drafts in both date editors. The parent should store the emitted value. The accepted dates determine selected presentation; this does not mean that an uncommitted manual draft is valid.

ShowClearButton/showClearButton (default false) adds an atomic clear action; ClearText/clearText defaults to Clear range and can be localized. Clear emits null once and resets both drafts even when the accepted value is already empty. Required validation remains application-owned (Flutter also supports required). Preset/clear reset recreates the two inner editors, closes open pickers and drops their local focus/selection state. It never submits the form. External assignments and manual typing retain their existing behavior.

Shared dual-calendar highlighting, relative-date engines and native/screen-reader certification remain open. These original preset contracts do not claim Telerik API compatibility.


## Blazor example

```razor
<NgForm Model="model" OnValidSubmit="()=>saved=true">
<NgDateRangePicker Label="Delivery period" Value="range" ValueChanged="Changed" ValueExpression="()=>range" Presets="presets" ShowClearButton="true" Min="min" Max="@(restricted?new DateOnly(2026,10,21):max)" DisabledDate="d=>d.DayOfWeek==DayOfWeek.Sunday" ReadOnly="readOnly" Disabled="disabled" />
<button type="submit" class="ng-button">Validate range</button>
</NgForm>
<div class="ng-prompt-actions"><NgButton OnClick="()=>readOnly=!readOnly">Toggle read only</NgButton><NgButton OnClick="()=>disabled=!disabled">Toggle disabled</NgButton><NgButton OnClick="()=>restricted=!restricted">Toggle bounds</NgButton></div>
<p>Changes: @changes · Range: @(range?.Start?.ToString("yyyy-MM-dd")??"empty") / @(range?.End?.ToString("yyyy-MM-dd")??"empty")</p>
<p>Validated: @saved</p>
@code {
 private object model=new(); private NgDateRange? range=new(new(2026,10,20),new(2026,10,23));
 private int changes; private bool readOnly,disabled,restricted,saved;
 private DateOnly min=new(2026,10,1),max=new(2026,10,31);
 private NgDateRangePreset[] presets=[new("week","Work week",new(2026,10,19),new(2026,10,23)),new("weekend","Across weekend",new(2026,10,23),new(2026,10,26)),new("sunday","Sunday start",new(2026,10,25),new(2026,10,26)),new("outside","Outside bounds",new(2026,10,30),new(2026,11,2)),new("locked","Unavailable preset",new(2026,10,20),new(2026,10,23),true)];
 private void Changed(NgDateRange? next){range=next;changes++;saved=false;}
}
```

## Flutter example

```dart
NgDateRange? range=NgDateRange(DateTime(2026,10,20),DateTime(2026,10,23));
int changes=0; bool readOnly=false,disabled=false,restricted=false,saved=false;
final presets=[NgDateRangePreset(id:'week',label:'Work week',start:DateTime(2026,10,19),end:DateTime(2026,10,23)),NgDateRangePreset(id:'weekend',label:'Across weekend',start:DateTime(2026,10,23),end:DateTime(2026,10,26)),NgDateRangePreset(id:'sunday',label:'Sunday start',start:DateTime(2026,10,25),end:DateTime(2026,10,26)),NgDateRangePreset(id:'outside',label:'Outside bounds',start:DateTime(2026,10,30),end:DateTime(2026,11,2)),NgDateRangePreset(id:'locked',label:'Unavailable preset',start:DateTime(2026,10,20),end:DateTime(2026,10,23),disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
NgForm(submitLabel:'Validate range',onValidSubmit:()async{setState(()=>saved=true);},child:NgDateRangePicker(label:'Delivery period',value:range,presets:presets,showClearButton:true,min:DateTime(2026,10,1),max:DateTime(2026,10,restricted?21:31),readOnly:readOnly,enabled:!disabled,disabledDate:(d)=>d.weekday==DateTime.sunday,onChanged:(v)=>setState((){range=v;changes++;saved=false;}))),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle read only')),NgButton(onPressed:()=>setState(()=>disabled=!disabled),child:const Text('Toggle disabled')),NgButton(onPressed:()=>setState(()=>restricted=!restricted),child:const Text('Toggle bounds'))]),
Text('Changes: $changes · Range: ${range?.start==null?'empty':NgDateRules.dateText(range!.start)} / ${range?.end==null?'empty':NgDateRules.dateText(range!.end)}'),Text('Validated: $saved')]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Date range" | Visible label or accessible name. |
| `Value` | `NgDateRange?` | not set | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<NgDateRange?>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `Expression<Func<NgDateRange?>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Min` | `DateOnly?` | not set | Inclusive minimum. |
| `Max` | `DateOnly?` | not set | Inclusive maximum. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `DisabledDate` | `Func<DateOnly,bool>?` | not set | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Presets` | `IReadOnlyList<NgDateRangePreset>` | Array.Empty<NgDateRangePreset>() | Ordered named date ranges with unique IDs; unavailable endpoints disable the action. |
| `ShowClearButton` | `bool` | false | Show an atomic clear action that resets both drafts and emits null. |
| `ClearText` | `string` | "Clear range" | Nonblank localized clear-action label; default Clear range. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgDateRange?` | Current value; see state ownership and model rules above. |
| `min` | `DateTime?` | Inclusive minimum. |
| `max` | `DateTime?` | Inclusive maximum. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `disabledDate` | `bool Function(DateTime)?` | See the behavior rules and model contract above. |
| `onChanged` | `ValueChanged<NgDateRange?>?` | Store the new value using setState or your state manager. |
| `presets` | `List<NgDateRangePreset>` | Ordered named date ranges with unique IDs; unavailable endpoints disable the action. |
| `showClearButton` | `bool` | Show an atomic clear action that resets both drafts and emits null. |
| `clearText` | `String` | Nonblank localized clear-action label; default Clear range. |

```dart
const NgDateRangePicker({
    super.key,
    this.label = 'Date range',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.enabled = true,
    this.required = false,
    this.readOnly = false,
    this.disabledDate,
    this.presets = const [],
    this.showClearButton = false,
    this.clearText = 'Clear range',
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDateRangePicker.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/dates.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
