import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../domain/feedback.dart';
import 'feedback_controller.dart';

/// Settings card for sending feedback or a feature request, with what you've
/// sent before and where each one stands.
class FeedbackCard extends ConsumerStatefulWidget {
  const FeedbackCard({super.key});

  @override
  ConsumerState<FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends ConsumerState<FeedbackCard> {
  final _message = TextEditingController();
  var _kind = FeedbackKind.feature;
  var _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final error = feedbackError(_message.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(feedbackHistoryProvider.notifier).send(_kind, _message.text);
      _message.clear();
      messenger.showSnackBar(const SnackBar(content: Text('Thanks! Your feedback was sent.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Couldn’t send. ${describeError(e)}')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final history = ref.watch(feedbackHistoryProvider).value ?? const <FeedbackEntry>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.feedback, tone: gt.violet, size: 40),
                const SizedBox(width: GtSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Feedback', style: t.titleSmall),
                      Text('Ask for a feature, report a problem, or tell us what you think.', style: t.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GtSpace.md),
            Wrap(
              spacing: GtSpace.sm,
              runSpacing: GtSpace.sm,
              children: [
                for (final k in FeedbackKind.values)
                  ChoiceChip(
                    label: Text(k.label),
                    selected: _kind == k,
                    onSelected: _sending ? null : (_) => setState(() => _kind = k),
                  ),
              ],
            ),
            const SizedBox(height: GtSpace.md),
            TextField(
              controller: _message,
              enabled: !_sending,
              minLines: 3,
              maxLines: 8,
              maxLength: feedbackMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: switch (_kind) {
                  FeedbackKind.feature => 'What would you like gradll to do?',
                  FeedbackKind.problem => 'What happened, and what did you expect?',
                  FeedbackKind.other => 'Your message',
                },
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Sending…' : 'Send'),
              ),
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: GtSpace.md),
              const Divider(height: 1),
              const SizedBox(height: GtSpace.md),
              Text('What you’ve sent', style: t.labelLarge),
              for (final f in history) _SentTile(entry: f),
            ],
          ],
        ),
      ),
    );
  }
}

class _SentTile extends StatelessWidget {
  const _SentTile({required this.entry});

  final FeedbackEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final tone = switch (entry.status) {
      FeedbackStatus.received => gt.neutral,
      FeedbackStatus.planned => gt.info,
      FeedbackStatus.done => gt.success,
      FeedbackStatus.declined => gt.neutral,
    };
    return Padding(
      padding: const EdgeInsets.only(top: GtSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.message, style: t.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                Text(
                  '${entry.kind.label} · ${DateFormat('d MMM y').format(entry.createdAt.toLocal())}',
                  style: t.bodySmall?.copyWith(color: gt.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: GtSpace.sm),
          ToneChip(label: entry.status.label, tone: tone),
        ],
      ),
    );
  }
}
