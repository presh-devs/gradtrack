import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/attention_item.dart';
import '../domain/attention_repository.dart';

part 'attention_repositories.g.dart';

@Riverpod(keepAlive: true)
AttentionRepository attentionRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseAttentionRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoAttentionRepository(ref.watch(demoStoreProvider)),
    };

class SupabaseAttentionRepository implements AttentionRepository {
  SupabaseAttentionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AttentionItem>> feed({Duration horizon = const Duration(days: 14)}) async {
    final rows = await _client.rpc<List<dynamic>>(
      'attention_feed',
      params: {'p_horizon': '${horizon.inDays} days'},
    );
    return rows.cast<Map<String, dynamic>>().map(_fromRow).toList();
  }

  static AttentionItem _fromRow(Map<String, dynamic> r) => AttentionItem(
        type: AttentionType.fromDb(r['item_type'] as String),
        itemId: r['item_id'] as String,
        applicationId: r['application_id'] as String?,
        professorId: r['professor_id'] as String?,
        title: r['title'] as String,
        context: r['context'] as String?,
        reason: r['reason'] as String? ?? '',
        dueAt: DateTime.parse(r['due_at'] as String).toUtc(),
        dueZone: r['due_tz'] as String?,
        score: r['score'] as int,
      );
}

class DemoAttentionRepository implements AttentionRepository {
  DemoAttentionRepository(this._store);

  final DemoStore _store;

  @override
  Future<List<AttentionItem>> feed({Duration horizon = const Duration(days: 14)}) async {
    await Future<void>.delayed(DemoStore.latency);
    final cutoff = DateTime.now().add(horizon);
    // Mirror the server rule: deadlines and checklist items drop off once submitted.
    final submitted = {
      for (final a in _store.applications)
        if (!a.stage.isPreSubmission) a.id,
    };
    return _store.attention
        .where((i) => i.dueAt.isBefore(cutoff))
        .where((i) => !({AttentionType.applicationDeadline, AttentionType.requirement}.contains(i.type) &&
            submitted.contains(i.applicationId)))
        .toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.dueAt.compareTo(b.dueAt);
      });
  }
}
