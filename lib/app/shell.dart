import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/icons.dart';
import '../core/env.dart';
import '../core/theme/tokens.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final GtGlyph icon;
  final GtGlyph selectedIcon;
}

const _destinations = [
  _Destination('Today', GtIcons.today, GtIcons.todaySelected),
  _Destination('Applications', GtIcons.applications, GtIcons.applicationsSelected),
  _Destination('People', GtIcons.people, GtIcons.peopleSelected),
  _Destination('Tasks', GtIcons.tasks, GtIcons.tasksSelected),
  _Destination('Settings', GtIcons.settings, GtIcons.settingsSelected),
];

/// Responsive navigation: side rail on wide screens, bottom bar on narrow.
/// Each tab keeps its own navigation stack (StatefulShellRoute).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gt = context.gt;

    if (width < GtBreakpoints.expanded) {
      return Scaffold(
        body: SafeArea(child: shell),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: gt.border))),
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            height: 68,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(
                  icon: GtIcon(d.icon),
                  selectedIcon: GtIcon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        ),
      );
    }

    final extended = width >= 1200;
    return Scaffold(
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: gt.surface,
              border: Border(right: BorderSide(color: gt.border)),
            ),
            child: NavigationRail(
              extended: extended,
              minExtendedWidth: 232,
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.sm, GtSpace.xl, GtSpace.sm, GtSpace.xl),
                child: BrandMark(showName: extended),
              ),
              trailing: Env.demo
                  ? Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: GtSpace.xl),
                          child: Tooltip(
                            message: 'No Supabase configured — using sample data',
                            child: Chip(label: Text(extended ? 'Demo data' : 'Demo')),
                          ),
                        ),
                      ),
                    )
                  : null,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: GtIcon(d.icon),
                    selectedIcon: GtIcon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.showName = true, this.onDark = false});

  final bool showName;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gt.heroStart, gt.heroEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(GtRadius.md),
            border: onDark ? Border.all(color: Colors.white24) : null,
          ),
          child: const GtIcon(GtIcons.brand, color: Colors.white, size: 22),
        ),
        if (showName) ...[
          const SizedBox(width: GtSpace.md),
          Text(
            'GradTrack',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: onDark ? Colors.white : null,
                ),
          ),
        ],
      ],
    );
  }
}
