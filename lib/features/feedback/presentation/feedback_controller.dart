import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/feedback_repositories.dart';
import '../domain/feedback.dart';

part 'feedback_controller.g.dart';

/// What this user has sent, newest first; [send] adds to the top.
@riverpod
class FeedbackHistory extends _$FeedbackHistory {
  @override
  Future<List<FeedbackEntry>> build() => ref.watch(feedbackRepositoryProvider).mine();

  Future<void> send(FeedbackKind kind, String message) async {
    final error = feedbackError(message);
    if (error != null) throw ArgumentError(error);
    final entry = await ref.read(feedbackRepositoryProvider).send(kind, message);
    state = AsyncData([entry, ...?state.value]);
  }
}
