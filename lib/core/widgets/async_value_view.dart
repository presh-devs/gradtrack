import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/icons.dart';
import '../theme/tokens.dart';

/// Renders an [AsyncValue] with consistent loading / error / data states.
///
/// * First load → [loading] (skeleton by default).
/// * Refresh with data already cached → keeps showing data with a thin
///   progress bar instead of flashing a spinner.
/// * Error with no data → error card with Retry.
/// * Error while data is cached → keeps data, shows an inline error banner.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) {
      // Same tree shape whether or not we're refreshing, so stateful content
      // (forms, scroll positions) survives a background reload.
      final refreshing = value.isLoading;
      final failed = value.hasError && !refreshing;
      return Stack(
        children: [
          Positioned.fill(child: data(value.requireValue)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: refreshing
                ? const LinearProgressIndicator(minHeight: 2)
                : failed
                    ? ErrorBanner(error: value.error!, onRetry: onRetry)
                    : const SizedBox.shrink(),
          ),
        ],
      );
    }
    if (value.hasError && !value.isLoading) {
      return Center(child: ErrorCard(error: value.error!, onRetry: onRetry));
    }
    return loading ?? const SkeletonList();
  }
}

String describeError(Object error) {
  final text = error.toString();
  if (text.contains('SocketException') || text.contains('ClientException')) {
    return "Couldn't reach the server. Check your connection.";
  }
  return text.replaceFirst('Exception: ', '').replaceFirst('FormatException: ', '');
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(GtSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GtIcon(GtIcons.offline, color: gt.danger.fg, size: 32),
              const SizedBox(height: GtSpace.md),
              Text('Something went wrong', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: GtSpace.xs),
              Text(describeError(error), textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: GtSpace.lg),
                OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tone = context.gt.danger;
    return Material(
      color: tone.bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: GtSpace.sm),
        child: Row(
          children: [
            GtIcon(GtIcons.error, size: 18, color: tone.fg),
            const SizedBox(width: GtSpace.sm),
            Expanded(
              child: Text(
                'Showing saved data. ${describeError(error)}',
                style: TextStyle(color: tone.fg),
              ),
            ),
            if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Placeholder rows shown on first load.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: gt.surfaceAlt,
            borderRadius: BorderRadius.circular(GtRadius.sm),
          ),
        );
    return Semantics(
      label: 'Loading',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(GtSpace.lg),
        itemCount: rows,
        separatorBuilder: (_, _) => const SizedBox(height: GtSpace.md),
        itemBuilder: (_, _) => Card(
          child: Padding(
            padding: const EdgeInsets.all(GtSpace.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: gt.surfaceAlt, shape: BoxShape.circle),
                ),
                const SizedBox(width: GtSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [bar(180, 14), const SizedBox(height: GtSpace.sm), bar(260, 12)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
