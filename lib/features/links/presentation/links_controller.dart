import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/links_repositories.dart';
import '../domain/application_link.dart';

part 'links_controller.g.dart';

/// One application's extra links. Edits and deletes are optimistic and roll
/// back (rethrowing for the caller to show) if the save fails.
@riverpod
class ApplicationLinks extends _$ApplicationLinks {
  @override
  Future<List<ApplicationLink>> build(String applicationId) =>
      ref.watch(linksRepositoryProvider).list(applicationId);

  Future<void> add(LinkInput input) async {
    final created = await ref.read(linksRepositoryProvider).add(applicationId, input);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> edit(ApplicationLink link, LinkInput input) => _optimistic(
        (list) => [
          for (final l in list)
            l.id == link.id ? l.copyWith(url: input.url, label: input.label, clearLabel: input.label == null) : l,
        ],
        () => ref.read(linksRepositoryProvider).update(link.id, input),
      );

  Future<void> delete(ApplicationLink link) => _optimistic(
        (list) => [for (final l in list) if (l.id != link.id) l],
        () => ref.read(linksRepositoryProvider).delete(link.id),
      );

  Future<void> _optimistic(
    List<ApplicationLink> Function(List<ApplicationLink>) change,
    Future<void> Function() save,
  ) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData(change(previous));
    try {
      await save();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
