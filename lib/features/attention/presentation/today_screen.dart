import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/icons.dart';
import '../../../app/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/deadline.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/domain/application.dart';
import '../../applications/presentation/applications_controller.dart';
import '../../applications/presentation/stage_style.dart';
import '../../auth/data/auth_repositories.dart';
import '../domain/attention_item.dart';
import 'today_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  Future<void> _refresh(WidgetRef ref) => Future.wait([
        ref.read(todayControllerProvider.notifier).refresh(),
        ref.read(applicationsControllerProvider.notifier).refresh(),
      ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1024;
    final pad = width < GtBreakpoints.medium ? GtSpace.lg : GtSpace.xxl;
    final name = ref.watch(authRepositoryProvider).displayName;

    final header = PageHeader(
      title: '${_greeting()}${name == null ? '' : ', $name'}',
      subtitle: DateFormat('EEEE, d MMMM').format(DateTime.now()),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _refresh(ref),
          icon: const GtIcon(GtIcons.refresh),
        ),
      ],
    );

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            sliver: SliverToBoxAdapter(
              child: PageBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    if (wide)
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 8, child: _MainColumn()),
                          SizedBox(width: GtSpace.xl),
                          Expanded(flex: 4, child: _SideColumn()),
                        ],
                      )
                    else
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [_MainColumn(includeSummary: true)],
                      ),
                    const SizedBox(height: GtSpace.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _MainColumn extends ConsumerWidget {
  const _MainColumn({this.includeSummary = false});

  final bool includeSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(todayGroupsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _NextDeadlineCard(),
        if (includeSummary) ...[const SizedBox(height: GtSpace.lg), const _SummaryRow()],
        const SizedBox(height: GtSpace.xl),
        switch (groups) {
          AsyncValue(:final value?) when value.isEmpty => const EmptyState(
              icon: GtIcons.allClear,
              title: 'Nothing needs you right now',
              message: 'No deadlines, letters or follow-ups in the next two weeks.',
            ),
          AsyncValue(:final value?) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (groups.isLoading) const LinearProgressIndicator(minHeight: 2),
                for (final entry in value.entries) _Group(bucket: entry.key, items: entry.value),
              ],
            ),
          AsyncValue(:final error?) => ErrorCard(
              error: error,
              onRetry: () => ref.invalidate(todayControllerProvider),
            ),
          _ => const SizedBox(height: 360, child: SkeletonList(rows: 4)),
        },
      ],
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_SummaryRow(), SizedBox(height: GtSpace.lg), _PipelineCard()],
      );
}

/// Blue hero card — the web take on the Innixx balance card.
class _NextDeadlineCard extends ConsumerWidget {
  const _NextDeadlineCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(nextDeadlineProvider);
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    const onHero = Colors.white;
    const onHeroMuted = Color(0xCCFFFFFF);

