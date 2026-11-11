import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../domain/letters.dart';
import 'letters_controller.dart';
import 'recommender_dialogs.dart';

/// People → Recommenders: everyone writing letters, with how many they're
/// writing. Letters themselves are added on each application's page.
class RecommendersView extends ConsumerWidget {
  const RecommendersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(recommendersControllerProvider);
    return AsyncValueView(
      value: value,
      onRetry: () => ref.invalidate(recommendersControllerProvider),
      data: (list) {
        if (list.isEmpty) {
          return Align(
            alignment: Alignment.topCenter,
            child: EmptyState(
              icon: GtIcons.letter,
              title: 'No recommenders yet',
              message: 'Add the people writing your letters, then attach them to each application.',
              action: FilledButton(
                onPressed: () => showRecommenderEditor(context),
                child: const Text('Add recommender'),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: GtSpace.xxl),
          children: [
            Card(
              child: Column(
                children: [
                  for (final (i, r) in list.indexed) ...[
                    if (i > 0) const Divider(height: 1),
                    _RecommenderRow(recommender: r),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommenderRow extends ConsumerWidget {
  const _RecommenderRow({required this.recommender});

  final Recommender recommender;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final r = recommender;
    final about = [r.relationship, r.institution].nonNulls.join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(GtSpace.lg, GtSpace.md, GtSpace.sm, GtSpace.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: GtSpace.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(r.displayName, style: t.titleSmall),
                    ToneChip(
                      label: r.letters == 0
                          ? 'No letters yet'
                          : '${r.submitted} of ${r.letters} letter${r.letters == 1 ? '' : 's'} submitted',
                      tone: r.letters > 0 && r.submitted == r.letters ? gt.success : gt.info,
                    ),
                  ],
                ),
                if (about.isNotEmpty) Text(about, style: t.bodySmall),
                if (r.email != null)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: r.email!));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${r.email}')));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GtIcon(GtIcons.copy, size: 14, color: gt.textMuted),
                        const SizedBox(width: 4),
                        Text(r.email!, style: t.bodySmall?.copyWith(color: gt.info.fg)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: GtIcon(GtIcons.more, size: 18, color: gt.textMuted),
            onSelected: (v) async {
              if (v == 'edit') {
                await showRecommenderEditor(context, recommender: r);
                return;
              }
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete ${r.displayName}?'),
                  content: Text(
                    r.letters == 0
                        ? 'This can’t be undone.'
                        : 'Their ${r.letters} letter${r.letters == 1 ? '' : 's'} will be removed from your applications. '
                            'This can’t be undone.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok != true || !context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(recommendersControllerProvider.notifier).delete(r.id);
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Couldn’t delete. ${describeError(e)}')));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
