import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import 'auth_controllers.dart';

/// Wraps the whole app: shows a "can't reach the server" strip on top while
/// the session can't be refreshed, instead of letting the error go uncaught.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authReachableProvider)) return child;

    final tone = context.gt.warning;
    return Column(
      children: [
        Material(
          color: tone.bg,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: GtSpace.sm),
              child: Row(
                children: [
                  GtIcon(GtIcons.offline, size: 18, color: tone.fg),
                  const SizedBox(width: GtSpace.sm),
                  Expanded(
                    child: Text(
                      "Can't reach the server. Changes may not load or save until it's back.",
                      style: TextStyle(color: tone.fg),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(authReachableProvider.notifier).retry(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // The banner already took the top inset.
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
      ],
    );
  }
}
