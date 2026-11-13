import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/icons.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/gt_widgets.dart';
import '../../data/programme_extractor.dart';
import '../../domain/application_draft.dart';
import '../../domain/programme_extraction.dart';

/// Field names the extractor may flag, as the form calls them.
const _fieldLabels = {
  'institution_name': 'university',
  'country_code': 'country',
  'location': 'location',
  'programme_name': 'programme name',
  'degree': 'degree',
  'department': 'department',
  'research_area': 'research area',
  'deadline': 'deadline',
  'deadline_date': 'deadline',
  'deadline_time': 'deadline time',
  'deadline_timezone': 'deadline time zone',
  'funding_deadline_date': 'funding deadline',
  'opens_on': 'applications open',
  'decision_expected': 'expected decision',
  'fee_amount': 'application fee',
  'fee_currency': 'fee currency',
  'tuition_amount': 'tuition',
  'tuition_currency': 'tuition currency',
  'portal_url': 'application portal',
  'requires_professor_acceptance': 'professor acceptance',
  'requirements': 'checklist',
};

/// "Fill from a programme page": paste a link (or the page's text) and the
/// form below is filled in for review. Nothing is saved until Save.
class FillFromPageCard extends ConsumerStatefulWidget {
  const FillFromPageCard({
    super.key,
    required this.onFilled,
    required this.requirements,
    required this.onRemoveRequirement,
  });

  final ValueChanged<ProgrammeExtraction> onFilled;

  /// The draft's checklist seeds, shown here so they can be trimmed before saving.
  final List<RequirementSeed> requirements;
  final ValueChanged<RequirementSeed> onRemoveRequirement;

  @override
  ConsumerState<FillFromPageCard> createState() => _FillFromPageCardState();
}

class _FillFromPageCardState extends ConsumerState<FillFromPageCard> {
  final _url = TextEditingController();
  final _text = TextEditingController();
  bool _pasteMode = false;
  bool _busy = false;
  String? _error;
  ProgrammeExtraction? _result;

  @override
  void dispose() {
    _url.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final url = _url.text.trim();
    final text = _text.text.trim();
    if (_pasteMode ? text.isEmpty : url.isEmpty) {
      setState(() => _error = _pasteMode ? 'Paste the page text first.' : 'Paste a link first.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final x = await ref
          .read(programmeExtractorProvider)
          .extract(url: _pasteMode ? null : url, text: _pasteMode ? text : null);
      if (!mounted) return;
      widget.onFilled(x);
      setState(() => _result = x);
    } on ExtractionException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        // The page couldn't be fetched or read: offer pasting straight away.
        if (!_pasteMode && (e.code == 'fetch' || e.code == 'empty' || e.code == 'refusal')) _pasteMode = true;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again, or fill the form in by hand.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final result = _result;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.link, tone: gt.violet, size: 36),
                const SizedBox(width: GtSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fill from a programme page', style: t.titleMedium),
                      Text(
                        'Paste the link to the programme’s page and gradll fills in what it can. '
                        'You check everything before saving.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GtSpace.md),
            if (!_pasteMode)
              TextField(
                controller: _url,
                enabled: !_busy,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                decoration: const InputDecoration(
                  hintText: 'https://university.edu/programmes/…',
                  isDense: true,
                ),
                onSubmitted: (_) => _run(),
              )
            else
              TextField(
                controller: _text,
                enabled: !_busy,
                minLines: 4,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'On the programme page, select all (Ctrl/⌘+A), copy, and paste here.',
                  alignLabelWithHint: true,
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: GtSpace.sm),
              Text(_error!, style: t.bodySmall?.copyWith(color: gt.danger.fg)),
            ],
            const SizedBox(height: GtSpace.sm),
            Wrap(
              spacing: GtSpace.sm,
              runSpacing: GtSpace.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _run,
                  icon: _busy
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const GtIcon(GtIcons.import, size: 18),
                  label: Text(_busy ? 'Reading the page…' : 'Fill in'),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _pasteMode = !_pasteMode;
                            _error = null;
                          }),
                  child: Text(_pasteMode ? 'Use a link instead' : 'Paste the page text instead'),
                ),
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: GtSpace.xs),
              Text('This usually takes 10–30 seconds.', style: t.bodySmall?.copyWith(color: gt.textMuted)),
            ],
            if (result != null && !_busy) ...[
              const SizedBox(height: GtSpace.md),
              const Divider(height: 1),
              const SizedBox(height: GtSpace.md),
              _Summary(
                result: result,
                requirements: widget.requirements,
                onRemoveRequirement: widget.onRemoveRequirement,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.result, required this.requirements, required this.onRemoveRequirement});

  final ProgrammeExtraction result;
  final List<RequirementSeed> requirements;
  final ValueChanged<RequirementSeed> onRemoveRequirement;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final check = {
      for (final f in result.checkFields)
        if (_fieldLabels[f] != null) _fieldLabels[f]!,
    }.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GtIcon(GtIcons.check, size: 18, color: gt.success.fg),
            const SizedBox(width: GtSpace.xs),
            Expanded(
              child: Text(
                'Filled ${result.filledCount} fields below. Check them against the page before saving.',
                style: t.bodyMedium,
              ),
            ),
          ],
        ),
        if (check.isNotEmpty) ...[
          const SizedBox(height: GtSpace.xs),
          Text('Double-check: ${check.join(', ')}.', style: t.bodySmall?.copyWith(color: gt.warning.fg)),
        ],
        if (result.truncated) ...[
          const SizedBox(height: GtSpace.xs),
          Text(
            'The page was very long, so only its first part was read.',
            style: t.bodySmall?.copyWith(color: gt.textMuted),
          ),
        ],
        if (requirements.isNotEmpty) ...[
          const SizedBox(height: GtSpace.md),
          Text('Checklist to add (remove any you don’t need)', style: t.labelLarge),
          const SizedBox(height: GtSpace.xs),
          Wrap(
            spacing: GtSpace.xs,
            runSpacing: GtSpace.xs,
            children: [
              for (final r in requirements)
                InputChip(
                  label: Text(r.title),
                  onDeleted: () => onRemoveRequirement(r),
                  deleteButtonTooltipMessage: 'Don’t add',
                ),
            ],
          ),
        ],
      ],
    );
  }
}
