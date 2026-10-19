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
No debounce, automatic resize, full appearance variants or certified screen-reader parity. Native/mobile verification remains deferred. Application supplies localized labels, guidance and validation errors.

### Clear action (0.46)
ShowClearButton/showClearButton adds a labelled Clear action. It is disabled for empty, read-only or disabled fields. Clear sets the value to the empty string, not null, updates the form field and emits one value-change callback. It restores input focus and does not explicitly invoke OnCommit/onSubmitted; Blazor native blur/change can still commit the preceding typed value when focus moves to the button. Required validators can therefore reject the empty field. Flutter preserves controller ownership and initialValue form reset; retained actions cannot clear a replacement controller or bypass locks. The clear action and supplied suffix can coexist.


## Blazor example

```razor
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgTextArea @ref="editor" Label="Delivery notes" @bind-Value="text" ReadOnly="locked" ShowClearButton="true" MaxLength="80" HelperText="Use a short, descriptive note." OnCommit="v=>committed=v">
<PrefixTemplate><span aria-hidden="true">✎</span></PrefixTemplate>
</NgTextArea>
<NgButton OnClick="()=>editor!.FocusAsync().AsTask()">Focus editor</NgButton>
<p>Current: @text</p><p>Committed: @committed</p>
@code { private NgTextArea? editor; private bool locked; private string? text="Design review",committed; }

```

## Flutter example

```dart
bool locked = false; String submitted = '';
final editor = TextEditingController(text:'Design review');
final focus = FocusNode();
@override void dispose(){editor.dispose();focus.dispose();super.dispose();}
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgTextArea(label:'Delivery notes',controller:editor,focusNode:focus,readOnly:locked,showClearButton:true,maxLength:80,
helperText:'Use a short, descriptive note.',prefix:const Icon(Icons.edit_outlined),
onChanged:(_)=>setState((){}),onSubmitted:(v)=>setState(()=>submitted=v)),
NgButton(onPressed:()=>focus.requestFocus(),child:const Text('Focus editor')),
Text('Current: ${editor.text}'),Text('Submitted: $submitted')]);

```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Notes" | Visible label or accessible name. |
| `Placeholder` | `string?` | not set | Hint displayed for empty input. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `ShowClearButton` | `bool` | false | See the behavior rules and model contract above. |
| `MaxLength` | `int?` | not set | See the behavior rules and model contract above. |
| `HelperText` | `string?` | not set | See the behavior rules and model contract above. |
| `PrefixTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `SuffixTemplate` | `RenderFragment?` | not set | See the behavior rules and model contract above. |
| `OnCommit` | `EventCallback<string?>` | not set | See the behavior rules and model contract above. |
| `Rows` | `int` | 4 | See the behavior rules and model contract above. |
| `Value` | `string?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<string?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<string?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `controller` | `TextEditingController?` | Text controller; do not combine with initialValue. Dispose in its owner. |
| `initialValue` | `String?` | Starting field value, not continuous controlled state. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `validator` | `FormFieldValidator<String>?` | Return null when valid or a user-facing validation error. |
| `rows` | `int` | See the behavior rules and model contract above. |
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
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.rows = 4,
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
