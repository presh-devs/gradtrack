import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/time/deadline.dart';
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
