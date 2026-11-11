// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professors_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(professorsRepository)
final professorsRepositoryProvider = ProfessorsRepositoryProvider._();

final class ProfessorsRepositoryProvider
    extends
        $FunctionalProvider<
          ProfessorsRepository,
          ProfessorsRepository,
          ProfessorsRepository
        >
    with $Provider<ProfessorsRepository> {
  ProfessorsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'professorsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$professorsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfessorsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfessorsRepository create(Ref ref) {
    return professorsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfessorsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfessorsRepository>(value),
    );
  }
}

String _$professorsRepositoryHash() =>
    r'9d7730a07a9fa5e41447614f2f51586cf95b7234';
