import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/time/local_zone.dart';
import '../data/profile_repositories.dart';
import '../domain/profile.dart';

part 'profile_controller.g.dart';

/// The user's settings. A profile still on the sign-up default (UTC, never
/// edited) is moved to this device's zone on first load, so the digest
/// arrives at 07:00 local time rather than 07:00 UTC.
@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  @override
  Future<Profile> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final profile = await repo.load();
    final local = localZoneName();
    if (profile.neverEdited &&
        profile.timezone == 'UTC' &&
        local != null &&
        local != 'UTC' &&
        tz.timeZoneDatabase.locations.containsKey(local)) {
      final adopted = profile.copyWith(timezone: local, neverEdited: false);
      try {
        await repo.save(adopted);
        return adopted;
      } catch (_) {
        return profile; // not worth failing Settings over
      }
    }
    return profile;
  }

  /// Optimistic; restores the previous value and rethrows on failure.
  Future<void> save(Profile next) async {
    final previous = state.value;
    state = AsyncData(next.copyWith(neverEdited: false));
    try {
      await ref.read(profileRepositoryProvider).save(next);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }

  Future<TestDigestResult> sendTestDigest() => ref.read(profileRepositoryProvider).sendTestDigest();
}
