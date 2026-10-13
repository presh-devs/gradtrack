import 'attention_item.dart';

abstract interface class AttentionRepository {
  /// Ranked items due within [horizon] (overdue items always included).
  Future<List<AttentionItem>> feed({Duration horizon = const Duration(days: 14)});
}
