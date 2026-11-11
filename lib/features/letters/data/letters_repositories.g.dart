// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letters_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lettersRepository)
final lettersRepositoryProvider = LettersRepositoryProvider._();

final class LettersRepositoryProvider
    extends
        $FunctionalProvider<
          LettersRepository,
          LettersRepository,
          LettersRepository
        >
    with $Provider<LettersRepository> {
  LettersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lettersRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lettersRepositoryHash();

  @$internal
  @override
  $ProviderElement<LettersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LettersRepository create(Ref ref) {
    return lettersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LettersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LettersRepository>(value),
    );
  }
}

String _$lettersRepositoryHash() => r'3d5856649d4c22bbdef83230177e7a7018718c7e';
