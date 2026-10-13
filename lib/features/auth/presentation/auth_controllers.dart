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
          .sendMagicLink(email.trim(), redirectTo: Uri.base.replace(path: '/', query: null, fragment: null));
      return true;
    });
  }

  void reset() => state = const AsyncData(false);
}
