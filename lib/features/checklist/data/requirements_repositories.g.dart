// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirements_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(requirementsRepository)
final requirementsRepositoryProvider = RequirementsRepositoryProvider._();

final class RequirementsRepositoryProvider
    extends
        $FunctionalProvider<
          RequirementsRepository,
          RequirementsRepository,
          RequirementsRepository
        >
    with $Provider<RequirementsRepository> {
  RequirementsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requirementsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requirementsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RequirementsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RequirementsRepository create(Ref ref) {
    return requirementsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RequirementsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RequirementsRepository>(value),
    );
  }
}

String _$requirementsRepositoryHash() =>
    r'02e19447a897e5d2d6c839cbca5e46578f365752';
