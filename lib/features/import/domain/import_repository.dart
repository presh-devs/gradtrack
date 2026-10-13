import '../../applications/domain/application_draft.dart';

class ImportSummary {
  const ImportSummary({required this.applications, required this.institutions});

  final int applications;
  final int institutions;
}

abstract interface class ImportRepository {
  /// Creates all [drafts] atomically: either every row is saved or none.
  /// [seedRequirements] adds the common checklist to each application.
  Future<ImportSummary> importAll(List<ApplicationDraft> drafts, {bool seedRequirements = false});
}
