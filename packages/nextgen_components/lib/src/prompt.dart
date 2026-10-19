import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components.dart';

class NgPromptResponse {
  final int id;
  final String prompt, text;
  const NgPromptResponse(this.id, this.prompt, this.text);
}

class NgPromptFeedback {
  final NgPromptResponse response;
  final bool? helpful;
  const NgPromptFeedback(this.response, this.helpful);
}

class NgPromptCancelled implements Exception {}

class NgPromptCancellation {
  final _signal = Completer<void>();
  bool get isCancelled => _signal.isCompleted;
  Future<void> get whenCancelled => _signal.future;
  void throwIfCancelled() {
    if (isCancelled) throw NgPromptCancelled();
  }

  void _cancel() {
    if (!isCancelled) _signal.complete();
  }
}

typedef NgPromptGenerator =
    Future<String> Function(String prompt, NgPromptCancellation cancellation);

/// Local UI session. Late completions cannot restore a cancelled/cleared request.
class NgPromptSession extends ChangeNotifier {
  static const maxPromptLength = 8000,
      maxResponseLength = 32000,
      historyLimit = 20;
  final List<NgPromptResponse> _responses = [];
  List<NgPromptResponse> get responses => List.unmodifiable(_responses);
  NgPromptResponse? _selected;
  bool _isBusy = false, _disposed = false;
  String? _error;
  String _status = 'Ready';
  NgPromptResponse? get selected => _selected;
  bool get isBusy => _isBusy;
  String? get error => _error;
  String get status => _status;
  int _revision = 0, _sequence = 0;
  NgPromptCancellation? _cancellation;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<NgPromptResponse?> run(
    String prompt,
    NgPromptGenerator generate,
  ) async {
    if (_disposed) throw StateError('Session disposed.');
    prompt = prompt.trim();
    if (prompt.isEmpty || prompt.length > maxPromptLength)
      throw ArgumentError('Prompt must contain 1–8000 characters.');
    if (_isBusy) return null;
    final version = ++_revision, cancellation = NgPromptCancellation();
    _cancellation = cancellation;
    _isBusy = true;
    _error = null;
    _status = 'Generating…';
    _notify();
    try {
      final text = await generate(prompt, cancellation);
      if (version != _revision || _disposed) return null;
      if (text.trim().isEmpty || text.length > maxResponseLength)
        throw ArgumentError('Invalid response.');
      final response = NgPromptResponse(++_sequence, prompt, text);
      _responses.add(response);
      if (_responses.length > historyLimit) _responses.removeAt(0);
      _selected = response;
      _status = 'Response ready.';
      return response;
    } on NgPromptCancelled {
      if (version == _revision && !_disposed) _status = 'Cancelled.';
      return null;
    } catch (_) {
      if (version == _revision && !_disposed) {
        _error = 'Generation failed. Try again.';
        _status = 'Request failed.';
      }
      return null;
    } finally {
      if (version == _revision && !_disposed) {
        _isBusy = false;
        _cancellation = null;
        _notify();
      }
    }
  }

  void cancel() {
    if (!_isBusy) return;
    _revision++;
    _cancellation?._cancel();
    _cancellation = null;
    _isBusy = false;
    _error = null;
    _status = 'Cancelled.';
    _notify();
  }

  void select(int id) {
    for (final item in _responses) {
      if (item.id == id) _selected = item;
    }
    _notify();
  }

  void clear() {
    cancel();
    _responses.clear();
    _selected = null;
    _error = null;
    _status = 'History cleared.';
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    cancel();
    super.dispose();
  }
}

class NgPromptBox extends StatefulWidget {
  final String label, value, placeholder;
  final int maxLength;
  final bool busy, readOnly;
  final ValueChanged<String>? onChanged, onSubmit;
  final VoidCallback? onCancel;
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
  @override
  State<NgPromptBox> createState() => _NgPromptBoxState();
}

