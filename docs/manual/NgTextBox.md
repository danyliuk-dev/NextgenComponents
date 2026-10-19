# NgTextBox — Single-line text

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a string with a visible label and form validation.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgTextBox) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgTextBox)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Editing and ownership
Blazor uses @bind-Value and InputBase/EditContext validation. Flutter uses an application-owned TextEditingController or initialValue, never both; initialValue is not a continuously controlled value. Dispose controllers and FocusNodes in their owner. Programmatic controller changes do not invoke onChanged.

ReadOnly/readOnly permits focus, selection and copying without editing. Disabled/enabled=false prevents normal interaction. Placeholder is a hint, not a replacement for the visible label. HelperText/helperText is persistent guidance. Blazor merges its helper ID with caller-supplied aria-describedby.

PrefixTemplate/SuffixTemplate and prefix/suffix accept decorative content beside the editor. Keep decoration short; provide separate labelled controls for interactive actions. These slots do not replace the field label or validator. Use FocusAsync after rendering in Blazor, or an owned focusNode.requestFocus() in Flutter.

MaxLength must be positive when supplied. It limits user entry, not application data: validate on the server too. Browser maxlength counts UTF-16 units; Flutter counts grapheme clusters and displays its native counter. Emoji limits can therefore differ. Existing/programmatic overlong values are not silently truncated.

OnCommit is the Blazor native change event (normally blur, or Enter for a single-line input); ValueChanged still fires while typing. Flutter onSubmitted is the platform submission action, not a blur event; multiline Enter normally inserts a newline. These are deliberately documented platform contracts, not identical event timing.

### Current scope
No arbitrary border/radius customization or certified screen-reader parity. Native/mobile verification remains deferred. Application supplies localized labels, guidance and validation errors.

### Clear action (0.46)
ShowClearButton/showClearButton adds a labelled Clear action. It is disabled for empty, read-only or disabled fields. Clear sets the value to the empty string, not null, updates the form field and emits one value-change callback. It restores input focus and does not explicitly invoke OnCommit/onSubmitted; Blazor native blur/change can still commit the preceding typed value when focus moves to the button. Required validators can therefore reject the empty field. Flutter preserves controller ownership and initialValue form reset; retained actions cannot clear a replacement controller or bypass locks. The clear action and supplied suffix can coexist.

### Password presentation
Password/password masks the single-line value; default false. ShowPasswordToggle/showPasswordToggle is opt-in and only appears in password mode. Reveal changes presentation, never the bound value or change callbacks. Read-only/disabled fields cannot reveal; entering these states hides the value. Clear and focus leaving the reveal control hide it too. Flutter controller replacement resets reveal. Password mode does not encrypt values or provide a credential manager; application storage and submission remain application responsibilities. Flutter disables suggestions/autocorrection in password mode. TextArea has no password mode.


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


## Blazor example

```razor
<p>IME input updates the draft immediately; notifications wait until composition ends.</p>
<div class="ng-prompt-actions"><NgButton OnClick="CycleRounded">Change corners</NgButton><NgButton OnClick="ToggleFlat">Toggle flat fill</NgButton></div>
<p>Corners: @rounded</p>
<div class="ng-prompt-actions"><NgButton OnClick="ReplaceDraft">Replace draft</NgButton><NgButton OnClick="()=>delay=delay==600?0:600">Change delay</NgButton></div>
<p>Delay: @delay ms · Notifications: @notifications · Notified length: @notifiedLength</p>
<div class="ng-prompt-actions"><NgButton OnClick="CycleSize">Change size</NgButton><NgButton OnClick="CycleFill">Change fill</NgButton></div>
<p>Size: @size · Fill: @fill</p>
<NgButton OnClick="()=>password=!password">Toggle password mode</NgButton>
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgTextBox Rounded="@rounded" DebounceDelay="delay" OnDebouncedChange="Debounced" Size="@size" FillMode="@fill" @ref="editor" Label="Project name" @bind-Value="text" ReadOnly="locked" ShowClearButton="true" Password="password" ShowPasswordToggle="true" MaxLength="80" HelperText="Use a short, descriptive name." OnCommit="v=>committed=v">
<PrefixTemplate><span aria-hidden="true">@@</span></PrefixTemplate>
</NgTextBox>
<NgButton OnClick="()=>editor!.FocusAsync().AsTask()">Focus editor</NgButton>
<p>Length: @(text?.Length??0)</p>
@code {
 private void ToggleFlat()=>fill=fill=="flat"?"theme":"flat";
 private string rounded="theme";
 private void CycleRounded()=>rounded=rounded=="theme"?"large":rounded=="large"?"none":rounded=="none"?"small":rounded=="small"?"medium":rounded=="medium"?"full":"theme";
 private int delay=600,notifications,notifiedLength;
 private void Debounced(string? value){notifications++;notifiedLength=value?.Length??0;}
 private void ReplaceDraft()=>text="External replacement";
 private string size="medium",fill="theme";
 private void CycleSize()=>size=size=="medium"?"large":size=="large"?"small":"medium";
 private void CycleFill()=>fill=fill=="theme"?"filled":fill=="filled"?"outline":"theme"; private NgTextBox? editor; private bool locked,password=true; private string? text="Design review",committed; }

```

