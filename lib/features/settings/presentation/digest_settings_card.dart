import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/presentation/form/deadline_field.dart' show TimezoneField;
import '../domain/profile.dart';
import 'profile_controller.dart';

/// Settings → Daily digest. Every control saves as soon as it changes.
class DigestSettingsCard extends ConsumerStatefulWidget {
  const DigestSettingsCard({super.key});

  @override
  ConsumerState<DigestSettingsCard> createState() => _DigestSettingsCardState();
}

class _DigestSettingsCardState extends ConsumerState<DigestSettingsCard> {
  bool _sending = false;

  Future<void> _save(Profile next) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(profileControllerProvider.notifier).save(next);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Couldn’t save. ${describeError(e)}')));
    }
  }

  Future<void> _test() async {
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await ref.read(profileControllerProvider.notifier).sendTestDigest();
      messenger.showSnackBar(SnackBar(
        content: Text(
          r.message ??
              (r.sent
                  ? 'Sent to ${r.to ?? 'your email'} with ${r.itemCount} item${r.itemCount == 1 ? '' : 's'}.'
                  : 'Not sent.'),
        ),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Couldn’t send the test digest. ${describeError(e)}')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  static String _hourLabel(int h) => '${h.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final value = ref.watch(profileControllerProvider);
    final p = value.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.digest, tone: gt.info, size: 40),
                const SizedBox(width: GtSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily digest', style: t.titleSmall),
                      Text(
                        'One email each morning with what’s overdue, due today and due this week.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (p != null)
                  Switch(
                    value: p.digestEnabled,
                    onChanged: (on) => _save(p.copyWith(digestEnabled: on)),
                  ),
              ],
            ),
            if (p == null && value.hasError) ...[
              const SizedBox(height: GtSpace.md),
              ErrorBanner(error: value.error!, onRetry: () => ref.invalidate(profileControllerProvider)),
            ] else if (p == null) ...[
              const SizedBox(height: GtSpace.md),
              const LinearProgressIndicator(minHeight: 2),
            ] else ...[
              const SizedBox(height: GtSpace.lg),
              TimezoneField(
                label: 'Your time zone',
                value: p.timezone,
                onChanged: (z) => _save(p.copyWith(timezone: z)),
              ),
              const SizedBox(height: GtSpace.md),
              DropdownMenu<int>(
                key: ValueKey(p.digestHour),
                initialSelection: p.digestHour,
                label: const Text('Send at'),
                enabled: p.digestEnabled,
                expandedInsets: EdgeInsets.zero,
                onSelected: (h) {
                  if (h != null) _save(p.copyWith(digestHour: h));
                },
                dropdownMenuEntries: [
                  for (var h = 0; h < 24; h++) DropdownMenuEntry(value: h, label: _hourLabel(h)),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: p.digestSendWhenEmpty,
                onChanged: p.digestEnabled ? (on) => _save(p.copyWith(digestSendWhenEmpty: on)) : null,
                title: Text('Send on quiet days too', style: t.bodyMedium),
                subtitle: const Text('An “All clear today” email when nothing needs you.'),
              ),
              const SizedBox(height: GtSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.digestEnabled
                          ? 'Next digest around ${_hourLabel(p.digestHour)} ${p.timezone}'
                              '${p.email == null ? '' : ' to ${p.email}'}.'
                          : 'The daily digest is off.',
                      style: t.bodySmall,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _sending ? null : _test,
                    child: Text(_sending ? 'Sending…' : 'Send test digest'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
