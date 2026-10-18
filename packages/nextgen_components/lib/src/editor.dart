import 'dart:convert';
import 'package:flutter/material.dart';
import 'components.dart';

enum NgBlockKind { paragraph, heading1, heading2, bullet, numbered, quote }

enum NgTextAlign { left, center, right }

class NgDocumentBlock {
  final String text;
  final NgBlockKind kind;
  final bool bold, italic, underline;
  final NgTextAlign align;
  const NgDocumentBlock({
    this.text = '',
    this.kind = NgBlockKind.paragraph,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.align = NgTextAlign.left,
  });
  NgDocumentBlock copyWith({
    String? text,
    NgBlockKind? kind,
    bool? bold,
    bool? italic,
    bool? underline,
    NgTextAlign? align,
  }) => NgDocumentBlock(
    text: text ?? this.text,
    kind: kind ?? this.kind,
    bold: bold ?? this.bold,
    italic: italic ?? this.italic,
    underline: underline ?? this.underline,
    align: align ?? this.align,
  );
  Map<String, Object> toMap() => {
    'text': text,
    'kind': kind.name,
    'bold': bold,
    'italic': italic,
    'underline': underline,
    'align': align.name,
  };
}

class NgDocument {
  final List<NgDocumentBlock> blocks;
  NgDocument({List<NgDocumentBlock>? blocks})
    : blocks = List.unmodifiable(
        (blocks ?? [const NgDocumentBlock()]).map(
          (b) => b.copyWith(
            text: b.text.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
          ),
        ),
      ) {
    if (this.blocks.isEmpty || this.blocks.length > 100)
      throw ArgumentError('Use 1–100 blocks.');
    if (this.blocks.any((b) => b.text.length > 10000))
      throw ArgumentError('Text exceeds 10000 characters.');
    if (characterCount > 100000)
      throw ArgumentError('Document exceeds 100000 characters.');
  }
  int get characterCount => blocks.fold(0, (n, b) => n + b.text.length);
  NgDocument replace(int index, NgDocumentBlock block) {
    final copy = blocks.toList();
    copy[index] = block;
    return NgDocument(blocks: copy);
  }

  NgDocument insertAfter(int index) {
    _index(index);
    final copy = blocks.toList()..insert(index + 1, const NgDocumentBlock());
    return NgDocument(blocks: copy);
  }

  NgDocument remove(int index) {
    final copy = blocks.toList()..removeAt(index);
    return NgDocument(blocks: copy.isEmpty ? null : copy);
  }

  NgDocument move(int index, int target) {
    _index(index);
    _index(target);
    final copy = blocks.toList();
    final b = copy.removeAt(index);
    copy.insert(target, b);
    return NgDocument(blocks: copy);
  }

  void _index(int index) {
    RangeError.checkValidIndex(index, blocks);
  }

  String toJson() => const JsonEncoder.withIndent(
    '  ',
  ).convert({'version': 1, 'blocks': blocks.map((b) => b.toMap()).toList()});
  static NgDocument fromJson(String json) {
    if (json.length > 1000000)
      throw ArgumentError('JSON exceeds 1000000 characters.');
    try {
      final data = jsonDecode(json);
      if (data is! Map<String, dynamic> ||
          data['version'] is! int ||
          data['version'] != 1 ||
          data['blocks'] is! List ||
          data.keys.any((k) => !['version', 'blocks'].contains(k)))
        throw const FormatException();
      final blocks = (data['blocks'] as List).map((b) {
        if (b is! Map<String, dynamic> ||
            b.keys.any(
              (k) => ![
                'text',
                'kind',
                'bold',
                'italic',
                'underline',
                'align',
              ].contains(k),
            ))
          throw const FormatException();
        return NgDocumentBlock(
          text: b.containsKey('text') ? b['text'] as String : '',
          kind: b.containsKey('kind')
              ? NgBlockKind.values.byName(b['kind'] as String)
              : NgBlockKind.paragraph,
          bold: b.containsKey('bold') ? b['bold'] as bool : false,
          italic: b.containsKey('italic') ? b['italic'] as bool : false,
          underline: b.containsKey('underline')
              ? b['underline'] as bool
              : false,
          align: b.containsKey('align')
              ? NgTextAlign.values.byName(b['align'] as String)
              : NgTextAlign.left,
        );
      }).toList();
      return NgDocument(blocks: blocks);
    } on Object {
      throw ArgumentError(
        'Invalid document JSON. Expected version 1 and valid blocks.',
      );
    }
  }

