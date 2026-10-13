import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/icons.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/gt_widgets.dart';
import '../../domain/application.dart';
import '../../domain/application_draft.dart';
import '../../domain/institution.dart';
import '../application_editor.dart';
import '../applications_controller.dart';
import '../stage_style.dart';
import 'deadline_field.dart';

/// `/applications/new` and `/applications/:id/edit` (spec S5).
class ApplicationFormScreen extends ConsumerWidget {
  const ApplicationFormScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = id;
    if (editId == null) {
      final zone = ref.read(lastDeadlineZoneProvider);
      return _ApplicationForm(
        initial: ApplicationDraft(
          deadline: DeadlineInput(zone: zone),
          fundingDeadline: DeadlineInput(zone: zone),
        ),
      );
    }
    final app = ref.watch(applicationByIdProvider(editId));
    return Scaffold(
      body: AsyncValueView(
        value: app,
        onRetry: () => ref.invalidate(applicationsControllerProvider),
        data: (a) => a == null
            ? Center(
                child: EmptyState(
                  icon: GtIcons.notFound,
                  title: 'Application not found',
                  message: 'It may have been archived or deleted.',
                  action: FilledButton(
                    onPressed: () => context.go(Routes.applications),
                    child: const Text('Back to applications'),
                  ),
                ),
              )
            // Keyed by id so a different application gets a fresh form.
            : _ApplicationForm(
                key: ValueKey(a.id),
                id: a.id,
                initial: ApplicationDraft.fromApplication(
                  a,
                  // Unset deadlines default to the university's zone, else the last one used.
                  fallbackZone:
                      ref
                          .read(institutionsProvider)
                          .value
                          ?.where((i) => i.id == a.institutionId)
                          .firstOrNull
                          ?.defaultTz ??
                      ref.read(lastDeadlineZoneProvider),
                ),
              ),
      ),
    );
  }
}

class _ApplicationForm extends ConsumerStatefulWidget {
  const _ApplicationForm({super.key, required this.initial, this.id});

  final ApplicationDraft initial;
  final String? id;

