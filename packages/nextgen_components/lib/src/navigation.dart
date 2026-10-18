import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components.dart';

class NgMenuItem {
  final String id, text;
  final bool disabled;
  final List<NgMenuItem> children;
  NgMenuItem(
    this.id,
    this.text, {
    this.disabled = false,
    List<NgMenuItem> children = const [],
  }) : children = List.unmodifiable(children);
}

abstract final class NgNavigationRules {
  static bool _id(String id) => RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(id);
  static bool _text(String text) =>
      text.trim().isNotEmpty && text.length <= 120;
  static void validateMenu(List<NgMenuItem> items) {
    final ids = <String>{};
    int count = 0;
    void walk(List<NgMenuItem> nodes, int depth) {
      if (depth > 3 && nodes.isNotEmpty)
        throw ArgumentError('Menus support at most three levels.');
      for (final n in nodes) {
        if (!_id(n.id) || !_text(n.text) || !ids.add(n.id) || ++count > 100)
          throw ArgumentError(
            'Use at most 100 unique IDs and nonempty labels.',
          );
        walk(n.children, depth + 1);
      }
    }

    walk(items, 1);
  }

  static bool canInvoke(List<NgMenuItem> items, String id) {
    for (final n in items) {
      if (n.disabled) continue;
      if (n.id == id) return n.children.isEmpty;
      if (canInvoke(n.children, id)) return true;
    }
    return false;
  }

  static void validateDrawer(List<NgOption> items, int width) {
    if (items.length > 100 || width < 200 || width > 400)
      throw ArgumentError('Use at most 100 items and width 200–400.');
    final ids = <String>{};
    for (final n in items) {
      if (!_id(n.value) || !_text(n.label) || !ids.add(n.value))
        throw ArgumentError(
          'Drawer items require unique IDs and nonempty labels.',
        );
    }
  }
}

class NgMenu extends StatelessWidget {
  final String label;
  final List<NgMenuItem> items;
  final String? selectedId;
  final ValueChanged<String>? onInvoke;
  final bool vertical, disabled;
  const NgMenu({
    super.key,
    this.label = 'Commands',
    required this.items,
    this.selectedId,
    this.onInvoke,
    this.vertical = false,
    this.disabled = false,
  });
  @override
  Widget build(BuildContext context) {
    NgNavigationRules.validateMenu(items);
    Widget entry(NgMenuItem item) {
      if (item.children.isNotEmpty)
        return SubmenuButton(
          menuChildren: disabled || item.disabled
              ? const []
              : item.children.map(entry).toList(),
          onOpen: null,
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surface,
            ),
          ),
          child: Text(item.text),
        );
      return Semantics(
        selected: selectedId == item.id,
        child: MenuItemButton(
          onPressed: disabled || item.disabled || onInvoke == null
              ? null
              : () => onInvoke!(item.id),
          trailingIcon: selectedId == item.id
              ? const Icon(Icons.check, size: 18)
              : null,
          child: Text(item.text),
        ),
      );
    }

    if (items.isEmpty)
      return Semantics(label: label, child: const Text('No commands'));
    return Semantics(
      label: label,
      container: true,
      explicitChildNodes: true,
      child: vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items.map(entry).toList(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: MenuBar(children: items.map(entry).toList()),
            ),
    );
  }
}

class NgDrawer extends StatefulWidget {
  final String label;
  final List<NgOption> items;
  final String? selectedId;
  final ValueChanged<String>? onSelectedIdChanged;
  final bool expanded, overlay;
  final ValueChanged<bool>? onExpandedChanged;
  final int width;
  final Widget child;
  const NgDrawer({
    super.key,
    this.label = 'Navigation',
    required this.items,
    this.selectedId,
    this.onSelectedIdChanged,
    this.expanded = false,
    this.onExpandedChanged,
    this.overlay = true,
    this.width = 260,
    required this.child,
  });
  @override
  State<NgDrawer> createState() => _NgDrawerState();
}

class _NgDrawerState extends State<NgDrawer> {
  RawDialogRoute<void>? route;
  NavigatorState? navigator;
  final update = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();
    schedule();
  }

  @override
  void didUpdateWidget(covariant NgDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    schedule();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    schedule();
  }

  void schedule() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) reconcile();
  });
  void close() => widget.onExpandedChanged?.call(false);
  void select(NgOption item) {
    if (item.disabled) return;
    widget.onSelectedIdChanged?.call(item.value);
    if (mounted && widget.overlay) close();
  }

  void reconcile() {
    final wanted =
        widget.expanded && widget.overlay && widget.onExpandedChanged != null;
    if (!wanted) {
      remove();
      return;
    }
    if (route != null) {
      update.value++;
      return;
    }
    navigator = Navigator.of(context, rootNavigator: true);
    final next = RawDialogRoute<void>(
      barrierDismissible: false,
      barrierColor: Colors.black54,
      requestFocus: true,
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      pageBuilder: (routeContext, animation, secondary) =>
          ValueListenableBuilder<int>(
            valueListenable: update,
            builder: (ctx, _, child) {
              if (!mounted) return const SizedBox.shrink();
              return Theme(
                data: Theme.of(context),
                child: Focus(
                  onKeyEvent: (_, event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.escape) {
                      close();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    label: widget.label,
                    explicitChildNodes: true,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: close,
                            child: const SizedBox.expand(),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SafeArea(
                            child: SizedBox(
                              width: widget.width.toDouble().clamp(
                                0,
                                MediaQuery.sizeOf(ctx).width - 24,
                              ),
                              height: double.infinity,
                              child: Material(
                                color: Theme.of(context).colorScheme.surface,
                                child: panel(true),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
    route = next;
    navigator!.push(next).whenComplete(() {
      if (mounted && route == next) {
        route = null;
        close();
      }
    });
  }

  void remove() {
    final old = route;
    route = null;
    if (old != null && old.isActive) navigator?.removeRoute(old);
  }

  Widget panel(bool modal) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              autofocus: modal,
              onPressed: close,
              tooltip: 'Close navigation',
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: widget.items.isEmpty
              ? const Text('No destinations')
              : ListView(
                  children: widget.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Semantics(
                            selected: widget.selectedId == item.value,
                            child: ListTile(
                              selected: widget.selectedId == item.value,
                              selectedTileColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              enabled: !item.disabled,
                              title: Text(item.label),
                              onTap: item.disabled ? null : () => select(item),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    NgNavigationRules.validateDrawer(widget.items, widget.width);
    if (widget.expanded && widget.overlay && widget.onExpandedChanged == null) {
      throw ArgumentError(
        "An expanded overlay requires onExpandedChanged to close it.",
      );
    }
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NgButton(
            onPressed: widget.onExpandedChanged == null
                ? null
                : () => widget.onExpandedChanged!(!widget.expanded),
            child: Text(
              widget.expanded ? 'Close navigation' : 'Open navigation',
            ),
          ),
        ),
        const SizedBox(height: 20),
        widget.child,
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (widget.overlay || !widget.expanded) return content;
        final side = SizedBox(
          width: box.maxWidth < 600 ? box.maxWidth : widget.width.toDouble(),
          height: 420,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: panel(false),
          ),
        );
        return box.maxWidth < 600
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [side, const SizedBox(height: 20), content],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  side,
                  const SizedBox(width: 20),
                  Expanded(child: content),
                ],
              );
      },
    );
  }

  @override
  void dispose() {
    final old = route;
    final nav = navigator;
    route = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (old != null && old.isActive) nav?.removeRoute(old);
      update.dispose();
    });
    super.dispose();
  }
}
