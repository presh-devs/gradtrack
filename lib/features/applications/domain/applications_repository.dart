import 'application.dart';
import 'application_draft.dart';

/// Data-access contract for applications. Implemented by the Supabase and
/// demo backends in `data/`; nothing above this layer knows which is used.
abstract interface class ApplicationsRepository {
  /// Active (non-archived) applications ordered by deadline, soonest first.
  Future<List<Application>> list();

  /// Creates the application (and its institution if new); returns its id.
  Future<String> create(ApplicationDraft draft);

  Future<void> update(String id, ApplicationDraft draft);

  Future<void> updateStage(String id, ApplicationStage stage);
}
