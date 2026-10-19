# NgTextArea — Multiline text

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a string with a visible label and form validation.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgTextArea) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgTextArea)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Editing and ownership
Blazor uses @bind-Value and InputBase/EditContext validation. Flutter uses an application-owned TextEditingController or initialValue, never both; initialValue is not a continuously controlled value. Dispose controllers and FocusNodes in their owner. Programmatic controller changes do not invoke onChanged.

ReadOnly/readOnly permits focus, selection and copying without editing. Disabled/enabled=false prevents normal interaction. Placeholder is a hint, not a replacement for the visible label. HelperText/helperText is persistent guidance. Blazor merges its helper ID with caller-supplied aria-describedby.

PrefixTemplate/SuffixTemplate and prefix/suffix accept decorative content beside the editor. Keep decoration short; provide separate labelled controls for interactive actions. These slots do not replace the field label or validator. Use FocusAsync after rendering in Blazor, or an owned focusNode.requestFocus() in Flutter.

MaxLength must be positive when supplied. It limits user entry, not application data: validate on the server too. Browser maxlength counts UTF-16 units; Flutter counts grapheme clusters and displays its native counter. Emoji limits can therefore differ. Existing/programmatic overlong values are not silently truncated. Rows must be 1–30; this is a fixed-row editor, not automatic resizing.

OnCommit is the Blazor native change event (normally blur, or Enter for a single-line input); ValueChanged still fires while typing. Flutter onSubmitted is the platform submission action, not a blur event; multiline Enter normally inserts a newline. These are deliberately documented platform contracts, not identical event timing.

### Current scope
No arbitrary border/radius customization or certified screen-reader parity. Native/mobile verification remains deferred. Application supplies localized labels, guidance and validation errors.

### Clear action (0.46)
ShowClearButton/showClearButton adds a labelled Clear action. It is disabled for empty, read-only or disabled fields. Clear sets the value to the empty string, not null, updates the form field and emits one value-change callback. It restores input focus and does not explicitly invoke OnCommit/onSubmitted; Blazor native blur/change can still commit the preceding typed value when focus moves to the button. Required validators can therefore reject the empty field. Flutter preserves controller ownership and initialValue form reset; retained actions cannot clear a replacement controller or bypass locks. The clear action and supplied suffix can coexist.


### Automatic height (0.47)
AutoSize/autoSize defaults to false. When enabled, Rows/rows is the minimum visible line count and MaxRows/maxRows is the maximum (default 12). Both accept 1–30; the maximum must be at least the minimum in automatic mode. Fixed mode keeps Rows and ignores MaxRows for layout. The automatic field grows for newlines and wrapped text, shrinks on deletion/clear/external replacement and scrolls internally above the cap. It also adapts to width changes in read-only and disabled states. Sizing never changes the value or emits a value callback.

Blazor uses a packaged JS module after interactive rendering; static SSR falls back to Rows. Automatic mode owns height and disables native manual resizing. Turning it off restores the previous inline height/overflow and normal fixed-mode behavior. Flutter uses native minLines/maxLines layout. The platforms retain their own font metrics and decorations, so equal row counts do not promise equal pixel heights. Avoid application CSS that overrides automatic height, line height or box sizing.


### Size and fill (0.48)
Size/size accepts small, medium (default), or large. FillMode/fillMode accepts theme (default), outline, filled, or flat. Invalid values throw. Medium and theme inherit the existing application density/decoration. Small and large adjust text size and padding; they do not impose a fixed TextArea height. Outline removes background fill; filled uses a theme-aware surface. Borders, focus and validation indicators remain controlled by the platform/theme. Flutter custom themes should supply an outline border if that shape is required; fill selection does not replace theme borders.

Changing appearance preserves the value, selection and form state and emits no change callback. Automatic TextArea height recalculates with the new metrics. Read-only/disabled permissions and clear/password behavior remain unchanged. Flutter keeps native action hit targets; compact fields containing actions can therefore remain taller than fields without actions. Prefix/suffix templates keep their own sizing. The two platforms do not promise equal pixel heights. Rounded presets and flat borders are available from 0.53; arbitrary border styling remains application-owned.


### Debounced notifications (0.49)
OnDebouncedChange/onDebouncedChange is an optional notification after typing or Clear pauses for DebounceDelay/debounceDelay milliseconds (default 300, range 0–60000). The latest value in a burst wins. Zero means no intentional wait; Flutter uses the next timer turn. Value binding, onChanged and form validation remain immediate. These callbacks receive the actual value even in password mode; the sample displays only its length.

