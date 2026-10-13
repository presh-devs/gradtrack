import 'package:flutter/material.dart';

import '../theme/icons.dart';
import '../theme/tokens.dart';

/// Pastel circle behind an icon — the Innixx list-row signature.
class IconWell extends StatelessWidget {
  const IconWell({super.key, required this.icon, required this.tone, this.size = 44});

  final GtGlyph icon;
  final GtTone tone;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: tone.bg, shape: BoxShape.circle),
        child: Center(child: GtIcon(icon, color: tone.fg, size: size * 0.48)),
      );
}

/// Small rounded label, e.g. a stage or countdown.
class ToneChip extends StatelessWidget {
  const ToneChip({super.key, required this.label, required this.tone, this.icon});

  final String label;
  final GtTone tone;
  final GtGlyph? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: tone.bg,
          borderRadius: BorderRadius.circular(GtRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              GtIcon(icon!, size: 14, color: tone.fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: tone.fg),
            ),
          ],
        ),
      );
}

/// Centres page content and caps its width on large screens.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = GtBreakpoints.contentMax});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}

/// Page title row used at the top of each destination.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, GtSpace.xl, 0, GtSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: Text(title, style: t.headlineMedium)),
                if (subtitle != null) ...[
                  const SizedBox(height: GtSpace.xs),
                  Text(subtitle!, style: t.bodyMedium),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final GtGlyph icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.xl, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconWell(icon: icon, tone: context.gt.info, size: 56),
            const SizedBox(height: GtSpace.lg),
            Text(title, style: t.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: GtSpace.xs),
            Text(message, style: t.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: GtSpace.lg), action!],
          ],
        ),
      ),
    );
  }
}

/// Thin rounded progress bar.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.color, this.track});

  final double value;
  final Color? color;
  final Color? track;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(GtRadius.pill),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          color: color ?? context.gt.primary,
          backgroundColor: track ?? context.gt.surfaceAlt,
        ),
      );
}
