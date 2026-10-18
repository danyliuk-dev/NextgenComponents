import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

class NavigationGallery extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDark;
  final VoidCallback onBack;
  const NavigationGallery({
    super.key,
    required this.dark,
    required this.onDark,
    required this.onBack,
  });
  @override
  State<NavigationGallery> createState() => _NavigationGalleryState();
}

class _NavigationGalleryState extends State<NavigationGallery> {
  bool rtl = false,
      end = false,
      keepMenu = false,
      keepDrawer = false,
      hideReports = false,
      disableDrawer = false;
  bool vertical = false,
      disabled = false,
      empty = false,
      overlay = true,
      expanded = false;
  String command = 'none', section = 'overview';
  int invocations = 0, selections = 0;
  final note = TextEditingController();
  final destinations = const [
    NgOption('overview', 'Overview'),
    NgOption('requests', 'Requests'),
    NgOption('divider', 'Workspace sections'),
    NgOption('reports', 'Reports'),
    NgOption('settings', 'Settings (unavailable)', disabled: true),
  ];
  final commands = [
    NgMenuItem(
      'workspace',
      'Workspace',
      children: [
        NgMenuItem('create', 'Create request'),
        NgMenuItem(
          'export',
          'Export',
          children: [
            NgMenuItem('pdf', 'PDF document'),
            NgMenuItem('csv', 'CSV data'),
          ],
        ),
        NgMenuItem('menu-divider', 'Navigation section', separator: true),
        NgMenuItem('internal', 'Internal command', visible: false),
        NgMenuItem('go-reports', 'Open reports'),
        NgMenuItem('delete', 'Delete workspace', disabled: true),
      ],
    ),
    NgMenuItem(
      'locked',
      'Restricted',
      disabled: true,
      children: [NgMenuItem('secret', 'Restricted action')],
    ),
    NgMenuItem('help', 'Help'),
  ];
  @override
  void dispose() {
    note.dispose();
    super.dispose();
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
                'Every action. In its place.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'FLUTTER WEB / NAVIGATION 0.27 · Nested commands and an application drawer. The host owns routes, state and action handlers.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  NgCheckBox(
                    label: 'Vertical menu',
                    value: vertical,
                    onChanged: (v) => setState(() => vertical = v),
                  ),
                  NgCheckBox(
                    label: 'Disable menu',
                    value: disabled,
                    onChanged: (v) => setState(() => disabled = v),
                  ),
                  NgCheckBox(
                    label: 'Right-to-left',
                    value: rtl,
                    onChanged: (v) => setState(() => rtl = v),
                  ),
                  NgCheckBox(
                    label: 'Keep menu open',
                    value: keepMenu,
                    onChanged: (v) => setState(() => keepMenu = v),
                  ),
                  NgCheckBox(
                    label: 'Empty navigation',
                    value: empty,
                    onChanged: (v) => setState(() => empty = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NgMenu(
                label: 'Workspace commands',
                rtl: rtl,
                closeOnClick: !keepMenu,
                leadingBuilder: (_, i) =>
                    const Icon(Icons.description_outlined, size: 18),
                itemBuilder: (_, i) => Text(
                  i.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                items: empty ? [] : commands,
                selectedId: command,
                vertical: vertical,
                disabled: disabled,
                onInvoke: (id) => setState(() {
                  command = id;
                  invocations++;
                  if (id == 'go-reports') section = 'reports';
                }),
              ),
              Text('Command: $command · Invocations: $invocations'),
              const Divider(height: 48),
              Wrap(
                spacing: 12,
                children: [
                  NgCheckBox(
                    label: 'Overlay mode',
                    value: overlay,
                    onChanged: (v) => setState(() => overlay = v),
                  ),
                  NgCheckBox(
                    label: 'End position',
                    value: end,
                    onChanged: (v) => setState(() => end = v),
                  ),
                  NgCheckBox(
                    label: 'Keep drawer open',
                    value: keepDrawer,
                    onChanged: (v) => setState(() => keepDrawer = v),
                  ),
                  NgCheckBox(
                    label: 'Hide Reports',
                    value: hideReports,
                    onChanged: (v) => setState(() => hideReports = v),
                  ),
                  NgCheckBox(
                    label: 'Disable drawer',
                    value: disableDrawer,
                    onChanged: (v) => setState(() => disableDrawer = v),
                  ),
                  NgButton(
                    onPressed: () => setState(() => section = 'reports'),
                    child: const Text('Show reports'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NgDrawer(
                label: 'Workspace navigation',
                rtl: rtl,
                position: end ? 'end' : 'start',
                closeOnSelect: !keepDrawer,
                disabled: disableDrawer,
                isVisible: (i) => !hideReports || i.value != 'reports',
                isSeparator: (i) => i.value == 'divider',
                header: const Text('Project workspace'),
                footer: const Text('Signed in as Morgan'),
                leadingBuilder: (_, i) =>
                    const Icon(Icons.folder_outlined, size: 18),
                itemBuilder: (_, i) => Text(
                  i.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                items: empty ? [] : destinations,
                selectedId: section,
                onSelectedIdChanged: (id) => setState(() {
                  section = id;
                  selections++;
                }),
                expanded: expanded,
                onExpandedChanged: (v) => setState(() => expanded = v),
                overlay: overlay,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Current section: $section',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      'Navigate with the drawer or use Workspace → Open reports. Unavailable destinations stay disabled.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: note,
                      decoration: const InputDecoration(
                        labelText: 'Workspace note',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    Text('Selections: $selections · Note: ${note.text}'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('47 CONTROLS / 53 CATALOGUE ENTRIES · WEB FIRST'),
            ],
          ),
        ),
      ),
    ),
  );
}
