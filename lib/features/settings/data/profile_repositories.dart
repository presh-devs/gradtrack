import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/profile.dart';

part 'profile_repositories.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoProfileRepository(ref.watch(demoStoreProvider)),
    };

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<Profile> load() async {
    final r = await _client.from('profiles').select().eq('id', _uid).single();
    return Profile(
      displayName: r['display_name'] as String?,
      email: _client.auth.currentUser?.email,
      timezone: r['timezone'] as String,
      digestEnabled: r['digest_enabled'] as bool,
      digestHour: r['digest_hour_local'] as int,
      digestSendWhenEmpty: r['digest_send_when_empty'] as bool,
      neverEdited: r['created_at'] == r['updated_at'],
    );
  }

  @override
  Future<void> save(Profile p) => _client.from('profiles').update({
        'display_name': p.displayName?.trim().isEmpty ?? true ? null : p.displayName!.trim(),
        'timezone': p.timezone,
        'digest_enabled': p.digestEnabled,
        'digest_hour_local': p.digestHour,
        'digest_send_when_empty': p.digestSendWhenEmpty,
      }).eq('id', _uid);

  @override
  Future<TestDigestResult> sendTestDigest() async {
    final res = await _client.functions.invoke('send-digests', body: {'test': true});
    final data = (res.data as Map).cast<String, dynamic>();
    return TestDigestResult(
      sent: data['sent'] == true,
      itemCount: (data['items'] as num?)?.toInt() ?? 0,
      to: data['to'] as String?,
      message: data['message'] as String?,
    );
  }
}

class DemoProfileRepository implements ProfileRepository {
  DemoProfileRepository(this._store);

  final DemoStore _store;

  @override
  Future<Profile> load() async {
    await Future<void>.delayed(DemoStore.latency);
    return _store.profile;
  }

  @override
  Future<void> save(Profile profile) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    _store.profile = profile.copyWith(neverEdited: false);
  }

  @override
  Future<TestDigestResult> sendTestDigest() async {
    await Future<void>.delayed(DemoStore.latency);
    return TestDigestResult(
      sent: false,
      itemCount: _store.attention.length,
      message: 'Demo mode doesn’t send email. With Supabase connected, this sends today’s digest to your inbox.',
    );
  }
}
