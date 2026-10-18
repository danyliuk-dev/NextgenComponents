import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class StepsGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const StepsGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<StepsGallery> createState() => _StepsGalleryState();
}

class _StepsGalleryState extends State<StepsGallery> {
  bool rtl = false, block = false, custom = false;
  String position = 'top', mode = 'all', guardStatus = 'Ready';
  Future<bool> guard(NgWizardChange change) async {
    final denied = block, version = generation;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (mounted && version == generation)
      setState(
        () => guardStatus = denied
            ? 'Blocked'
            : '${change.current} → ${change.target}',
      );
    return !denied;
  }

  Widget customActions(BuildContext context, NgWizardActions a) => Wrap(
    spacing: 16,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      NgButton(
        onPressed: a.canBack ? a.back : null,
        child: const Text('Previous'),
      ),
      Text(
        a.busy
            ? 'Working…'
            : a.finished
            ? 'Application complete'
            : 'Custom action bar',
      ),
      if (!a.isLast)
        NgButton(
          primary: true,
          onPressed: a.canNext ? a.next : null,
          child: const Text('Continue'),
        )
      else if (!a.finished)
        NgButton(
          primary: true,
          onPressed: a.canFinish ? a.finish : null,
          child: const Text('Submit application'),
        ),
    ],
  );
  bool vertical = false, fail = false, updates = false;
  int current = 0, selected = 0, generation = 0, saved = 0;
  String name = '';
  static const steps = [
    NgStep('Contact'),
    NgStep('Business only', disabled: true),
    NgStep('Preferences', optional: true),
    NgStep('Review'),
  ];
  static const standalone = [
    NgStep('Draft', valid: true),
    NgStep('Details', valid: false),
    NgStep('Unavailable', disabled: true),
    NgStep('Publish'),
  ];
  Future<String?> validate(int index) async {
    final failed = fail, valid = name.trim().length >= 2;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (failed) throw StateError('Demo failure');
    return index == 0 && !valid
        ? 'Enter an applicant name (at least 2 characters).'
        : null;
  }

  Future<void> save() async {
    final version = generation;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted && version == generation) setState(() => saved++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('NEXTGEN COMPONENTS'),
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Foundation'),
                  ),
                  NgSwitch(
                    label: 'Dark theme',
                    value: widget.dark,
                    onChanged: widget.onDark,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'A clear path to completion.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'FLUTTER WEB / STEPS 0.28 · Step-by-step application with asynchronous validation. Demo saves locally only.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  NgCheckBox(
                    label: 'Vertical',
                    value: vertical,
                    onChanged: (v) => setState(() => vertical = v),
                  ),
                  NgCheckBox(
                    label: 'Simulate failure',
                    value: fail,
                    onChanged: (v) => setState(() => fail = v),
                  ),
                  NgCheckBox(
                    label: 'Right-to-left',
                    value: rtl,
                    onChanged: (v) => setState(() => rtl = v),
                  ),
                  NgCheckBox(
                    label: 'Block transitions',
                    value: block,
                    onChanged: (v) => setState(() => block = v),
                  ),
                  NgCheckBox(
                    label: 'Custom actions',
                    value: custom,
                    onChanged: (v) => setState(() => custom = v),
                  ),
                  NgButton(
                    onPressed: () => setState(() {
                      generation++;
                      guardStatus = 'Ready';
                      current = 0;
                      name = '';
                      updates = false;
                      saved = 0;
                    }),
                    child: const Text('Reset wizard'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      initialValue: position,
                      decoration: const InputDecoration(
                        labelText: 'Stepper position',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'top', child: Text('Top')),
                        DropdownMenuItem(
                          value: 'bottom',
                          child: Text('Bottom'),
                        ),
                        DropdownMenuItem(
                          value: 'start',
                          child: Text('Start side'),
                        ),
                        DropdownMenuItem(value: 'end', child: Text('End side')),
                      ],
                      onChanged: (v) => setState(() => position = v!),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      initialValue: mode,
                      decoration: const InputDecoration(
                        labelText: 'Step display',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Indicators and labels'),
                        ),
                        DropdownMenuItem(
                          value: 'labels',
                          child: Text('Labels only'),
                        ),
                        DropdownMenuItem(
                          value: 'indicators',
                          child: Text('Indicators only'),
                        ),
                      ],
                      onChanged: (v) => setState(() => mode = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              NgWizard(
                resetKey: generation,
                rtl: rtl,
                position: position,
                displayMode: mode,
                beforeChange: guard,
                backText: 'Previous',
                nextText: 'Continue',
                finishText: 'Submit application',
                actionsBuilder: custom ? customActions : null,
                indicatorBuilder: (_, step) => Icon(
                  step.index == 0
                      ? Icons.person_outline
                      : step.index == 3
                      ? Icons.check
                      : Icons.tune,
                  size: 20,
                ),
                labelBuilder: (_, step) => Text(
                  step.step.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                label: 'Application',
                items: steps,
                value: current,
                onChanged: (v) => setState(() => current = v),
                vertical: vertical,
                validateStep: validate,
                onFinish: save,
                contentBuilder: (context, index) {
                  if (index == 0)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Contact details'),
                        TextFormField(
                          key: ValueKey(generation),
                          initialValue: name,
                          decoration: const InputDecoration(
                            labelText: 'Applicant name',
                          ),
                          onChanged: (v) => name = v,
                        ),
                        const Text(
                          'Enter at least two characters. Next waits for validation.',
                        ),
                      ],
                    );
                  if (index == 2)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Preferences'),
                        NgCheckBox(
                          label: 'Email updates',
                          value: updates,
                          onChanged: (v) => setState(() => updates = v),
                        ),
                        const Text('This optional step can be left unchanged.'),
                      ],
                    );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Review application'),
                      Text('Applicant: $name'),
                      Text('Email updates: $updates'),
                    ],
                  );
                },
              ),
              Text('Saved: $saved · Guard: $guardStatus'),
              const Divider(height: 48),
              Text(
                'Standalone Stepper',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              NgStepper(
                items: standalone,
                rtl: rtl,
                displayMode: mode,
                indicatorBuilder: (_, step) =>
                    const Icon(Icons.star_outline, size: 20),
                labelBuilder: (_, step) => Text(
                  step.step.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                value: selected,
                vertical: vertical,
                onChanged: (v) => setState(() => selected = v),
              ),
              Text('Selected step: ${selected + 1}'),
              const SizedBox(height: 32),
              const Text('47 CONTROLS / 53 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