A different externally supplied value, a changed delay, read-only/disabled state, handler removal, Flutter controller replacement or disposal cancels a pending notification. External changes alone never schedule notifications. Appearance changes and ordinary parent rebuilds retain pending work; the current callback receives the notification. Flutter selection-only controller changes do not cancel it. Flutter Form.reset follows TextFormField's native onChanged behavior and may schedule the reset value; use a replacement key/controller to discard all draft work.

OnCommit/onSubmitted stays independent: blur/submit neither flushes nor cancels the delayed callback. Debouncing does not make submission wait or perform validation/network requests. Once a callback starts, cancelling later input cannot undo its effects: applications must protect asynchronous search results with their own request/version checks. IME composition suppression is available from 0.57; see below. Blazor cannot distinguish an external assignment of the same string from the normal binding echo; use a replacement key to reset the editor unconditionally.


### Rounded corners and flat fill (0.53)
Rounded/rounded accepts theme (default), none, small, medium, large, or full. Presets request radii of 0, 4, 8, 16, or 9999 logical pixels; the platform clamps large radii to the field bounds. Theme preserves the existing CSS/Flutter decoration. Unknown values throw. The radius applies to the editor border, not to separate action buttons or adornment content. Full is most suitable for short single-line fields; prefer smaller radii for long multiline text.

Flat uses the same theme-aware surface as filled and hides the idle/disabled border without changing field dimensions. Focus and validation error indicators remain visible in the provided theme. Custom Flutter border sides/colors are retained for focus and errors; InputBorder.none remains an explicit application choice. Outline and underline theme borders retain their type when rounded presets are applied. Arbitrary custom InputBorder subclasses are replaced with an outline for an explicit rounded preset; theme retains them.

Changing these options retains text, selection, focus and validation and does not emit editing events. It also retains TextArea autosizing, read-only/disabled permissions and clear/password actions. Original design values are used; this is not Telerik API, theme or pixel compatibility.


### IME composition (0.57)
While an input method is composing text, debounced notifications are suppressed, including with a zero delay. Binding, validation and onChanged still follow native edits immediately. Completing composition starts the configured delay again; completion with unchanged text also produces one notification. A later edit replaces that pending notification normally.

Locks, external replacement, handler removal and disposal still cancel pending work. Clear is a new empty edit. Composition does not delay form submission or OnCommit/onSubmitted. Blazor uses a native composition observer loaded after interactive rendering; Flutter observes the editing composition range and native Web composition events (including semantics mode), while retaining TextFormField controller/reset ownership. Initial rendering does not notify. Browser automation checks native Chromium composition events and Flutter tests cover editing ranges; physical OS input methods, mobile keyboards and assistive technology certification remain separate verification.


### Character counters (0.59)
CounterMode/counterMode accepts native (default), hidden, used or remaining. Native preserves existing presentation: no counter in Blazor, the framework counter in Flutter when MaxLength/maxLength is set. Hidden removes only the counter; it never disables length enforcement or validation. Used displays the current count, with the maximum when present. Remaining requires a maximum, displays the remaining allowance and reports an over-limit amount for externally supplied overlong text.

CounterText/counterText optionally formats the displayed text from the current count and nullable maximum. It applies only in used/remaining modes; use it for localized text. It receives counts, never the password value. In Blazor it is Func<int,int?,string>; in Flutter it is String Function(int current,int? maximum). Returned text is plain text, not HTML. Keep this formatting function pure.

Counts follow each platform's existing length limit: Blazor browser maxlength and counter use UTF-16 units; Flutter uses grapheme clusters. A family emoji can therefore count as 11 in Blazor and 1 in Flutter. Counts do not promise byte counts or a shared server-side length policy. External overlong values remain visible; a counter is presentation, not additional validation.

Counters update immediately for drafts (including IME), Clear, external replacement and native Flutter Form.reset. Appearance/mode changes retain text and pending debounce work. Blazor merges the counter ID into aria-describedby and exposes a polite atomic live region; Flutter retains framework counter semantics with a live text update. Physical screen-reader behavior remains unverified. Long labels can wrap; custom code should avoid announcing sensitive information.


## Blazor example

