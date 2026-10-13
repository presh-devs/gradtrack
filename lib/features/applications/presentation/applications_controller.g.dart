// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cached list of active applications — the single source of truth on the
/// client. Kept alive so moving between tabs never refetches; screens that
/// need one application derive it from here (see [applicationById]), so an
/// edit made anywhere updates every screen at once.

@ProviderFor(ApplicationsController)
final applicationsControllerProvider = ApplicationsControllerProvider._();

/// The cached list of active applications — the single source of truth on the
/// client. Kept alive so moving between tabs never refetches; screens that
/// need one application derive it from here (see [applicationById]), so an
/// edit made anywhere updates every screen at once.
final class ApplicationsControllerProvider
    extends $AsyncNotifierProvider<ApplicationsController, List<Application>> {
  /// The cached list of active applications — the single source of truth on the
  /// client. Kept alive so moving between tabs never refetches; screens that
  /// need one application derive it from here (see [applicationById]), so an
  /// edit made anywhere updates every screen at once.
  ApplicationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationsControllerHash();

  @$internal
  @override
  ApplicationsController create() => ApplicationsController();
}

String _$applicationsControllerHash() =>
    r'6f3d6891fe8244ea59b731c07a7492c0b5659ee3';

/// The cached list of active applications — the single source of truth on the
/// client. Kept alive so moving between tabs never refetches; screens that
/// need one application derive it from here (see [applicationById]), so an
/// edit made anywhere updates every screen at once.

abstract class _$ApplicationsController
    extends $AsyncNotifier<List<Application>> {
  FutureOr<List<Application>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Application>>, List<Application>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Application>>, List<Application>>,
              AsyncValue<List<Application>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Derived, not fetched: watches the cached list and picks one application.
/// Loading and error states flow through from the list automatically.

@ProviderFor(applicationById)
final applicationByIdProvider = ApplicationByIdFamily._();

/// Derived, not fetched: watches the cached list and picks one application.
/// Loading and error states flow through from the list automatically.

final class ApplicationByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Application?>,
          Application?,
          FutureOr<Application?>
        >
    with $FutureModifier<Application?>, $FutureProvider<Application?> {
  /// Derived, not fetched: watches the cached list and picks one application.
  /// Loading and error states flow through from the list automatically.
  ApplicationByIdProvider._({
    required ApplicationByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationByIdHash();

  @override
  String toString() {
    return r'applicationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Application?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Application?> create(Ref ref) {
    final argument = this.argument as String;
    return applicationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationByIdHash() => r'b645e7e8ac227ddcdfd30c9f9ad58a50ac770f15';

/// Derived, not fetched: watches the cached list and picks one application.
/// Loading and error states flow through from the list automatically.

final class ApplicationByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Application?>, String> {
  ApplicationByIdFamily._()
    : super(
        retry: null,
        name: r'applicationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Derived, not fetched: watches the cached list and picks one application.
  /// Loading and error states flow through from the list automatically.

  ApplicationByIdProvider call(String id) =>
      ApplicationByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'applicationByIdProvider';
}

/// Counts per stage for the pipeline summary on Today.

@ProviderFor(stageCounts)
final stageCountsProvider = StageCountsProvider._();

/// Counts per stage for the pipeline summary on Today.

final class StageCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<ApplicationStage, int>>,
          Map<ApplicationStage, int>,
          FutureOr<Map<ApplicationStage, int>>
        >
    with
        $FutureModifier<Map<ApplicationStage, int>>,
        $FutureProvider<Map<ApplicationStage, int>> {
  /// Counts per stage for the pipeline summary on Today.
  StageCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stageCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stageCountsHash();

  @$internal
  @override
  $FutureProviderElement<Map<ApplicationStage, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<ApplicationStage, int>> create(Ref ref) {
    return stageCounts(ref);
  }
}

String _$stageCountsHash() => r'5538b4007cc7b65da6ca1bdf3e62363621b7dfe2';

/// The soonest upcoming deadline among applications not yet submitted.

@ProviderFor(nextDeadline)
final nextDeadlineProvider = NextDeadlineProvider._();

/// The soonest upcoming deadline among applications not yet submitted.

final class NextDeadlineProvider
    extends
        $FunctionalProvider<
          AsyncValue<Application?>,
          Application?,
          FutureOr<Application?>
        >
    with $FutureModifier<Application?>, $FutureProvider<Application?> {
  /// The soonest upcoming deadline among applications not yet submitted.
  NextDeadlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextDeadlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextDeadlineHash();

  @$internal
  @override
  $FutureProviderElement<Application?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Application?> create(Ref ref) {
    return nextDeadline(ref);
  }
}

String _$nextDeadlineHash() => r'dcce0c33c27486671990519361f98f35c2877fe1';
