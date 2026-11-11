import 'requirement.dart';

abstract interface class RequirementsRepository {
  /// One application's checklist in display order.
  Future<List<Requirement>> list(String applicationId);

  /// Adds items at the end of the list; returns them with their ids.
  Future<List<Requirement>> add(
    String applicationId,
    List<({String title, String kind, bool external})> items,
  );

  Future<void> setStatus(String id, RequirementStatus status);

  Future<void> rename(String id, String title);

  Future<void> delete(String id);
}
