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
                'FLUTTER WEB / STEPS 0.11 · Step-by-step application with asynchronous validation. Demo saves locally only.',
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
                  NgButton(
                    onPressed: () => setState(() {
                      generation++;
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
              NgWizard(
                key: ValueKey(generation),
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
              Text('Saved: $saved'),
              const Divider(height: 48),
              Text(
                'Standalone Stepper',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              NgStepper(
                items: standalone,
                value: selected,
                vertical: vertical,
                onChanged: (v) => setState(() => selected = v),
              ),
              Text('Selected step: ${selected + 1}'),
              const SizedBox(height: 32),
              const Text('41 CONTROLS / 47 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
