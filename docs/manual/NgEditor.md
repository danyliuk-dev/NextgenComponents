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

Changing selection/type/alignment/formatting, Add block and Move automatically applies the draft; one action creates one history entry. Add inserts a paragraph after the current block. Move preserves selection. Delete discards the selected draft; deleting the final block leaves one empty paragraph. Undo/Redo stores the last 50 applied operations and discards an unapplied draft.

### State and storage
Value is an immutable NgDocument. Save the new instance from ValueChanged/onChanged and pass it back. An independent replacement (import or another file) resets history and draft; do not manufacture an equivalent new instance on every render. ReadOnly preserves selection/preview but does not auto-save a pending draft. NgEditor is not an InputBase/FormField: the host validates document business rules.

ToJson/toJson produces the shared version-1 format. Restore with NgDocument.FromJson/fromJson, catch ArgumentException/ArgumentError and preserve the current document on failure. ToHtml/toHtml exports applied blocks only, escapes text, groups adjacent list items and converts newlines to br. It returns a fragment without theme/container. Store JSON as the editable source; HTML import is not supported. The component does not upload or write files. The Editor gallery demonstrates Save/Restore.

### Keyboard and limits
Tab navigates controls; Enter/Space activates buttons. The textarea uses ordinary multiline input. Document Undo/Redo buttons are separate from operating-system text-input undo; there are no custom Ctrl+Z/Ctrl+Y shortcuts.

Limits: 1–100 blocks, 10,000 UTF-16 units per block, 100,000 total, 1,000,000 units of input JSON. The model checks each operation. No nested lists, links, images, tables, font picker, selection formatting, HTML/Word import, PDF/print, collaboration, AI or virtualization. Native mobile and full screen-reader verification remain separate.

## Blazor example

```razor
<NgEditor Label="Project description" @bind-Value="document"/>
<NgButton OnClick="Save">Save JSON</NgButton>
<pre>@saved</pre>
@code {
    private NgDocument document = new([
        new("Project plan", NgBlockKind.Heading1),
        new("Agree on requirements", NgBlockKind.Bullet),
        new("Review the result", NgBlockKind.Bullet, Bold: true)
    ]);
    private string saved = "";
    private void Save() => saved = document.ToJson();
}
```

## Flutter example

```dart
NgDocument document = NgDocument(blocks: const [
  NgDocumentBlock(text: 'Project plan', kind: NgBlockKind.heading1),
  NgDocumentBlock(text: 'Agree on requirements', kind: NgBlockKind.bullet),
  NgDocumentBlock(text: 'Review the result', kind: NgBlockKind.bullet, bold: true),
]);
String saved = '';
Widget build(BuildContext context) => Column(children: [
  NgEditor(label: 'Project description', value: document,
    onChanged: (v) => setState(() => document = v)),
  NgButton(onPressed: () => setState(() => saved = document.toJson()),
    child: const Text('Save JSON')),
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
| `onChanged` | `ValueChanged<NgDocument>` | Store the new value using setState or your state manager. |
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |

```dart
const NgEditor({
    super.key,
    this.label = 'Document editor',
    required this.value,
    required this.onChanged,
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