  @override
  ConsumerState<_ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends ConsumerState<_ApplicationForm> {
  late ApplicationDraft _draft = widget.initial;
  late bool _showFunding = widget.initial.fundingDeadline.isSet;
  late bool _showMore = widget.id != null;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  /// Ctrl/⌘ + Enter saves. A global handler runs before the focused text
  /// field, which would otherwise consume Enter.
  bool _onKey(KeyEvent event) {
    final kb = HardwareKeyboard.instance;
    final isSave =
        event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        (kb.isControlPressed || kb.isMetaPressed);
    // Only while this form is the visible route (not under a dialog/picker).
    if (!isSave || !mounted || ModalRoute.of(context)?.isCurrent != true) {
      return false;
    }
    if (!ref.read(applicationEditorProvider).isLoading) _save();
    return true;
  }

  bool get _isNew => widget.id == null;
  bool get _dirty => _draft != widget.initial;

  void _update(ApplicationDraft Function(ApplicationDraft d) change) =>
      setState(() => _draft = change(_draft));

  String? _error(DraftField f) => _attempted ? _draft.validate()[f] : null;

  Future<void> _save() async {
    setState(() => _attempted = true);
    final draft = _showFunding
        ? _draft
        : _draft.copyWith(fundingDeadline: const DeadlineInput());
    if (draft.validate().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check the highlighted fields.')),
      );
      return;
    }
    final savedId = await ref
        .read(applicationEditorProvider.notifier)
        .save(draft, id: widget.id);
    if (!mounted || savedId == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isNew ? 'Application added' : 'Changes saved')),
    );
    // Replace the form in history so Back doesn't return to it.
    context.go(Routes.application(savedId));
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'Your edits to this application haven’t been saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _cancel() async {
    if (!await _confirmDiscard() || !mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_isNew ? Routes.applications : Routes.application(widget.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(applicationEditorProvider);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= GtBreakpoints.medium;
    final pad = wide ? GtSpace.xxl : GtSpace.lg;
    final t = Theme.of(context).textTheme;
    final gt = context.gt;

    Widget pair(Widget a, Widget b) => wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: GtSpace.md),
              Expanded(child: b),
            ],
          )
        : Column(
            children: [
              a,
              const SizedBox(height: GtSpace.md),
              b,
            ],
          );

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _cancel,
            icon: const GtIcon(GtIcons.back, size: 18),
            label: Text(_isNew ? 'Applications' : 'Back'),
          ),
        ),
        PageHeader(
          title: _isNew ? 'Add application' : 'Edit application',
          subtitle: _isNew
              ? 'Only the university and programme are required. Add the rest any time.'
              : _draft.institutionName,
        ),

        // ── Programme ──────────────────────────────────────────────
        _Section(
          title: 'Programme',
          icon: GtIcons.university,
          tone: gt.info,
          children: [
            _InstitutionField(
              draft: _draft,
              errorText: _error(DraftField.institution),
              onUpdate: _update,
            ),
            if (_draft.createsInstitution &&
                _draft.institutionName.trim().isNotEmpty) ...[
              const SizedBox(height: GtSpace.md),
              _CountryField(
                value: _draft.institutionCountry,
                onChanged: (code) => _update((d) {
                  final suggested = countryDefaultZones[code];
                  // Prefill the deadline zone from the country unless the date is already set up.
                  final adjustZone = suggested != null && !d.deadline.isSet;
                  return d.copyWith(
                    institutionCountry: code,
                    deadline: adjustZone
                        ? d.deadline.copyWith(zone: suggested)
                        : d.deadline,
                    fundingDeadline: adjustZone
                        ? d.fundingDeadline.copyWith(zone: suggested)
                        : d.fundingDeadline,
                  );
                }),
              ),
            ],
            const SizedBox(height: GtSpace.md),
            pair(
              TextFormField(
                initialValue: _draft.programmeName,
                decoration: InputDecoration(
                  labelText: 'Programme name *',
                  hintText: 'e.g. Computer Science',
                  errorText: _error(DraftField.programmeName),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (v) => _update((d) => d.copyWith(programmeName: v)),
              ),
              _Dropdown<DegreeType>(
                label: 'Degree',
                value: _draft.degree,
                values: DegreeType.values,
                labelOf: (d) => d.label,
                onChanged: (v) => _update((d) => d.copyWith(degree: v)),
              ),
            ),
            const SizedBox(height: GtSpace.md),
            pair(
              TextFormField(
                initialValue: _draft.department,
                decoration: const InputDecoration(labelText: 'Department'),
                onChanged: (v) => _update((d) => d.copyWith(department: v)),
              ),
              TextFormField(
                initialValue: _draft.researchArea,
                decoration: const InputDecoration(
                  labelText: 'Research area',
                  hintText: 'e.g. NLP, robotics',
                ),
                onChanged: (v) => _update((d) => d.copyWith(researchArea: v)),
              ),
            ),
          ],
        ),

        // ── Deadlines ──────────────────────────────────────────────
        _Section(
          title: 'Deadlines',
          subtitle: 'Enter them exactly as the university publishes them, in its own time zone.',
          icon: GtIcons.deadline,
          tone: gt.warning,
          children: [
            DeadlineField(
              label: 'Application deadline',
              value: _draft.deadline,
              errorText: _error(DraftField.deadline),
              onUpdate: (f) =>
                  _update((d) => d.copyWith(deadline: f(d.deadline))),
            ),
            const SizedBox(height: GtSpace.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _showFunding,
              onChanged: (on) => setState(() {
                _showFunding = on;
                if (on && !_draft.fundingDeadline.isSet) {
                  _draft = _draft.copyWith(
                    fundingDeadline: _draft.fundingDeadline.copyWith(
                      zone: _draft.deadline.zone,
                    ),
                  );
                }
              }),
              title: Text(
                'Separate funding or scholarship deadline',
                style: t.titleSmall,
              ),
              subtitle: const Text(
                'Often earlier than the application deadline.',
              ),
            ),
            if (_showFunding) ...[
              const SizedBox(height: GtSpace.sm),
              DeadlineField(
                label: 'Funding deadline',
                value: _draft.fundingDeadline,
                errorText: _error(DraftField.fundingDeadline),
                onUpdate: (f) => _update(
                  (d) => d.copyWith(fundingDeadline: f(d.fundingDeadline)),
                ),
              ),
            ],
          ],
        ),

        // ── Status ─────────────────────────────────────────────────
        _Section(
          title: 'Status',
          icon: GtIcons.checklist,
          tone: gt.success,
          children: [
            pair(
              _Dropdown<ApplicationStage>(
                label: 'Stage',
                value: _draft.stage,
                values: ApplicationStage.values,
                labelOf: (s) => s.label,
                leading: (s) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.tone(gt).fg,
                    shape: BoxShape.circle,
                  ),
                ),
                onChanged: (v) => _update((d) => d.copyWith(stage: v)),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Top choice')),
                  ButtonSegment(value: 2, label: Text('Normal')),
                  ButtonSegment(value: 3, label: Text('Backup')),
                ],
                selected: {_draft.priority},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    _update((d) => d.copyWith(priority: s.first)),
              ),
            ),
          ],
        ),

        // ── More details ───────────────────────────────────────────
        Card(
          margin: const EdgeInsets.only(bottom: GtSpace.lg),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            initiallyExpanded: _showMore,
            onExpansionChanged: (open) => _showMore = open,
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: GtSpace.lg,
              vertical: GtSpace.xs,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              GtSpace.lg,
              0,
              GtSpace.lg,
              GtSpace.lg,
            ),
            leading: IconWell(icon: GtIcons.note, tone: gt.violet, size: 36),
            title: Text('More details', style: t.titleMedium),
            subtitle: Text('Links, portal, fees and notes', style: t.bodySmall),
            children: [
              pair(
                _UrlField(
                  label: 'Programme page',
                  value: _draft.programmeUrl,
                  errorText: _error(DraftField.programmeUrl),
                  onChanged: (v) => _update((d) => d.copyWith(programmeUrl: v)),
                ),
                _UrlField(
                  label: 'Application portal',
                  value: _draft.portalUrl,
                  errorText: _error(DraftField.portalUrl),
                  onChanged: (v) => _update((d) => d.copyWith(portalUrl: v)),
                ),
              ),
              const SizedBox(height: GtSpace.md),
              pair(
                TextFormField(
                  initialValue: _draft.portalUsername,
                  decoration: const InputDecoration(
                    labelText: 'Portal username',
                    helperText: 'Never store your password here.',
                  ),
                  autofillHints: const <String>[],
                  onChanged: (v) =>
                      _update((d) => d.copyWith(portalUsername: v)),
                ),
                _UrlField(
                  label: 'Funding information',
                  value: _draft.fundingUrl,
                  errorText: _error(DraftField.fundingUrl),
                  onChanged: (v) => _update((d) => d.copyWith(fundingUrl: v)),
                ),
              ),
              const SizedBox(height: GtSpace.md),
              pair(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: _draft.feeAmount,
                        decoration: InputDecoration(
                          labelText: 'Application fee',
                          errorText: _error(DraftField.fee),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (v) =>
                            _update((d) => d.copyWith(feeAmount: v)),
                      ),
                    ),
                    const SizedBox(width: GtSpace.md),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _draft.feeCurrency,
                        decoration: InputDecoration(
                          labelText: 'Currency',
                          hintText: 'CAD',
                          errorText: _error(DraftField.feeCurrency),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(3),
                          FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                          const _UpperCase(),
                        ],
                        onChanged: (v) =>
                            _update((d) => d.copyWith(feeCurrency: v)),
                      ),
                    ),
                  ],
                ),
                _Dropdown<FeeWaiver>(
                  label: 'Fee waiver',
                  value: _draft.feeWaiver,
                  values: FeeWaiver.values,
                  labelOf: (w) => w.label,
                  onChanged: (v) => _update((d) => d.copyWith(feeWaiver: v)),
                ),
              ),
              const SizedBox(height: GtSpace.md),
              TextFormField(
                initialValue: _draft.notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText:
                      'Admission requirements, funding notes, impressions…',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 8,
                onChanged: (v) => _update((d) => d.copyWith(notes: v)),
              ),
            ],
          ),
        ),

        if (saving.hasError && !saving.isLoading) ...[
          ErrorBanner(error: saving.error!),
          const SizedBox(height: GtSpace.lg),
        ],
      ],
    );

    final actions = Container(
      decoration: BoxDecoration(
        color: gt.surface,
        border: Border(top: BorderSide(color: gt.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: GtSpace.md),
      child: PageBody(
        maxWidth: 880,
        child: Row(
          children: [
            if (wide)
              Expanded(
                child: Text(
                  _dirty
                      ? 'Unsaved changes · Ctrl/⌘ + Enter to save'
                      : 'No changes yet',
                  style: t.bodySmall,
                ),
              )
            else
              const Spacer(),
            OutlinedButton(
              onPressed: saving.isLoading ? null : _cancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: GtSpace.md),
            FilledButton(
              onPressed: saving.isLoading ? null : _save,
              child: saving.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isNew ? 'Add application' : 'Save changes'),
            ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          context.go(
            _isNew ? Routes.applications : Routes.application(widget.id!),
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(pad, GtSpace.lg, pad, GtSpace.xl),
                children: [PageBody(maxWidth: 880, child: form)],
              ),
            ),
            actions,
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.tone,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final GtGlyph icon;
  final GtTone tone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: GtSpace.lg),
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: icon, tone: tone, size: 36),
                const SizedBox(width: GtSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: t.titleMedium),
                      ),
                      if (subtitle != null) Text(subtitle!, style: t.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GtSpace.lg),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T extends Object> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.leading,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final Widget Function(T)? leading;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => DropdownMenu<T>(
      width: c.maxWidth,
      label: Text(label),
      initialSelection: value,
      requestFocusOnTap: false,
      leadingIcon: leading == null
          ? null
          : Center(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: GtSpace.md),
                child: leading!(value),
              ),
            ),
      onSelected: (v) {
        if (v != null) onChanged(v);
      },
      dropdownMenuEntries: [
        for (final v in values)
          DropdownMenuEntry(
            value: v,
            label: labelOf(v),
            leadingIcon: leading?.call(v),
          ),
      ],
    ),
  );
}

