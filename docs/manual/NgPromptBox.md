# NgPromptBox — Prompt input

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Compose a multiline request with explicit submission and cancellation.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgPromptBox) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgPromptBox)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Value/value supplies the draft. Store ValueChanged/onChanged and pass the value back; unchanged parent values preserve local edits. External value replacement updates the field. MaxLength is 1–8000 UTF-16 code units, default 8000; emoji may occupy two units. External values may contain up to 8000 units. A value or retained draft above MaxLength stays visible with an error and Send disabled, so reducing the limit never silently truncates text. Input beyond the limit is rejected unless it shortens an already oversized draft; further deletion remains possible. Values over the absolute 8000-unit cap are rejected. Blank input cannot be submitted. Send trims outer whitespace; Enter inserts a newline. Tab followed by Enter/Space activates buttons; no special submit shortcut is installed.

Busy makes the input read-only and replaces Send with Cancel. The parent owns the asynchronous request, busy state, result/error display and cancellation. OnCancel only signals the parent: it does not stop a network request by itself. Use a cancellation token/transport adapter and invalidate late responses. The example demonstrates this ownership. ReadOnly prevents submission and editing; a busy Cancel remains available when its callback exists. A missing submit/cancel callback disables the corresponding action.

This is an input control, not an AI client or form-validation engine. Use NgAIPrompt for history and response actions. Attachments, speech input, model selection, streaming and provider integration are not included. Do not put provider secrets in browser code.

Actions recheck the current busy/read-only state and current callbacks, including retained actions after a rebuild or disposal. Cancel requires Busy; ReadOnly alone does not disable cancellation.


## Blazor example

```razor
<NgButton OnClick="()=>limit=limit==80?8:80">Toggle length limit</NgButton>
<NgPromptBox Label="Prompt" @bind-Value="prompt" MaxLength="limit" Busy="busy" OnSubmit="Submit" OnCancel="Cancel"/>
<p>@result</p>
@code {
 private string prompt="",result=""; private bool busy; private int revision; private int limit=80;
 private async Task Submit(string text) {
  var request=++revision; busy=true;
  await Task.Delay(700); // Local example; replace with an application handler.
  if(request!=revision)return;
  result=$"Received prompt: {text}"; busy=false;
 }
 private void Cancel(){revision++;busy=false;result="Cancelled";}
}
```

## Flutter example

```dart
String prompt = '', result = '';
bool busy = false;
int revision = 0, limit = 80;
Future<void> submit(String text) async {
  final request = ++revision;
  setState(() => busy = true);
  await Future<void>.delayed(const Duration(milliseconds: 700));
  if (!mounted || request != revision) return;
  setState(() { result = 'Received prompt: $text'; busy = false; });
}
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
 NgButton(onPressed: () => setState(() => limit = limit == 80 ? 8 : 80), child: const Text('Toggle length limit')),
 NgPromptBox(label: 'Prompt', value: prompt, maxLength: limit,
  onChanged: (v) => setState(() => prompt = v), busy: busy,
  onSubmit: submit,
  onCancel: () => setState(() { revision++; busy = false; result = 'Cancelled'; })), Text(result)]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Prompt" | Visible label or accessible name. |
| `Value` | `string` | "" | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<string>` | not set | New value for the parent to store and pass back. |
| `Placeholder` | `string` | "Describe what you need…" | Hint displayed for empty input. |
| `MaxLength` | `int` | 8000 | See the behavior rules and model contract above. |
| `Busy` | `bool` | false | Request in progress; the parent owns it for a standalone PromptBox. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `OnSubmit` | `EventCallback<string>` | not set | Trimmed nonempty prompt submitted by the user. |
| `OnCancel` | `EventCallback` | not set | Request cancellation; the application owns stopping its transport. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `String` | Current value; see state ownership and model rules above. |
| `placeholder` | `String` | Hint displayed for empty input. |
| `maxLength` | `int` | See the behavior rules and model contract above. |
| `busy` | `bool` | Request in progress; the parent owns it for a standalone PromptBox. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `onSubmit` | `ValueChanged<String>?` | Trimmed nonempty prompt submitted by the user. |
| `onCancel` | `VoidCallback?` | Request cancellation; the application owns stopping its transport. |

```dart
const NgPromptBox({
    super.key,
    this.label = 'Prompt',
    this.value = '',
    this.placeholder = 'Describe what you need…',
    this.maxLength = 8000,
    this.busy = false,
    this.readOnly = false,
    this.onChanged,
    this.onSubmit,
    this.onCancel,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgPromptBox.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/prompt.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
