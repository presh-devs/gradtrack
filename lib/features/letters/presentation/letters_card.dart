import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/domain/application.dart';
import '../domain/letters.dart';
import 'letters_controller.dart';
import 'recommender_dialogs.dart';

GtTone letterTone(LetterStatus s, GtPalette gt) => switch (s) {
      LetterStatus.planned => gt.warning,
      LetterStatus.requested => gt.info,
      LetterStatus.invited => gt.violet,
      LetterStatus.submitted => gt.success,
      LetterStatus.declined => gt.neutral,
    };

/// Recommendation letters for one application: who's writing, and how far
/// each letter has got (not asked → asked → portal invite sent → submitted).
class LettersCard extends ConsumerWidget {
  const LettersCard({super.key, required this.app});

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final provider = applicationLettersProvider(app.id);
    final value = ref.watch(provider);
    final letters = value.value;
    final p = letters == null ? (submitted: app.lettersSubmitted, total: app.lettersTotal) : letterProgress(letters);

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
                IconWell(icon: GtIcons.letter, tone: gt.warning, size: 36),
                const SizedBox(width: GtSpace.md),
                Expanded(child: Text('Recommendation letters', style: t.titleMedium)),
                if (p.total > 0) Text('${p.submitted} of ${p.total} submitted', style: t.labelLarge),
              ],
            ),
            const SizedBox(height: GtSpace.sm),
            if (letters == null && value.hasError)
              ErrorBanner(error: value.error!, onRetry: () => ref.invalidate(provider))
            else if (letters == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: GtSpace.lg),
                child: LinearProgressIndicator(minHeight: 2),
              )
            else ...[
              if (letters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: GtSpace.sm),
                  child: Text('No recommenders added for this programme yet.', style: t.bodyMedium),
                ),
              for (final l in letters)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.recommenderTitle == null ? l.recommenderName : '${l.recommenderTitle} ${l.recommenderName}',
                              style: t.bodyMedium,
                            ),
                            if (l.statusChangedAt != null)
                              Text(
                                '${l.status.label} ${DateFormat('d MMM').format(l.statusChangedAt!.toLocal())}',
                                style: t.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Change status',
                        onSelected: (v) => v == 'remove'
                            ? run(() => ref.read(provider.notifier).remove(l))
                            : run(() => ref
                                .read(provider.notifier)
                                .setStatus(l, LetterStatus.values.firstWhere((s) => s.db == v))),
                        itemBuilder: (_) => [
                          for (final s in LetterStatus.values)
                            if (s != l.status) PopupMenuItem(value: s.db, child: Text(s.label)),
                          const PopupMenuDivider(),
                          const PopupMenuItem(value: 'remove', child: Text('Remove from this application')),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ToneChip(label: l.status.label, tone: letterTone(l.status, gt)),
                            GtIcon(GtIcons.chevronDown, size: 16, color: gt.textMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: GtSpace.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final id = await showPickRecommenderDialog(
                      context,
                      exclude: {for (final l in letters) l.recommenderId},
                    );
                    if (id != null) await run(() => ref.read(provider.notifier).add(id));
                  },
                  icon: const GtIcon(GtIcons.add, size: 18),
                  label: const Text('Add recommender'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
