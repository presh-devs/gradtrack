/// An extra link saved on an application (scholarship page, faculty list,
/// admissions FAQ…), beyond the programme page and portal.
class ApplicationLink {
  const ApplicationLink({
    required this.id,
    required this.applicationId,
    required this.url,
    this.label,
    this.sortOrder = 0,
  });

  final String id;
  final String applicationId;
  final String url;
  final String? label;
  final int sortOrder;

  /// The label, or the site's address when there is none ("csc.edu.cn").
  String get displayLabel {
    if (label != null && label!.trim().isNotEmpty) return label!.trim();
    final host = Uri.tryParse(url)?.host ?? '';
    return host.isEmpty ? url : host.replaceFirst(RegExp(r'^www\.'), '');
  }

  ApplicationLink copyWith({String? url, String? label, bool clearLabel = false}) => ApplicationLink(
        id: id,
        applicationId: applicationId,
        url: url ?? this.url,
        label: clearLabel ? null : (label ?? this.label),
        sortOrder: sortOrder,
      );

  @override
  bool operator ==(Object other) =>
      other is ApplicationLink &&
      other.id == id &&
      other.applicationId == applicationId &&
      other.url == url &&
      other.label == label &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(id, applicationId, url, label, sortOrder);
}

/// What the add/edit dialog produces, already cleaned up.
typedef LinkInput = ({String url, String? label});

/// Cleans a typed link: trims, adds https:// to bare addresses
/// ("csc.edu.cn/apply"). Returns null with an error message when it isn't a
/// usable web address.
({LinkInput? input, String? error}) parseLinkInput(String rawUrl, String rawLabel) {
  var url = rawUrl.trim();
  if (url.isEmpty) return (input: null, error: 'Enter the link');
  // "mailto:", "javascript:" etc. aren't web pages; "example.edu:8080" is.
  final otherScheme = RegExp(r'^[a-z][a-z0-9+.-]*:(?!\d)', caseSensitive: false).hasMatch(url) &&
      !RegExp(r'^https?://', caseSensitive: false).hasMatch(url);
  if (!url.contains('://') && !otherScheme) url = 'https://$url';
  final uri = otherScheme || url.contains(RegExp(r'\s')) ? null : Uri.tryParse(url);
  final ok = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.contains('.');
  if (!ok) return (input: null, error: 'Enter a web address, e.g. https://example.edu/scholarships');
  final label = rawLabel.trim();
  return (input: (url: url, label: label.isEmpty ? null : label), error: null);
}