    Widget body(Application? app) {
      if (app == null) {
        return Text('No upcoming deadlines', style: t.headlineSmall?.copyWith(color: onHero));
      }
      final d = app.deadline!;
      final readiness = app.readiness;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${app.institutionName} · ${app.degreeLabel} ${app.programmeName}',
            style: t.titleMedium?.copyWith(color: onHeroMuted),
          ),
          const SizedBox(height: GtSpace.sm),
          Text(DueText.relative(d.instant), style: t.displaySmall?.copyWith(color: onHero)),
          const SizedBox(height: GtSpace.sm),
          Text(
            d.differsFromLocal ? '${d.zoneLabel}  ·  ${d.localLabel} your time' : d.zoneLabel,
            style: t.bodyMedium?.copyWith(color: onHeroMuted),
          ),
          if (readiness != null) ...[
            const SizedBox(height: GtSpace.lg),
            Row(
              children: [
                Expanded(
                  child: ProgressBar(
                    value: readiness,
                    color: GtBrand.mint,
                    track: const Color(0x33FFFFFF),
                  ),
                ),
                const SizedBox(width: GtSpace.md),
                Text(
                  '${app.requirementsDone + app.lettersSubmitted} of ${app.requirementsTotal + app.lettersTotal} ready',
                  style: t.labelMedium?.copyWith(color: onHero),
                ),
              ],
            ),
          ],
        ],
      );
    }

    final app = next.value;
    return Semantics(
      button: app != null,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gt.heroStart, gt.heroEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(GtRadius.lg),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(GtRadius.lg),
            onTap: app == null ? null : () => context.go(Routes.application(app.id)),
            child: Padding(
              padding: const EdgeInsets.all(GtSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x2EFFFFFF),
                      borderRadius: BorderRadius.circular(GtRadius.pill),
                    ),
                    child: Text('Next deadline', style: t.labelMedium?.copyWith(color: onHero)),
                  ),
                  const SizedBox(height: GtSpace.lg),
                  switch (next) {
                    AsyncValue(:final value?) => body(value),
                    AsyncValue(hasValue: true) => body(null),
                    AsyncValue(:final error?) =>
                      Text(describeError(error), style: t.bodyMedium?.copyWith(color: onHero)),
                    _ => const SizedBox(
                        height: 96,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(color: onHero, strokeWidth: 2),
                        ),
                      ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(todayGroupsProvider).value;
    final gt = context.gt;
    final overdue = groups?[DueBucket.overdue]?.length ?? 0;
    final week = (groups?[DueBucket.today]?.length ?? 0) + (groups?[DueBucket.thisWeek]?.length ?? 0);
    String show(int n) => groups == null ? '–' : '$n';
    final tiles = [
      _StatTile(
        label: 'Overdue',
        value: show(overdue),
        icon: GtIcons.overdue,
        tone: overdue > 0 ? gt.danger : gt.success,
      ),
      _StatTile(label: 'Due this week', value: show(week), icon: GtIcons.thisWeek, tone: gt.info),
    ];
    return Row(
      children: [
        Expanded(child: tiles[0]),
        const SizedBox(width: GtSpace.md),
        Expanded(child: tiles[1]),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon, required this.tone});

  final String label;
  final String value;
  final GtGlyph icon;
  final GtTone tone;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconWell(icon: icon, tone: tone, size: 36),
            const SizedBox(height: GtSpace.md),
            Text(value, style: t.headlineMedium),
            Text(label, style: t.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PipelineCard extends ConsumerWidget {
  const _PipelineCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(stageCountsProvider).value;
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Pipeline', style: t.titleMedium)),
                TextButton(
                  onPressed: () => context.go(Routes.applications),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: GtSpace.sm),
            if (counts == null)
              const LinearProgressIndicator(minHeight: 2)
            else
              for (final stage in ApplicationStage.values)
                if (counts[stage]! > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: stage.tone(gt).fg, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: GtSpace.md),
                        Expanded(child: Text(stage.label, style: t.bodyMedium)),
                        Text('${counts[stage]}', style: t.titleSmall),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.bucket, required this.items});

  final DueBucket bucket;
  final List<AttentionItem> items;

  static const _titles = {
    DueBucket.overdue: 'Overdue',
    DueBucket.today: 'Today',
    DueBucket.thisWeek: 'Next 7 days',
    DueBucket.later: 'Later',
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    return Padding(
      padding: const EdgeInsets.only(bottom: GtSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: GtSpace.xs, bottom: GtSpace.md),
            child: Row(
              children: [
                Semantics(header: true, child: Text(_titles[bucket]!, style: t.titleMedium)),
                const SizedBox(width: GtSpace.sm),
                ToneChip(
                  label: '${items.length}',
                  tone: bucket == DueBucket.overdue ? gt.danger : gt.neutral,
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(indent: 76),
                  _AttentionTile(item: items[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  const _AttentionTile({required this.item});

  final AttentionItem item;

  (GtGlyph, GtTone) _style(GtPalette gt) => switch (item.type) {
        AttentionType.applicationDeadline => (GtIcons.deadline, gt.info),
        AttentionType.fundingDeadline => (GtIcons.funding, gt.success),
        AttentionType.requirement => (GtIcons.requirement, gt.violet),
        AttentionType.letter => (GtIcons.letter, gt.warning),
        AttentionType.followUp => (GtIcons.followUp, gt.info),
        AttentionType.task => (GtIcons.task, gt.neutral),
      };

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    final (icon, tone) = _style(gt);
    final due = DueText.relative(item.dueAt);
    final appId = item.applicationId;
    final compact = MediaQuery.sizeOf(context).width < GtBreakpoints.medium;

    return InkWell(
      onTap: appId == null
          ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Professors and tasks arrive in week 3.')),
              )
          : () => context.go(Routes.application(appId)),
      child: Semantics(
        label: '${item.title}. ${item.reason}. $due',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
          child: Row(
            children: [
              IconWell(icon: icon, tone: tone),
              const SizedBox(width: GtSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: t.titleSmall),
                    if (item.context != null) ...[
                      const SizedBox(height: 2),
                      Text(item.context!, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 2),
                    Text(item.reason, style: t.bodyMedium),
                    if (compact) ...[
                      const SizedBox(height: GtSpace.sm),
                      ToneChip(label: due, tone: item.dueAt.dueTone(gt)),
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: GtSpace.md),
                ToneChip(label: due, tone: item.dueAt.dueTone(gt)),
              ],
              const SizedBox(width: GtSpace.xs),
              GtIcon(GtIcons.chevronRight, color: gt.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
