import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../domain/professor.dart';
import '../../letters/presentation/recommender_dialogs.dart';
import '../../letters/presentation/recommenders_view.dart';
import '../../applications/domain/application.dart';
import '../../applications/presentation/applications_controller.dart';
import 'professor_dialogs.dart';
import 'professors_controller.dart';

/// Professors you're contacting, grouped by university, with where each
/// conversation stands and one-tap "emailed" / "replied" logging.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

enum _PeopleTab { professors, recommenders }

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  _PeopleTab _tab = _PeopleTab.professors;
  PeopleFilter _filter = PeopleFilter.all;
  String _query = '';

  bool _matchesQuery(Professor p) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return [
      p.name,
      p.institutionName,
      p.researchInterests,
      p.email,
      p.department,
    ].any((v) => v != null && v.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < GtBreakpoints.medium ? GtSpace.lg : GtSpace.xxl;
    final value = ref.watch(professorsControllerProvider);
    final all = value.value ?? const <Professor>[];
    final now = DateTime.now();
    final gt = context.gt;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'People',
              subtitle: _tab == _PeopleTab.recommenders
                  ? 'Who’s writing your letters'
                  : value.hasValue
                  ? _subtitle(
                      all.where((p) => p.state != OutreachState.closed).length,
                      all.where((p) => p.followUpDue(now)).length,
                    )
                  : 'Professors you’re contacting',
              actions: [
                if (_tab == _PeopleTab.professors) ...[
                  OutlinedButton.icon(
                    onPressed: () => showProfessorPasteDialog(context),
                    icon: const GtIcon(GtIcons.import, size: 18),
                    label: Text(
                      width >= GtBreakpoints.medium ? 'Paste a list' : 'Paste',
                    ),
                  ),
                  const SizedBox(width: GtSpace.sm),
                ],
                FilledButton.icon(
                  onPressed: () => _tab == _PeopleTab.professors
                      ? showProfessorEditor(context)
                      : showRecommenderEditor(context),
                  icon: const GtIcon(GtIcons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<_PeopleTab>(
                segments: const [
                  ButtonSegment(
                    value: _PeopleTab.professors,
                    label: Text('Professors'),
                  ),
                  ButtonSegment(
                    value: _PeopleTab.recommenders,
                    label: Text('Recommenders'),
                  ),
                ],
                selected: {_tab},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
            ),
            const SizedBox(height: GtSpace.md),
            if (_tab == _PeopleTab.recommenders)
              const Expanded(child: RecommendersView())
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in PeopleFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: GtSpace.sm),
                        child: FilterChip(
                          label: Text(
                            f == PeopleFilter.all || !value.hasValue
                                ? f.label
                                : '${f.label} · ${all.where((p) => f.matches(p, now)).length}',
                          ),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          showCheckmark: false,
                          selectedColor: f == PeopleFilter.followUpDue
                              ? gt.danger.bg
                              : gt.info.bg,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: GtSpace.md),
              TextField(
                decoration: const InputDecoration(
                  hintText:
                      'Search by name, university, research area or email',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      left: GtSpace.md,
                      right: GtSpace.sm,
                    ),
                    child: GtIcon(GtIcons.search, size: 18),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 40),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: GtSpace.lg),
              Expanded(
                child: AsyncValueView(
                  value: value,
                  onRetry: () => ref.invalidate(professorsControllerProvider),
                  data: (list) {
                    if (list.isEmpty) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: EmptyState(
                          icon: GtIcons.people,
                          title: 'No professors yet',
                          message: 'Add the supervisors you want to contact, or paste them from your spreadsheet.',
                          action: FilledButton(
                            onPressed: () => showProfessorPasteDialog(context),
                            child: const Text('Paste a list'),
                          ),
                        ),
                      );
                    }
                    final visible = list
                        .where(
                          (p) => _filter.matches(p, now) && _matchesQuery(p),
                        )
                        .toList();
                    if (visible.isEmpty) {
                      return const Align(
                        alignment: Alignment.topCenter,
                        child: EmptyState(
                          icon: GtIcons.search,
                          title: 'No one matches',
                          message: 'Try another filter or search.',
                        ),
                      );
                    }
                    final groups = groupBy(
                      visible,
                      (Professor p) => p.institutionName,
                    );
                    return ListView(
                      padding: const EdgeInsets.only(bottom: GtSpace.xxl),
                      children: [
                        for (final entry in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: GtSpace.sm,
                              top: GtSpace.sm,
                            ),
                            child: Row(
                              children: [
                                GtIcon(
                                  GtIcons.university,
                                  size: 18,
                                  color: gt.textMuted,
                                ),
                                const SizedBox(width: GtSpace.sm),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                                Text(
                                  '${entry.value.length}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              children: [
                                for (final (i, p) in entry.value.indexed) ...[
                                  if (i > 0) const Divider(height: 1),
                                  _ProfessorRow(
                                    professor: p,
                                    wide: width >= GtBreakpoints.medium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: GtSpace.lg),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _subtitle(int professors, int due) =>
    '$professors professor${professors == 1 ? '' : 's'}'
    '${due == 0 ? '' : ' · $due follow-up${due == 1 ? '' : 's'} due'}';

class _ProfessorRow extends ConsumerWidget {
  const _ProfessorRow({required this.professor, required this.wide});

  final Professor professor;
  final bool wide;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String done,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (done.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(done)));
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Couldn’t save. ${describeError(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final p = professor;
    final notifier = ref.read(professorsControllerProvider.notifier);
    final apps = ref.watch(applicationsControllerProvider).value ?? const <Application>[];
    final programmes = [
      for (final a in apps)
        if (p.applicationIds.contains(a.id)) '${a.degreeLabel} ${a.programmeName}',
    ];
    final day = DateFormat('d MMM');
    final now = DateTime.now();

    final (statusLabel, statusTone) = switch (p.state) {
      OutreachState.closed => ('Closed', gt.neutral),
      OutreachState.replied => (
        'Replied ${p.lastReplyAt == null ? '' : day.format(p.lastReplyAt!.toLocal())}',
        gt.success,
      ),
      OutreachState.awaitingReply when p.followUpDue(now) => (
        'Follow up now',
        gt.danger,
      ),
      OutreachState.awaitingReply => (
        'Emailed ${p.lastSentAt == null ? '' : day.format(p.lastSentAt!.toLocal())}',
        gt.info,
      ),
      OutreachState.drafting => ('Drafting', gt.warning),
      OutreachState.toContact => ('To contact', gt.warning),
    };

    Future<void> logSent({bool followUp = false}) async {
      final r = await showLogSentDialog(
        context,
        professor: p,
        isFollowUp: followUp,
      );
      if (r == null || !context.mounted) return;
      await _run(
        context,
        () => notifier.logSent(
          p.id,
          sentAt: r.sentAt,
          followUpAt: r.followUpAt,
          isFollowUp: followUp,
        ),
        r.followUpAt == null
            ? 'Logged email to ${p.displayName}'
            : 'Logged. Reminder on ${day.format(r.followUpAt!)} if no reply',
      );
    }

    Future<void> logReply() async {
      final r = await showLogReplyDialog(context, professor: p);
      if (r == null || !context.mounted) return;
      await _run(
        context,
        () => notifier.logReply(p.id, at: r.at, stance: r.stance),
        'Reply logged',
      );
    }

    final primary = switch (p.state) {
      OutreachState.toContact || OutreachState.drafting => FilledButton.tonal(
        onPressed: () => logSent(),
        child: const Text('Emailed'),
      ),
      OutreachState.awaitingReply => FilledButton.tonal(
        onPressed: logReply,
        child: const Text('Replied'),
      ),
      _ => null,
    };

    final menu = PopupMenuButton<String>(
      tooltip: 'More',
      icon: GtIcon(GtIcons.more, size: 18, color: gt.textMuted),
      onSelected: (v) async {
        switch (v) {
          case 'sent':
            await logSent();
          case 'followup':
            await logSent(followUp: true);
          case 'reply':
            await logReply();
          case 'edit':
            await showProfessorEditor(context, professor: p);
          case 'close':
            await _run(
              context,
              () => notifier.setClosed(p.id, p.state != OutreachState.closed),
              '',
            );
          case 'delete':
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Delete ${p.displayName}?'),
                content: const Text(
                  'Their details and logged emails are removed. This can’t be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (ok == true && context.mounted) {
              await _run(context, () => notifier.delete(p.id), 'Deleted');
            }
          default:
            final stance = ProfessorStance.values.firstWhereOrNull(
              (s) => s.db == v,
            );
            if (stance != null) {
              await _run(context, () => notifier.setStance(p.id, stance), '');
            }
        }
      },
      itemBuilder: (_) => [
        if (p.state == OutreachState.toContact ||
            p.state == OutreachState.drafting)
          const PopupMenuItem(value: 'sent', child: Text('Log email sent'))
        else ...[
          const PopupMenuItem(
            value: 'followup',
            child: Text('Log follow-up sent'),
          ),
          const PopupMenuItem(value: 'reply', child: Text('Log reply')),
        ],
        const PopupMenuDivider(),
        for (final s in ProfessorStance.values)
          if (s != p.stance)
            PopupMenuItem(
              value: s.db,
              child: Text('Mark: ${s.label.toLowerCase()}'),
            ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'close',
          child: Text(
            p.state == OutreachState.closed
                ? 'Reopen conversation'
                : 'Close conversation',
          ),
        ),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: GtSpace.sm,
          runSpacing: GtSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(p.displayName, style: t.titleSmall),
            ToneChip(label: statusLabel.trim(), tone: statusTone),
            if (p.stance != ProfessorStance.unknown)
              ToneChip(
                label: p.stance.label,
                tone: p.stance == ProfessorStance.interested
                    ? gt.success
                    : gt.neutral,
              ),
          ],
        ),
        if (programmes.isNotEmpty)
          Text('For: ${programmes.join(', ')}', style: t.bodySmall?.copyWith(color: gt.textSecondary)),
        if (p.researchInterests != null) ...[
          const SizedBox(height: 2),
          Text(
            p.researchInterests!,
            style: t.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (p.email != null || p.profileUrl != null) ...[
          const SizedBox(height: GtSpace.xs),
          Wrap(
            spacing: GtSpace.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (p.email != null)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: p.email!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied ${p.email}')),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GtIcon(GtIcons.copy, size: 14, color: gt.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        p.email!,
                        style: t.bodySmall?.copyWith(color: gt.info.fg),
                      ),
                    ],
                  ),
                ),
              if (p.profileUrl != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GtIcon(GtIcons.link, size: 14, color: gt.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: SelectableText(
                        p.profileUrl!.replaceFirst(RegExp(r'^https?://'), ''),
                        style: t.bodySmall,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GtSpace.lg,
        GtSpace.md,
        GtSpace.sm,
        GtSpace.md,
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: details),
                const SizedBox(width: GtSpace.md),
                ?primary,
                menu,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: details),
                    menu,
                  ],
                ),
                if (primary != null)
                  Align(alignment: Alignment.centerLeft, child: primary),
              ],
            ),
    );
  }
}
