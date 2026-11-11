import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/requirement.dart';
import '../domain/requirements_repository.dart';

part 'requirements_repositories.g.dart';

@Riverpod(keepAlive: true)
RequirementsRepository requirementsRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseRequirementsRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoRequirementsRepository(ref.watch(demoStoreProvider)),
    };

class SupabaseRequirementsRepository implements RequirementsRepository {
  SupabaseRequirementsRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, application_id, kind, title, status, depends_on, sort_order, notes';

  @override
  Future<List<Requirement>> list(String applicationId) async {
    final rows = await _client
        .from('requirements')
        .select(_columns)
        .eq('application_id', applicationId)
        .order('sort_order')
        .order('created_at');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Requirement>> add(
    String applicationId,
    List<({String title, String kind, bool external})> items,
  ) async {
    if (items.isEmpty) return const [];
    final last = await _client
        .from('requirements')
        .select('sort_order')
        .eq('application_id', applicationId)
        .order('sort_order', ascending: false)
        .limit(1);
    final start = last.isEmpty ? 0 : (last.first['sort_order'] as int);
    final rows = await _client
        .from('requirements')
        .insert([
          for (final (i, item) in items.indexed)
            {
              'application_id': applicationId,
              'title': item.title.trim(),
              'kind': item.kind,
              'depends_on': item.external ? 'external' : 'self',
              'sort_order': start + i + 1,
            },
        ])
        .select(_columns);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> setStatus(String id, RequirementStatus status) => _client.from('requirements').update({
        'status': status.db,
        'completed_at': status == RequirementStatus.done ? DateTime.now().toUtc().toIso8601String() : null,
      }).eq('id', id);

  @override
  Future<void> rename(String id, String title) =>
      _client.from('requirements').update({'title': title.trim()}).eq('id', id);

  @override
  Future<void> delete(String id) => _client.from('requirements').delete().eq('id', id);

  static Requirement _fromRow(Map<String, dynamic> r) => Requirement(
        id: r['id'] as String,
        applicationId: r['application_id'] as String,
        title: r['title'] as String,
        kind: r['kind'] as String,
        status: RequirementStatus.fromDb(r['status'] as String?),
        external: r['depends_on'] == 'external',
        sortOrder: r['sort_order'] as int,
        notes: r['notes'] as String?,
      );
}

/// Demo checklists are created on first view to match each sample
/// application's counters, and keep those counters in sync afterwards.
class DemoRequirementsRepository implements RequirementsRepository {
  DemoRequirementsRepository(this._store);

  final DemoStore _store;

  static const _extraTitles = [
    ('writing_sample', 'Writing sample', false),
    ('research_statement', 'Research proposal', false),
    ('other', 'Passport copy', false),
    ('certificate', 'Degree certificate', false),
  ];

  List<Requirement> _items(String applicationId) => _store.requirements.putIfAbsent(applicationId, () {
        final app = _store.applications.where((a) => a.id == applicationId).firstOrNull;
        if (app == null) return [];
        final pool = [...commonRequirements, ..._extraTitles];
        return [
          for (var i = 0; i < app.requirementsTotal && i < pool.length; i++)
            Requirement(
              id: 'r${_store.nextId()}',
              applicationId: applicationId,
              kind: pool[i].$1,
              title: pool[i].$2,
              external: pool[i].$3,
              sortOrder: i + 1,
              status: i < app.requirementsDone ? RequirementStatus.done : RequirementStatus.notStarted,
            ),
        ];
      });

  void _syncCounts(String applicationId) {
    final i = _store.applications.indexWhere((a) => a.id == applicationId);
    if (i < 0) return;
    final p = checklistProgress(_items(applicationId));
    _store.applications[i] = _store.applications[i].copyWith(requirementsDone: p.done, requirementsTotal: p.total);
  }

  (String, int)? _locate(String id) {
    for (final e in _store.requirements.entries) {
      final i = e.value.indexWhere((r) => r.id == id);
      if (i >= 0) return (e.key, i);
    }
    return null;
  }

  @override
  Future<List<Requirement>> list(String applicationId) async {
    await Future<void>.delayed(DemoStore.latency);
    return List.unmodifiable(_items(applicationId));
  }

  @override
  Future<List<Requirement>> add(
    String applicationId,
    List<({String title, String kind, bool external})> items,
  ) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    final list = _items(applicationId);
    final start = list.isEmpty ? 0 : list.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b);
    final created = [
      for (final (i, item) in items.indexed)
        Requirement(
          id: 'r${_store.nextId()}',
          applicationId: applicationId,
          title: item.title.trim(),
          kind: item.kind,
          external: item.external,
          sortOrder: start + i + 1,
        ),
    ];
    list.addAll(created);
    _syncCounts(applicationId);
    return created;
  }

  @override
  Future<void> setStatus(String id, RequirementStatus status) => _patch(id, (r) => r.copyWith(status: status));

  @override
  Future<void> rename(String id, String title) => _patch(id, (r) => r.copyWith(title: title.trim()));

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    final at = _locate(id);
    if (at == null) return;
    _store.requirements[at.$1]!.removeAt(at.$2);
    _syncCounts(at.$1);
  }

  Future<void> _patch(String id, Requirement Function(Requirement) change) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    final at = _locate(id);
    if (at == null) return;
    final list = _store.requirements[at.$1]!;
    list[at.$2] = change(list[at.$2]);
    _syncCounts(at.$1);
  }
}
