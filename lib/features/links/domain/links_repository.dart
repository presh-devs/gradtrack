import 'application_link.dart';

abstract interface class LinksRepository {
  /// One application's links in display order.
  Future<List<ApplicationLink>> list(String applicationId);

  /// Adds a link at the end of the list; returns it with its id.
  Future<ApplicationLink> add(String applicationId, LinkInput input);

  Future<void> update(String id, LinkInput input);

  Future<void> delete(String id);
}
