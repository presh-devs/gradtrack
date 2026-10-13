import 'package:freezed_annotation/freezed_annotation.dart';

part 'attention_item.freezed.dart';

enum AttentionType {
  applicationDeadline('application_deadline'),
  fundingDeadline('funding_deadline'),
  requirement('requirement'),
  letter('letter'),
  followUp('follow_up'),
  task('task');

  const AttentionType(this.db);
  final String db;

  static AttentionType fromDb(String value) => values.firstWhere((t) => t.db == value);
}

/// One row of the ranked "needs attention" feed. Ranking and wording are
/// computed server-side by `attention_feed()` (spec 03); the client only renders.
@freezed
abstract class AttentionItem with _$AttentionItem {
  const factory AttentionItem({
    required AttentionType type,
    required String itemId,
    required String title,
    required String reason,
    required DateTime dueAt,
    required int score,
    String? applicationId,
    String? professorId,
    String? context,
    String? dueZone,
  }) = _AttentionItem;
}
