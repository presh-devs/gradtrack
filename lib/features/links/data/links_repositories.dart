import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/application_link.dart';
import '../domain/links_repository.dart';

part 'links_repositories.g.dart';

@Riverpod(keepAlive: true)
LinksRepository linksRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseLinksRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoLinksRepository(ref.watch(demoStoreProvider)),
    };

class SupabaseLinksRepository implements LinksRepository {
  SupabaseLinksRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, application_id, label, url, sort_order';

  @override
  Future<List<ApplicationLink>> list(String applicationId) async {
    final rows = await _client
        .from('application_links')
        .select(_columns)
        .eq('application_id', applicationId)
        .order('sort_order')
        .order('created_at');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<ApplicationLink> add(String applicationId, LinkInput input) async {
    final last = await _client
        .from('application_links')
        .select('sort_order')
        .eq('application_id', applicationId)
        .order('sort_order', ascending: false)
        .limit(1);
    final next = last.isEmpty ? 1 : (last.first['sort_order'] as int) + 1;
    final row = await _client
        .from('application_links')
        .insert({'application_id': applicationId, 'url': input.url, 'label': input.label, 'sort_order': next})
        .select(_columns)
        .single();
    return _fromRow(row);
  }

  @override
  Future<void> update(String id, LinkInput input) =>
      _client.from('application_links').update({'url': input.url, 'label': input.label}).eq('id', id);

  @override
  Future<void> delete(String id) => _client.from('application_links').delete().eq('id', id);

  static ApplicationLink _fromRow(Map<String, dynamic> r) => ApplicationLink(
        id: r['id'] as String,
        applicationId: r['application_id'] as String,
        url: r['url'] as String,
        label: r['label'] as String?,
        sortOrder: r['sort_order'] as int,
      );
}

class DemoLinksRepository implements LinksRepository {
  DemoLinksRepository(this._store);

  final DemoStore _store;

  List<ApplicationLink> _items(String applicationId) => _store.links.putIfAbsent(applicationId, () => []);

  (String, int)? _locate(String id) {
    for (final e in _store.links.entries) {
      final i = e.value.indexWhere((l) => l.id == id);
      if (i >= 0) return (e.key, i);
    }
    return null;
  }

  @override
  Future<List<ApplicationLink>> list(String applicationId) async {
    await Future<void>.delayed(DemoStore.latency);
    return List.unmodifiable(_items(applicationId));
  }

  @override
  Future<ApplicationLink> add(String applicationId, LinkInput input) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    final list = _items(applicationId);
    final link = ApplicationLink(
      id: 'l${_store.nextId()}',
      applicationId: applicationId,
      url: input.url,
      label: input.label,
      sortOrder: list.isEmpty ? 1 : list.last.sortOrder + 1,
    );
    list.add(link);
    return link;
  }

  @override
  Future<void> update(String id, LinkInput input) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    final at = _locate(id);
    if (at == null) return;
    final list = _store.links[at.$1]!;
    list[at.$2] = list[at.$2].copyWith(url: input.url, label: input.label, clearLabel: input.label == null);
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(DemoStore.latency ~/ 2);
    final at = _locate(id);
    if (at != null) _store.links[at.$1]!.removeAt(at.$2);
  }
}
