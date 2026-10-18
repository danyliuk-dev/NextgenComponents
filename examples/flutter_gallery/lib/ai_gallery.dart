import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class AiGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const AiGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<AiGallery> createState() => _AiGalleryState();
}

class _AiGalleryState extends State<AiGallery> {
  bool readOnly = false, fail = false, ignoreCancellation = false;
  String prompt = 'Draft a welcome message',
      quick = '',
      quickStatus = 'none',
      feedback = 'none';
  int started = 0, completed = 0;
  Future<String> generate(
    String text,
    NgPromptCancellation cancellation,
  ) async {
    setState(() => started++);
    final error = fail, ignore = ignoreCancellation;
    await Future<void>.delayed(Duration(milliseconds: ignore ? 4000 : 1100));
    if (!ignore) cancellation.throwIfCancelled();
    if (error) throw StateError('Simulated provider failure');
    return 'Local demo response\n\nRequest: $text\n\n1. Clarify the intended audience.\n2. State the main idea in a short paragraph.\n3. Review the result before sharing.\n\nConnect your application handler to generate a real AI response.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'NEXTGEN COMPONENTS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            'From prompt to response.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'FLUTTER WEB / AI INTERFACE 0.10 · Local demonstration handler. No AI provider is connected and no prompts leave this app.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              NgCheckBox(
                label: 'Read only',
                value: readOnly,
                onChanged: (v) => setState(() => readOnly = v),
              ),
              NgCheckBox(
                label: 'Simulate error',
                value: fail,
                onChanged: (v) => setState(() => fail = v),
              ),
              NgCheckBox(
                label: 'Ignore cancellation (demo)',
                value: ignoreCancellation,
                onChanged: (v) => setState(() => ignoreCancellation = v),
              ),
              NgButton(
                onPressed: () =>
                    setState(() => prompt = 'External prompt replacement'),
                child: const Text('Replace prompt'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          NgAIPrompt(
            label: 'Writing assistant',
            value: prompt,
            onChanged: (v) => setState(() => prompt = v),
            generate: generate,
            readOnly: readOnly,
            suggestions: const [
              'Draft a welcome message',
              'Summarize the project goals',
              'Suggest three next steps',
            ],
            onCompleted: (_) => setState(() => completed++),
            onFeedback: (v) => setState(
              () => feedback =
                  'Response ${v.response.id}: ${v.helpful == null
                      ? 'cleared'
                      : v.helpful!
                      ? 'helpful'
                      : 'not helpful'}',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Started: $started · Completed: $completed · Feedback: $feedback',
          ),
          const Divider(height: 48),
          Text(
            'Standalone PromptBox',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          NgPromptBox(
            label: 'Standalone prompt',
            value: quick,
            onChanged: (v) => setState(() => quick = v),
            onSubmit: (text) => setState(() => quickStatus = text),
          ),
          const SizedBox(height: 12),
          Text('Submitted: $quickStatus'),
          const SizedBox(height: 32),
          const Text('39 CONTROLS / 45 CATALOGUE ENTRIES · WEB FIRST'),
        ],
      ),
    ),
  );
}
