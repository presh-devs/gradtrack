import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/platform/browser_file.dart';
import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/presentation/form/deadline_field.dart';
import '../domain/csv_import.dart';
import '../domain/value_parsers.dart';
import 'import_controller.dart';

/// `/applications/import` — CSV / spreadsheet import (spec S11, US-02).
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(importWizardProvider.select((s) => s.step));
    final wide = MediaQuery.sizeOf(context).width >= GtBreakpoints.medium;
    final pad = wide ? GtSpace.xxl : GtSpace.lg;

    final body = switch (step) {
      ImportStep.source => const _SourceStep(),
      ImportStep.columns => const _ColumnsStep(),
      ImportStep.review => const _ReviewStep(),
      ImportStep.done => const _DoneStep(),
    };

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, GtSpace.lg, pad, GtSpace.xl),
              children: [
                PageBody(
                  maxWidth: 960,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => context.go(Routes.applications),
                          icon: const GtIcon(GtIcons.back, size: 18),
                          label: const Text('Applications'),
                        ),
                      ),
                      const PageHeader(
                        title: 'Import applications',
                        subtitle: 'Bring in your existing spreadsheet. Nothing is saved until you confirm.',
                      ),
                      if (step != ImportStep.done) ...[
                        _Steps(current: step),
                        const SizedBox(height: GtSpace.xl),
                      ],
                      body,
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (step == ImportStep.columns || step == ImportStep.review) _ActionBar(step: step, pad: pad),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.current});

  final ImportStep current;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    const steps = [(ImportStep.source, 'Source'), (ImportStep.columns, 'Columns'), (ImportStep.review, 'Review')];
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: GtSpace.sm),
                color: steps[i].$1.index <= current.index ? gt.primary : gt.border,
              ),
            ),
          Builder(builder: (context) {
            final (step, label) = steps[i];
            final done = step.index < current.index;
            final active = step == current;
            return Semantics(
              label: 'Step ${i + 1} of 3: $label${active ? ', current' : done ? ', done' : ''}',
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done || active ? gt.primary : gt.surfaceAlt,
                    ),
                    child: done
                        ? GtIcon(GtIcons.check, size: 16, color: gt.onPrimary)
                        : Text(
                            '${i + 1}',
                            style: t.labelMedium?.copyWith(color: active ? gt.onPrimary : gt.textMuted),
                          ),
                  ),
                  const SizedBox(width: GtSpace.sm),
                  Text(label, style: t.labelLarge?.copyWith(color: active ? gt.textPrimary : gt.textMuted)),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ── Step 1: source ──────────────────────────────────────────────────────

class _SourceStep extends ConsumerStatefulWidget {
  const _SourceStep();

  @override
  ConsumerState<_SourceStep> createState() => _SourceStepState();
}

class _SourceStepState extends ConsumerState<_SourceStep> {
  final _paste = TextEditingController();
  bool _picking = false;

  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final file = await pickTextFile();
      if (file != null) ref.read(importWizardProvider.notifier).load(file.name, file.text);
    } catch (e) {
      ref.read(importWizardProvider.notifier).sourceFailed("Couldn't read that file: ${describeError(e)}");
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(importWizardProvider.select((s) => s.sourceError));
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= GtBreakpoints.expanded;

    final upload = Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconWell(icon: GtIcons.import, tone: gt.info, size: 48),
            const SizedBox(height: GtSpace.lg),
            Text('Upload a file', style: t.titleMedium),
            const SizedBox(height: GtSpace.xs),
            Text('A .csv or .tsv exported from Excel, Google Sheets or Numbers.', style: t.bodyMedium),
            const SizedBox(height: GtSpace.xl),
            Wrap(
              spacing: GtSpace.md,
              runSpacing: GtSpace.sm,
              children: [
                FilledButton(
                  onPressed: _picking ? null : _pick,
                  child: Text(_picking ? 'Opening…' : 'Choose file'),
                ),
                TextButton.icon(
                  onPressed: () => downloadTextFile('gradtrack-template.csv', buildTemplateCsv()),
                  icon: const GtIcon(GtIcons.download, size: 18),
                  label: const Text('Download template'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final paste = Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: IconWell(icon: GtIcons.copy, tone: gt.violet, size: 48)),
            const SizedBox(height: GtSpace.lg),
            Text('Paste from a spreadsheet', style: t.titleMedium),
            const SizedBox(height: GtSpace.xs),
            Text('Select the cells including the header row, copy, and paste here.', style: t.bodyMedium),
            const SizedBox(height: GtSpace.lg),
            TextField(
              controller: _paste,
              minLines: 4,
              maxLines: 8,
              style: t.bodySmall?.copyWith(fontFamily: 'monospace', color: gt.textPrimary),
              decoration: const InputDecoration(hintText: 'University\tProgramme\tDeadline\nMcGill\tComputer Science\t2026-12-01'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: GtSpace.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: _paste.text.trim().isEmpty
                    ? null
                    : () => ref.read(importWizardProvider.notifier).load('Pasted data', _paste.text),
                child: const Text('Use pasted data'),
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null) ...[
          _Banner(tone: gt.danger, icon: GtIcons.error, text: error),
          const SizedBox(height: GtSpace.lg),
        ],
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Expanded(child: upload), const SizedBox(width: GtSpace.lg), Expanded(child: paste)],
            ),
          )
        else ...[
          upload,
          const SizedBox(height: GtSpace.lg),
          paste,
        ],
        const SizedBox(height: GtSpace.lg),
        Text(
          'Recognised columns: ${ImportField.values.map((f) => f.label).join(', ')}. '
          'Only University and Programme are required; anything else can be added later.',
          style: t.bodySmall,
        ),
      ],
    );
  }
}

