import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/auth_repository.dart';

part 'auth_repositories.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoAuthRepository(ref.watch(demoStoreProvider)),
    };

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Stream<bool> watchSignedIn() => _client.auth.onAuthStateChange
      // Refresh failures arrive as stream errors; they don't change whether
      // we're signed in (an invalid token arrives as a signedOut event).
      .handleError((Object _) {})
      .map((s) => s.session != null)
      .distinct();

  @override
  Stream<bool> watchReachable() => _client.auth.onAuthStateChange
      .transform(StreamTransformer<AuthState, bool>.fromHandlers(
        handleData: (_, sink) => sink.add(true),
        handleError: (error, _, sink) {
          if (kDebugMode) debugPrint('Auth error: $error');
          // Only network/5xx failures mean "can't reach the server". Other
          // auth errors (e.g. a rejected Google sign-in read from the URL)
          // are shown on the sign-in screen instead.
          if (error is AuthException && error is! AuthRetryableFetchException) return;
          sink.add(false);
        },
      ))
      .distinct();

  @override
  Future<void> retryConnection() async {
    if (_client.auth.currentSession == null) return;
    try {
      await _client.auth.refreshSession();
    } catch (_) {
      // Already reported through onAuthStateChange.
    }
  }

  @override
  String? get displayName {
    final user = _client.auth.currentUser;
    final meta = user?.userMetadata?['full_name'] as String?;
    return meta ?? user?.email?.split('@').first;
  }

  @override
  Future<void> sendMagicLink(String email, {required Uri redirectTo}) async {
    try {
      await _client.auth.signInWithOtp(email: email, emailRedirectTo: redirectTo.toString());
    } on AuthException catch (e) {
      throw AuthFailure(switch (e.statusCode) {
        '429' => 'Too many sign-in emails. Wait a minute and try again.',
        // 403 from the invite-only hook carries a user-facing message.
        _ => e.message,
      });
    }
  }

  @override
  Future<void> signInWithGoogleIdToken(String idToken, {required String nonce}) async {
    try {
      await _client.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, nonce: nonce);
    } on AuthException catch (e) {
      // 403 from the sign-up hook ("gradll is full right now…") is user-facing.
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

/// Demo: "sending" the link signs you in straight away.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._store);

  final DemoStore _store;

  @override
  bool get isSignedIn => _store.signedIn;

  @override
  Stream<bool> watchSignedIn() => _store.signedInChanges;

  @override
  Stream<bool> watchReachable() => const Stream.empty();

  @override
  Future<void> retryConnection() async {}

  @override
  String? get displayName => 'Presh';

  @override
  Future<void> sendMagicLink(String email, {required Uri redirectTo}) async {
    await Future<void>.delayed(DemoStore.latency * 2);
    if (!email.contains('@')) throw const FormatException('Enter a valid email address.');
    _store.setSignedIn(true);
  }

  @override
  Future<void> signInWithGoogleIdToken(String idToken, {required String nonce}) async {
    await Future<void>.delayed(DemoStore.latency * 2);
    _store.setSignedIn(true);
  }

  @override
  Future<void> signOut() async => _store.setSignedIn(false);
}
