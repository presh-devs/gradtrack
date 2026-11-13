// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme_extractor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programmeExtractor)
final programmeExtractorProvider = ProgrammeExtractorProvider._();

final class ProgrammeExtractorProvider
    extends
        $FunctionalProvider<
          ProgrammeExtractor,
          ProgrammeExtractor,
          ProgrammeExtractor
        >
    with $Provider<ProgrammeExtractor> {
  ProgrammeExtractorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programmeExtractorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programmeExtractorHash();

  @$internal
  @override
  $ProviderElement<ProgrammeExtractor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgrammeExtractor create(Ref ref) {
    return programmeExtractor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgrammeExtractor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgrammeExtractor>(value),
    );
  }
}

String _$programmeExtractorHash() =>
    r'92ff2cb44cad6d37d9584920ff102b8e385b7212';