```razor
<div class="ng-prompt-actions"><NgButton OnClick="CycleCounter">Change counter</NgButton><NgButton OnClick="()=>customCounter=!customCounter">Custom counter</NgButton><NgButton OnClick="LoadEmoji">Load emoji</NgButton><NgButton OnClick="LoadOverflow">Load over limit</NgButton></div>
<p>IME input updates the draft immediately; notifications wait until composition ends.</p>
<div class="ng-prompt-actions"><NgButton OnClick="CycleRounded">Change corners</NgButton><NgButton OnClick="ToggleFlat">Toggle flat fill</NgButton></div>
<p>Corners: @rounded</p>
<div class="ng-prompt-actions"><NgButton OnClick="ReplaceDraft">Replace draft</NgButton><NgButton OnClick="()=>delay=delay==600?0:600">Change delay</NgButton></div>
<p>Delay: @delay ms · Notifications: @notifications · Notified length: @notifiedLength</p>
<div class="ng-prompt-actions"><NgButton OnClick="CycleSize">Change size</NgButton><NgButton OnClick="CycleFill">Change fill</NgButton></div>
<p>Size: @size · Fill: @fill</p>
<div class="ng-prompt-actions">
 <NgButton OnClick="()=>automatic=!automatic">Toggle automatic height</NgButton>
 <NgButton OnClick="LoadLong">Load long text</NgButton>
 <NgButton OnClick="LoadShort">Load short text</NgButton>
</div>
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgTextArea MaxLength="80" CounterMode="@counterMode" CounterText="@(customCounter?FormatCounter:null)" Rounded="@rounded" DebounceDelay="delay" OnDebouncedChange="Debounced" Size="@size" FillMode="@fill" Label="Delivery notes" @bind-Value="text" Rows="2" MaxRows="6" AutoSize="automatic"
 ReadOnly="locked" ShowClearButton="true" HelperText="Grows from 2 to 6 rows; longer notes scroll."/>
<p>Automatic height: @automatic · Length: @(text?.Length??0)</p>
@code {
 private string counterMode="used";private bool customCounter;
 private string FormatCounter(int current,int? maximum)=>$"Used: {current}; limit: {maximum}";
 private void CycleCounter()=>counterMode=counterMode=="used"?"remaining":counterMode=="remaining"?"hidden":counterMode=="hidden"?"native":"used";
 private void LoadEmoji()=>text="👨‍👩‍👧‍👦";
 private void LoadOverflow()=>text=new string('x',85);
 private void ToggleFlat()=>fill=fill=="flat"?"theme":"flat";
 private string rounded="theme";
 private void CycleRounded()=>rounded=rounded=="theme"?"large":rounded=="large"?"none":rounded=="none"?"small":rounded=="small"?"medium":rounded=="medium"?"full":"theme";
 private int delay=600,notifications,notifiedLength;
 private void Debounced(string? value){notifications++;notifiedLength=value?.Length??0;}
 private void ReplaceDraft()=>text="External replacement";
 private string size="medium",fill="theme";
 private void CycleSize()=>size=size=="medium"?"large":size=="large"?"small":"medium";
 private void CycleFill()=>fill=fill=="theme"?"filled":fill=="filled"?"outline":"theme";
 private bool automatic=true,locked; private string? text="Short note";
 private void LoadShort()=>text="Short note";
 private void LoadLong()=>text=string.Join("\n",Enumerable.Range(1,14).Select(i=>$"Line {i}: a detailed delivery note."));
}

```

## Flutter example