class _NgPromptBoxState extends State<NgPromptBox> {
  late final controller = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant NgPromptBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != controller.text)
      controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.maxLength < 1 ||
        widget.maxLength > 8000 ||
        widget.value.length > 8000)
      throw ArgumentError(
        'Use maxLength 1–8000 and a value up to 8000 UTF-16 units.',
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          inputFormatters: [
            TextInputFormatter.withFunction(
              (oldValue, newValue) =>
                  (newValue.text.length <= widget.maxLength ||
                      newValue.text.length < oldValue.text.length)
                  ? newValue
                  : oldValue,
            ),
          ],
          readOnly: widget.readOnly || widget.busy,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.placeholder,
            counterText: '${controller.text.length} / ${widget.maxLength}',
          ),
          onChanged: (value) {
            if (!mounted || widget.readOnly || widget.busy) return;
            setState(() {});
            widget.onChanged?.call(value);
          },
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Enter adds a new line'),
            if (controller.text.length > widget.maxLength)
              Semantics(
                liveRegion: true,
                child: Text(
                  'Shorten the prompt to ${widget.maxLength} UTF-16 units before sending.',
                ),
              ),
            if (widget.busy)
              NgButton(
                onPressed: widget.onCancel == null
                    ? null
                    : () {
                        if (mounted && widget.busy) widget.onCancel?.call();
                      },
                child: const Text('Cancel'),
              )
            else
              NgButton(
                primary: true,
                onPressed:
                    widget.readOnly ||
                        controller.text.trim().isEmpty ||
                        controller.text.length > widget.maxLength ||
                        widget.onSubmit == null
                    ? null
                    : () {
                        if (mounted &&
                            !widget.readOnly &&
                            !widget.busy &&
                            controller.text.length <= widget.maxLength &&
                            controller.text.trim().isNotEmpty)
                          widget.onSubmit?.call(controller.text.trim());
                      },
                child: const Text('Send'),
              ),
          ],
        ),
      ],
    );
  }
}

class NgAIPrompt extends StatefulWidget {
  final String label, value;
  final List<String> suggestions;
  final NgPromptGenerator? generate;
  final bool readOnly, generationReadOnly, historyReadOnly, feedbackReadOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<NgPromptResponse>? onCompleted;
  final ValueChanged<NgPromptFeedback>? onFeedback;
  const NgAIPrompt({
    super.key,
    this.label = 'AI prompt',
    this.value = '',
    this.suggestions = const [],
    this.generate,
    this.readOnly = false,
    this.generationReadOnly = false,
    this.historyReadOnly = false,
    this.feedbackReadOnly = false,
    this.onChanged,
    this.onCompleted,
    this.onFeedback,
  });
  @override
  State<NgAIPrompt> createState() => _NgAIPromptState();
}