// ── Step 2: columns ─────────────────────────────────────────────────────

class _ColumnsStep extends ConsumerWidget {
  const _ColumnsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final table = wizard.table!;
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= GtBreakpoints.medium;
    final hasAmbiguousDates = [ImportField.deadline, ImportField.fundingDeadline].any((f) {
      final col = wizard.mapping.entries.where((e) => e.value == f).firstOrNull?.key;
      return col != null && table.rows.any((r) => isAmbiguousNumericDate(r[col]));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wizard.missingRequired.isNotEmpty) ...[
          _Banner(
            tone: gt.danger,
            icon: GtIcons.error,
            text: 'Choose which column holds: ${wizard.missingRequired.map((f) => f.label).join(' and ')}.',
          ),
          const SizedBox(height: GtSpace.lg),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(GtSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${wizard.sourceName} · ${table.rows.length} rows', style: t.titleMedium),
                Text(
                  'Matched ${wizard.mapping.length} of ${table.headers.length} columns. Adjust any that are wrong.',
                  style: t.bodySmall,
                ),
                const SizedBox(height: GtSpace.lg),
                for (var c = 0; c < table.headers.length; c++) ...[
                  if (c > 0) const Divider(height: GtSpace.xl),
                  _ColumnRow(
                    header: table.headers[c].isEmpty ? 'Column ${c + 1}' : table.headers[c],
                    sample: table.sample(c),
                    value: wizard.mapping[c],
                    wide: wide,
                    onChanged: (f) => notifier.mapColumn(c, f),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: GtSpace.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(GtSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Options', style: t.titleMedium),
                const SizedBox(height: GtSpace.lg),
                TimezoneField(value: wizard.defaultZone, label: 'Default time zone', onChanged: notifier.setDefaultZone),
                const SizedBox(height: GtSpace.xs),
                Text(
                  'Used for deadlines without a time zone column, a zone in the date, or a known country.',
                  style: t.bodySmall,
                ),
                const SizedBox(height: GtSpace.lg),
                Text('Numeric dates like 03/04/2026 are', style: t.labelLarge),
                const SizedBox(height: GtSpace.sm),
                SegmentedButton<DateOrder>(
                  segments: [for (final o in DateOrder.values) ButtonSegment(value: o, label: Text(o.label))],
                  selected: {wizard.dateOrder},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => notifier.setDateOrder(s.first),
                ),
                if (hasAmbiguousDates)
                  Padding(
                    padding: const EdgeInsets.only(top: GtSpace.xs),
                    child: Text(
                      'Some dates in this file could be read either way. Check this setting.',
                      style: t.bodySmall?.copyWith(color: gt.warning.fg),
                    ),
                  ),
                const SizedBox(height: GtSpace.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: wizard.seedRequirements,
                  onChanged: notifier.setSeedRequirements,
                  title: Text('Add common requirements', style: t.titleSmall),
                  subtitle: const Text('Transcript, CV, statement of purpose, English test and fee on each application.'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({
    required this.header,
    required this.sample,
    required this.value,
    required this.wide,
    required this.onChanged,
  });

  final String header;
  final String sample;
  final ImportField? value;
  final bool wide;
  final ValueChanged<ImportField?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: t.titleSmall, overflow: TextOverflow.ellipsis),
        Text(
          sample.isEmpty ? 'Empty' : 'e.g. $sample',
          style: t.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    final picker = LayoutBuilder(
      builder: (context, c) => DropdownMenu<ImportField?>(
        width: c.maxWidth,
        initialSelection: value,
        key: ValueKey(value), // re-sync when another row takes this field
        requestFocusOnTap: false,
        leadingIcon: Center(
          widthFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
            child: GtIcon(
              value == null ? GtIcons.close : GtIcons.check,
              size: 18,
              color: value == null ? gt.textMuted : gt.success.fg,
            ),
          ),
        ),
        onSelected: onChanged,
        dropdownMenuEntries: [
          const DropdownMenuEntry(value: null, label: "Don't import"),
          for (final f in ImportField.values) DropdownMenuEntry(value: f, label: f.required ? '${f.label} *' : f.label),
        ],
      ),
    );
    return wide
        ? Row(
            children: [
              Expanded(flex: 5, child: info),
              const SizedBox(width: GtSpace.lg),
              Expanded(flex: 4, child: picker),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info, const SizedBox(height: GtSpace.sm), picker],
          );
  }
}

// ── Step 3: review ──────────────────────────────────────────────────────

class _ReviewStep extends ConsumerStatefulWidget {
  const _ReviewStep();

  @override
  ConsumerState<_ReviewStep> createState() => _ReviewStepState();
}

enum _Filter { all, ready, problems }

class _ReviewStepState extends ConsumerState<_ReviewStep> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(importPreviewProvider);
    final submit = ref.watch(importSubmitterProvider);
    final gt = context.gt;

    return switch (preview) {
      AsyncValue(:final value?) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (submit.hasError && !submit.isLoading) ...[
              _Banner(
                tone: gt.danger,
                icon: GtIcons.error,
                text: 'Nothing was imported. ${describeError(submit.error!)}',
              ),
              const SizedBox(height: GtSpace.lg),
            ],
            _Summary(rows: value),
            const SizedBox(height: GtSpace.lg),
            SegmentedButton<_Filter>(
              segments: const [
                ButtonSegment(value: _Filter.all, label: Text('All')),
                ButtonSegment(value: _Filter.ready, label: Text('Ready')),
                ButtonSegment(value: _Filter.problems, label: Text('Skipped')),
              ],
              selected: {_filter},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
            const SizedBox(height: GtSpace.md),
            Card(
              child: Column(
                children: [
                  for (final (i, row) in value
                      .where((r) => switch (_filter) {
                            _Filter.all => true,
                            _Filter.ready => r.status == RowStatus.ready,
                            _Filter.problems => r.status != RowStatus.ready,
                          })
                      .indexed) ...[
                    if (i > 0) const Divider(indent: 72),
                    _RowTile(row: row),
                  ],
                ],
              ),
            ),
          ],
        ),
      AsyncValue(:final error?) => ErrorCard(error: error, onRetry: () => ref.invalidate(importPreviewProvider)),
      _ => const SizedBox(height: 300, child: SkeletonList(rows: 4)),
    };
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.rows});

  final List<ImportRow> rows;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    int count(RowStatus s) => rows.where((r) => r.status == s).length;
    final warnings = rows.where((r) => r.status == RowStatus.ready && r.warnings.isNotEmpty).length;
    return Wrap(
      spacing: GtSpace.sm,
      runSpacing: GtSpace.sm,
      children: [
        ToneChip(label: '${count(RowStatus.ready)} ready to import', tone: gt.success, icon: GtIcons.check),
        if (count(RowStatus.invalid) > 0)
          ToneChip(label: '${count(RowStatus.invalid)} need fixing', tone: gt.danger, icon: GtIcons.error),
        if (count(RowStatus.duplicate) > 0)
          ToneChip(label: '${count(RowStatus.duplicate)} already in GradTrack', tone: gt.neutral, icon: GtIcons.copy),
        if (warnings > 0) ToneChip(label: '$warnings with notes', tone: gt.warning, icon: GtIcons.info),
      ],
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});

  final ImportRow row;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    final d = row.draft!;
    final (icon, tone, status) = switch (row.status) {
      RowStatus.ready => (GtIcons.check, gt.success, 'Ready'),
      RowStatus.invalid => (GtIcons.error, gt.danger, 'Skipped'),
      RowStatus.duplicate => (GtIcons.copy, gt.neutral, 'Already in GradTrack'),
    };
    final deadline = d.deadline.toDeadline();
    final title = [
      if (d.institutionName.trim().isNotEmpty) d.institutionName.trim() else 'No university',
      if (d.programmeName.trim().isNotEmpty) '${d.degree.label} ${d.programmeName.trim()}',
    ].join(' · ');

    return Semantics(
      label: 'Line ${row.line}, $status: $title',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconWell(icon: icon, tone: tone, size: 40),
            const SizedBox(width: GtSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Line ${row.line}', style: t.labelSmall),
                  Text(title, style: t.titleSmall),
                  if (deadline != null)
                    Text(
                      'Deadline ${deadline.zoneLabel} · ${row.zoneSource}'
                      '${d.institutionId != null ? ' · existing university' : ''}',
                      style: t.bodySmall,
                    ),
                  for (final e in row.errors) Text(e, style: t.bodySmall?.copyWith(color: gt.danger.fg)),
                  if (row.status == RowStatus.duplicate)
                    Text('Same university, programme and degree as one you already have.', style: t.bodySmall),
                  for (final w in row.warnings) Text(w, style: t.bodySmall?.copyWith(color: gt.warning.fg)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Done ────────────────────────────────────────────────────────────────

class _DoneStep extends ConsumerWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(importSubmitterProvider).value;
    final gt = context.gt;
    final t = Theme.of(context).textTheme;
    final apps = summary?.applications ?? 0;
    final unis = summary?.institutions ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GtSpace.xl, vertical: 48),
        child: Column(
          children: [
            IconWell(icon: GtIcons.check, tone: gt.success, size: 64),
            const SizedBox(height: GtSpace.lg),
            Text('Imported $apps application${apps == 1 ? '' : 's'}', style: t.headlineSmall),
            const SizedBox(height: GtSpace.xs),
            Text(
              unis == 0 ? 'All universities were already in your list.' : 'Added $unis new universit${unis == 1 ? 'y' : 'ies'}.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: GtSpace.xl),
            Wrap(
              spacing: GtSpace.md,
              runSpacing: GtSpace.sm,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(onPressed: () => context.go(Routes.applications), child: const Text('View applications')),
                OutlinedButton(onPressed: () => context.go(Routes.today), child: const Text('Go to Today')),
                TextButton(
                  onPressed: () {
                    ref.invalidate(importSubmitterProvider);
                    ref.read(importWizardProvider.notifier).reset();
                  },
                  child: const Text('Import another file'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared ──────────────────────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.step, required this.pad});

  final ImportStep step;
  final double pad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gt = context.gt;
    final wizard = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final preview = ref.watch(importPreviewProvider);
    final submitting = ref.watch(importSubmitterProvider).isLoading;
    final ready = preview.value?.where((r) => r.status == RowStatus.ready).length ?? 0;

    final (back, next) = switch (step) {
      ImportStep.columns => (
          OutlinedButton(onPressed: () => notifier.goTo(ImportStep.source), child: const Text('Back')),
          FilledButton(
            onPressed: wizard.missingRequired.isEmpty ? () => notifier.goTo(ImportStep.review) : null,
            child: Text('Review ${wizard.table?.rows.length ?? 0} rows'),
          ),
        ),
      _ => (
          OutlinedButton(
            onPressed: submitting ? null : () => notifier.goTo(ImportStep.columns),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: ready == 0 || submitting ? null : () => ref.read(importSubmitterProvider.notifier).submit(),
            child: submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Import $ready application${ready == 1 ? '' : 's'}'),
          ),
        ),
    };

    return Container(
      decoration: BoxDecoration(color: gt.surface, border: Border(top: BorderSide(color: gt.border))),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: GtSpace.md),
      child: PageBody(
        maxWidth: 960,
        child: Row(children: [back, const Spacer(), next]),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.tone, required this.icon, required this.text});

  final GtTone tone;
  final GtGlyph icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(GtSpace.md),
        decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(GtRadius.md)),
        child: Row(
          children: [
            GtIcon(icon, size: 20, color: tone.fg),
            const SizedBox(width: GtSpace.md),
            Expanded(child: Text(text, style: TextStyle(color: tone.fg))),
          ],
        ),
      );
}
