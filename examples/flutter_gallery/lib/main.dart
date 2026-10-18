import 'package:flutter/material.dart';
import 'forms_gallery.dart';
import 'data_gallery.dart';
import 'analytics_gallery.dart';
import 'workbook_gallery.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() => runApp(const Gallery());

class Gallery extends StatefulWidget {
  const Gallery({super.key});
  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  bool dark = false,
      compact = false,
      forms = false,
      data = false,
      analytics = false,
      workbook = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Nextgen • Flutter',
    debugShowCheckedModeBanner: false,
    theme: NgTheme.light(compact: compact),
    darkTheme: NgTheme.dark(compact: compact),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: workbook
        ? WorkbookGallery(
            dark: dark,
            compact: compact,
            onDark: (v) => setState(() => dark = v),
            onCompact: (v) => setState(() => compact = v),
            onBack: () => setState(() => workbook = false),
          )
        : analytics
        ? AnalyticsGallery(
            dark: dark,
            compact: compact,
            onDark: (v) => setState(() => dark = v),
            onCompact: (v) => setState(() => compact = v),
            onBack: () => setState(() => analytics = false),
          )
        : data
        ? DataGallery(
            dark: dark,
            compact: compact,
            onDark: (v) => setState(() => dark = v),
            onCompact: (v) => setState(() => compact = v),
            onBack: () => setState(() => data = false),
          )
        : forms
        ? FormsGallery(
            dark: dark,
            compact: compact,
            onDark: (v) => setState(() => dark = v),
            onCompact: (v) => setState(() => compact = v),
            onBack: () => setState(() => forms = false),
          )
        : GalleryPage(
            onForms: () => setState(() => forms = true),
            onData: () => setState(() => data = true),
            onAnalytics: () => setState(() => analytics = true),
            onWorkbook: () => setState(() => workbook = true),
            dark: dark,
            compact: compact,
            onDark: (v) => setState(() => dark = v),
            onCompact: (v) => setState(() => compact = v),
          ),
  );
}

class GalleryPage extends StatefulWidget {
  final bool dark, compact;
  final VoidCallback onForms, onData, onAnalytics, onWorkbook;
  final ValueChanged<bool> onDark, onCompact;
  const GalleryPage({
    super.key,
    required this.onForms,
    required this.onData,
    required this.onAnalytics,
    required this.onWorkbook,
    required this.dark,
    required this.compact,
    required this.onDark,
    required this.onCompact,
  });
  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final form = GlobalKey<FormState>();
  String name = 'Alex Morgan', team = 'design', access = 'editor';
  double? seats = 5;
  bool updates = true, active = true, notification = false;
  int tab = 0;
  static const teams = [
    NgOption('design', 'Design'),
    NgOption('engineering', 'Engineering'),
    NgOption('operations', 'Operations'),
  ];
  static const roles = [
    NgOption('viewer', 'Viewer'),
    NgOption('editor', 'Editor'),
    NgOption('admin', 'Administrator'),
  ];
  Widget panel(String title, Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: .4),
      ),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        child,
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 36,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'N / NEXTGEN COMPONENTS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onWorkbook,
                      child: const Text('Workbook'),
                    ),
                    TextButton(
                      onPressed: widget.onAnalytics,
                      child: const Text('Analytics and schedule'),
                    ),
                    TextButton(
                      onPressed: widget.onData,
                      child: const Text('Data workspace'),
                    ),
                    TextButton(
                      onPressed: widget.onForms,
                      child: const Text('Forms and dates'),
                    ),
                    NgSwitch(
                      label: 'Dark theme',
                      value: widget.dark,
                      onChanged: widget.onDark,
                    ),
                    NgCheckBox(
                      label: 'Compact',
                      value: widget.compact,
                      onChanged: widget.onCompact,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'FLUTTER / FOUNDATION 0.1',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A consistent interface.\nOn every platform.',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Explore the first collection of Nextgen controls. Edit the form, switch themes, and try the interactions.',
                ),
                const SizedBox(height: 32),
                if (notification)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: NgNotification(
                      message: 'Workspace settings saved for $name.',
                      onDismiss: () => setState(() => notification = false),
                    ),
                  ),
                panel(
                  'Workspace settings',
                  Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) => Wrap(
                            spacing: 20,
                            runSpacing: 24,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth > 650
                                    ? (constraints.maxWidth - 20) / 2
                                    : constraints.maxWidth,
                                child: NgTextBox(
                                  label: 'Display name',
                                  initialValue: name,
                                  onChanged: (v) => name = v,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Display name is required'
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth > 650
                                    ? (constraints.maxWidth - 20) / 2
                                    : constraints.maxWidth,
                                child: NgDropDownList(
                                  label: 'Team',
                                  value: team,
                                  items: teams,
                                  onChanged: (v) => setState(() => team = v!),
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth > 650
                                    ? (constraints.maxWidth - 20) / 2
                                    : constraints.maxWidth,
                                child: NgNumericTextBox(
                                  label: 'Seats (1–100)',
                                  value: seats,
                                  min: 1,
                                  max: 100,
                                  onChanged: (v) => setState(() => seats = v),
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth > 650
                                    ? (constraints.maxWidth - 20) / 2
                                    : constraints.maxWidth,
                                child: const NgTextBox(
                                  label: 'Workspace ID',
                                  initialValue: 'NG-2026-001',
                                  enabled: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        NgRadioGroup(
                          label: 'Access level',
                          value: access,
                          items: roles,
                          onChanged: (v) => setState(() => access = v!),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 24,
                          children: [
                            NgCheckBox(
                              label: 'Email updates',
                              value: updates,
                              onChanged: (v) => setState(() => updates = v),
                            ),
                            NgSwitch(
                              label: 'Workspace active',
                              value: active,
                              onChanged: (v) => setState(() => active = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            NgButton(
                              primary: true,
                              onPressed: () {
                                if (form.currentState!.validate())
                                  setState(() => notification = true);
                              },
                              child: const Text('Save settings'),
                            ),
                            NgButton(
                              onPressed: () => NgDialog.show(
                                context,
                                title: 'Workspace preview',
                                child: Text(
                                  '$name\nTeam: $team\nSeats: ${seats ?? 0}\nAccess: $access',
                                ),
                                actions: [
                                  NgButton(
                                    primary: true,
                                    onPressed: () => Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(),
                                    child: const Text('Done'),
                                  ),
                                ],
                              ),
                              child: const Text('Open dialog'),
                            ),
                            const NgButton(child: Text('Disabled')),
                            const NgTooltip(
                              text: 'Changes apply to this demo only',
                              child: IconButton(
                                onPressed: null,
                                icon: Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                panel(
                  'Explore the collection',
                  NgTabs(
                    selectedIndex: tab,
                    onChanged: (v) => setState(() => tab = v),
                    items: const [
                      NgTab(
                        'Overview',
                        Text(
                          '11 foundation controls. Shared colors, dimensions, light and dark themes.',
                        ),
                      ),
                      NgTab(
                        'Keyboard',
                        Text(
                          'Use Tab to move between controls. Space toggles checkboxes. Escape closes dialogs.',
                        ),
                      ),
                      NgTab(
                        'Roadmap',
                        Text(
                          'Next: calendars and forms, data grids and trees, charts and scheduling, document tools.',
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'NEXTGEN COMPONENTS     /     Blazor + Flutter',
                  style: TextStyle(fontSize: 12, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
