enum FeedbackKind {
  feature('feature', 'Feature request'),
  problem('problem', 'Something’s wrong'),
  other('other', 'Other');

  const FeedbackKind(this.db, this.label);
  final String db;
  final String label;

  static FeedbackKind fromDb(String? v) => values.firstWhere((k) => k.db == v, orElse: () => other);
}

/// Set by the gradll owner in the Supabase dashboard.
enum FeedbackStatus {
  received('new', 'Received'),
  planned('planned', 'Planned'),
  done('done', 'Done'),
  declined('declined', 'Not planned');

  const FeedbackStatus(this.db, this.label);
  final String db;
  final String label;

  static FeedbackStatus fromDb(String? v) => values.firstWhere((s) => s.db == v, orElse: () => received);
}

class FeedbackEntry {
  const FeedbackEntry({
    required this.id,
    required this.kind,
    required this.message,
    required this.createdAt,
    this.status = FeedbackStatus.received,
  });

  final String id;
  final FeedbackKind kind;
  final String message;
  final FeedbackStatus status;
  final DateTime createdAt;
}

const feedbackMaxLength = 4000;

/// Null when [message] can be sent, otherwise why not.
String? feedbackError(String message) {
  final m = message.trim();
  if (m.isEmpty) return 'Write a message first';
  if (m.length > feedbackMaxLength) return 'Keep it under $feedbackMaxLength characters';
  return null;
}

abstract interface class FeedbackRepository {
  /// What this user has sent, newest first.
  Future<List<FeedbackEntry>> mine({int limit = 10});

  Future<FeedbackEntry> send(FeedbackKind kind, String message);
}