```dart
String counterMode='used';bool customCounter=false;
String rounded='theme';
int delay=600,notifications=0,notifiedLength=0;
String size='medium',fill='theme';
bool automatic = true, locked = false;
final editor = TextEditingController(text:'Short note');
@override void dispose(){editor.dispose();super.dispose();}
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Wrap(spacing:8,runSpacing:8,children:[NgButton(onPressed:()=>setState(()=>counterMode=counterMode=='used'?'remaining':counterMode=='remaining'?'hidden':counterMode=='hidden'?'native':'used'),child:const Text('Change counter')),NgButton(onPressed:()=>setState(()=>customCounter=!customCounter),child:const Text('Custom counter')),NgButton(onPressed:()=>setState(()=>editor.text='👨‍👩‍👧‍👦'),child:const Text('Load emoji')),NgButton(onPressed:()=>setState(()=>editor.text='x'*85),child:const Text('Load over limit'))]),const Text('IME input updates the draft immediately; notifications wait until composition ends.'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>rounded=rounded=='theme'?'large':rounded=='large'?'none':rounded=='none'?'small':rounded=='small'?'medium':rounded=='medium'?'full':'theme'),child:const Text('Change corners')),NgButton(onPressed:()=>setState(()=>fill=fill=='flat'?'theme':'flat'),child:const Text('Toggle flat fill'))]),
Text('Corners: $rounded'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>editor.text='External replacement'),child:const Text('Replace draft')),NgButton(onPressed:()=>setState(()=>delay=delay==600?0:600),child:const Text('Change delay'))]),
Text('Delay: $delay ms · Notifications: $notifications · Notified length: $notifiedLength'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>size=size=='medium'?'large':size=='large'?'small':'medium'),child:const Text('Change size')),NgButton(onPressed:()=>setState(()=>fill=fill=='theme'?'filled':fill=='filled'?'outline':'theme'),child:const Text('Change fill'))]),
Text('Size: $size · Fill: $fill'),
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>automatic=!automatic),child:const Text('Toggle automatic height')),
  NgButton(onPressed:()=>setState(()=>editor.text=List.generate(14,(i)=>'Line ${i+1}: a detailed delivery note.').join('\n')),child:const Text('Load long text')),
  NgButton(onPressed:()=>setState(()=>editor.text='Short note'),child:const Text('Load short text')),
 ]),
 NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
 NgTextArea(maxLength:80,counterMode:counterMode,counterText:customCounter?(n,m)=>'Used: $n; limit: $m':null,rounded:rounded,debounceDelay:delay,onDebouncedChange:(v)=>setState((){notifications++;notifiedLength=v.length;}),size:size,fillMode:fill,label:'Delivery notes',controller:editor,rows:2,maxRows:6,autoSize:automatic,
  readOnly:locked,showClearButton:true,helperText:'Grows from 2 to 6 rows; longer notes scroll.',onChanged:(_)=>setState((){})),
 Text('Automatic height: $automatic · Length: ${editor.text.length}'),
]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `CounterMode` | `string` | "native" | native (default), hidden, used or remaining; remaining requires a maximum. |
| `CounterText` | `Func<int,int?,string>?` | not set | Optional plain-text formatter receiving current count and nullable maximum; used/remaining only. |
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Notes" | Visible label or accessible name. |
| `Size` | `string` | "medium" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "theme" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "theme" | Chip fill: solid or outline; see the documented defaults. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `ShowClearButton` | `bool` | false | See the behavior rules and model contract above. |
| `MaxLength` | `int?` | not set | See the behavior rules and model contract above. |
| `HelperText` | `string?` | not set | See the behavior rules and model contract above. |
| `PrefixTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `SuffixTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `DebounceDelay` | `int` | 300 | See the behavior rules and model contract above. |
| `OnDebouncedChange` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `OnCommit` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `Rows` | `int` | 4 | See the behavior rules and model contract above. |
| `AutoSize` | `bool` | false | See the behavior rules and model contract above. |
| `MaxRows` | `int` | 12 | See the behavior rules and model contract above. |
| `Value` | `string?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `counterMode` | `String` | native (default), hidden, used or remaining; remaining requires a maximum. |
| `counterText` | `String Function(int current, int? maximum)?` | Optional plain-text formatter receiving current count and nullable maximum; used/remaining only. |
| `debounceDelay` | `int` | See the behavior rules and model contract above. |
| `onDebouncedChange` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `size` | `String` | See the behavior rules and model contract above. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `controller` | `TextEditingController?` | Text controller; do not combine with initialValue. Dispose in its owner. |
| `initialValue` | `String?` | Starting field value, not continuous controlled state. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `validator` | `FormFieldValidator<String>?` | Return null when valid or a user-facing validation error. |
| `rows` | `int` | See the behavior rules and model contract above. |
| `maxRows` | `int` | See the behavior rules and model contract above. |
| `autoSize` | `bool` | See the behavior rules and model contract above. |
| `placeholder` | `String?` | Hint displayed for empty input. |
| `maxLength` | `int?` | See the behavior rules and model contract above. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `showClearButton` | `bool` | See the behavior rules and model contract above. |
| `focusNode` | `FocusNode?` | See the behavior rules and model contract above. |
| `helperText` | `String?` | See the behavior rules and model contract above. |
| `prefix` | `Widget?` | See the behavior rules and model contract above. |
| `suffix` | `Widget?` | See the behavior rules and model contract above. |
| `onSubmitted` | `ValueChanged<String>?` | See the behavior rules and model contract above. |

```dart
const NgTextArea({
    super.key,
    this.label = 'Notes',
    this.counterMode = 'native',
    this.counterText,
    this.size = 'medium',
    this.fillMode = 'theme',
    this.rounded = 'theme',
    this.debounceDelay = 300,
    this.onDebouncedChange,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.rows = 4,
    this.autoSize = false,
    this.maxRows = 12,
    this.placeholder,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.showClearButton = false,
    this.focusNode,
    this.helperText,
    this.prefix,
    this.suffix,
    this.onSubmitted,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTextArea.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/forms.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
