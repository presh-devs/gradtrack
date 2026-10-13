// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attention_repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attentionRepository)
final attentionRepositoryProvider = AttentionRepositoryProvider._();

final class AttentionRepositoryProvider
    extends
        $FunctionalProvider<
          AttentionRepository,
          AttentionRepository,
          AttentionRepository
        >
    with $Provider<AttentionRepository> {
  AttentionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attentionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attentionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AttentionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttentionRepository create(Ref ref) {
    return attentionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttentionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttentionRepository>(value),
    );
  }
}

String _$attentionRepositoryHash() =>
    r'9c0dc13d60ac19c67e79e19dc31efcb3a1ae17a2';
