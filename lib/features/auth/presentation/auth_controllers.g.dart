// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Signed-in flag, kept in sync with the auth stream. The router listens to
/// this to redirect between /sign-in and the app.

@ProviderFor(AuthStatus)
final authStatusProvider = AuthStatusProvider._();

/// Signed-in flag, kept in sync with the auth stream. The router listens to
/// this to redirect between /sign-in and the app.
final class AuthStatusProvider extends $NotifierProvider<AuthStatus, bool> {
  /// Signed-in flag, kept in sync with the auth stream. The router listens to
  /// this to redirect between /sign-in and the app.
  AuthStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusHash();

  @$internal
  @override
  AuthStatus create() => AuthStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authStatusHash() => r'4c0899078bab4b77686c89329cdc9f6240f20462';

/// Signed-in flag, kept in sync with the auth stream. The router listens to
/// this to redirect between /sign-in and the app.

abstract class _$AuthStatus extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// False while the auth server can't be reached (offline, Supabase project
/// paused). Supabase keeps retrying in the background; [retry] forces it.

@ProviderFor(AuthReachable)
final authReachableProvider = AuthReachableProvider._();

/// False while the auth server can't be reached (offline, Supabase project
/// paused). Supabase keeps retrying in the background; [retry] forces it.
final class AuthReachableProvider
    extends $NotifierProvider<AuthReachable, bool> {
  /// False while the auth server can't be reached (offline, Supabase project
  /// paused). Supabase keeps retrying in the background; [retry] forces it.
  AuthReachableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authReachableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authReachableHash();

  @$internal
  @override
  AuthReachable create() => AuthReachable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authReachableHash() => r'03356149598e255f725425871cdd8ef3b7a1fe38';

/// False while the auth server can't be reached (offline, Supabase project
/// paused). Supabase keeps retrying in the background; [retry] forces it.

abstract class _$AuthReachable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sign-in form state: idle (data false) → loading → sent (data true) | error.

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// Sign-in form state: idle (data false) → loading → sent (data true) | error.
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, bool> {
  /// Sign-in form state: idle (data false) → loading → sent (data true) | error.
  SignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInControllerHash();

  @$internal
  @override
  SignInController create() => SignInController();
}

String _$signInControllerHash() => r'90db5e7cb3c4f4f86281b51185340e8b80714dd5';

/// Sign-in form state: idle (data false) → loading → sent (data true) | error.

abstract class _$SignInController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
