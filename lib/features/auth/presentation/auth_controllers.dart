import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repositories.dart';

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

/// Sign-in form state: idle (data null) → loading → sent (data true) | error.
@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<bool> build() => false;

  Future<void> sendLink(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          // The site root. (Uri.replace(query: null) would *keep* the current
          // query, e.g. /sign-in?from=…, so build from the origin instead.)
          .sendMagicLink(email.trim(), redirectTo: Uri.parse('${Uri.base.origin}/'));
      return true;
    });
  }

  void reset() => state = const AsyncData(false);
}
