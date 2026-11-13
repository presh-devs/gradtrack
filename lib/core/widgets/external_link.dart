import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/icons.dart';
import '../theme/tokens.dart';

/// http(s) links only; anything else stays plain text.
Uri? webLink(String raw) {
  final uri = Uri.tryParse(raw.trim());
  final isWeb = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  return isWeb ? uri : null;
}

/// A link that opens in a new browser tab.
class ExternalLink extends StatelessWidget {
  const ExternalLink({super.key, required this.text, required this.uri, this.style});

  final String text;
  final Uri uri;

  /// Base text style; defaults to bodyMedium. Colour and underline are added.
  final TextStyle? style;

  Future<void> _open(BuildContext context) async {
    final opened = await launchUrl(uri, webOnlyWindowName: '_blank');
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Couldn't open $text")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.gt.primary;
    return Semantics(
      link: true,
      child: Tooltip(
        message: 'Open in a new tab',
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GtIcon(GtIcons.link, size: 14, color: color),
                  ),
                ),
              ],
            ),
            style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
              color: color,
              decoration: TextDecoration.underline,
              decorationColor: color,
            ),
          ),
        ),
      ),
    );
  }
}