  String toHtml() {
    final html = StringBuffer();
    String? list;
    for (final b in blocks) {
      final next = b.kind == NgBlockKind.bullet
          ? 'ul'
          : b.kind == NgBlockKind.numbered
          ? 'ol'
          : null;
      if (next != list) {
        if (list != null) html.write('</$list>');
        if (next != null) html.write('<$next>');
        list = next;
      }
      final tag = switch (b.kind) {
        NgBlockKind.heading1 => 'h1',
        NgBlockKind.heading2 => 'h2',
        NgBlockKind.quote => 'blockquote',
        NgBlockKind.bullet || NgBlockKind.numbered => 'li',
        _ => 'p',
      };
      var text = const HtmlEscape().convert(b.text).replaceAll('\n', '<br>');
      if (b.underline) text = '<u>$text</u>';
      if (b.italic) text = '<em>$text</em>';
      if (b.bold) text = '<strong>$text</strong>';
      html.write(
        '<$tag style="text-align:${b.align.name};white-space:pre-wrap">$text</$tag>',
      );
    }
    if (list != null) html.write('</$list>');
    return html.toString();
  }
}

class NgEditor extends StatefulWidget {
  final String label;
  final NgDocument value;
  final ValueChanged<NgDocument> onChanged;
  final bool readOnly;
  const NgEditor({
    super.key,
    this.label = 'Document editor',
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });
  @override
  State<NgEditor> createState() => _NgEditorState();
}

class _NgEditorState extends State<NgEditor> {
  late NgDocument current;
  late final TextEditingController controller;
  final List<NgDocument> undo = [], redo = [];
  int selected = 0;
  String message = '';
  bool get dirty => controller.text != current.blocks[selected].text;
  @override
  void initState() {
    super.initState();
    current = widget.value;
    controller = TextEditingController(text: current.blocks.first.text);
  }

