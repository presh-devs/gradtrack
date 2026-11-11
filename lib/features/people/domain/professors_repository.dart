import 'professor.dart';

abstract interface class ProfessorsRepository {
  /// All professors, grouped by institution then name.
  Future<List<Professor>> list();

  /// Creates the professor (and the institution if new); returns its id.
  Future<String> create(ProfessorDraft draft);

  Future<void> update(String id, ProfessorDraft draft);

  Future<void> delete(String id);

  /// Records an email sent to them. [followUpAt] sets the reminder shown on
  /// Today if they haven't replied by then.
  Future<void> logSent(String id, {required DateTime sentAt, DateTime? followUpAt, bool isFollowUp = false});

  /// Records their reply, which clears any pending follow-up.
  Future<void> logReply(String id, {required DateTime at});

  Future<void> setStance(String id, ProfessorStance stance);

  /// Closed conversations leave the active lists and stop reminders.
  Future<void> setClosed(String id, bool closed);

  Future<void> link(String professorId, String applicationId);

  Future<void> unlink(String professorId, String applicationId);

  /// All-or-nothing bulk add. Professors already saved (same name at the same
  /// university, or same email) are skipped.
  Future<({int professors, int institutions, int skipped})> importAll(List<ProfessorImport> rows);
}