class _UrlField extends StatelessWidget {
  const _UrlField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      hintText: 'https://',
      errorText: errorText,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: GtSpace.md, right: GtSpace.sm),
        child: GtIcon(
          GtIcons.link,
          size: GtIconSize.inline,
          color: context.gt.textMuted,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
    ),
    keyboardType: TextInputType.url,
    autocorrect: false,
    onChanged: onChanged,
  );
}

/// Pick an existing university or add a new one by name.
class _InstitutionField extends ConsumerWidget {
  const _InstitutionField({
    required this.draft,
    required this.onUpdate,
    this.errorText,
  });

  final ApplicationDraft draft;
  final void Function(
    ApplicationDraft Function(ApplicationDraft current) change,
  )
  onUpdate;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final institutions = ref.watch(institutionsProvider);
    final known = institutions.value ?? const <Institution>[];
    final gt = context.gt;

    ApplicationDraft select(ApplicationDraft d, Institution i) {
      final zone = i.defaultTz;
      final keepDeadlineZone = d.deadline.isSet || zone == null;
      return d.copyWith(
        institutionId: i.id,
        institutionName: i.name,
        institutionCountry: i.country,
        deadline: keepDeadlineZone
            ? d.deadline
            : d.deadline.copyWith(zone: zone),
        fundingDeadline: keepDeadlineZone
            ? d.fundingDeadline
            : d.fundingDeadline.copyWith(zone: zone),
      );
    }

