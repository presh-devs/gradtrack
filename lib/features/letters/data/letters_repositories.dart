import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../../applications/domain/application_draft.dart' show blankToNull;
import '../domain/letters.dart';
import '../domain/letters_repository.dart';

part 'letters_repositories.g.dart';

@Riverpod(keepAlive: true)
LettersRepository lettersRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseLettersRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoLettersRepository(ref.watch(demoStoreProvider)),
    };

Map<String, dynamic> _recommenderColumns(RecommenderDraft d) => {
      'name': d.name.trim(),
      'academic_title': blankToNull(d.academicTitle),
      'email': blankToNull(d.email)?.toLowerCase(),
      'institution': blankToNull(d.institution),
      'relationship': blankToNull(d.relationship),
      'notes': blankToNull(d.notes),
    };

/// Timestamp column stamped when a letter reaches [s].
String? _stampColumn(LetterStatus s) => switch (s) {
      LetterStatus.requested => 'requested_at',
      LetterStatus.invited => 'invited_at',
      LetterStatus.submitted => 'submitted_at',
      _ => null,
    };

class SupabaseLettersRepository implements LettersRepository {
  SupabaseLettersRepository(this._client);

  final SupabaseClient _client;

  static const _letterColumns =
      'id, application_id, recommender_id, status, requested_at, invited_at, submitted_at, notes, '
      'recommender:recommenders(name, academic_title)';

  @override
  Future<List<Recommender>> recommenders() async {
    final rows = await _client.from('recommenders').select('*, letter_requests(status)').order('name');
    return [
      for (final r in rows)
        () {
          final letters = (r['letter_requests'] as List)
              .map((l) => LetterStatus.fromDb((l as Map<String, dynamic>)['status'] as String?))
              .where((s) => s != LetterStatus.declined);
          return Recommender(
            id: r['id'] as String,
            name: r['name'] as String,
            academicTitle: r['academic_title'] as String?,
            email: r['email'] as String?,
            institution: r['institution'] as String?,
            relationship: r['relationship'] as String?,
            notes: r['notes'] as String?,
            letters: letters.length,
            submitted: letters.where((s) => s == LetterStatus.submitted).length,
          );
        }(),
    ];
  }

  @override
  Future<String> createRecommender(RecommenderDraft draft) async {
    final row = await _client.from('recommenders').insert(_recommenderColumns(draft)).select('id').single();
    return row['id'] as String;
  }

  @override
  Future<void> updateRecommender(String id, RecommenderDraft draft) =>
      _client.from('recommenders').update(_recommenderColumns(draft)).eq('id', id);

  @override
  Future<void> deleteRecommender(String id) => _client.from('recommenders').delete().eq('id', id);

  @override
  Future<List<LetterRequest>> forApplication(String applicationId) async {
    final rows = await _client
        .from('letter_requests')
        .select(_letterColumns)
        .eq('application_id', applicationId)
        .order('created_at');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<LetterRequest> addLetter(String applicationId, String recommenderId) async {
    final row = await _client
        .from('letter_requests')
        .insert({'application_id': applicationId, 'recommender_id': recommenderId})
        .select(_letterColumns)
        .single();
    return _fromRow(row);
  }

  @override
  Future<void> setStatus(String letterId, LetterStatus status) {
    final stamp = _stampColumn(status);
    return _client.from('letter_requests').update({
      'status': status.db,
      ?stamp: DateTime.now().toUtc().toIso8601String(),
    }).eq('id', letterId);
  }

  @override
  Future<void> removeLetter(String letterId) => _client.from('letter_requests').delete().eq('id', letterId);

  static LetterRequest _fromRow(Map<String, dynamic> r) {
    final status = LetterStatus.fromDb(r['status'] as String?);
    final stamp = _stampColumn(status);
    final rec = r['recommender'] as Map<String, dynamic>;
    return LetterRequest(
      id: r['id'] as String,
      applicationId: r['application_id'] as String,
      recommenderId: r['recommender_id'] as String,
      recommenderName: rec['name'] as String,
      recommenderTitle: rec['academic_title'] as String?,
      status: status,
      statusChangedAt: stamp == null || r[stamp] == null ? null : DateTime.parse(r[stamp] as String),
      notes: r['notes'] as String?,
    );
  }
}

/// Demo letters are created on first view to match each sample
/// application's counters, and keep those counters in sync afterwards.
class DemoLettersRepository implements LettersRepository {
  DemoLettersRepository(this._store);

  final DemoStore _store;

  Future<void> _wait([int divisor = 1]) => Future<void>.delayed(DemoStore.latency ~/ divisor);

