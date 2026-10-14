/// A sign-in problem with a message fit to show the user as-is
/// (e.g. "GradTrack is invite-only…" from the sign-up hook).
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  bool get isSignedIn;
  Stream<bool> watchSignedIn();
  String? get displayName;

  /// Sends a passwordless sign-in link. [redirectTo] is where the link lands.
  Future<void> sendMagicLink(String email, {required Uri redirectTo});
  Future<void> signOut();
}
