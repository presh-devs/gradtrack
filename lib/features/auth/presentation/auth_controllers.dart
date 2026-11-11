import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/env.dart';
import '../data/auth_repositories.dart';
import '../data/google/google_identity.dart';
import '../domain/google_nonce.dart';
import '../domain/auth_redirect.dart';

part 'auth_controllers.g.dart';

/// Signed-in flag, kept in sync with the auth stream. The router listens to
/// this to redirect between /sign-in and the app.
@Riverpod(keepAlive: true)
class AuthStatus extends _$AuthStatus {
  @override
  bool build() {
    final repo = ref.watch(authRepositoryProvider);
    final sub = repo.watchSignedIn().listen((signedIn) => state = signedIn);
    ref.onDispose(sub.cancel);
    return repo.isSignedIn;
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

/// False while the auth server can't be reached (offline, Supabase project
/// paused). Supabase keeps retrying in the background; [retry] forces it.
@Riverpod(keepAlive: true)
class AuthReachable extends _$AuthReachable {
  @override
  bool build() {
    final sub = ref.watch(authRepositoryProvider).watchReachable().listen((ok) => state = ok);
    ref.onDispose(sub.cancel);
    return true;
  }

  Future<void> retry() => ref.read(authRepositoryProvider).retryConnection();
}

/// The URL the app was opened with, overridden in main(). Holds a failed
/// Google sign-in's error until the sign-in form shows it.
final authRedirectProvider = Provider<AuthRedirect>((ref) => AuthRedirect(Uri()));

/// Sign-in form state: idle (data false) → loading → sent (data true) | error.
@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<bool> build() => false;

  /// A failed Google sign-in from the URL the app was opened with. Shown
  /// until the next attempt (not thrown from build: Riverpod would retry it).
  String? get redirectError => ref.read(authRedirectProvider).error;

  /// Called with the ID token from Google's button. On success the router
  /// leaves the sign-in screen.
  Future<void> finishGoogle(String idToken, {required String nonce}) async {
    ref.read(authRedirectProvider).clear();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogleIdToken(idToken, nonce: nonce);
      return false;
    });
  }

  void googleFailed(Object error) => state = AsyncError(error, StackTrace.current);

  Future<void> sendLink(String email) async {
    ref.read(authRedirectProvider).clear();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .sendMagicLink(email.trim(), redirectTo: _siteRoot);
      return true;
    });
  }

  void reset() {
    ref.read(authRedirectProvider).clear();
    state = const AsyncData(false);
  }

  // The site root. (Uri.replace(query: null) would *keep* the current query,
  // e.g. /sign-in?from=…, so build from the origin instead.)
  static Uri get _siteRoot => Uri.parse('${Uri.base.origin}/');
}

/// Google's sign-in button, set up once per page load. True when it can be
/// shown (web, real backend, client ID configured).
@Riverpod(keepAlive: true)
class GoogleButtonReady extends _$GoogleButtonReady {
  @override
  Future<bool> build() async {
    if (Env.demo || Env.googleClientId.isEmpty || !googleIdentitySupported) return false;
    final nonce = GoogleNonce.generate();
    await initGoogleIdentity(
      clientId: Env.googleClientId,
      hashedNonce: nonce.hashed,
      onIdToken: (token) => ref.read(signInControllerProvider.notifier).finishGoogle(token, nonce: nonce.raw),
      onError: (e) => ref.read(signInControllerProvider.notifier).googleFailed(e),
    );
    return true;
  }
}