  @override
  void didUpdateWidget(covariant NgEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.value, widget.value) &&
        !identical(current, widget.value)) {
      current = widget.value;
      selected = selected.clamp(0, current.blocks.length - 1);
      controller.text = current.blocks[selected].text;
      undo.clear();
      redo.clear();
      message = '';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  NgDocument draft(NgDocument doc) => doc.replace(
    selected,
    doc.blocks[selected].copyWith(text: controller.text),
  );
  bool commit(NgDocument Function(NgDocument) update, {int? select}) {
    if (widget.readOnly) return false;
    try {
      final next = update(current);
      if (next.toJson() == current.toJson()) return true;
      setState(() {
        undo.add(current);
        if (undo.length > 50) undo.removeAt(0);
        redo.clear();
        current = next;
        selected = (select ?? selected).clamp(0, current.blocks.length - 1);
        controller.text = current.blocks[selected].text;
        message = 'Document updated.';
      });
      widget.onChanged(current);
      return true;
    } on ArgumentError catch (e) {
      setState(() => message = e.message.toString());
      return false;
    }
  }

  void select(int index) {
    if (dirty && !widget.readOnly && !commit(draft)) return;
    setState(() {
      selected = index;
      controller.text = current.blocks[index].text;
    });
  }

  void history(bool forward) {
    if (widget.readOnly) return;
    final source = forward ? redo : undo, target = forward ? undo : redo;
    if (source.isEmpty) return;
    setState(() {
      target.add(current);
      current = source.removeLast();
      selected = selected.clamp(0, current.blocks.length - 1);
      controller.text = current.blocks[selected].text;
      message = forward ? 'Redone.' : 'Undone.';
    });
    widget.onChanged(current);
  }

  Widget toggle(
    String label,
    bool active,
    NgDocumentBlock Function(NgDocumentBlock) change,
  ) => Semantics(
    toggled: active,
    child: NgButton(
      onPressed: widget.readOnly
          ? null
          : () => commit(
              (d) => d.replace(
                selected,
                change(d.blocks[selected].copyWith(text: controller.text)),
              ),
            ),
      primary: active,
      child: Text(label),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final b = current.blocks[selected], ro = widget.readOnly;
    final outline = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(current.blocks.length, (i) {
            final block = current.blocks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Semantics(
                selected: selected == i,
                child: NgButton(
                  primary: selected == i,
                  onPressed: () => select(i),
                  child: Text(
                    '${i + 1}. ${block.kind.name}: ${block.text.isEmpty ? 'Empty' : block.text}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Block ${selected + 1} of ${current.blocks.length} · Formatting applies to the whole block.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<NgBlockKind>(
                isExpanded: true,
                key: ValueKey('kind-$selected-${b.kind}'),
                initialValue: b.kind,
                decoration: const InputDecoration(labelText: 'Block type'),
                items: NgBlockKind.values
                    .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                    .toList(),
                onChanged: ro
                    ? null
                    : (v) {
                        if (v != null)
                          commit(
                            (d) => draft(d).replace(
                              selected,
                              b.copyWith(text: controller.text, kind: v),
                            ),
                          );
                      },
              ),
            ),
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<NgTextAlign>(
                isExpanded: true,
                key: ValueKey('align-$selected-${b.align}'),
                initialValue: b.align,
                decoration: const InputDecoration(labelText: 'Alignment'),
                items: NgTextAlign.values
                    .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                    .toList(),
                onChanged: ro
                    ? null
                    : (v) {
                        if (v != null)
                          commit(
                            (d) => draft(d).replace(
                              selected,
                              b.copyWith(text: controller.text, align: v),
                            ),
                          );
                      },
              ),
            ),
            toggle('Bold', b.bold, (b) => b.copyWith(bold: !b.bold)),
            toggle('Italic', b.italic, (b) => b.copyWith(italic: !b.italic)),
            toggle(
              'Underline',
              b.underline,
              (b) => b.copyWith(underline: !b.underline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          readOnly: ro,
          maxLines: 5,
          maxLength: 10000,
          decoration: const InputDecoration(labelText: 'Block text'),
          onChanged: (_) => setState(() {}),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: NgButton(
            primary: true,
            onPressed: ro || !dirty ? null : () => commit(draft),
            child: const Text('Apply text'),
          ),
        ),
        const Text(
          'Apply text saves this block. Switching blocks or formatting also applies the draft.',
        ),
      ],
    );
    var number = 0;
    final preview = current.blocks.map((b) {
      number = b.kind == NgBlockKind.numbered ? number + 1 : 0;
      final prefix = b.kind == NgBlockKind.bullet
          ? '• '
          : b.kind == NgBlockKind.numbered
          ? '$number. '
          : b.kind == NgBlockKind.quote
          ? '│ '
          : '';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Semantics(
          header:
              b.kind == NgBlockKind.heading1 || b.kind == NgBlockKind.heading2,
          child: Text(
            '$prefix${b.text.isEmpty ? ' ' : b.text}',
            textAlign: switch (b.align) {
              NgTextAlign.left => TextAlign.left,
              NgTextAlign.center => TextAlign.center,
              NgTextAlign.right => TextAlign.right,
            },
            style: TextStyle(
              fontSize: b.kind == NgBlockKind.heading1
                  ? 28
                  : b.kind == NgBlockKind.heading2
                  ? 22
                  : 14,
              fontWeight:
                  b.bold ||
                      b.kind == NgBlockKind.heading1 ||
                      b.kind == NgBlockKind.heading2
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: b.italic ? FontStyle.italic : FontStyle.normal,
              decoration: b.underline
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            NgButton(
              onPressed: ro || undo.isEmpty ? null : () => history(false),
              child: const Text('Undo'),
            ),
            NgButton(
              onPressed: ro || redo.isEmpty ? null : () => history(true),
              child: const Text('Redo'),
            ),
            NgButton(
              onPressed: ro || current.blocks.length == 100
                  ? null
                  : () => commit(
                      (d) => draft(d).insertAfter(selected),
                      select: selected + 1,
                    ),
              child: const Text('Add block'),
            ),
            NgButton(
              onPressed: ro ? null : () => commit((d) => d.remove(selected)),
              child: const Text('Delete block'),
            ),
            NgButton(
              onPressed: ro || selected == 0
                  ? null
                  : () => commit(
                      (d) => draft(d).move(selected, selected - 1),
                      select: selected - 1,
                    ),
              child: const Text('Move up'),
            ),
            NgButton(
              onPressed: ro || selected == current.blocks.length - 1
                  ? null
                  : () => commit(
                      (d) => draft(d).move(selected, selected + 1),
                      select: selected + 1,
                    ),
              child: const Text('Move down'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth < 650
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [outline, const SizedBox(height: 12), controls],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 210, child: outline),
                    const SizedBox(width: 16),
                    Expanded(child: controls),
                  ],
                ),
        ),
        Semantics(liveRegion: true, child: Text(message)),
        Text(
          '${current.blocks.length} blocks · ${current.characterCount} characters · ${dirty ? 'Unapplied text' : 'Applied'}',
        ),
        const SizedBox(height: 12),
        Text(
          'Document preview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Container(
          key: const ValueKey('document-preview'),
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: preview,
          ),
        ),
      ],
    );
  }
}
