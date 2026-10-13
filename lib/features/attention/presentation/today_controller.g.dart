// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ranked "needs attention" feed. Kept alive so returning to Today is
/// instant; invalidated by any mutation that can change what it contains.

@ProviderFor(TodayController)
final todayControllerProvider = TodayControllerProvider._();

/// The ranked "needs attention" feed. Kept alive so returning to Today is
/// instant; invalidated by any mutation that can change what it contains.
final class TodayControllerProvider
    extends $AsyncNotifierProvider<TodayController, List<AttentionItem>> {
  /// The ranked "needs attention" feed. Kept alive so returning to Today is
  /// instant; invalidated by any mutation that can change what it contains.
  TodayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayControllerHash();

  @$internal
  @override
  TodayController create() => TodayController();
}

String _$todayControllerHash() => r'ef525ded3959b06afaae17cde60c533638c5a62a';

/// The ranked "needs attention" feed. Kept alive so returning to Today is
/// instant; invalidated by any mutation that can change what it contains.

abstract class _$TodayController extends $AsyncNotifier<List<AttentionItem>> {
  FutureOr<List<AttentionItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AttentionItem>>, List<AttentionItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AttentionItem>>, List<AttentionItem>>,
              AsyncValue<List<AttentionItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Feed grouped into Overdue / Today / This week / Later, keeping server rank
/// order inside each group. Kept alive alongside the feed so a refresh shows
/// the previous groups (with a progress bar) instead of a skeleton.

@ProviderFor(todayGroups)
final todayGroupsProvider = TodayGroupsProvider._();

/// Feed grouped into Overdue / Today / This week / Later, keeping server rank
/// order inside each group. Kept alive alongside the feed so a refresh shows
/// the previous groups (with a progress bar) instead of a skeleton.

final class TodayGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DueBucket, List<AttentionItem>>>,
          Map<DueBucket, List<AttentionItem>>,
          FutureOr<Map<DueBucket, List<AttentionItem>>>
        >
    with
        $FutureModifier<Map<DueBucket, List<AttentionItem>>>,
        $FutureProvider<Map<DueBucket, List<AttentionItem>>> {
  /// Feed grouped into Overdue / Today / This week / Later, keeping server rank
  /// order inside each group. Kept alive alongside the feed so a refresh shows
  /// the previous groups (with a progress bar) instead of a skeleton.
  TodayGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayGroupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayGroupsHash();

  @$internal
  @override
  $FutureProviderElement<Map<DueBucket, List<AttentionItem>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<DueBucket, List<AttentionItem>>> create(Ref ref) {
    return todayGroups(ref);
  }
}

String _$todayGroupsHash() => r'8de143900b32e2372285f879e8e9ec5fc65a5b2e';
