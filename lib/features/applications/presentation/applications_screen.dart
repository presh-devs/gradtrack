import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/icons.dart';
import '../../../app/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/deadline.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../domain/application.dart';
import 'applications_controller.dart';
import 'stage_style.dart';

part 'applications_screen.g.dart';

/// Selected stage filters (empty = all). UI state, but kept in Riverpod so
/// it survives tab switches.
@Riverpod(keepAlive: true)
class StageFilter extends _$StageFilter {
  @override
  Set<ApplicationStage> build() => const {};

  void toggle(ApplicationStage stage) =>
      state = state.contains(stage) ? ({...state}..remove(stage)) : {...state, stage};

  void clear() => state = const {};
}

/// Filtered view derived from the cached list + filter; recomputes only when
/// either changes, with no extra network calls.
@riverpod
AsyncValue<List<Application>> filteredApplications(Ref ref) {
  final filter = ref.watch(stageFilterProvider);
  return ref.watch(applicationsControllerProvider).whenData((apps) {
    final visible = filter.isEmpty ? apps : apps.where((a) => filter.contains(a.stage));
    // Active applications first (deadline order is preserved), then the rest.
    return [
      ...visible.where((a) => a.stage.isPreSubmission),
      ...visible.where((a) => !a.stage.isPreSubmission),
    ];
  });
}

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < GtBreakpoints.medium ? GtSpace.lg : GtSpace.xxl;
    final total = ref.watch(applicationsControllerProvider).value?.length;
    final apps = ref.watch(filteredApplicationsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Applications',
              subtitle: total == null ? null : '$total programmes this cycle',
              actions: [
                if (width >= GtBreakpoints.medium) ...[
                  OutlinedButton.icon(
                    onPressed: () => _soon(context, 'CSV import'),
                    icon: const GtIcon(GtIcons.import, size: 18),
                    label: const Text('Import CSV'),
                  ),
                  const SizedBox(width: GtSpace.sm),
                ],
                FilledButton.icon(
                  onPressed: () => _soon(context, 'Adding applications'),
                  icon: const GtIcon(GtIcons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const _FilterBar(),
            const SizedBox(height: GtSpace.lg),
            Expanded(
              child: AsyncValueView(
                value: apps,
                onRetry: () => ref.invalidate(applicationsControllerProvider),
                data: (list) {
                  if (list.isEmpty) {
                    return const Align(
                      alignment: Alignment.topCenter,
                      child: EmptyState(
                        icon: GtIcons.applications,
                        title: 'No applications match',
                        message: 'Clear the filters or add a programme.',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(applicationsControllerProvider.notifier).refresh(),
                    child: width >= GtBreakpoints.expanded
                        ? _Table(apps: list)
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: GtSpace.xxl),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const SizedBox(height: GtSpace.md),
                            itemBuilder: (_, i) => _ApplicationCard(app: list[i]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _soon(BuildContext context, String what) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('$what lands later this week.')));
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(stageFilterProvider);
    final counts = ref.watch(stageCountsProvider).value;
    final gt = context.gt;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selected.isEmpty,
            onSelected: (_) => ref.read(stageFilterProvider.notifier).clear(),
            showCheckmark: false,
            selectedColor: gt.info.bg,
          ),
          for (final stage in ApplicationStage.values)
            if ((counts?[stage] ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(left: GtSpace.sm),
                child: FilterChip(
                  label: Text('${stage.label} · ${counts![stage]}'),
                  selected: selected.contains(stage),
                  onSelected: (_) => ref.read(stageFilterProvider.notifier).toggle(stage),
                  showCheckmark: false,
                  selectedColor: stage.tone(gt).bg,
                ),
              ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.apps});

  final List<Application> apps;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget head(String s) => Text(s.toUpperCase(), style: t.labelSmall?.copyWith(letterSpacing: 0.6));
    return ListView(
      padding: const EdgeInsets.only(bottom: GtSpace.xxl),
      children: [
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.lg, GtSpace.md),
                child: Row(
                  children: [
                    Expanded(flex: 5, child: head('Programme')),
                    Expanded(flex: 4, child: head('Deadline')),
                    Expanded(flex: 3, child: head('Stage')),
                    Expanded(flex: 3, child: head('Readiness')),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              for (final app in apps) ...[const Divider(), _TableRow(app: app)],
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    return InkWell(
      onTap: () => context.go(Routes.application(app.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  _InstitutionAvatar(name: app.institutionName),
                  const SizedBox(width: GtSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.institutionName, style: t.titleSmall, overflow: TextOverflow.ellipsis),
                        Text('${app.degreeLabel} ${app.programmeName}', style: t.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 4, child: _DeadlineCell(app: app)),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ToneChip(label: app.outcome?.label ?? app.stage.label, tone: app.stage.tone(gt)),
              ),
            ),
            Expanded(flex: 3, child: _Readiness(app: app)),
            SizedBox(
              width: 32,
              child: app.isTopChoice
                  ? Tooltip(
                      message: 'Top choice',
                      child: GtIcon(GtIcons.topChoice, color: gt.warning.fg, size: 20),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.application(app.id)),
        child: Padding(
          padding: const EdgeInsets.all(GtSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _InstitutionAvatar(name: app.institutionName),
                  const SizedBox(width: GtSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.institutionName, style: t.titleSmall),
                        Text('${app.degreeLabel} ${app.programmeName}', style: t.bodySmall),
                      ],
                    ),
                  ),
                  ToneChip(label: app.stage.label, tone: app.stage.tone(gt)),
                ],
              ),
              const SizedBox(height: GtSpace.md),
              _DeadlineCell(app: app),
              const SizedBox(height: GtSpace.md),
              _Readiness(app: app),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstitutionAvatar extends StatelessWidget {
  const _InstitutionAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    final tones = [gt.info, gt.violet, gt.success, gt.warning];
    final tone = tones[name.codeUnits.fold<int>(0, (a, b) => a + b) % tones.length];
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty && w[0].toUpperCase() == w[0] && w.toLowerCase() != 'of')
        .take(2)
        .map((w) => w[0])
        .join();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(GtRadius.md)),
      child: Text(initials, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: tone.fg)),
    );
  }
}

class _DeadlineCell extends StatelessWidget {
  const _DeadlineCell({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final d = app.deadline;
    final t = Theme.of(context).textTheme;
    if (d == null) return Text('No deadline', style: t.bodySmall);
    final relevant = app.stage.isPreSubmission;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(d.zoneLabel, style: t.labelLarge),
        const SizedBox(height: 2),
        relevant
            ? ToneChip(label: DueText.relative(d.instant), tone: d.instant.dueTone(context.gt))
            : Text(d.differsFromLocal ? '${d.localLabel} your time' : 'Passed', style: t.bodySmall),
      ],
    );
  }
}

class _Readiness extends StatelessWidget {
  const _Readiness({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final r = app.readiness;
    final t = Theme.of(context).textTheme;
    if (r == null) return Text('Checklist not set up', style: t.bodySmall);
    final gt = context.gt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressBar(value: r, color: r == 1 ? gt.success.fg : gt.primary),
        const SizedBox(height: 4),
        Text(
          '${app.requirementsDone}/${app.requirementsTotal} items · ${app.lettersSubmitted}/${app.lettersTotal} letters',
          style: t.bodySmall,
        ),
      ],
    );
  }
}
