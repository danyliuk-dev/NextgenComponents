# NgAIPrompt — AI prompt interface

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Compose requests, inspect responses and manage retries, history and feedback.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgAIPrompt) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgAIPrompt)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Provider contract
Blazor Generate is Func<string,CancellationToken,Task<string>>; Flutter generate is NgPromptGenerator: Future<String> Function(String,NgPromptCancellation). The handler receives a captured, trimmed prompt and returns complete response text. Without it the input is disabled. The example/gallery uses a deterministic delayed local handler, not an AI model.

The application owns authentication, model choice, rate limits, timeouts and provider calls. Keep provider credentials on your backend. In Blazor pass CancellationToken into the HTTP/AI client. In Flutter connect cancellation.whenCancelled to transport cancellation; isCancelled and throwIfCancelled detect cancellation. Checking after await stops result processing, not the remote request or billing. The component itself makes no network requests.

### Draft and request lifecycle
Value/value and change callbacks control the draft. Maximum prompt: 8000 UTF-16 units. Up to 8 nonempty suggestions, each at most 200 units. Suggestions fill the draft without sending. Enter inserts a newline; Send submits. Duplicate submission is blocked while busy. The user cannot edit during a request, but an external Value replacement changes the next draft, not the captured request.

Cancel immediately releases the UI and signals cancellation. A new request may start immediately. Even if an older handler ignores cancellation, its late result/error cannot enter history or replace newer state. Disposal, ReadOnly or removing the handler also cancels pending work. ReadOnly keeps history browsing/copying available. Transport cancellation is the application's responsibility.

Provider exceptions show a generic Generation failed. Try again. message; log details in your handler. Retry request uses the last failed prompt even if the draft changed. Empty/whitespace responses and responses over 32000 UTF-16 units are errors. Previous successful history survives failures. Timeouts belong to the application.

### Responses and events
The last 20 successful responses are kept in memory; oldest entries are evicted. IDs increase throughout the component session, including after Clear history. Selecting history changes the displayed response. Regenerate runs that response's original prompt. Clear removes history/selection/votes and cancels work in the public session API; the UI button is disabled while busy. History is not durable and is lost on component disposal.

NgPromptResponse contains Id/id, Prompt/prompt and Text/text. OnCompleted fires once for each accepted successful response, never for cancellation/failure. NgPromptFeedback contains the response and Helpful/helpful: true, false or null for a cleared vote. Clicking the same vote toggles it off; votes do not call the provider. Callback exceptions belong to the host application.

Responses render as plain text, with no HTML/Markdown execution. Copy response uses the browser/platform clipboard; when unavailable, select the text manually. Clipboard permissions and secure-context rules depend on the host. There are no attachments, speech, command templates, streaming, provider SDKs, model picker, durable conversations or automatic moderation.

### Session API and integration
NgPromptSession exposes read-only Responses/responses, Selected/selected, IsBusy/isBusy, Error/error and Status/status. RunAsync/run invokes a handler; Cancel/cancel invalidates pending work; Select/select changes selection; Clear/clear resets history; Dispose/dispose ends the session. Blazor Changed and Flutter ChangeNotifier report state changes. Use it on the UI thread, dispose it in its owner, and do not mutate response collections. The component owns its own session; use the public session only when building a separate custom interface. Native mobile and full accessibility certification remain separate.

## Blazor example

```razor
<NgAIPrompt Label="Assistant" @bind-Value="prompt" Generate="Generate"
    Suggestions="suggestions" OnCompleted="Completed" OnFeedback="Feedback"/>
<p>@status</p>
@code {
 private string prompt="Draft a meeting agenda",status="";
 private string[] suggestions=["Draft a meeting agenda","Suggest next steps"];
 private async Task<string> Generate(string text,CancellationToken cancellation) {
  await Task.Delay(600,cancellation);
  return $"Local example response to: {text}"; // Connect your application service here.
 }
 private void Completed(NgPromptResponse response){status=$"Response {response.Id} ready";}
 private void Feedback(NgPromptFeedback feedback){status=$"Response feedback {feedback.Response.Id}: {feedback.Helpful}";}
}
```

## Flutter example

```dart
String prompt = 'Draft a meeting agenda', status = '';
Future<String> generate(String text, NgPromptCancellation cancellation) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  cancellation.throwIfCancelled();
  return 'Local example response to: $text'; // Replace with your application service.
}
Widget build(BuildContext context) => NgAIPrompt(label: 'Assistant', value: prompt,
  onChanged: (v) => setState(() => prompt = v), generate: generate,
  suggestions: const ['Draft a meeting agenda', 'Suggest next steps'],
  onCompleted: (r) => setState(() => status = 'Response ${r.id} ready'),
  onFeedback: (f) => setState(() => status = 'Response feedback ${f.response.id}: ${f.helpful}'));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "AI prompt" | Visible label or accessible name. |
| `Value` | `string` | "" | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<string>` | not set | New value for the parent to store and pass back. |
| `Suggestions` | `IReadOnlyList<string>` | Array.Empty<string>() | See the behavior rules and model contract above. |
| `Generate` | `Func<string,CancellationToken,Task<string>>?` | not set | Application-owned async response handler; provider credentials belong on the backend. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `OnCompleted` | `EventCallback<NgPromptResponse>` | not set | Accepted successful response callback; not called for failed/cancelled requests. |
| `OnFeedback` | `EventCallback<NgPromptFeedback>` | not set | Response and helpful/not-helpful/cleared vote. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `String` | Current value; see state ownership and model rules above. |
| `suggestions` | `List<String>` | See the behavior rules and model contract above. |
| `generate` | `NgPromptGenerator?` | Application-owned async response handler; provider credentials belong on the backend. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `onChanged` | `ValueChanged<String>?` | Store the new value using setState or your state manager. |
| `onCompleted` | `ValueChanged<NgPromptResponse>?` | Accepted successful response callback; not called for failed/cancelled requests. |
| `onFeedback` | `ValueChanged<NgPromptFeedback>?` | Response and helpful/not-helpful/cleared vote. |

```dart
const NgAIPrompt({
    super.key,
    this.label = 'AI prompt',
    this.value = '',
    this.suggestions = const [],
    this.generate,
    this.readOnly = false,
    this.onChanged,
    this.onCompleted,
    this.onFeedback,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgAIPrompt.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/prompt.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
