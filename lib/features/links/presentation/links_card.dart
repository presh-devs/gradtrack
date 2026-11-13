import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/external_link.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../applications/domain/application.dart';
import '../domain/application_link.dart';
import 'links_controller.dart';

/// Extra links for one application (scholarships, faculty lists, FAQs…),
/// beyond the programme page and portal shown in Details.
class LinksCard extends ConsumerWidget {
  const LinksCard({super.key, required this.app});

  final Application app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final provider = applicationLinksProvider(app.id);
    final value = ref.watch(provider);
    final links = value.value;

    Future<void> run(Future<void> Function() action, String failure) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await action();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('$failure ${describeError(e)}')));
      }
    }

    Future<void> add() async {
      final input = await showLinkDialog(context);
      if (input != null) await run(() => ref.read(provider.notifier).add(input), 'Couldn’t add the link.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GtSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconWell(icon: GtIcons.link, tone: gt.success, size: 36),
                const SizedBox(width: GtSpace.md),
                Expanded(child: Text('Links', style: t.titleMedium)),
              ],
            ),
            const SizedBox(height: GtSpace.sm),
            if (links == null && value.hasError)
              ErrorBanner(error: value.error!, onRetry: () => ref.invalidate(provider))
            else if (links == null)
              const LinearProgressIndicator(minHeight: 2)
            else ...[
              if (links.isEmpty)
                Text(
                  'Save other useful pages here: scholarships, faculty lists, admissions FAQs.',
                  style: t.bodyMedium,
                ),
              for (final link in links)
                _LinkTile(
                  link: link,
                  onEdit: () async {
                    final input = await showLinkDialog(context, existing: link);
                    if (input != null) {
                      await run(() => ref.read(provider.notifier).edit(link, input), 'Couldn’t save the link.');
                    }
                  },
                  onDelete: () => run(() => ref.read(provider.notifier).delete(link), 'Couldn’t delete the link.'),
                ),
              const SizedBox(height: GtSpace.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: add,
                  icon: const GtIcon(GtIcons.add, size: 18),
                  label: const Text('Add link'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.link, required this.onEdit, required this.onDelete});

  final ApplicationLink link;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final uri = webLink(link.url);
    final hasLabel = link.label != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (uri == null)
                  SelectableText(link.displayLabel, style: t.bodyMedium)
                else
                  ExternalLink(text: link.displayLabel, uri: uri),
                if (hasLabel)
                  Text(
                    link.url,
                    style: t.bodySmall?.copyWith(color: gt.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: GtIcon(GtIcons.more, size: 18, color: gt.textMuted),
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Add or edit a link. Returns the cleaned-up input, or null if cancelled.
Future<LinkInput?> showLinkDialog(BuildContext context, {ApplicationLink? existing}) =>
    showDialog<LinkInput>(context: context, builder: (_) => _LinkDialog(existing: existing));

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({this.existing});

  final ApplicationLink? existing;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late final _url = TextEditingController(text: widget.existing?.url);
  late final _label = TextEditingController(text: widget.existing?.label);
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    _label.dispose();
    super.dispose();
  }

  void _save() {
    final parsed = parseLinkInput(_url.text, _label.text);
    if (parsed.input == null) {
      setState(() => _error = parsed.error);
      return;
    }
    Navigator.pop(context, parsed.input);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add link' : 'Edit link'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _url,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Link *',
                hintText: 'https://…',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: GtSpace.md),
            TextField(
              controller: _label,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Scholarships, Faculty list',
                helperText: 'Optional. Without one, the site’s address is shown.',
              ),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: Text(widget.existing == null ? 'Add' : 'Save')),
      ],
    );
  }
}
