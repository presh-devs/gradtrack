/// A sign-in problem with a message fit to show the user as-is
/// (e.g. "gradll is invite-only…" from the sign-up hook).
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  bool get isSignedIn;
  Stream<bool> watchSignedIn();

  /// Whether the auth server is reachable. Emits `false` when refreshing the
  /// session failed for network reasons (offline, project paused), and `true`
  /// again on the next successful auth event. The session is kept meanwhile.
  Stream<bool> watchReachable();

  /// Retries the session refresh after [watchReachable] reported `false`.
  /// The outcome arrives through [watchReachable] / [watchSignedIn].
  Future<void> retryConnection();
  String? get displayName;

  /// Sends a passwordless sign-in link. [redirectTo] is where the link lands.
  Future<void> sendMagicLink(String email, {required Uri redirectTo});

  /// Exchanges an ID token from Google's sign-in button for a session.
  /// [nonce] is the raw nonce whose SHA-256 was given to Google.
  Future<void> signInWithGoogleIdToken(String idToken, {required String nonce});
  Future<void> signOut();
}
