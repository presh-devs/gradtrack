import 'attention_item.dart';

abstract interface class AttentionRepository {
  /// Ranked items due within [horizon] (overdue items always included).
  Future<List<AttentionItem>> feed({Duration horizon = const Duration(days: 14)});

  /// Called after an inline action has dealt with [item]. The server feed
  /// recomputes itself, so only the demo backend needs this.
  Future<void> markHandled(AttentionItem item);
}
