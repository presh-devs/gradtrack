// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One application's checklist. Edits are optimistic: the list changes at
/// once, rolls back if the save fails, and the error is rethrown for the
/// caller to show. Each change also updates the application's progress
/// counters in the cached list and refreshes Today.

@ProviderFor(Checklist)
final checklistProvider = ChecklistFamily._();

/// One application's checklist. Edits are optimistic: the list changes at
/// once, rolls back if the save fails, and the error is rethrown for the
/// caller to show. Each change also updates the application's progress
/// counters in the cached list and refreshes Today.
final class ChecklistProvider
    extends $AsyncNotifierProvider<Checklist, List<Requirement>> {
  /// One application's checklist. Edits are optimistic: the list changes at
  /// once, rolls back if the save fails, and the error is rethrown for the
  /// caller to show. Each change also updates the application's progress
  /// counters in the cached list and refreshes Today.
  ChecklistProvider._({
    required ChecklistFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'checklistProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checklistHash();

  @override
  String toString() {
    return r'checklistProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Checklist create() => Checklist();

  @override
  bool operator ==(Object other) {
    return other is ChecklistProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checklistHash() => r'eff9c929da3bce5afaf2ada8d069cbe0fb0fd597';

/// One application's checklist. Edits are optimistic: the list changes at
/// once, rolls back if the save fails, and the error is rethrown for the
/// caller to show. Each change also updates the application's progress
/// counters in the cached list and refreshes Today.

final class ChecklistFamily extends $Family
    with
        $ClassFamilyOverride<
          Checklist,
          AsyncValue<List<Requirement>>,
          List<Requirement>,
          FutureOr<List<Requirement>>,
          String
        > {
  ChecklistFamily._()
    : super(
        retry: null,
        name: r'checklistProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One application's checklist. Edits are optimistic: the list changes at
  /// once, rolls back if the save fails, and the error is rethrown for the
  /// caller to show. Each change also updates the application's progress
  /// counters in the cached list and refreshes Today.

  ChecklistProvider call(String applicationId) =>
      ChecklistProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'checklistProvider';
}

/// One application's checklist. Edits are optimistic: the list changes at
/// once, rolls back if the save fails, and the error is rethrown for the
/// caller to show. Each change also updates the application's progress
/// counters in the cached list and refreshes Today.

abstract class _$Checklist extends $AsyncNotifier<List<Requirement>> {
  late final _$args = ref.$arg as String;
  String get applicationId => _$args;

  FutureOr<List<Requirement>> build(String applicationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Requirement>>, List<Requirement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Requirement>>, List<Requirement>>,
              AsyncValue<List<Requirement>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
