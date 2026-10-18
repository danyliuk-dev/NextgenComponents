import 'package:flutter/material.dart';
import 'components.dart';

class NgStep {
  final String label;
  final bool disabled, optional;
  final bool? valid;
  const NgStep(
    this.label, {
    this.disabled = false,
    this.optional = false,
    this.valid,
  });
}

class NgStepRules {
  static void validate(List<NgStep> items, int value) {
    if (items.isEmpty ||
        items.length > 30 ||
        items.any((s) => s.label.trim().isEmpty || s.label.length > 120)) {
      throw ArgumentError('Use 1–30 steps with labels of 1–120 characters.');
    }
    if (value < 0 || value >= items.length || items[value].disabled) {
      throw ArgumentError('Value must identify an enabled step.');
    }
  }

  static int adjacent(List<NgStep> items, int value, int direction) {
    if (direction != -1 && direction != 1) {
      throw ArgumentError("Direction must be -1 or 1");
    }
    for (
      var i = value + direction;
      i >= 0 && i < items.length;
      i += direction
    ) {
      if (!items[i].disabled) return i;
    }
    return -1;
  }

  static bool canMove(List<NgStep> items, int value, int target, bool linear) =>
      target >= 0 &&
      target < items.length &&
      !items[target].disabled &&
      target != value &&
      (!linear || target < value || target == adjacent(items, value, 1));
}

class NgStepper extends StatelessWidget {
  final String label;
  final List<NgStep> items;
  final int value;
  final ValueChanged<int>? onChanged;
  final bool linear, vertical, disabled;
  const NgStepper({
    super.key,
    this.label = 'Progress',
    required this.items,
    this.value = 0,
    this.onChanged,
    this.linear = false,
    this.vertical = false,
    this.disabled = false,
  });
  @override
  Widget build(BuildContext context) {
    NgStepRules.validate(items, value);
    final color = Theme.of(context).colorScheme;
    final buttons = List<Widget>.generate(items.length, (i) {
      final step = items[i];
      return Semantics(
        selected: i == value,
        child: OutlinedButton(
          onPressed:
              disabled ||
                  step.disabled ||
                  onChanged == null ||
                  (i != value && !NgStepRules.canMove(items, value, i, linear))
              ? null
              : () {
                  if (i != value) onChanged!(i);
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            side: BorderSide(
              color: i == value ? color.primary : color.outline,
              width: i == value ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.valid == false
                    ? '!'
                    : step.valid == true
                    ? '✓'
                    : '${i + 1}',
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.label),
                    if (step.optional) const Text('Optional'),
                    if (step.valid != null)
                      Text(step.valid! ? 'Valid' : 'Needs attention'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
    return Semantics(
      label: label,
      container: true,
      child: vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final b in buttons)
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: b),
              ],
            )
          : Wrap(spacing: 12, runSpacing: 12, children: buttons),
    );
  }
}

class NgWizard extends StatefulWidget {
  final String label;
  final List<NgStep> items;
  final int value;
  final ValueChanged<int>? onChanged;
  final bool linear, vertical, disabled;
  final Future<String?> Function(int)? validateStep;
  final Future<void> Function()? onFinish;
  final Widget Function(BuildContext, int) contentBuilder;
  const NgWizard({
    super.key,
    this.label = 'Wizard',
    required this.items,
    this.value = 0,
    this.onChanged,
    this.linear = true,
    this.vertical = false,
    this.disabled = false,
    this.validateStep,
    this.onFinish,
    required this.contentBuilder,
  });
  @override
  State<NgWizard> createState() => _NgWizardState();
}

class _NgWizardState extends State<NgWizard> {
  bool busy = false, finished = false;
  String? error;
  int revision = 0;
  int get previous => NgStepRules.adjacent(widget.items, widget.value, -1);
  int get next => NgStepRules.adjacent(widget.items, widget.value, 1);
  @override
  void didUpdateWidget(covariant NgWizard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.disabled != widget.disabled ||
        !same(oldWidget.items, widget.items)) {
      revision++;
      busy = false;
      finished = false;
      error = null;
    }
  }

  bool same(List<NgStep> a, List<NgStep> b) =>
      a.length == b.length &&
      List.generate(
        a.length,
        (i) =>
            a[i].label == b[i].label &&
            a[i].disabled == b[i].disabled &&
            a[i].optional == b[i].optional &&
            a[i].valid == b[i].valid,
      ).every((v) => v);
  Future<void> move(int target) async {
    if (NgStepRules.canMove(widget.items, widget.value, target, widget.linear))
      await act(target, false);
  }

  Future<void> act(int target, bool finish) async {
    if (widget.disabled || busy || finished) return;
    final version = ++revision, source = widget.value;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if ((target > source || finish) && widget.validateStep != null) {
        final message = await widget.validateStep!(source);
        if (!mounted || version != revision) return;
        if (message != null && message.isNotEmpty) {
          setState(() => error = message);
          return;
        }
      }
      if (!mounted || version != revision) return;
      if (finish) {
        await widget.onFinish!();
        if (mounted && version == revision) setState(() => finished = true);
      } else {
        widget.onChanged?.call(target);
      }
    } catch (_) {
      if (mounted && version == revision)
        setState(() => error = 'Unable to complete this action. Try again.');
    } finally {
      if (mounted && version == revision) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    revision++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NgStepRules.validate(widget.items, widget.value);
    return Semantics(
      label: widget.label,
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NgStepper(
            label: widget.label,
            items: widget.items,
            value: widget.value,
            linear: widget.linear,
            vertical: widget.vertical,
            disabled: widget.disabled || busy || finished,
            onChanged: move,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: KeyedSubtree(
              key: ValueKey(widget.value),
              child: widget.contentBuilder(context, widget.value),
            ),
          ),
          if (error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Semantics(
            liveRegion: true,
            child: Text(
              busy
                  ? 'Checking…'
                  : finished
                  ? 'Completed.'
                  : 'Step ${widget.value + 1} of ${widget.items.length}',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NgButton(
                onPressed: widget.disabled || busy || finished || previous < 0
                    ? null
                    : () => move(previous),
                child: const Text('Back'),
              ),
              if (next >= 0)
                NgButton(
                  primary: true,
                  onPressed: widget.disabled || busy || finished
                      ? null
                      : () => move(next),
                  child: const Text('Next'),
                )
              else
                NgButton(
                  primary: true,
                  onPressed:
                      widget.disabled ||
                          busy ||
                          finished ||
                          widget.onFinish == null
                      ? null
                      : () => act(widget.value, true),
                  child: const Text('Finish'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
