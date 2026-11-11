import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../applications/domain/institution.dart';
import '../../applications/presentation/application_editor.dart';
import '../../import/domain/csv_import.dart';
import '../domain/professor.dart';
import '../domain/professor_import.dart';
import 'professors_controller.dart';

// ── Log email sent ────────────────────────────────────────────────────────

/// Follow-up choices after logging an email, in days (null = no reminder).
const _followUpChoices = <(int?, String)>[
  (7, 'In 1 week'),
  (14, 'In 2 weeks'),
  (21, 'In 3 weeks'),
  (null, 'No reminder'),
];

Future<({DateTime sentAt, DateTime? followUpAt})?> showLogSentDialog(
  BuildContext context, {
  required Professor professor,
  bool isFollowUp = false,
}) {
  var sentOn = DateUtils.dateOnly(DateTime.now());
  int? followUpDays = 14;
  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(isFollowUp ? 'Follow-up sent to ${professor.displayName}' : 'Emailed ${professor.displayName}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateButton(
                label: 'Sent on',
                value: sentOn,
                onChanged: (d) => setState(() => sentOn = d),
              ),
              const SizedBox(height: GtSpace.lg),
              DropdownMenu<int?>(
                initialSelection: followUpDays,
                label: const Text('Remind me to follow up'),
                expandedInsets: EdgeInsets.zero,
                onSelected: (v) => setState(() => followUpDays = v),
                dropdownMenuEntries: [
                  for (final (days, label) in _followUpChoices) DropdownMenuEntry(value: days, label: label),
                ],
              ),
              const SizedBox(height: GtSpace.sm),
              Text(
                followUpDays == null
                    ? 'No reminder will be set.'
                    : 'If there’s no reply by ${DateFormat('EEE d MMM').format(sentOn.add(Duration(days: followUpDays!)))}, '
                        'it shows up on Today.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              // A date picked as "today" keeps the current time so ordering
              // against a reply logged later today stays right.
              final now = DateTime.now();
              final sentAt = DateUtils.isSameDay(sentOn, now) ? now : sentOn.add(const Duration(hours: 12));
              final followUpAt = followUpDays == null
                  ? null
                  : DateTime(sentOn.year, sentOn.month, sentOn.day + followUpDays!, 9);
              Navigator.pop(context, (sentAt: sentAt, followUpAt: followUpAt));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

// ── Log reply ─────────────────────────────────────────────────────────────

Future<({DateTime at, ProfessorStance? stance})?> showLogReplyDialog(
  BuildContext context, {
  required Professor professor,
}) {
  var on = DateUtils.dateOnly(DateTime.now());
  var stance = professor.stance;
  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Reply from ${professor.displayName}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateButton(label: 'Received on', value: on, onChanged: (d) => setState(() => on = d)),
              const SizedBox(height: GtSpace.lg),
              Text('What did they say?', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: GtSpace.sm),
              RadioGroup<ProfessorStance>(
                groupValue: stance,
                onChanged: (v) => setState(() => stance = v!),
                child: Column(
                  children: [
                    for (final s in ProfessorStance.values)
                      RadioListTile<ProfessorStance>(
                        value: s,
                        title: Text(s == ProfessorStance.unknown ? 'Nothing definite yet' : s.label),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final now = DateTime.now();
              final at = DateUtils.isSameDay(on, now) ? now : on.add(const Duration(hours: 12));
              Navigator.pop(context, (at: at, stance: stance == professor.stance ? null : stance));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(GtRadius.md),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(now.year - 2),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: GtSpace.md, right: GtSpace.sm),
            child: GtIcon(GtIcons.thisWeek, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
        child: Text(
          DateUtils.isSameDay(value, DateTime.now()) ? 'Today' : DateFormat('EEE d MMM yyyy').format(value),
        ),
      ),
    );
  }
}

// ── Add / edit ────────────────────────────────────────────────────────────

Future<void> showProfessorEditor(BuildContext context, {Professor? professor}) => showDialog<void>(
      context: context,
      builder: (_) => _ProfessorEditor(professor: professor),
    );

class _ProfessorEditor extends ConsumerStatefulWidget {
  const _ProfessorEditor({this.professor});

  final Professor? professor;

  @override
  ConsumerState<_ProfessorEditor> createState() => _ProfessorEditorState();
}

class _ProfessorEditorState extends ConsumerState<_ProfessorEditor> {
  late ProfessorDraft _draft =
      widget.professor == null ? const ProfessorDraft() : ProfessorDraft.fromProfessor(widget.professor!);
  Map<String, String> _errors = const {};
  bool _saving = false;
  Object? _saveError;

  Future<void> _save() async {
    final errors = _draft.validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final notifier = ref.read(professorsControllerProvider.notifier);
    try {
      if (widget.professor == null) {
        await notifier.create(_draft);
      } else {
        await notifier.save(widget.professor!.id, _draft);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = e;
        });
      }
    }
  }

  Widget _field(
    String label,
    String? value,
    ProfessorDraft Function(String v) apply, {
    String? errorKey,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: GtSpace.md),
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorKey == null ? null : _errors[errorKey],
          ),
          minLines: 1,
          maxLines: maxLines,
          keyboardType: keyboard,
          onChanged: (v) => setState(() => _draft = apply(v)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final institutions = ref.watch(institutionsProvider).value ?? const <Institution>[];
    return AlertDialog(
      title: Text(widget.professor == null ? 'Add professor' : 'Edit ${widget.professor!.displayName}'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: GtSpace.md),
                child: Autocomplete<Institution>(
                  initialValue: TextEditingValue(text: _draft.institutionName),
                  displayStringForOption: (i) => i.name,
                  optionsBuilder: (v) {
                    final q = v.text.trim().toLowerCase();
                    return q.isEmpty
                        ? institutions
                        : institutions.where((i) => i.name.toLowerCase().contains(q));
                  },
                  onSelected: (i) => setState(
                    () => _draft = _draft.copyWith(institutionId: i.id, institutionName: i.name),
                  ),
                  fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
                    controller: controller,
                    focusNode: focus,
                    decoration: InputDecoration(
                      labelText: 'University or institute',
                      errorText: _errors['institution'],
                    ),
                    onChanged: (v) {
                      final match = institutions.where((i) => i.name.toLowerCase() == v.trim().toLowerCase());
                      setState(
                        () => _draft = _draft.copyWith(
                          institutionId: match.firstOrNull?.id,
                          institutionName: match.firstOrNull?.name ?? v,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: _field('Title', _draft.academicTitle, (v) => _draft.copyWith(academicTitle: v),
                        hint: 'Prof.'),
                  ),
                  const SizedBox(width: GtSpace.md),
                  Expanded(
                    child: _field('Name', _draft.name, (v) => _draft.copyWith(name: v), errorKey: 'name'),
                  ),
                ],
              ),
              _field('Department or lab', _draft.department, (v) => _draft.copyWith(department: v)),
              _field('Email', _draft.email, (v) => _draft.copyWith(email: v),
                  errorKey: 'email', keyboard: TextInputType.emailAddress),
              _field('Website', _draft.profileUrl, (v) => _draft.copyWith(profileUrl: v),
                  errorKey: 'profileUrl', hint: 'https://', keyboard: TextInputType.url),
              _field('Research interests', _draft.researchInterests, (v) => _draft.copyWith(researchInterests: v),
                  maxLines: 3),
              _field('Notes', _draft.notes, (v) => _draft.copyWith(notes: v),
                  hint: 'Papers you read, what to mention…', maxLines: 4),
              if (_saveError != null) ErrorBanner(error: _saveError!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
      ],
    );
  }
}

// ── Paste a list ──────────────────────────────────────────────────────────

Future<void> showProfessorPasteDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => const _PasteDialog(),
    );

class _PasteDialog extends ConsumerStatefulWidget {
  const _PasteDialog();

  @override
  ConsumerState<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends ConsumerState<_PasteDialog> {
  final _text = TextEditingController();
  CsvTable? _table;
  Map<int, ProfessorField> _mapping = {};
  bool _saving = false;
  Object? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _read() {
    final table = CsvTable.parse(_text.text);
    setState(() {
      _table = table.isEmpty ? null : table;
      _mapping = table.isEmpty ? {} : autoMapProfessors(table.headers);
      _error = table.isEmpty ? 'Paste the header row and at least one professor.' : null;
    });
  }

  Future<void> _import(List<ProfessorImportRow> rows) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final r = await ref
          .read(professorsControllerProvider.notifier)
          .importAll([for (final row in rows) if (row.ok) row.import!]);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${r.professors} professors'
            '${r.skipped > 0 ? ' · ${r.skipped} already saved' : ''}'
            '${r.institutions > 0 ? ' · ${r.institutions} new universities' : ''}',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final table = _table;
    final rows = table == null ? const <ProfessorImportRow>[] : buildProfessorRows(table, _mapping);
    final ready = rows.where((r) => r.ok).toList();
    final contacted = ready.where((r) => r.import!.contacted).length;
    final hasName = _mapping.containsValue(ProfessorField.name);
    final hasSchool = _mapping.containsValue(ProfessorField.school);

    return AlertDialog(
      title: const Text('Paste professors'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (table == null) ...[
                Text(
                  'Copy the rows from your sheet, including the header row (for example School, Supervisor, '
                  'Area of interest, Email, Website, Status), and paste them here. A blank School cell uses the '
                  'school above it. A status of “sent” marks them as already emailed.',
                  style: t.bodySmall,
                ),
                const SizedBox(height: GtSpace.md),
                TextField(
                  controller: _text,
                  minLines: 8,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    hintText: 'School\tSupervisor\tArea of interest\tEmail\nUSTC\tProf Wang Qingsong\tBattery fire safety\t…',
                    alignLabelWithHint: true,
                  ),
                  style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ] else ...[
                Text('Columns', style: t.titleSmall),
                const SizedBox(height: GtSpace.sm),
                for (var c = 0; c < table.headers.length; c++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GtSpace.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(table.headers[c].isEmpty ? 'Column ${c + 1}' : table.headers[c], style: t.bodyMedium),
                              Text(
                                table.sample(c).isEmpty ? 'Empty' : 'e.g. ${table.sample(c)}',
                                style: t.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: GtSpace.md),
                        SizedBox(
                          width: 220,
                          child: DropdownMenu<ProfessorField?>(
                            key: ValueKey(_mapping[c]),
                            initialSelection: _mapping[c],
                            expandedInsets: EdgeInsets.zero,
                            requestFocusOnTap: false,
                            onSelected: (f) => setState(() {
                              _mapping = {..._mapping}..removeWhere((k, v) => k == c || v == f);
                              if (f != null) _mapping[c] = f;
                            }),
                            dropdownMenuEntries: [
                              const DropdownMenuEntry(value: null, label: 'Don’t import'),
                              for (final f in ProfessorField.values) DropdownMenuEntry(value: f, label: f.label),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: GtSpace.xl),
                if (!hasName || !hasSchool)
                  Text(
                    'Choose which column holds the ${[if (!hasSchool) 'school', if (!hasName) 'name'].join(' and ')}.',
                    style: t.bodyMedium?.copyWith(color: gt.danger.fg),
                  )
                else ...[
                  Text(
                    '${ready.length} professors ready'
                    '${contacted > 0 ? ' · $contacted already emailed' : ''}'
                    '${rows.length > ready.length ? ' · ${rows.length - ready.length} skipped' : ''}',
                    style: t.titleSmall,
                  ),
                  const SizedBox(height: GtSpace.xs),
                  for (final r in rows.where((r) => !r.ok).take(5))
                    Text('Line ${r.line}: ${r.errors.join('; ')}', style: t.bodySmall?.copyWith(color: gt.danger.fg)),
                  for (final r in ready.take(4))
                    Text(
                      '${r.import!.draft.institutionName} · ${[r.import!.draft.academicTitle, r.import!.draft.name].nonNulls.join(' ')}'
                      '${r.import!.draft.email == null ? '' : ' · ${r.import!.draft.email}'}',
                      style: t.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (ready.length > 4) Text('…and ${ready.length - 4} more', style: t.bodySmall),
                  if (contacted > 0) ...[
                    const SizedBox(height: GtSpace.sm),
                    Text(
                      'Already-emailed professors are logged as emailed today with no reminder, since the sheet '
                      'doesn’t say when. Use “Log follow-up sent” on anyone you chase.',
                      style: t.bodySmall,
                    ),
                  ],
                ],
              ],
              if (_error != null) ...[
                const SizedBox(height: GtSpace.md),
                _error is String
                    ? Text(_error as String, style: t.bodySmall?.copyWith(color: gt.danger.fg))
                    : ErrorBanner(error: _error!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (table != null)
          TextButton(onPressed: _saving ? null : () => setState(() => _table = null), child: const Text('Back')),
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        if (table == null)
          FilledButton(onPressed: _read, child: const Text('Next'))
        else
          FilledButton(
            onPressed: _saving || ready.isEmpty || !hasName || !hasSchool ? null : () => _import(rows),
            child: Text(_saving ? 'Importing…' : 'Import ${ready.length}'),
          ),
      ],
    );
  }
}
