import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../domain/letters.dart';
import 'letters_controller.dart';

/// Add or edit a recommender. Returns the saved recommender's id.
Future<String?> showRecommenderEditor(BuildContext context, {Recommender? recommender}) => showDialog<String>(
      context: context,
      builder: (_) => _RecommenderEditor(recommender: recommender),
    );

class _RecommenderEditor extends ConsumerStatefulWidget {
  const _RecommenderEditor({this.recommender});

  final Recommender? recommender;

  @override
  ConsumerState<_RecommenderEditor> createState() => _RecommenderEditorState();
}

class _RecommenderEditorState extends ConsumerState<_RecommenderEditor> {
  late RecommenderDraft _draft =
      widget.recommender == null ? const RecommenderDraft() : RecommenderDraft.fromRecommender(widget.recommender!);
  Map<String, String> _errors = const {};
  bool _saving = false;
  Object? _error;

  Future<void> _save() async {
    final errors = _draft.validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final notifier = ref.read(recommendersControllerProvider.notifier);
    try {
      final String id;
      if (widget.recommender == null) {
        id = await notifier.create(_draft);
      } else {
        id = widget.recommender!.id;
        await notifier.save(id, _draft);
      }
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e;
        });
      }
    }
  }

  Widget _field(String label, String? value, RecommenderDraft Function(String) apply,
          {String? errorKey, String? hint, int maxLines = 1, TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: GtSpace.md),
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: label, hintText: hint, errorText: _errors[errorKey]),
          minLines: 1,
          maxLines: maxLines,
          keyboardType: keyboard,
          onChanged: (v) => setState(() => _draft = apply(v)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.recommender == null ? 'Add recommender' : 'Edit ${widget.recommender!.displayName}'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: _field('Title', _draft.academicTitle, (v) => _draft.copyWith(academicTitle: v), hint: 'Dr.'),
                  ),
                  const SizedBox(width: GtSpace.md),
                  Expanded(child: _field('Name', _draft.name, (v) => _draft.copyWith(name: v), errorKey: 'name')),
                ],
              ),
              _field('Email', _draft.email, (v) => _draft.copyWith(email: v),
                  errorKey: 'email', keyboard: TextInputType.emailAddress),
              _field('Institution or employer', _draft.institution, (v) => _draft.copyWith(institution: v)),
              _field('How they know you', _draft.relationship, (v) => _draft.copyWith(relationship: v),
                  hint: 'Final-year project supervisor'),
              _field('Notes', _draft.notes, (v) => _draft.copyWith(notes: v), maxLines: 3),
              if (_error != null) ErrorBanner(error: _error!),
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

/// Pick a recommender for an application, or add a new one. Returns their id.
Future<String?> showPickRecommenderDialog(BuildContext context, {required Set<String> exclude}) =>
    showDialog<String>(context: context, builder: (_) => _PickRecommender(exclude: exclude));

class _PickRecommender extends ConsumerWidget {
  const _PickRecommender({required this.exclude});

  final Set<String> exclude;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final value = ref.watch(recommendersControllerProvider);
    final available = [for (final r in value.value ?? const <Recommender>[]) if (!exclude.contains(r.id)) r];
    return AlertDialog(
      title: const Text('Who’s writing this letter?'),
      content: SizedBox(
        width: 420,
        child: value.isLoading && !value.hasValue
            ? const LinearProgressIndicator(minHeight: 2)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (value.hasError && !value.hasValue) ErrorBanner(error: value.error!),
                  if (available.isEmpty && value.hasValue)
                    Padding(
                      padding: const EdgeInsets.only(bottom: GtSpace.md),
                      child: Text(
                        value.value!.isEmpty
                            ? 'No recommenders yet. Add the first one.'
                            : 'Everyone you’ve added is already on this application.',
                        style: t.bodyMedium,
                      ),
                    ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final r in available)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(r.displayName),
                            subtitle: Text(
                              [r.relationship, r.institution, if (r.letters > 0) '${r.letters} letters']
                                  .nonNulls
                                  .join(' · '),
                            ),
                            onTap: () => Navigator.pop(context, r.id),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () async {
            final id = await showRecommenderEditor(context);
            if (id != null && context.mounted) Navigator.pop(context, id);
          },
          icon: const GtIcon(GtIcons.add, size: 18),
          label: const Text('New recommender'),
        ),
      ],
    );
  }
}
