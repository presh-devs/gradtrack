import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/time/deadline.dart';
import '../domain/application.dart';
import '../domain/applications_repository.dart';

class SupabaseApplicationsRepository implements ApplicationsRepository {
  SupabaseApplicationsRepository(this._client);

  final SupabaseClient _client;

  // One round trip: the application, its institution, and just the status
  // columns needed for the checklist / letters progress counters.
  static const _select =
      '*, institution:institutions(name, country), requirements(status), letter_requests(status)';

  @override
  Future<List<Application>> list() async {
    final rows = await _client
        .from('applications')
        .select(_select)
        .isFilter('archived_at', null)
        .order('deadline_at', ascending: true, nullsFirst: false);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> updateStage(String id, ApplicationStage stage) async {
    final patch = <String, dynamic>{'stage': stage.db};
    if (stage == ApplicationStage.submitted) {
      patch['submitted_at'] = DateTime.now().toUtc().toIso8601String();
    }
    if (stage != ApplicationStage.decided) patch['outcome'] = null;
    await _client.from('applications').update(patch).eq('id', id);
  }

  static Application _fromRow(Map<String, dynamic> r) {
    final requirements = (r['requirements'] as List).cast<Map<String, dynamic>>();
    final letters = (r['letter_requests'] as List).cast<Map<String, dynamic>>();
    final countedReqs = requirements.where((q) => q['status'] != 'not_applicable');
    final activeLetters = letters.where((l) => l['status'] != 'declined');
    final institution = r['institution'] as Map<String, dynamic>;

    return Application(
      id: r['id'] as String,
      institutionName: institution['name'] as String,
      country: institution['country'] as String?,
      programmeName: r['programme_name'] as String,
      degreeType: r['degree_type'] as String,
      department: r['department'] as String?,
      researchArea: r['research_area'] as String?,
      programmeUrl: r['programme_url'] as String?,
      portalUrl: r['portal_url'] as String?,
      stage: ApplicationStage.fromDb(r['stage'] as String),
      outcome: ApplicationOutcome.fromDb(r['outcome'] as String?),
      priority: r['priority'] as int,
      deadline: _deadline(r['deadline_at'], r['deadline_tz']),
      fundingDeadline: _deadline(r['funding_deadline_at'], r['funding_deadline_tz']),
      requirementsTotal: countedReqs.length,
      requirementsDone: countedReqs.where((q) => q['status'] == 'done').length,
      lettersTotal: activeLetters.length,
      lettersSubmitted: activeLetters.where((l) => l['status'] == 'submitted').length,
      notes: r['notes'] as String?,
    );
  }

  static Deadline? _deadline(Object? at, Object? zone) => at == null
      ? null
      : Deadline(instant: DateTime.parse(at as String).toUtc(), zone: zone as String);
}
