abstract interface class AuthRepository {
  bool get isSignedIn;
  Stream<bool> watchSignedIn();
  String? get displayName;

  /// Sends a passwordless sign-in link. [redirectTo] is where the link lands.
  Future<void> sendMagicLink(String email, {required Uri redirectTo});
  Future<void> signOut();
}