## Flutter example

```dart
String rounded='theme';
int delay=600,notifications=0,notifiedLength=0;
String size='medium',fill='theme';
bool locked = false, password = true; String submitted = '';
final editor = TextEditingController(text:'Design review');
final focus = FocusNode();
@override void dispose(){editor.dispose();focus.dispose();super.dispose();}
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('IME input updates the draft immediately; notifications wait until composition ends.'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>rounded=rounded=='theme'?'large':rounded=='large'?'none':rounded=='none'?'small':rounded=='small'?'medium':rounded=='medium'?'full':'theme'),child:const Text('Change corners')),NgButton(onPressed:()=>setState(()=>fill=fill=='flat'?'theme':'flat'),child:const Text('Toggle flat fill'))]),
Text('Corners: $rounded'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>editor.text='External replacement'),child:const Text('Replace draft')),NgButton(onPressed:()=>setState(()=>delay=delay==600?0:600),child:const Text('Change delay'))]),
Text('Delay: $delay ms · Notifications: $notifications · Notified length: $notifiedLength'),
Wrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>size=size=='medium'?'large':size=='large'?'small':'medium'),child:const Text('Change size')),NgButton(onPressed:()=>setState(()=>fill=fill=='theme'?'filled':fill=='filled'?'outline':'theme'),child:const Text('Change fill'))]),
Text('Size: $size · Fill: $fill'),
NgButton(onPressed:()=>setState(()=>password=!password),child:const Text('Toggle password mode')),
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgTextBox(rounded:rounded,debounceDelay:delay,onDebouncedChange:(v)=>setState((){notifications++;notifiedLength=v.length;}),size:size,fillMode:fill,label:'Project name',controller:editor,focusNode:focus,readOnly:locked,showClearButton:true,password:password,showPasswordToggle:true,maxLength:80,
helperText:'Use a short, descriptive name.',prefix:const Icon(Icons.edit_outlined),
onChanged:(_)=>setState((){}),onSubmitted:(v)=>setState(()=>submitted=v)),
NgButton(onPressed:()=>focus.requestFocus(),child:const Text('Focus editor')),
Text('Length: ${editor.text.length}')]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "" | Visible label or accessible name. |
| `Size` | `string` | "medium" | See the behavior rules and model contract above. |
| `Rounded` | `string` | "theme" | Chip corners: sm, md, lg or full. |
| `FillMode` | `string` | "theme" | Chip fill: solid or outline; see the documented defaults. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `ShowClearButton` | `bool` | false | See the behavior rules and model contract above. |
| `Password` | `bool` | false | See the behavior rules and model contract above. |
| `ShowPasswordToggle` | `bool` | false | See the behavior rules and model contract above. |
| `MaxLength` | `int?` | not set | See the behavior rules and model contract above. |
| `HelperText` | `string?` | not set | See the behavior rules and model contract above. |
| `PrefixTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `SuffixTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `DebounceDelay` | `int` | 300 | See the behavior rules and model contract above. |
| `OnDebouncedChange` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `OnCommit` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `Value` | `string?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `debounceDelay` | `int` | See the behavior rules and model contract above. |
| `onDebouncedChange` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `size` | `String` | See the behavior rules and model contract above. |
| `fillMode` | `String` | Chip fill: solid or outline; see the documented defaults. |
| `rounded` | `String` | Chip corners: sm, md, lg or full. |
| `controller` | `TextEditingController?` | Text controller; do not combine with initialValue. Dispose in its owner. |
| `initialValue` | `String?` | Starting field value, not continuous controlled state. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `validator` | `FormFieldValidator<String>?` | Return null when valid or a user-facing validation error. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `showClearButton` | `bool` | See the behavior rules and model contract above. |
| `password` | `bool` | See the behavior rules and model contract above. |
| `showPasswordToggle` | `bool` | See the behavior rules and model contract above. |
| `focusNode` | `FocusNode?` | See the behavior rules and model contract above. |
| `helperText` | `String?` | See the behavior rules and model contract above. |
| `prefix` | `Widget?` | See the behavior rules and model contract above. |
| `suffix` | `Widget?` | See the behavior rules and model contract above. |
| `onSubmitted` | `ValueChanged<String>?` | See the behavior rules and model contract above. |
| `placeholder` | `String?` | Hint displayed for empty input. |
| `maxLength` | `int?` | See the behavior rules and model contract above. |

```dart
const NgTextBox({
    super.key,
    required this.label,
    this.size = 'medium',
    this.fillMode = 'theme',
    this.rounded = 'theme',
    this.debounceDelay = 300,
    this.onDebouncedChange,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.showClearButton = false,
    this.password = false,
    this.showPasswordToggle = false,
    this.focusNode,
    this.helperText,
    this.prefix,
    this.suffix,
    this.onSubmitted,
    this.placeholder,
    this.maxLength,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTextBox.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
