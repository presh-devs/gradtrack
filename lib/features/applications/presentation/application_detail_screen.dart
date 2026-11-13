import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/icons.dart';
import '../../../app/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/deadline.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../checklist/presentation/checklist_card.dart';
import '../../letters/presentation/letters_card.dart';
import '../../people/presentation/application_professors_card.dart';
import '../domain/application.dart';
import 'applications_controller.dart';
import 'stage_style.dart';

class ApplicationDetailScreen extends ConsumerWidget {
  const ApplicationDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(applicationByIdProvider(id));
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < GtBreakpoints.medium ? GtSpace.lg : GtSpace.xxl;

    return Scaffold(
      body: AsyncValueView(
        value: app,
        onRetry: () => ref.invalidate(applicationsControllerProvider),
        data: (a) => a == null
            ? Center(
                child: EmptyState(
                  icon: GtIcons.notFound,
                  title: 'Application not found',
                  message: 'It may have been archived or deleted.',
                  action: FilledButton(
                    onPressed: () => context.go(Routes.applications),
                    child: const Text('Back to applications'),
                  ),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(pad, GtSpace.lg, pad, GtSpace.xxl),
                children: [
                  PageBody(
                    child: _Workspace(app: a, wide: width >= 1024),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Workspace extends StatelessWidget {
  const _Workspace({required this.app, required this.wide});

  final Application app;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final main = [ChecklistCard(app: app), const SizedBox(height: GtSpace.lg), LettersCard(app: app)];
    final side = [
      _DeadlineCard(app: app),
      const SizedBox(height: GtSpace.lg),
      _DetailsCard(app: app),
      const SizedBox(height: GtSpace.lg),
      ApplicationProfessorsCard(app: app),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(Routes.applications),
            icon: const GtIcon(GtIcons.back, size: 18),
            label: const Text('Applications'),
          ),
        ),
        _Header(app: app),
        const SizedBox(height: GtSpace.xl),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: main,
                ),
              ),
              const SizedBox(width: GtSpace.xl),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: side,
                ),
              ),
            ],
          )
        else ...[
          ...side,
          const SizedBox(height: GtSpace.lg),
          ...main,
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Wrap(
      spacing: GtSpace.lg,
      runSpacing: GtSpace.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.institutionName,
                style: t.titleMedium?.copyWith(color: context.gt.textSecondary),
              ),
              const SizedBox(height: GtSpace.xs),
              Semantics(
                header: true,
                child: Text(
                  '${app.degreeLabel} ${app.programmeName}',
                  style: t.headlineMedium,
                ),
              ),
              if (app.department != null || app.researchArea != null) ...[
                const SizedBox(height: GtSpace.xs),
                Text(
                  [
                    app.department,
                    app.researchArea,
                  ].whereType<String>().join(' · '),
                  style: t.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go(Routes.editApplication(app.id)),
              icon: const GtIcon(GtIcons.edit, size: 18),
              label: const Text('Edit'),
            ),
            const SizedBox(width: GtSpace.md),
            _StageMenu(app: app),
          ],
        ),
      ],
    );
  }
}

/// Stage picker with optimistic update; failures roll back and show a snackbar.
class _StageMenu extends ConsumerWidget {
  const _StageMenu({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gt = context.gt;
    final tone = app.stage.tone(gt);
    return PopupMenuButton<ApplicationStage>(
      tooltip: 'Change stage',
      initialValue: app.stage,
      onSelected: (stage) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await ref
              .read(applicationsControllerProvider.notifier)
              .updateStage(app.id, stage);
          messenger.showSnackBar(
            SnackBar(content: Text('Moved to ${stage.label}')),
          );
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(
              content: Text("Couldn't update stage. ${describeError(e)}"),
            ),
          );
        }
      },
      itemBuilder: (_) => [
        for (final s in ApplicationStage.values)
          PopupMenuItem(
            value: s,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.tone(gt).fg,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: GtSpace.md),
                Text(s.label),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GtSpace.lg,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: tone.bg,
          borderRadius: BorderRadius.circular(GtRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              app.stage.label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: tone.fg),
            ),
            const SizedBox(width: GtSpace.sm),
            GtIcon(GtIcons.chevronDown, color: tone.fg, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    Widget row(String label, Deadline d) => Padding(
      padding: const EdgeInsets.only(top: GtSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.bodySmall),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: Text(d.zoneLabel, style: t.titleMedium)),
              if (app.stage.isPreSubmission)
                ToneChip(label: d.dueLabel(), tone: d.instant.dueTone(gt)),
            ],
          ),
          if (d.differsFromLocal)
            Text('${d.localLabel} your time · ${d.zone}', style: t.bodySmall),
        ],
      ),
    );

    Widget dateRow(String label, ApproxDate d) => Padding(
      padding: const EdgeInsets.only(top: GtSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.bodySmall),
          const SizedBox(height: 2),
          Text(d.label, style: t.titleMedium),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.deadline, tone: gt.info, size: 36),
                const SizedBox(width: GtSpace.md),
                Text('Deadlines', style: t.titleMedium),
              ],
            ),
            if (app.deadline == null && app.fundingDeadline == null)
              Padding(
                padding: const EdgeInsets.only(top: GtSpace.md),
                child: Text('No deadline recorded yet.', style: t.bodyMedium),
              ),
            if (app.opensOn != null) dateRow('Applications open', app.opensOn!),
            if (app.deadline != null) row('Application', app.deadline!),
            if (app.fundingDeadline != null)
              row('Funding / scholarship', app.fundingDeadline!),
            if (app.decisionExpected != null)
              dateRow('Decision expected', app.decisionExpected!),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rows = <(String, String)>[
      ('Degree', app.degreeLabel),
      if (app.location != null) ('Location', app.location!),
      if (app.country != null) ('Country', app.country!),
      (
        'Priority',
        switch (app.priority) {
          1 => 'Top choice',
          2 => 'Normal',
          _ => 'Backup',
        },
      ),
      if (app.programmeUrl != null) ('Programme page', app.programmeUrl!),
      if (app.portalUrl != null) ('Portal', app.portalUrl!),
      if (app.portalUsername != null) ('Portal username', app.portalUsername!),
      if (app.feeAmount != null)
        ('Application fee', '${app.feeCurrency} ${_money(app.feeAmount!)}'),
      if (app.feeWaiver != FeeWaiver.none) ('Fee waiver', app.feeWaiver.label),
      if (app.tuitionAmount != null)
        (
          'Tuition / year',
          '${app.tuitionCurrency} ${_money(app.tuitionAmount!)}',
        ),
      if (app.notes != null) ('Notes', app.notes!),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.info, tone: context.gt.violet, size: 36),
                const SizedBox(width: GtSpace.md),
                Text('Details', style: t.titleMedium),
              ],
            ),
            const SizedBox(height: GtSpace.sm),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(label, style: t.bodySmall),
                    ),
                    Expanded(child: SelectableText(value, style: t.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _money(double v) => NumberFormat.decimalPatternDigits(
  decimalDigits: v == v.roundToDouble() ? 0 : 2,
).format(v);
