// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's settings. A profile still on the sign-up default (UTC, never
/// edited) is moved to this device's zone on first load, so the digest
/// arrives at 07:00 local time rather than 07:00 UTC.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// The user's settings. A profile still on the sign-up default (UTC, never
/// edited) is moved to this device's zone on first load, so the digest
/// arrives at 07:00 local time rather than 07:00 UTC.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, Profile> {
  /// The user's settings. A profile still on the sign-up default (UTC, never
  /// edited) is moved to this device's zone on first load, so the digest
  /// arrives at 07:00 local time rather than 07:00 UTC.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'3cbc5ee16fd456d2d27edbd4e2b534b628e133f1';

/// The user's settings. A profile still on the sign-up default (UTC, never
/// edited) is moved to this device's zone on first load, so the digest
/// arrives at 07:00 local time rather than 07:00 UTC.

abstract class _$ProfileController extends $AsyncNotifier<Profile> {
  FutureOr<Profile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile>, Profile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile>, Profile>,
              AsyncValue<Profile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
