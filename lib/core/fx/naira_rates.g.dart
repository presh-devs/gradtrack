// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'naira_rates.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetched once per app session. On failure the UI just leaves naira out.

@ProviderFor(nairaRates)
final nairaRatesProvider = NairaRatesProvider._();

/// Fetched once per app session. On failure the UI just leaves naira out.

final class NairaRatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<NairaRates>,
          NairaRates,
          FutureOr<NairaRates>
        >
    with $FutureModifier<NairaRates>, $FutureProvider<NairaRates> {
  /// Fetched once per app session. On failure the UI just leaves naira out.
  NairaRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nairaRatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nairaRatesHash();

  @$internal
  @override
  $FutureProviderElement<NairaRates> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<NairaRates> create(Ref ref) {
    return nairaRates(ref);
  }
}

String _$nairaRatesHash() => r'7f250e9841293fd991563854fb5fddf4d2acf5d6';
