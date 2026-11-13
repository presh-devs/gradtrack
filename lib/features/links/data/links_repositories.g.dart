// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'links_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linksRepository)
final linksRepositoryProvider = LinksRepositoryProvider._();

final class LinksRepositoryProvider
    extends
        $FunctionalProvider<LinksRepository, LinksRepository, LinksRepository>
    with $Provider<LinksRepository> {
  LinksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linksRepositoryHash();

  @$internal
  @override
  $ProviderElement<LinksRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinksRepository create(Ref ref) {
    return linksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinksRepository>(value),
    );
  }
}

String _$linksRepositoryHash() => r'c4b617ba739af16c5f320a721b3177e3380a45e1';
