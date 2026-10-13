// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected stage filters (empty = all). UI state, but kept in Riverpod so
/// it survives tab switches.

@ProviderFor(StageFilter)
final stageFilterProvider = StageFilterProvider._();

/// Selected stage filters (empty = all). UI state, but kept in Riverpod so
/// it survives tab switches.
final class StageFilterProvider
    extends $NotifierProvider<StageFilter, Set<ApplicationStage>> {
  /// Selected stage filters (empty = all). UI state, but kept in Riverpod so
  /// it survives tab switches.
  StageFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stageFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stageFilterHash();

  @$internal
  @override
  StageFilter create() => StageFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<ApplicationStage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<ApplicationStage>>(value),
    );
  }
}

String _$stageFilterHash() => r'b01d9f1229596871c399abde13c20b020e3e7b3d';

/// Selected stage filters (empty = all). UI state, but kept in Riverpod so
/// it survives tab switches.

abstract class _$StageFilter extends $Notifier<Set<ApplicationStage>> {
  Set<ApplicationStage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<ApplicationStage>, Set<ApplicationStage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<ApplicationStage>, Set<ApplicationStage>>,
              Set<ApplicationStage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Filtered view derived from the cached list + filter; recomputes only when
/// either changes, with no extra network calls.

@ProviderFor(filteredApplications)
final filteredApplicationsProvider = FilteredApplicationsProvider._();

/// Filtered view derived from the cached list + filter; recomputes only when
/// either changes, with no extra network calls.

final class FilteredApplicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Application>>,
          AsyncValue<List<Application>>,
          AsyncValue<List<Application>>
        >
    with $Provider<AsyncValue<List<Application>>> {
  /// Filtered view derived from the cached list + filter; recomputes only when
  /// either changes, with no extra network calls.
  FilteredApplicationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredApplicationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredApplicationsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Application>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Application>> create(Ref ref) {
    return filteredApplications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Application>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Application>>>(
        value,
      ),
    );
  }
}

String _$filteredApplicationsHash() =>
    r'82323d4dcce8a6689cd599b3eb119a56c2917c72';