class _NgAIPromptState extends State<NgAIPrompt> {
  bool get generationLocked => widget.readOnly || widget.generationReadOnly;
  final session = NgPromptSession();
  final Map<int, bool?> votes = {};
  late String draft = widget.value;
  String lastPrompt = '';
  String? notice;
  @override
  void initState() {
    super.initState();
    session.addListener(changed);
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant NgAIPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) draft = widget.value;
    if (generationLocked || widget.generate == null) session.cancel();
  }

  @override
  void dispose() {
    session.removeListener(changed);
    session.dispose();
    super.dispose();
  }

  void edit(String value) {
    if (!mounted ||
        generationLocked ||
        session.isBusy ||
        widget.generate == null ||
        value.length > 8000)
      return;
    setState(() {
      draft = value;
      notice = null;
    });
    widget.onChanged?.call(value);
  }

  Future<void> run(String prompt) async {
    if (!mounted ||
        generationLocked ||
        session.isBusy ||
        widget.generate == null ||
        prompt.trim().isEmpty ||
        prompt.length > 8000)
      return;
    lastPrompt = prompt;
    notice = null;
    final result = await session.run(prompt, widget.generate!);
    if (result != null && mounted) {
      votes.removeWhere((id, _) => !session.responses.any((r) => r.id == id));
      widget.onCompleted?.call(result);
    }
  }

  void feedback(NgPromptResponse response, bool helpful) {
    if (!mounted ||
        widget.readOnly ||
        widget.feedbackReadOnly ||
        widget.onFeedback == null ||
        !identical(session.selected, response))
      return;
    final vote = votes[response.id] == helpful ? null : helpful;
    setState(() => votes[response.id] = vote);
    widget.onFeedback?.call(NgPromptFeedback(response, vote));
  }

  Future<void> copy(String text) async {
    if (!mounted) return;
    String message;
    try {
      await Clipboard.setData(ClipboardData(text: text));
      message = 'Response copied.';
    } catch (_) {
      message = 'Copy unavailable. Select the response text to copy it.';
    }
    if (mounted) setState(() => notice = message);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value.length > 8000 ||
        widget.suggestions.length > 8 ||
        widget.suggestions.any((s) => s.trim().isEmpty || s.length > 200))
      throw ArgumentError(
        'Use up to 8 suggestions (1–200 characters) and a prompt up to 8000 characters.',
      );
    final response = session.selected;
    final compose = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NgPromptBox(
          value: draft,
          onChanged: edit,
          busy: session.isBusy,
          readOnly: generationLocked || widget.generate == null,
          onSubmit: run,
          onCancel: () {
            if (!mounted || !session.isBusy) return;
            notice = null;
            session.cancel();
          },
        ),
        if (widget.generate == null)
          const Text('Connect a generation handler to enable requests.'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in widget.suggestions)
              NgButton(
                onPressed:
                    generationLocked ||
                        session.isBusy ||
                        widget.generate == null
                    ? null
                    : () {
                        if (widget.suggestions.contains(suggestion))
                          edit(suggestion);
                      },
                child: Text(suggestion),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(liveRegion: true, child: Text(notice ?? session.status)),
        if (session.error != null) ...[
          Text(
            session.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          NgButton(
            onPressed:
                generationLocked || session.isBusy || widget.generate == null
                ? null
                : () => run(lastPrompt),
            child: const Text('Retry request'),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('History (${session.responses.length} / 20)'),
            NgButton(
              onPressed:
                  widget.readOnly ||
                      widget.historyReadOnly ||
                      session.isBusy ||
                      session.responses.isEmpty
                  ? null
                  : () {
                      if (!mounted ||
                          widget.readOnly ||
                          widget.historyReadOnly ||
                          session.isBusy)
                        return;
                      notice = null;
                      votes.clear();
                      session.clear();
                    },
              child: const Text('Clear history'),
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in session.responses.reversed)
                  Semantics(
                    selected: response?.id == item.id,
                    child: TextButton(
                      onPressed: () {
                        if (!mounted || !session.responses.contains(item))
                          return;
                        notice = null;
                        session.select(item.id);
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${item.id}. ${item.prompt}'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    final output = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (response == null)
            const Text(
              'No responses yet. Enter a prompt or choose a suggestion.',
            )
          else ...[
            Text(
              'Response ${response.id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(response.prompt),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: SelectableText(response.text),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NgButton(
                  onPressed: () => copy(response.text),
                  child: const Text('Copy response'),
                ),
                NgButton(
                  onPressed:
                      generationLocked ||
                          session.isBusy ||
                          widget.generate == null
                      ? null
                      : () {
                          if (identical(session.selected, response))
                            run(response.prompt);
                        },
                  child: const Text('Regenerate'),
                ),
                for (final helpful in [true, false])
                  Semantics(
                    selected: votes[response.id] == helpful,
                    child: NgButton(
                      primary: votes[response.id] == helpful,
                      onPressed:
                          widget.readOnly ||
                              widget.feedbackReadOnly ||
                              widget.onFeedback == null
                          ? null
                          : () => feedback(response, helpful),
                      child: Text(helpful ? 'Helpful' : 'Not helpful'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, size) => size.maxWidth < 760
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [compose, const SizedBox(height: 20), output],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: compose),
                    const SizedBox(width: 24),
                    Expanded(child: output),
                  ],
                ),
        ),
      ],
    );
  }
}
