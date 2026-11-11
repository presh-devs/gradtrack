import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../../applications/domain/application_draft.dart' show blankToNull;
import '../../applications/domain/institution.dart';
import '../domain/professor.dart';
import '../domain/professors_repository.dart';

part 'professors_repositories.g.dart';

@Riverpod(keepAlive: true)
ProfessorsRepository professorsRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseProfessorsRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoProfessorsRepository(ref.watch(demoStoreProvider)),
    };

int compareProfessors(Professor a, Professor b) {
  final byInst = a.institutionName.toLowerCase().compareTo(b.institutionName.toLowerCase());
  return byInst != 0 ? byInst : a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

Map<String, dynamic> _columns(ProfessorDraft d) => {
      'name': d.name.trim(),
      'academic_title': blankToNull(d.academicTitle),
      'department': blankToNull(d.department),
      'email': blankToNull(d.email)?.toLowerCase(),
      'profile_url': blankToNull(d.profileUrl),
      'research_interests': blankToNull(d.researchInterests),
      'notes': blankToNull(d.notes),
    };

class SupabaseProfessorsRepository implements ProfessorsRepository {
  SupabaseProfessorsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Professor>> list() async {
    // The status view has no foreign key to embed through, so it's a second
    // query merged by id.
    final (rows, statuses) = await (
      _client.from('professors').select('*, institution:institutions(name), application_professors(application_id)'),
      _client
          .from('professor_outreach_status')
          .select('professor_id, thread_state, last_sent_at, last_reply_at, next_follow_up_at'),
    ).wait;
    final status = {for (final s in statuses) s['professor_id'] as String: s};
    DateTime? at(Object? v) => v == null ? null : DateTime.parse(v as String).toUtc();
    return [
      for (final r in rows)
        Professor(
          id: r['id'] as String,
          institutionId: r['institution_id'] as String,
          institutionName: (r['institution'] as Map<String, dynamic>)['name'] as String,
          name: r['name'] as String,
          academicTitle: r['academic_title'] as String?,
          department: r['department'] as String?,
          email: r['email'] as String?,
          profileUrl: r['profile_url'] as String?,
          researchInterests: r['research_interests'] as String?,
          notes: r['notes'] as String?,
          stance: ProfessorStance.fromDb(r['stance'] as String?),
          state: OutreachState.fromDb(status[r['id']]?['thread_state'] as String?),
          lastSentAt: at(status[r['id']]?['last_sent_at']),
          lastReplyAt: at(status[r['id']]?['last_reply_at']),
          followUpAt: at(status[r['id']]?['next_follow_up_at']),
          applicationIds: [
            for (final l in r['application_professors'] as List) (l as Map<String, dynamic>)['application_id'] as String,
          ],
        ),
    ]..sort(compareProfessors);
  }

  Future<String> _institutionId(ProfessorDraft d) async {
    if (d.institutionId != null) return d.institutionId!;
    final row = await _client
        .from('institutions')
        .upsert({'name': d.institutionName.trim()}, onConflict: 'owner_id,name')
        .select('id')
        .single();
    return row['id'] as String;
  }

  @override
  Future<String> create(ProfessorDraft draft) async {
    final row = await _client
        .from('professors')
        .insert({'institution_id': await _institutionId(draft), ..._columns(draft)})
        .select('id')
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> update(String id, ProfessorDraft draft) async {
    await _client
        .from('professors')
        .update({'institution_id': await _institutionId(draft), ..._columns(draft)})
        .eq('id', id);
  }

  @override
  Future<void> delete(String id) => _client.from('professors').delete().eq('id', id);

  @override
  Future<void> logSent(String id, {required DateTime sentAt, DateTime? followUpAt, bool isFollowUp = false}) =>
      _client.from('outreach_messages').insert({
        'professor_id': id,
        'direction': 'outbound',
        'kind': isFollowUp ? 'follow_up' : 'intro',
        'state': 'sent',
        'sent_at': sentAt.toUtc().toIso8601String(),
        'follow_up_at': followUpAt?.toUtc().toIso8601String(),
      });

  @override
  Future<void> logReply(String id, {required DateTime at}) => _client.from('outreach_messages').insert({
        'professor_id': id,
        'direction': 'inbound',
        'kind': 'reply',
        'state': 'sent',
        'sent_at': at.toUtc().toIso8601String(),
      });

  @override
  Future<void> setStance(String id, ProfessorStance stance) =>
      _client.from('professors').update({'stance': stance.db}).eq('id', id);

  @override
  Future<void> setClosed(String id, bool closed) => _client
      .from('professors')
      .update({'closed_at': closed ? DateTime.now().toUtc().toIso8601String() : null}).eq('id', id);

  @override
  Future<void> link(String professorId, String applicationId) => _client
      .from('application_professors')
      .upsert({'professor_id': professorId, 'application_id': applicationId}, ignoreDuplicates: true);

  @override
  Future<void> unlink(String professorId, String applicationId) => _client
      .from('application_professors')
      .delete()
      .eq('professor_id', professorId)
      .eq('application_id', applicationId);

  @override
  Future<({int professors, int institutions, int skipped})> importAll(List<ProfessorImport> rows) async {
    final result = await _client.rpc<List<dynamic>>('import_professors', params: {
      'p_rows': [
        for (final r in rows)
          {
            'institution_name': r.draft.institutionName.trim(),
            ..._columns(r.draft),
            'contacted': r.contacted,
          },
      ],
    });
    final m = result.single as Map<String, dynamic>;
    return (
      professors: m['created_professors'] as int,
      institutions: m['created_institutions'] as int,
      skipped: m['skipped'] as int,
    );
  }
}

class DemoProfessorsRepository implements ProfessorsRepository {
  DemoProfessorsRepository(this._store);

  final DemoStore _store;

  Future<void> _wait([int divisor = 1]) => Future<void>.delayed(DemoStore.latency ~/ divisor);

  Institution _institution(ProfessorDraft d) {
    final found = _store.institutions.where(
      (i) => i.id == d.institutionId || i.name.toLowerCase() == d.institutionName.trim().toLowerCase(),
    );
    if (found.isNotEmpty) return found.first;
    final created = Institution(id: 'i${_store.nextId()}', name: d.institutionName.trim());
    _store.institutions.add(created);
    return created;
  }

  Professor _apply(Professor base, ProfessorDraft d) {
    final inst = _institution(d);
    return base.copyWith(
      institutionId: inst.id,
      institutionName: inst.name,
      name: d.name.trim(),
      academicTitle: blankToNull(d.academicTitle),
      department: blankToNull(d.department),
      email: blankToNull(d.email)?.toLowerCase(),
      profileUrl: blankToNull(d.profileUrl),
      researchInterests: blankToNull(d.researchInterests),
      notes: blankToNull(d.notes),
    );
  }

  void _patch(String id, Professor Function(Professor) change) {
    final i = _store.professors.indexWhere((p) => p.id == id);
    if (i >= 0) _store.professors[i] = change(_store.professors[i]);
  }

  @override
  Future<List<Professor>> list() async {
    await _wait();
    return [..._store.professors]..sort(compareProfessors);
  }

  @override
  Future<String> create(ProfessorDraft draft) async {
    await _wait(2);
    final p = _apply(Professor(id: 'p${_store.nextId()}', institutionId: '', institutionName: '', name: ''), draft);
    _store.professors.add(p);
    return p.id;
  }

  @override
  Future<void> update(String id, ProfessorDraft draft) async {
    await _wait(2);
    _patch(id, (p) => _apply(p, draft));
  }

  @override
  Future<void> delete(String id) async {
    await _wait(2);
    _store.professors.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> logSent(String id, {required DateTime sentAt, DateTime? followUpAt, bool isFollowUp = false}) async {
    await _wait(2);
    _patch(
      id,
      (p) => p.copyWith(
        lastSentAt: sentAt,
        followUpAt: p.stance == ProfessorStance.unknown || p.stance == ProfessorStance.interested ? followUpAt : null,
        state: p.state == OutreachState.closed ? OutreachState.closed : OutreachState.awaitingReply,
      ),
    );
  }

  @override
  Future<void> logReply(String id, {required DateTime at}) async {
    await _wait(2);
    _patch(
      id,
      (p) => p.copyWith(
        lastReplyAt: at,
        followUpAt: null,
        state: p.state == OutreachState.closed ? OutreachState.closed : OutreachState.replied,
      ),
    );
  }

  @override
  Future<void> setStance(String id, ProfessorStance stance) async {
    await _wait(2);
    _patch(
      id,
      (p) => p.copyWith(
        stance: stance,
        followUpAt:
            stance == ProfessorStance.notTakingStudents || stance == ProfessorStance.declined ? null : p.followUpAt,
      ),
    );
  }

  @override
  Future<void> setClosed(String id, bool closed) async {
    await _wait(2);
    _patch(
      id,
      (p) => p.copyWith(
        state: closed
            ? OutreachState.closed
            : p.lastSentAt == null
                ? OutreachState.toContact
                : (p.lastReplyAt != null && !p.lastReplyAt!.isBefore(p.lastSentAt!))
                    ? OutreachState.replied
                    : OutreachState.awaitingReply,
        followUpAt: closed ? null : p.followUpAt,
      ),
    );
  }

  @override
  Future<void> link(String professorId, String applicationId) async {
    await _wait(2);
    _patch(professorId, (p) => p.applicationIds.contains(applicationId)
        ? p
        : p.copyWith(applicationIds: [...p.applicationIds, applicationId]));
  }

  @override
  Future<void> unlink(String professorId, String applicationId) async {
    await _wait(2);
    _patch(professorId, (p) => p.copyWith(applicationIds: [for (final a in p.applicationIds) if (a != applicationId) a]));
  }

  @override
  Future<({int professors, int institutions, int skipped})> importAll(List<ProfessorImport> rows) async {
    await _wait();
    final before = _store.institutions.length;
    var created = 0, skipped = 0;
    for (final r in rows) {
      final inst = _institution(r.draft);
      final email = blankToNull(r.draft.email)?.toLowerCase();
      final exists = _store.professors.any(
        (p) =>
            (email != null && p.email == email) ||
            (p.institutionId == inst.id && p.name.toLowerCase() == r.draft.name.trim().toLowerCase()),
      );
      if (exists) {
        skipped++;
        continue;
      }
      final now = DateTime.now();
      _store.professors.add(
        _apply(Professor(id: 'p${_store.nextId()}', institutionId: '', institutionName: '', name: ''), r.draft)
            .copyWith(
          state: r.contacted ? OutreachState.awaitingReply : OutreachState.toContact,
          lastSentAt: r.contacted ? now : null,
        ),
      );
      created++;
    }
    return (professors: created, institutions: _store.institutions.length - before, skipped: skipped);
  }
}
