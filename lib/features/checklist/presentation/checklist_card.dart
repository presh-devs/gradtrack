import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/domain/application.dart';
import '../domain/requirement.dart';
import 'checklist_controller.dart';

/// Editable checklist for one application: tick items off, mark them in
/// progress or not needed, rename, delete, and add new ones (several at once
/// when pasted as a comma-separated list).
class ChecklistCard extends ConsumerWidget {
  const ChecklistCard({super.key, required this.app});

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final provider = checklistProvider(app.id);
    final value = ref.watch(provider);
    final items = value.value;
    final progress = items == null ? (done: app.requirementsDone, total: app.requirementsTotal) : checklistProgress(items);

    Future<void> run(Future<void> Function() action, String failure) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await action();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('$failure ${describeError(e)}')));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.checklist, tone: gt.success, size: 36),
                const SizedBox(width: GtSpace.md),
                Expanded(child: Text('Checklist', style: t.titleMedium)),
                if (progress.total > 0) Text('${progress.done} of ${progress.total} done', style: t.labelLarge),
              ],
            ),
            if (progress.total > 0) ...[
              const SizedBox(height: GtSpace.md),
              ProgressBar(value: progress.done / progress.total),
            ],
            const SizedBox(height: GtSpace.sm),
            if (items == null && value.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: GtSpace.md),
                child: ErrorBanner(error: value.error!, onRetry: () => ref.invalidate(provider)),
              )
            else if (items == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: GtSpace.lg),
                child: LinearProgressIndicator(minHeight: 2),
              )
            else ...[
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: GtSpace.md),
                  child: Text(
                    'Nothing on the checklist yet. Add what this programme asks for, or start from the common set.',
                    style: t.bodyMedium,
                  ),
                ),
              for (final item in items)
                _RequirementTile(
                  item: item,
                  onStatus: (s) => run(() => ref.read(provider.notifier).setStatus(item, s), 'Couldn’t update.'),
                  onRename: (title) => run(() => ref.read(provider.notifier).rename(item, title), 'Couldn’t rename.'),
                  onDelete: () => run(() => ref.read(provider.notifier).delete(item), 'Couldn’t delete.'),
                ),
              const SizedBox(height: GtSpace.sm),
              _AddField(
                onAdd: (titles) async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final n = await ref.read(provider.notifier).addTitles(titles);
                    if (n == 0 && titles.isNotEmpty) {
                      messenger.showSnackBar(const SnackBar(content: Text('Already on the checklist')));
                    }
                    return true;
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('Couldn’t add. ${describeError(e)}')));
                    return false;
                  }
                },
              ),
              if (!commonRequirements.every((c) => items.any((r) => r.kind == c.$1)))
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => run(() async {
                      final n = await ref.read(provider.notifier).addCommon();
                      if (context.mounted && n > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $n common requirements')));
                      }
                    }, 'Couldn’t add.'),
                    icon: const GtIcon(GtIcons.add, size: 18),
                    label: const Text('Add common requirements'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({
    required this.item,
    required this.onStatus,
    required this.onRename,
    required this.onDelete,
  });

  final Requirement item;
  final ValueChanged<RequirementStatus> onStatus;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: item.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Requirement'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (title != null) onRename(title);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final muted = item.isDone || item.status == RequirementStatus.notApplicable;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Checkbox(
            value: item.isDone,
            onChanged: item.status == RequirementStatus.notApplicable
                ? null
                : (on) => onStatus(on == true ? RequirementStatus.done : RequirementStatus.notStarted),
          ),
          const SizedBox(width: GtSpace.xs),
          Expanded(
            child: Wrap(
              spacing: GtSpace.sm,
              runSpacing: GtSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.title,
                  style: t.bodyMedium?.copyWith(
                    color: muted ? gt.textMuted : null,
                    decoration: muted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.status == RequirementStatus.inProgress) ToneChip(label: 'In progress', tone: gt.info),
                if (item.status == RequirementStatus.notApplicable) ToneChip(label: 'Not needed', tone: gt.neutral),
                if (item.external && item.status.isOpen) ToneChip(label: 'Depends on others', tone: gt.warning),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: GtIcon(GtIcons.more, size: 18, color: gt.textMuted),
            onSelected: (v) => switch (v) {
              'rename' => _rename(context),
              'delete' => onDelete(),
              _ => onStatus(RequirementStatus.values.firstWhere((s) => s.db == v)),
            },
            itemBuilder: (_) => [
              for (final s in RequirementStatus.values)
                if (s != item.status) PopupMenuItem(value: s.db, child: Text('Mark ${s.label.toLowerCase()}')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddField extends StatefulWidget {
  const _AddField({required this.onAdd});

  /// Returns true when saved, so the field can clear.
  final Future<bool> Function(List<String> titles) onAdd;

  @override
  State<_AddField> createState() => _AddFieldState();
}

class _AddFieldState extends State<_AddField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    final ok = await widget.onAdd(text.split(RegExp(r'[,;\n]+')));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      enabled: !_busy,
      decoration: InputDecoration(
        hintText: 'Add a requirement, or several separated by commas',
        isDense: true,
        suffixIcon: IconButton(
          tooltip: 'Add',
          onPressed: _submit,
          icon: const GtIcon(GtIcons.add, size: 18),
        ),
      ),
      onSubmitted: (_) => _submit(),
    );
  }
}
