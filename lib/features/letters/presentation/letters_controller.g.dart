// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everyone writing letters for you, with their letter counts.

@ProviderFor(RecommendersController)
final recommendersControllerProvider = RecommendersControllerProvider._();

/// Everyone writing letters for you, with their letter counts.
final class RecommendersControllerProvider
    extends $AsyncNotifierProvider<RecommendersController, List<Recommender>> {
  /// Everyone writing letters for you, with their letter counts.
  RecommendersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendersControllerHash();

  @$internal
  @override
  RecommendersController create() => RecommendersController();
}

String _$recommendersControllerHash() =>
    r'623713cfee4eeae3b7eed657a731480a5804dcc4';

/// Everyone writing letters for you, with their letter counts.

abstract class _$RecommendersController
    extends $AsyncNotifier<List<Recommender>> {
  FutureOr<List<Recommender>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Recommender>>, List<Recommender>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recommender>>, List<Recommender>>,
              AsyncValue<List<Recommender>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One application's letters. Status changes are optimistic; every change
/// updates the application's letter counters, the recommender counts and
/// Today.

@ProviderFor(ApplicationLetters)
final applicationLettersProvider = ApplicationLettersFamily._();

/// One application's letters. Status changes are optimistic; every change
/// updates the application's letter counters, the recommender counts and
/// Today.
final class ApplicationLettersProvider
    extends $AsyncNotifierProvider<ApplicationLetters, List<LetterRequest>> {
  /// One application's letters. Status changes are optimistic; every change
  /// updates the application's letter counters, the recommender counts and
  /// Today.
  ApplicationLettersProvider._({
    required ApplicationLettersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationLettersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationLettersHash();

  @override
  String toString() {
    return r'applicationLettersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ApplicationLetters create() => ApplicationLetters();

  @override
  bool operator ==(Object other) {
    return other is ApplicationLettersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationLettersHash() =>
    r'92ea6233ff402ac7d6795119f1e8ba8d2769b9f9';

/// One application's letters. Status changes are optimistic; every change
/// updates the application's letter counters, the recommender counts and
/// Today.

final class ApplicationLettersFamily extends $Family
    with
        $ClassFamilyOverride<
          ApplicationLetters,
          AsyncValue<List<LetterRequest>>,
          List<LetterRequest>,
          FutureOr<List<LetterRequest>>,
          String
        > {
  ApplicationLettersFamily._()
    : super(
        retry: null,
        name: r'applicationLettersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One application's letters. Status changes are optimistic; every change
  /// updates the application's letter counters, the recommender counts and
  /// Today.

  ApplicationLettersProvider call(String applicationId) =>
      ApplicationLettersProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'applicationLettersProvider';
}

/// One application's letters. Status changes are optimistic; every change
/// updates the application's letter counters, the recommender counts and
/// Today.

abstract class _$ApplicationLetters
    extends $AsyncNotifier<List<LetterRequest>> {
  late final _$args = ref.$arg as String;
  String get applicationId => _$args;

  FutureOr<List<LetterRequest>> build(String applicationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<LetterRequest>>, List<LetterRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<LetterRequest>>, List<LetterRequest>>,
              AsyncValue<List<LetterRequest>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
