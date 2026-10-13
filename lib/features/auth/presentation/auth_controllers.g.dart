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

/// Sign-in form state: idle (data null) → loading → sent (data true) | error.

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// Sign-in form state: idle (data null) → loading → sent (data true) | error.
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, bool> {
  /// Sign-in form state: idle (data null) → loading → sent (data true) | error.
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

String _$signInControllerHash() => r'c57fae8b00f559517ea48dd4fe9bd2022bf4eeba';

/// Sign-in form state: idle (data null) → loading → sent (data true) | error.

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
