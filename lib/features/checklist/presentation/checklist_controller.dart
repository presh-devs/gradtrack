import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../applications/presentation/applications_controller.dart';
import '../../attention/presentation/today_controller.dart';
import '../data/requirements_repositories.dart';
import '../domain/requirement.dart';

part 'checklist_controller.g.dart';

/// One application's checklist. Edits are optimistic: the list changes at
/// once, rolls back if the save fails, and the error is rethrown for the
/// caller to show. Each change also updates the application's progress
/// counters in the cached list and refreshes Today.
@riverpod
class Checklist extends _$Checklist {
  @override
  Future<List<Requirement>> build(String applicationId) =>
      ref.watch(requirementsRepositoryProvider).list(applicationId);

  Future<void> setStatus(Requirement item, RequirementStatus status) => _optimistic(
        (list) => [for (final r in list) r.id == item.id ? r.copyWith(status: status) : r],
        () => ref.read(requirementsRepositoryProvider).setStatus(item.id, status),
      );

  Future<void> rename(Requirement item, String title) {
    final t = title.trim();
    if (t.isEmpty || t == item.title) return Future.value();
    return _optimistic(
      (list) => [for (final r in list) r.id == item.id ? r.copyWith(title: t) : r],
      () => ref.read(requirementsRepositoryProvider).rename(item.id, t),
    );
  }

  Future<void> delete(Requirement item) => _optimistic(
        (list) => [for (final r in list) if (r.id != item.id) r],
        () => ref.read(requirementsRepositoryProvider).delete(item.id),
      );

  /// Adds items by title; the kind is guessed from the wording. Titles
  /// already on the list (ignoring case) are skipped. Returns how many were
  /// added.
  Future<int> addTitles(List<String> titles) async {
    final existing = {for (final r in state.value ?? const <Requirement>[]) r.title.toLowerCase()};
    final items = <({String title, String kind, bool external})>[];
    for (final raw in titles) {
      final title = raw.trim();
      if (title.isEmpty || !existing.add(title.toLowerCase())) continue;
      final (kind, external) = requirementKindFor(title);
      items.add((title: title, kind: kind, external: external));
    }
    return _add(items);
  }

  /// Adds whichever of the common requirements aren't on the list yet.
  Future<int> addCommon() {
    final existing = {for (final r in state.value ?? const <Requirement>[]) r.kind};
    return _add([
      for (final (kind, title, external) in commonRequirements)
        if (!existing.contains(kind)) (title: title, kind: kind, external: external),
    ]);
  }

  Future<int> _add(List<({String title, String kind, bool external})> items) async {
    if (items.isEmpty) return 0;
    final created = await ref.read(requirementsRepositoryProvider).add(applicationId, items);
    state = AsyncData([...?state.value, ...created]);
    _afterChange();
    return created.length;
  }

  Future<void> _optimistic(
    List<Requirement> Function(List<Requirement>) change,
    Future<void> Function() save,
  ) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData(change(previous));
    try {
      await save();
      _afterChange();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  void _afterChange() {
    final p = checklistProgress(state.value ?? const []);
    ref.read(applicationsControllerProvider.notifier).setChecklistCounts(applicationId, p.done, p.total);
    ref.invalidate(todayControllerProvider);
  }
}