  List<LetterRequest> _letters(String applicationId) => _store.letters.putIfAbsent(applicationId, () {
        final app = _store.applications.where((a) => a.id == applicationId).firstOrNull;
        if (app == null) return [];
        return [
          for (var i = 0; i < app.lettersTotal && i < _store.recommenders.length; i++)
            LetterRequest(
              id: 'l${_store.nextId()}',
              applicationId: applicationId,
              recommenderId: _store.recommenders[i].id,
              recommenderName: _store.recommenders[i].name,
              recommenderTitle: _store.recommenders[i].academicTitle,
              status: i < app.lettersSubmitted
                  ? LetterStatus.submitted
                  : (i == app.lettersSubmitted ? LetterStatus.invited : LetterStatus.requested),
            ),
        ];
      });

  void _sync(String applicationId) {
    final i = _store.applications.indexWhere((a) => a.id == applicationId);
    if (i < 0) return;
    final p = letterProgress(_letters(applicationId));
    _store.applications[i] = _store.applications[i].copyWith(lettersSubmitted: p.submitted, lettersTotal: p.total);
  }

  @override
  Future<List<Recommender>> recommenders() async {
    await _wait();
    // Make sure every sample application's letters exist before counting.
    for (final a in _store.applications) {
      _letters(a.id);
    }
    final all = _store.letters.values.expand((l) => l).where((l) => l.status != LetterStatus.declined);
    return [
      for (final r in [..._store.recommenders]..sort((a, b) => a.name.compareTo(b.name)))
        r.copyWith(
          letters: all.where((l) => l.recommenderId == r.id).length,
          submitted: all.where((l) => l.recommenderId == r.id && l.status == LetterStatus.submitted).length,
        ),
    ];
  }

  Recommender _apply(Recommender base, RecommenderDraft d) => base.copyWith(
        name: d.name.trim(),
        academicTitle: blankToNull(d.academicTitle),
        email: blankToNull(d.email)?.toLowerCase(),
        institution: blankToNull(d.institution),
        relationship: blankToNull(d.relationship),
        notes: blankToNull(d.notes),
      );

  @override
  Future<String> createRecommender(RecommenderDraft draft) async {
    await _wait(2);
    final r = _apply(Recommender(id: 'rc${_store.nextId()}', name: ''), draft);
    _store.recommenders.add(r);
    return r.id;
  }

  @override
  Future<void> updateRecommender(String id, RecommenderDraft draft) async {
    await _wait(2);
    final i = _store.recommenders.indexWhere((r) => r.id == id);
    if (i < 0) return;
    final updated = _apply(_store.recommenders[i], draft);
    _store.recommenders[i] = updated;
    for (final list in _store.letters.values) {
      for (var j = 0; j < list.length; j++) {
        if (list[j].recommenderId == id) {
          list[j] = list[j].copyWith(recommenderName: updated.name, recommenderTitle: updated.academicTitle);
        }
      }
    }
  }

  @override
  Future<void> deleteRecommender(String id) async {
    await _wait(2);
    _store.recommenders.removeWhere((r) => r.id == id);
    for (final e in _store.letters.entries) {
      e.value.removeWhere((l) => l.recommenderId == id);
      _sync(e.key);
    }
  }

  @override
  Future<List<LetterRequest>> forApplication(String applicationId) async {
    await _wait();
    return List.unmodifiable(_letters(applicationId));
  }

  @override
  Future<LetterRequest> addLetter(String applicationId, String recommenderId) async {
    await _wait(2);
    final list = _letters(applicationId);
    if (list.any((l) => l.recommenderId == recommenderId)) {
      throw StateError('They’re already writing a letter for this application.');
    }
    final r = _store.recommenders.firstWhere((r) => r.id == recommenderId);
    final letter = LetterRequest(
      id: 'l${_store.nextId()}',
      applicationId: applicationId,
      recommenderId: r.id,
      recommenderName: r.name,
      recommenderTitle: r.academicTitle,
    );
    list.add(letter);
    _sync(applicationId);
    return letter;
  }

  (String, int)? _locate(String id) {
    for (final e in _store.letters.entries) {
      final i = e.value.indexWhere((l) => l.id == id);
      if (i >= 0) return (e.key, i);
    }
    return null;
  }

  @override
  Future<void> setStatus(String letterId, LetterStatus status) async {
    await _wait(2);
    final at = _locate(letterId);
    if (at == null) return;
    final list = _store.letters[at.$1]!;
    list[at.$2] = list[at.$2].copyWith(status: status, statusChangedAt: DateTime.now());
    _sync(at.$1);
  }

  @override
  Future<void> removeLetter(String letterId) async {
    await _wait(2);
    final at = _locate(letterId);
    if (at == null) return;
    _store.letters[at.$1]!.removeAt(at.$2);
    _sync(at.$1);
  }
}
