import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// The signed-in user's preferences (`profiles`).
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    String? displayName,
    String? email,

    /// IANA zone used for the digest's "today" and send hour.
    @Default('UTC') String timezone,
    @Default(true) bool digestEnabled,

    /// Local hour (0–23) the digest is sent.
    @Default(7) int digestHour,

    /// Send even when nothing needs attention ("All clear today").
    @Default(false) bool digestSendWhenEmpty,

    /// True until the user saves settings once. The zone of a never-edited
    /// profile is the sign-up default (UTC), not a choice.
    @Default(false) bool neverEdited,
  }) = _Profile;
}

/// What happened when a test digest was requested.
class TestDigestResult {
  const TestDigestResult({required this.sent, required this.itemCount, this.to, this.message});

  final bool sent;
  final int itemCount;
  final String? to;
  final String? message;
}

abstract interface class ProfileRepository {
  Future<Profile> load();

  Future<void> save(Profile profile);

  /// Emails the caller today's digest now (no daily bookkeeping).
  Future<TestDigestResult> sendTestDigest();
}
