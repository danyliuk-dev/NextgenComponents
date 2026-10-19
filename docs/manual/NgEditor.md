# NgEditor — Structured document editor

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a small document as typed blocks with a separate preview.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgEditor) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgEditor)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Editing
Select a block, change Block text and press Apply text. Until applied, the local draft is not included in callbacks, preview or export. Block type supports paragraphs, level 1/2 headings, bullet/numbered items and quotes. Bold, Italic, Underline and Alignment apply to the entire block, not a selected text range.

Changing selection/type/alignment/formatting, Add block and Move automatically applies the draft; one accepted action creates one history entry. Add inserts a paragraph after the current block. Move preserves selection. Delete discards the selected draft; deleting the final block leaves one empty paragraph. Undo/Redo stores the last 50 accepted operations and discards an unapplied draft only when the history proposal is accepted.

### State and storage
Value is an immutable NgDocument controlled by the parent. ValueChanged/onChanged proposes a new instance: return that exact instance to accept the operation. Until accepted, the preview, export, selection and history retain the accepted document. Keeping the old Value rejects the proposal and retains the draft. Flutter hosts must rebuild after acceptance or rejection (as in this example). A different returned instance is an independent replacement, even if its JSON is equivalent. Accept or reject within the event-driven update; late asynchronous responses are parent-owned replacements and must be guarded by the host against newer documents. An independent replacement (import or another file) resets history and draft; do not manufacture an equivalent new instance on every render. ReadOnly or an absent callback disables edits and history while preserving block inspection. Switching blocks in this mode discards the unsaved draft without a callback. Discard draft restores the selected accepted text without changing the document or history, and is also available while read-only. Flutter presents read-only text explicitly instead of a disabled editor input. Captured actions from an earlier parent update, selection or disposed editor are ignored. NgEditor is not an InputBase/FormField: the host validates document business rules.

ToJson/toJson produces the shared version-1 format. Restore with NgDocument.FromJson/fromJson, catch ArgumentException/ArgumentError and preserve the current document on failure. ToHtml/toHtml exports applied blocks only, escapes text, groups adjacent list items and converts newlines to br. It returns a fragment without theme/container. Store JSON as the editable source; HTML import is not supported. The component does not upload or write files. The Editor gallery demonstrates Save/Restore.

### Keyboard and limits
Tab navigates controls; Enter/Space activates buttons. The textarea uses ordinary multiline input. Document Undo/Redo buttons are separate from operating-system text-input undo; there are no custom Ctrl+Z/Ctrl+Y shortcuts.

Limits: 1–100 blocks, 10,000 UTF-16 units per block, 100,000 total, 1,000,000 units of input JSON. The model checks each operation. No nested lists, links, images, tables, font picker, selection formatting, HTML/Word import, PDF/print, collaboration, AI or virtualization. Native mobile and full screen-reader verification remain separate.

## Blazor example

```razor
<div class="row">
<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>
<NgButton OnClick="()=>readOnly=!readOnly">Toggle read-only</NgButton>
<NgButton OnClick="Reset">Replace document</NgButton>
<NgButton OnClick="Save">Save JSON</NgButton>
</div>
<p>Acceptance: @(accept ? "enabled" : "rejected") · Accepted first block: @document.Blocks[0].Text</p>
<NgEditor Label="Project description" Value="document" ValueChanged="Change" ReadOnly="readOnly"/>
<pre>@saved</pre>
@code {
    private NgDocument document = Sample();
    private bool accept = true, readOnly;
    private string saved = "";
    private static NgDocument Sample() => new([
        new("Project plan", NgBlockKind.Heading1),
        new("Agree on requirements", NgBlockKind.Bullet),
        new("Review the result", NgBlockKind.Bullet, Bold: true)
    ]);
    private void Change(NgDocument next) { if(accept) document=next; }
    private void Reset() => document=new([new("Imported brief"),new("Review imported content")]);
    private void Save() => saved=document.ToJson();
}
```

## Flutter example

```dart
NgDocument document = NgDocument(blocks: const [
  NgDocumentBlock(text: 'Project plan', kind: NgBlockKind.heading1),
  NgDocumentBlock(text: 'Agree on requirements', kind: NgBlockKind.bullet),
  NgDocumentBlock(text: 'Review the result', kind: NgBlockKind.bullet, bold: true),
]);
bool accept = true, readOnly = false;
String saved = '';
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  Wrap(spacing: 8, runSpacing: 8, children: [
    NgButton(onPressed: () => setState(() => accept = !accept), child: const Text('Toggle acceptance')),
    NgButton(onPressed: () => setState(() => readOnly = !readOnly), child: const Text('Toggle read-only')),
    NgButton(onPressed: () => setState(() => document = NgDocument(blocks: const [NgDocumentBlock(text: 'Imported brief'), NgDocumentBlock(text: 'Review imported content')])), child: const Text('Replace document')),
    NgButton(onPressed: () => setState(() => saved = document.toJson()), child: const Text('Save JSON')),
  ]),
  Text('Acceptance: ${accept ? "enabled" : "rejected"} · Accepted first block: ${document.blocks.first.text}'),
  NgEditor(label: 'Project description', value: document, readOnly: readOnly,
    onChanged: (v) => setState(() { if (accept) document = v; })),
  Text(saved),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Document editor" | Visible label or accessible name. |
| `Value` | `NgDocument` | required | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<NgDocument>` | not set | New value for the parent to store and pass back. |
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgDocument` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<NgDocument>?` | Store the new value using setState or your state manager. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |

```dart
const NgEditor({
    super.key,
    this.label = 'Document editor',
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgEditor.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/editor.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
