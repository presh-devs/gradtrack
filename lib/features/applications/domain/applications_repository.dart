import 'application.dart';

/// Data-access contract for applications. Implemented by the Supabase and
/// demo backends in `data/`; nothing above this layer knows which is used.
abstract interface class ApplicationsRepository {
  /// Active (non-archived) applications ordered by deadline, soonest first.
  Future<List<Application>> list();

  Future<void> updateStage(String id, ApplicationStage stage);
}
