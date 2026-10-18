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

  static void validatePresentation(
    String label, [
    String displayMode = 'all',
    String position = 'top',
  ]) {
    if (label.trim().isEmpty || label.length > 120)
      throw ArgumentError('Use a nonempty label of at most 120 characters.');
    if (!['all', 'labels', 'indicators'].contains(displayMode))
      throw ArgumentError('Display mode must be all, labels or indicators.');
    if (!['top', 'bottom', 'start', 'end'].contains(position))
      throw ArgumentError('Position must be top, bottom, start or end.');
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

class NgStepContext {
  final NgStep step;
  final int index;
  final bool current;
  const NgStepContext(this.step, this.index, this.current);
}

class NgWizardChange {
  final int current, target;
  final bool isFinish;
  const NgWizardChange(this.current, this.target, this.isFinish);
}

class NgWizardActions {
  final int value;
  final bool busy, finished, isLast, canBack, canNext, canFinish;
  final Future<void> Function() back, next, finish;
  const NgWizardActions({
    required this.value,
    required this.busy,
    required this.finished,
    required this.isLast,
    required this.canBack,
    required this.canNext,
    required this.canFinish,
    required this.back,
    required this.next,
    required this.finish,
  });
}

class NgStepper extends StatelessWidget {
  final String label, displayMode;
  final List<NgStep> items;
  final int value;
  final ValueChanged<int>? onChanged;
  final bool linear, vertical, disabled, rtl;
  final Widget Function(BuildContext, NgStepContext)? indicatorBuilder,
      labelBuilder;
  const NgStepper({
    super.key,
    this.label = 'Progress',
    required this.items,
    this.value = 0,
    this.onChanged,
    this.linear = false,
    this.vertical = false,
    this.disabled = false,
    this.rtl = false,
    this.displayMode = 'all',
    this.indicatorBuilder,
    this.labelBuilder,
  });
  @override
  Widget build(BuildContext context) {
    NgStepRules.validate(items, value);
    NgStepRules.validatePresentation(label, displayMode);
    final color = Theme.of(context).colorScheme;
    final buttons = List<Widget>.generate(items.length, (i) {
      final step = items[i], data = NgStepContext(items[i], i, i == value);
      final name =
          'Step ${i + 1}: ${step.label}${step.optional ? ', Optional' : ''}${step.valid == null
              ? ''
              : step.valid!
              ? ', Valid'
              : ', Needs attention'}';
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
          child: Semantics(
            label: name,
            excludeSemantics: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (displayMode != 'labels')
                  indicatorBuilder?.call(context, data) ??
                      Text(
                        step.valid == false
                            ? '!'
                            : step.valid == true
                            ? '✓'
                            : '${i + 1}',
                      ),
                if (displayMode == 'all') const SizedBox(width: 10),
                if (displayMode != 'indicators')
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        labelBuilder?.call(context, data) ?? Text(step.label),
                        if (step.optional) const Text('Optional'),
                        if (step.valid != null)
                          Text(step.valid! ? 'Valid' : 'Needs attention'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Semantics(
        label: label,
        container: true,
        child: vertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final b in buttons)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: b,
                    ),
                ],
              )
            : Wrap(spacing: 12, runSpacing: 12, children: buttons),
      ),
    );
  }
}

class NgWizard extends StatefulWidget {
  final String label;
  final List<NgStep> items;
  final int value;
  final ValueChanged<int>? onChanged;
  final bool linear, vertical, disabled, rtl;
  final String position, displayMode, backText, nextText, finishText;
  final int resetKey;
  final Widget Function(BuildContext, NgStepContext)? indicatorBuilder,
      labelBuilder;
  final Widget Function(BuildContext, NgWizardActions)? actionsBuilder;
  final Future<bool> Function(NgWizardChange)? beforeChange;
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
    this.rtl = false,
    this.position = 'top',
    this.displayMode = 'all',
    this.resetKey = 0,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.finishText = 'Finish',
    this.indicatorBuilder,
    this.labelBuilder,
    this.actionsBuilder,
    this.beforeChange,
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
    if (oldWidget.resetKey != widget.resetKey ||
        oldWidget.linear != widget.linear ||
        oldWidget.value != widget.value ||
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
    if (widget.onChanged != null &&
        NgStepRules.canMove(widget.items, widget.value, target, widget.linear))
      await act(target, false);
  }

  Future<void> act(int target, bool finish) async {
    if (!mounted ||
        widget.disabled ||
        busy ||
        finished ||
        (finish && (next >= 0 || widget.onFinish == null)))
      return;
    final version = ++revision, source = widget.value;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (widget.beforeChange != null) {
        final accepted = await widget.beforeChange!(
          NgWizardChange(source, target, finish),
        );
        if (!mounted || version != revision || !accepted) return;
      }
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
    NgStepRules.validatePresentation(
      widget.label,
      widget.displayMode,
      widget.position,
    );
    for (final text in [widget.backText, widget.nextText, widget.finishText])
      NgStepRules.validatePresentation(text);
    final body = Semantics(
      label: widget.label,
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          if (widget.actionsBuilder != null)
            widget.actionsBuilder!(context, actions)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NgButton(
                  onPressed:
                      widget.disabled ||
                          busy ||
                          finished ||
                          widget.onChanged == null ||
                          previous < 0
                      ? null
                      : () => move(previous),
                  child: Text(widget.backText),
                ),
                if (next >= 0)
                  NgButton(
                    primary: true,
                    onPressed:
                        widget.disabled ||
                            busy ||
                            finished ||
                            widget.onChanged == null
                        ? null
                        : () => move(next),
                    child: Text(widget.nextText),
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
                    child: Text(widget.finishText),
                  ),
              ],
            ),
        ],
      ),
    );
    final side = widget.position == 'start' || widget.position == 'end';
    final rail = NgStepper(
      label: widget.label,
      items: widget.items,
      value: widget.value,
      linear: widget.linear,
      vertical: widget.vertical || side,
      disabled: widget.disabled || busy || finished || widget.onChanged == null,
      rtl: widget.rtl,
      displayMode: widget.displayMode,
      indicatorBuilder: widget.indicatorBuilder,
      labelBuilder: widget.labelBuilder,
      onChanged: move,
    );
    return Directionality(
      textDirection: widget.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, box) {
          if (side && box.maxWidth >= 600) {
            final panel = SizedBox(
              width: box.maxWidth * .3 > 240 ? 240 : box.maxWidth * .3,
              child: rail,
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.position == 'start') ...[
                  panel,
                  const SizedBox(width: 24),
                ],
                Expanded(child: body),
                if (widget.position == 'end') ...[
                  const SizedBox(width: 24),
                  panel,
                ],
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.position != 'bottom') ...[
                rail,
                const SizedBox(height: 12),
              ],
              body,
              if (widget.position == 'bottom') ...[
                const SizedBox(height: 12),
                rail,
              ],
            ],
          );
        },
      ),
    );
  }

  NgWizardActions get actions => NgWizardActions(
    value: widget.value,
    busy: busy,
    finished: finished,
    isLast: next < 0,
    canBack:
        !widget.disabled &&
        !busy &&
        !finished &&
        widget.onChanged != null &&
        previous >= 0,
    canNext:
        !widget.disabled &&
        !busy &&
        !finished &&
        widget.onChanged != null &&
        next >= 0,
    canFinish:
        !widget.disabled &&
        !busy &&
        !finished &&
        widget.onFinish != null &&
        next < 0,
    back: () => move(previous),
    next: () => move(next),
    finish: () => act(widget.value, true),
  );
}
