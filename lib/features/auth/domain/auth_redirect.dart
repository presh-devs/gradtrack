/// What the page URL said when the app loaded after a sign-in redirect.
///
/// When an email sign-in link fails (expired, already used), Supabase sends
/// the browser back with `error_description` in the query or fragment.
/// The router rewrites the URL before the sign-in screen exists, so main()
/// reads it once at startup; the sign-in form shows it until the next try.
class AuthRedirect {
  AuthRedirect(Uri startUri) : _error = errorFrom(startUri);

  String? _error;
  String? get error => _error;

  void clear() => _error = null;

  static String? errorFrom(Uri uri) {
    String? read(Map<String, String> p) {
      final d = p['error_description']?.trim();
      if (d != null && d.isNotEmpty) return d;
      return p['error'];
    }

    var raw = read(uri.queryParameters);
    if (raw == null && uri.fragment.contains('error')) {
      try {
        raw = read(Uri.splitQueryString(uri.fragment));
      } on FormatException {
        return null;
      }
    }
    if (raw == null) return null;
    if (raw.contains('invite-only')) return raw;
    if (raw == 'access_denied') return 'That sign-in link has expired or was already used. Send a new one.';
    return 'Sign-in didn’t complete: $raw';
  }
}
