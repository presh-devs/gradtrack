import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../core/demo/demo_store.dart';
import '../domain/feedback.dart';

part 'feedback_repositories.g.dart';

@Riverpod(keepAlive: true)
FeedbackRepository feedbackRepository(Ref ref) => switch (ref.watch(backendProvider)) {
      Backend.supabase => SupabaseFeedbackRepository(ref.watch(supabaseClientProvider)),
      Backend.demo => DemoFeedbackRepository(ref.watch(demoStoreProvider)),
    };

class SupabaseFeedbackRepository implements FeedbackRepository {
  SupabaseFeedbackRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, kind, message, status, created_at';

  @override
  Future<List<FeedbackEntry>> mine({int limit = 10}) async {
    final rows = await _client.from('feedback').select(_columns).order('created_at', ascending: false).limit(limit);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<FeedbackEntry> send(FeedbackKind kind, String message) async {
    final row = await _client
        .from('feedback')
        .insert({'kind': kind.db, 'message': message.trim()})
        .select(_columns)
        .single();
    return _fromRow(row);
  }

  static FeedbackEntry _fromRow(Map<String, dynamic> r) => FeedbackEntry(
        id: r['id'] as String,
        kind: FeedbackKind.fromDb(r['kind'] as String?),
        message: r['message'] as String,
        status: FeedbackStatus.fromDb(r['status'] as String?),
        createdAt: DateTime.parse(r['created_at'] as String),
      );
}

class DemoFeedbackRepository implements FeedbackRepository {
  DemoFeedbackRepository(this._store);

  final DemoStore _store;

  @override
  Future<List<FeedbackEntry>> mine({int limit = 10}) async {
    await Future<void>.delayed(DemoStore.latency);
    return _store.feedback.reversed.take(limit).toList();
  }

  @override
  Future<FeedbackEntry> send(FeedbackKind kind, String message) async {
    await Future<void>.delayed(DemoStore.latency);
    final entry = FeedbackEntry(
      id: 'f${_store.nextId()}',
      kind: kind,
      message: message.trim(),
      createdAt: DateTime.now(),
    );
    _store.feedback.add(entry);
    return entry;
  }
}
