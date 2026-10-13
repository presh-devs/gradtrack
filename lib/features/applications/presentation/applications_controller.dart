import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../attention/presentation/today_controller.dart';
import '../data/applications_repository_provider.dart';
import '../domain/application.dart';

part 'applications_controller.g.dart';

/// The cached list of active applications — the single source of truth on the
/// client. Kept alive so moving between tabs never refetches; screens that
/// need one application derive it from here (see [applicationById]), so an
/// edit made anywhere updates every screen at once.
@Riverpod(keepAlive: true)
class ApplicationsController extends _$ApplicationsController {
  @override
  Future<List<Application>> build() => ref.watch(applicationsRepositoryProvider).list();

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Optimistic: the UI updates immediately; on failure the previous list is
  /// restored and the error is rethrown for the caller to show.
  Future<void> updateStage(String id, ApplicationStage stage) async {
    final previous = state.value;
    if (previous == null) return;

    state = AsyncData([
      for (final a in previous) a.id == id ? a.copyWith(stage: stage) : a,
    ]);
    try {
      await ref.read(applicationsRepositoryProvider).updateStage(id, stage);
      // Stage affects what the feed shows (deadlines drop off once submitted).
      ref.invalidate(todayControllerProvider);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

/// Derived, not fetched: watches the cached list and picks one application.
/// Loading and error states flow through from the list automatically.
@riverpod
Future<Application?> applicationById(Ref ref, String id) async {
  final apps = await ref.watch(applicationsControllerProvider.future);
  for (final a in apps) {
    if (a.id == id) return a;
  }
  return null;
}

/// Counts per stage for the pipeline summary on Today.
@riverpod
Future<Map<ApplicationStage, int>> stageCounts(Ref ref) async {
  final apps = await ref.watch(applicationsControllerProvider.future);
  return {
    for (final s in ApplicationStage.values) s: apps.where((a) => a.stage == s).length,
  };
}

/// The soonest upcoming deadline among applications not yet submitted.
@riverpod
Future<Application?> nextDeadline(Ref ref) async {
  final apps = await ref.watch(applicationsControllerProvider.future);
  final now = DateTime.now();
  final upcoming = apps
      .where((a) => a.stage.isPreSubmission && a.deadline != null && a.deadline!.instant.isAfter(now))
      .toList()
    ..sort((a, b) => a.deadline!.instant.compareTo(b.deadline!.instant));
  return upcoming.firstOrNull;
}
