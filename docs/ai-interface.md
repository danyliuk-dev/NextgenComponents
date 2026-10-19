# AI interface 0.45.0

Original Web-first implementation for Blazor and Flutter. This is a UI and state-management subset, not an AI service or Telerik API-compatible implementation.

| Capability | Both Web implementations |
|---|---|
| NgPromptBox | Multiline draft, trimmed submission, recoverable UTF-16 length validation, busy/cancel and read-only states |
| NgAIPrompt | Up to 8 suggestions, asynchronous application handler, error/retry, cancel, regeneration |
| Response history | Last 20 responses, selection, clear, monotonic IDs |
| Output | Plain text, copy, helpful/not-helpful/cleared feedback callbacks |
| Cancellation | Immediate UI release; late results cannot replace newer state, even if the handler ignores cancellation |
| Themes/layout | Shared light/dark tokens; stacked layout below 760 px |

Each request is limited to 8,000 UTF-16 code units and each response to 32,000. Empty or oversized responses become recoverable errors. Provider exceptions are not exposed to users. Previous successful responses remain available after an error. Clearing, disposing, switching to read-only or removing the handler cancels pending work. History lives only in the component session.

Application code owns provider calls, authentication, transport cancellation, persistence and billing. Blazor handlers receive CancellationToken; Flutter handlers receive NgPromptCancellation with isCancelled, whenCancelled and throwIfCancelled. Merely cancelling the UI does not guarantee that a remote provider stops billing. Put provider secrets on your backend. The demos use deterministic delayed local handlers; no AI provider is connected.

Not implemented: streaming, Markdown/rich output, file attachments, speech input, command templates, model selection, built-in provider SDKs, durable conversations, Inline AI Prompt, LLM Kit or SmartPasteButton. Native Flutter platforms remain separately unverified.

## Reference audit

Reviewed the public [Telerik PromptBox overview](https://www.telerik.com/blazor-ui/documentation/components/promptbox/overview) and [AI Prompt overview](https://www.telerik.com/blazor-ui/documentation/components/aiprompt/overview) on 2026-10-18. Their broader speech, attachments, command/template and integration options remain outside this release. No proprietary source was imported.

## Manuals and examples

- [NgPromptBox](manual/NgPromptBox.md): controlled input, submission, cancellation ownership and examples on both platforms.
- [NgAIPrompt](manual/NgAIPrompt.md): provider contract, history, feedback, failure recovery, cancellation and examples on both platforms.
- Blazor gallery: `/ai`; Flutter gallery: AI interface navigation.

## Permissions and drafts (0.45)

`GenerationReadOnly` / `generationReadOnly` disables editing, suggestions and generation actions, and cancels pending work. `HistoryReadOnly` / `historyReadOnly` prevents clearing history. `FeedbackReadOnly` / `feedbackReadOnly` prevents voting. Each defaults to false; global `ReadOnly` applies all three. History browsing and response copying remain available. A missing feedback handler disables voting; a missing provider disables suggestions and composition. These UI permissions do not replace backend authorization.

Handlers recheck current permissions and component lifetime. Feedback and regeneration require the captured response still to be selected. Removed suggestions and removed history entries cannot act through retained callbacks. The live manual demonstrates each lock independently, including cancellation during a request.

PromptBox accepts external values up to its absolute 8000 UTF-16-unit cap. If a draft exceeds the current MaxLength, it remains visible with a validation message and Send disabled. Decreasing an oversized draft is allowed before it reaches the limit; increasing it is rejected. Reducing MaxLength never silently truncates the draft. External value changes replace local text; unchanged parent values preserve local edits. Busy/read-only and missing-handler checks apply again when actions execute.
