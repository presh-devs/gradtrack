import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/domain/application.dart';
import '../domain/professor.dart';
import 'professors_controller.dart';

/// Short status wording shared by this card and the picker.
(String, GtTone) professorStatus(Professor p, GtPalette gt) => switch (p.state) {
      OutreachState.closed => ('Closed', gt.neutral),
      OutreachState.replied => ('Replied', gt.success),
      OutreachState.awaitingReply when p.followUpDue() => ('Follow up now', gt.danger),
      OutreachState.awaitingReply => ('Awaiting reply', gt.info),
      OutreachState.drafting => ('Drafting', gt.warning),
      OutreachState.toContact => ('To contact', gt.warning),
    };

/// Professors linked to one application, with where each conversation stands.
/// Logging emails and replies happens on People.
class ApplicationProfessorsCard extends ConsumerWidget {
  const ApplicationProfessorsCard({super.key, required this.app});

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final value = ref.watch(applicationProfessorsProvider(app.id));
    final linked = value.value;

    Future<void> run(Future<void> Function() action) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await action();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Couldn’t save. ${describeError(e)}')));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.people, tone: gt.info, size: 36),
                const SizedBox(width: GtSpace.md),
                Expanded(child: Text('Professors', style: t.titleMedium)),
              ],
            ),
            const SizedBox(height: GtSpace.sm),
            if (linked == null && value.hasError)
              ErrorBanner(error: value.error!, onRetry: () => ref.invalidate(professorsControllerProvider))
            else if (linked == null)
              const LinearProgressIndicator(minHeight: 2)
            else ...[
              if (linked.isEmpty)
                Text('No professors linked to this programme.', style: t.bodyMedium),
              for (final p in linked)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
                  child: Row(
                    children: [
                      Expanded(child: Text(p.displayName, style: t.bodyMedium)),
                      ToneChip(label: professorStatus(p, gt).$1, tone: professorStatus(p, gt).$2),
                      IconButton(
                        tooltip: 'Unlink',
                        onPressed: () =>
                            run(() => ref.read(professorsControllerProvider.notifier).unlink(p.id, app.id)),
                        icon: GtIcon(GtIcons.close, size: 16, color: gt.textMuted),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: GtSpace.xs),
              Wrap(
                spacing: GtSpace.sm,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final id = await _pick(context, ref, app, {for (final p in linked) p.id});
                      if (id != null) {
                        await run(() => ref.read(professorsControllerProvider.notifier).link(id, app.id));
                      }
                    },
                    icon: const GtIcon(GtIcons.add, size: 18),
                    label: const Text('Link professor'),
                  ),
                  if (linked.isNotEmpty)
                    TextButton(onPressed: () => context.go(Routes.people), child: const Text('Open People')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<String?> _pick(BuildContext context, WidgetRef ref, Application app, Set<String> exclude) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final t = Theme.of(context).textTheme;
        final all = ref.read(professorsControllerProvider).value ?? const <Professor>[];
        final candidates = [for (final p in all) if (!exclude.contains(p.id)) p]
          ..sort((a, b) {
            // Same university first.
            final sa = a.institutionId == app.institutionId ? 0 : 1;
            final sb = b.institutionId == app.institutionId ? 0 : 1;
            return sa != sb ? sa - sb : a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        return AlertDialog(
          title: Text('Link a professor to ${app.institutionName}'),
          content: SizedBox(
            width: 440,
            child: candidates.isEmpty
                ? Text('No other professors saved. Add them on People first.', style: t.bodyMedium)
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final p in candidates)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(p.displayName),
                          subtitle: Text(
                            [p.institutionName, p.researchInterests].nonNulls.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.pop(context, p.id),
                        ),
                    ],
                  ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        );
      },
    );
  }
}