    return Autocomplete<_InstitutionOption>(
      initialValue: TextEditingValue(text: draft.institutionName),
      displayStringForOption: (o) => o.name,
      optionsBuilder: (text) {
        final q = text.text.trim();
        final matches = known
            .where((i) => i.name.toLowerCase().contains(q.toLowerCase()))
            .map(_InstitutionOption.existing)
            .toList();
        final exact = known.any((i) => i.name.toLowerCase() == q.toLowerCase());
        return [
          ...matches,
          if (q.isNotEmpty && !exact) _InstitutionOption.create(q),
        ];
      },
      onSelected: (o) => onUpdate(
        (d) => o.institution != null
            ? select(d, o.institution!)
            : d.copyWith(institutionId: null, institutionName: o.name),
      ),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => onSubmitted(),
            onChanged: (v) {
              // Typing detaches from a previously picked institution; an exact
              // name match re-attaches so we never create duplicates.
              final match = known
                  .where((i) => i.name.toLowerCase() == v.trim().toLowerCase())
                  .firstOrNull;
              onUpdate(
                (d) => match != null
                    ? select(d, match)
                    : d.copyWith(institutionId: null, institutionName: v),
              );
            },
            decoration: InputDecoration(
              labelText: 'University *',
              hintText: 'Start typing to search or add',
              errorText: errorText,
              helperText:
                  draft.createsInstitution &&
                      draft.institutionName.trim().isNotEmpty
                  ? 'New university, it will be added to your list'
                  : null,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: GtSpace.md,
                  right: GtSpace.sm,
                ),
                child: GtIcon(
                  GtIcons.university,
                  size: GtIconSize.inline,
                  color: gt.textMuted,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              suffixIcon: institutions.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
      optionsViewBuilder: (context, onSelected, options) =>
          OptionsPanel<_InstitutionOption>(
            options: options.toList(),
            onSelected: onSelected,
            itemBuilder: (context, o, highlighted) => ListTile(
              dense: true,
              selected: highlighted,
              leading: GtIcon(
                o.institution == null ? GtIcons.add : GtIcons.university,
                size: GtIconSize.inline,
              ),
              title: Text(o.institution == null ? 'Add “${o.name}”' : o.name),
              subtitle: o.institution?.country == null
                  ? null
                  : Text(o.institution!.country!),
            ),
          ),
    );
  }
}

class _InstitutionOption {
  _InstitutionOption.existing(Institution i) : institution = i, name = i.name;
  _InstitutionOption.create(this.name) : institution = null;

  final Institution? institution;
  final String name;
}

class _CountryField extends StatelessWidget {
  const _CountryField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value,
    decoration: const InputDecoration(
      labelText: 'Country code',
      hintText: 'e.g. CA, GB, DE',
      helperText: 'Two letters. Used to suggest the deadline time zone.',
    ),
    textCapitalization: TextCapitalization.characters,
    inputFormatters: [
      LengthLimitingTextInputFormatter(2),
      FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
      const _UpperCase(),
    ],
    onChanged: (v) =>
        onChanged(v.trim().isEmpty ? null : v.trim().toUpperCase()),
  );
}

/// Shows codes in capitals as they're typed (desktop browsers ignore
/// [TextCapitalization]).
class _UpperCase extends TextInputFormatter {
  const _UpperCase();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
