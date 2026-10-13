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
  Stream<bool> watchSignedIn() =>
      _client.auth.onAuthStateChange.map((s) => s.session != null).distinct();

  @override
  String? get displayName {
    final user = _client.auth.currentUser;
    final meta = user?.userMetadata?['full_name'] as String?;
    return meta ?? user?.email?.split('@').first;
  }

  @override
  Future<void> sendMagicLink(String email, {required Uri redirectTo}) =>
      _client.auth.signInWithOtp(email: email, emailRedirectTo: redirectTo.toString());

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
  String? get displayName => 'Presh';

  @override
  Future<void> sendMagicLink(String email, {required Uri redirectTo}) async {
    await Future<void>.delayed(DemoStore.latency * 2);
    if (!email.contains('@')) throw const FormatException('Enter a valid email address.');
    _store.setSignedIn(true);
  }

  @override
  Future<void> signOut() async => _store.setSignedIn(false);
}
