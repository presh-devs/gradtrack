import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/time/deadline.dart';
import '../../applications/presentation/applications_controller.dart';
import '../../checklist/data/requirements_repositories.dart';
import '../../checklist/domain/requirement.dart';
import '../../checklist/presentation/checklist_controller.dart';
import '../../letters/data/letters_repositories.dart';
import '../../letters/domain/letters.dart';
import '../../letters/presentation/letters_controller.dart';
import '../../people/data/professors_repositories.dart';
import '../../people/presentation/professors_controller.dart';
import '../data/attention_repositories.dart';
import '../domain/attention_item.dart';

part 'today_controller.g.dart';

/// The ranked "needs attention" feed. Kept alive so returning to Today is
/// instant; invalidated by any mutation that can change what it contains.
@Riverpod(keepAlive: true)
class TodayController extends _$TodayController {
  @override
  Future<List<AttentionItem>> build() => ref.watch(attentionRepositoryProvider).feed();

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Handles [item] from Today without opening it. The item disappears at
  /// once; on failure it comes back and the error is rethrown.
  Future<void> act(AttentionItem item, TodayAction action) async {
    final previous = state.value;
    if (previous != null) {
      state = AsyncData([
        for (final i in previous)
          if (!(i.type == item.type && i.itemId == item.itemId)) i,
      ]);
    }
    try {
      final now = DateTime.now();
      switch (action) {
        case TodayAction.requirementDone:
          await ref.read(requirementsRepositoryProvider).setStatus(item.itemId, RequirementStatus.done);
        case TodayAction.letterSubmitted:
          await ref.read(lettersRepositoryProvider).setStatus(item.itemId, LetterStatus.submitted);
        case TodayAction.replied:
          await ref.read(professorsRepositoryProvider).logReply(item.professorId!, at: now);
        case TodayAction.followedUp:
          await ref.read(professorsRepositoryProvider).logSent(
                item.professorId!,
                sentAt: now,
                followUpAt: DateTime(now.year, now.month, now.day + 14, 9),
                isFollowUp: true,
              );
      }
      await ref.read(attentionRepositoryProvider).markHandled(item);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
    // Everything that shows the same data.
    final appId = item.applicationId;
    if (appId != null) {
      ref.invalidate(checklistProvider(appId));
      ref.invalidate(applicationLettersProvider(appId));
      ref.invalidate(applicationsControllerProvider);
      ref.invalidate(recommendersControllerProvider);
    }
    if (item.professorId != null) ref.invalidate(professorsControllerProvider);
    ref.invalidateSelf();
  }
}

enum TodayAction {
  requirementDone('Done'),
  letterSubmitted('Submitted'),
  replied('Replied'),
  followedUp('Followed up');

  const TodayAction(this.label);
  final String label;

  /// The one-tap action for each kind of item (deadlines open the
  /// application instead).
  static List<TodayAction> forType(AttentionType type) => switch (type) {
        AttentionType.requirement => const [requirementDone],
        AttentionType.letter => const [letterSubmitted],
        AttentionType.followUp => const [replied, followedUp],
        _ => const [],
      };
}

/// Feed grouped into Overdue / Today / This week / Later, keeping server rank
/// order inside each group. Kept alive alongside the feed so a refresh shows
/// the previous groups (with a progress bar) instead of a skeleton.
@Riverpod(keepAlive: true)
Future<Map<DueBucket, List<AttentionItem>>> todayGroups(Ref ref) async {
  final items = await ref.watch(todayControllerProvider.future);
  final grouped = groupBy(items, (AttentionItem i) => DueText.bucket(i.dueAt));
  return {
    for (final b in DueBucket.values)
      if (grouped[b] case final list? when list.isNotEmpty) b: list,
  };
}
