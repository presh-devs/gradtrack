import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../applications/presentation/application_editor.dart';
import '../../attention/presentation/today_controller.dart';
import '../data/professors_repositories.dart';
import '../domain/professor.dart';

part 'professors_controller.g.dart';

/// Every professor with their outreach status. Kept alive like the
/// applications list. Each change reloads the list (the status comes from a
/// server-side view) and refreshes Today, where follow-ups appear.
@Riverpod(keepAlive: true)
class ProfessorsController extends _$ProfessorsController {
  @override
  Future<List<Professor>> build() => ref.watch(professorsRepositoryProvider).list();

  Future<void> _then(Future<void> Function() change, {bool institutions = false}) async {
    await change();
    final fresh = await ref.read(professorsRepositoryProvider).list();
    state = AsyncData(fresh);
    ref.invalidate(todayControllerProvider);
    if (institutions) ref.invalidate(institutionsProvider);
  }

  Future<void> create(ProfessorDraft d) =>
      _then(() => ref.read(professorsRepositoryProvider).create(d), institutions: d.institutionId == null);

  Future<void> save(String id, ProfessorDraft d) =>
      _then(() => ref.read(professorsRepositoryProvider).update(id, d), institutions: d.institutionId == null);

  Future<void> delete(String id) => _then(() => ref.read(professorsRepositoryProvider).delete(id));

  Future<void> logSent(String id, {required DateTime sentAt, DateTime? followUpAt, bool isFollowUp = false}) =>
      _then(() => ref
          .read(professorsRepositoryProvider)
          .logSent(id, sentAt: sentAt, followUpAt: followUpAt, isFollowUp: isFollowUp));

  Future<void> logReply(String id, {required DateTime at, ProfessorStance? stance}) => _then(() async {
        final repo = ref.read(professorsRepositoryProvider);
        await repo.logReply(id, at: at);
        if (stance != null) await repo.setStance(id, stance);
      });

  Future<void> setStance(String id, ProfessorStance stance) =>
      _then(() => ref.read(professorsRepositoryProvider).setStance(id, stance));

  Future<void> setClosed(String id, bool closed) =>
      _then(() => ref.read(professorsRepositoryProvider).setClosed(id, closed));

  Future<void> link(String professorId, String applicationId) =>
      _then(() => ref.read(professorsRepositoryProvider).link(professorId, applicationId));

  Future<void> unlink(String professorId, String applicationId) =>
      _then(() => ref.read(professorsRepositoryProvider).unlink(professorId, applicationId));

  Future<({int professors, int institutions, int skipped})> importAll(List<ProfessorImport> rows) async {
    late ({int professors, int institutions, int skipped}) result;
    await _then(() async => result = await ref.read(professorsRepositoryProvider).importAll(rows), institutions: true);
    return result;
  }
}

/// Professors linked to one application, derived from the cached list.
@riverpod
Future<List<Professor>> applicationProfessors(Ref ref, String applicationId) async {
  final all = await ref.watch(professorsControllerProvider.future);
  return [for (final p in all) if (p.applicationIds.contains(applicationId)) p];
}

/// The People screen's filter.
enum PeopleFilter {
  all('All'),
  toContact('To contact'),
  followUpDue('Follow-up due'),
  awaitingReply('Awaiting reply'),
  replied('Replied'),
  closed('Closed');

  const PeopleFilter(this.label);
  final String label;

  bool matches(Professor p, DateTime now) => switch (this) {
        all => p.state != OutreachState.closed,
        toContact => p.state == OutreachState.toContact || p.state == OutreachState.drafting,
        followUpDue => p.followUpDue(now),
        awaitingReply => p.state == OutreachState.awaitingReply,
        replied => p.state == OutreachState.replied,
        closed => p.state == OutreachState.closed,
      };
}
