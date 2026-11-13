// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What this user has sent, newest first; [send] adds to the top.

@ProviderFor(FeedbackHistory)
final feedbackHistoryProvider = FeedbackHistoryProvider._();

/// What this user has sent, newest first; [send] adds to the top.
final class FeedbackHistoryProvider
    extends $AsyncNotifierProvider<FeedbackHistory, List<FeedbackEntry>> {
  /// What this user has sent, newest first; [send] adds to the top.
  FeedbackHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackHistoryHash();

  @$internal
  @override
  FeedbackHistory create() => FeedbackHistory();
}

String _$feedbackHistoryHash() => r'cc11dc5a431610e284aac2e91271fe24bb3396aa';

/// What this user has sent, newest first; [send] adds to the top.

abstract class _$FeedbackHistory extends $AsyncNotifier<List<FeedbackEntry>> {
  FutureOr<List<FeedbackEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FeedbackEntry>>, List<FeedbackEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FeedbackEntry>>, List<FeedbackEntry>>,
              AsyncValue<List<FeedbackEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
