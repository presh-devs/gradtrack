import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repositories.dart';
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

  /// The page navigates away to Google, so this stays loading on success.
  Future<void> signInWithGoogle() async {
    ref.read(authRedirectProvider).clear();
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle(redirectTo: _siteRoot);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

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
