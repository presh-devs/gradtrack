import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/time/deadline.dart';
import '../domain/application.dart';
import '../domain/application_draft.dart';
import '../domain/applications_repository.dart';
import '../domain/institution.dart';

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
  Future<String> create(ApplicationDraft draft) async {
    final institutionId = await _resolveInstitution(draft);
    final row = {
      ..._row(draft, institutionId),
      'cycle_id': await _activeCycleId(),
      if (!draft.stage.isPreSubmission) 'submitted_at': DateTime.now().toUtc().toIso8601String(),
    };
    final created = await _client.from('applications').insert(row).select('id').single();
    return created['id'] as String;
  }

  @override
  Future<void> update(String id, ApplicationDraft draft) async {
    final institutionId = await _resolveInstitution(draft);
    await _client.from('applications').update(_row(draft, institutionId)).eq('id', id);
  }

  /// Existing institution, or create it. Upsert on (owner_id, name) makes a
  /// retry after a failed application insert reuse the same row.
  Future<String> _resolveInstitution(ApplicationDraft d) async {
    if (d.institutionId != null) return d.institutionId!;
    final row = await _client
        .from('institutions')
        .upsert({
          'name': d.institutionName.trim(),
          'country': blankToNull(d.institutionCountry)?.toUpperCase(),
          'default_tz': d.deadline.zone,
        }, onConflict: 'owner_id,name')
        .select('id')
        .single();
    return row['id'] as String;
  }

  /// MVP-0 has one cycle; create it on first use.
  Future<String> _activeCycleId() async {
    final rows = await _client
        .from('cycles')
        .select('id')
        .eq('is_active', true)
        .order('created_at')
        .limit(1);
    if (rows.isNotEmpty) return rows.first['id'] as String;
    final created = await _client.from('cycles').insert({'name': 'Current cycle'}).select('id').single();
    return created['id'] as String;
  }

  static Map<String, dynamic> _row(ApplicationDraft d, String institutionId) => {
        'institution_id': institutionId,
        ...applicationColumns(d),
      };

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
      institutionId: r['institution_id'] as String,
      institutionName: institution['name'] as String,
      country: institution['country'] as String?,
      programmeName: r['programme_name'] as String,
      degree: DegreeType.fromDb(r['degree_type'] as String),
      department: r['department'] as String?,
      researchArea: r['research_area'] as String?,
      programmeUrl: r['programme_url'] as String?,
      portalUrl: r['portal_url'] as String?,
      portalUsername: r['portal_username'] as String?,
      fundingUrl: r['funding_url'] as String?,
      feeAmount: (r['fee_amount'] as num?)?.toDouble(),
      feeCurrency: r['fee_currency'] as String?,
      feeWaiver: FeeWaiver.fromDb(r['fee_waiver'] as String?),
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

class SupabaseInstitutionsRepository implements InstitutionsRepository {
  SupabaseInstitutionsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Institution>> list() async {
    final rows = await _client.from('institutions').select('id, name, country, default_tz').order('name');
    return [
      for (final r in rows)
        Institution(
          id: r['id'] as String,
          name: r['name'] as String,
          country: r['country'] as String?,
          defaultTz: r['default_tz'] as String?,
        ),
    ];
  }
}

/// Draft → `applications` columns (everything except ids). Shared by
/// create/update and bulk import so both write identical rows.
Map<String, dynamic> applicationColumns(ApplicationDraft d) {
  final deadline = d.deadline.toDeadline();
  final funding = d.fundingDeadline.toDeadline();
  final fee = d.parsedFee;
  return {
    'programme_name': d.programmeName.trim(),
    'degree_type': d.degree.db,
    'stage': d.stage.db,
    if (d.stage != ApplicationStage.decided) 'outcome': null,
    'priority': d.priority,
    'department': blankToNull(d.department),
    'research_area': blankToNull(d.researchArea),
    'programme_url': blankToNull(d.programmeUrl),
    'portal_url': blankToNull(d.portalUrl),
    'portal_username': blankToNull(d.portalUsername),
    'funding_url': blankToNull(d.fundingUrl),
    'deadline_at': deadline?.instant.toIso8601String(),
    'deadline_tz': deadline?.zone,
    'funding_deadline_at': funding?.instant.toIso8601String(),
    'funding_deadline_tz': funding?.zone,
    'fee_amount': fee,
    'fee_currency': fee == null ? null : d.feeCurrency?.trim().toUpperCase(),
    'fee_waiver': d.feeWaiver.db,
    'notes': blankToNull(d.notes),
  };
}
