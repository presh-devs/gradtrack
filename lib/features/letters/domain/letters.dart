import 'package:freezed_annotation/freezed_annotation.dart';

part 'letters.freezed.dart';

/// Where one recommendation letter for one application stands.
enum LetterStatus {
  planned('planned', 'Not asked yet'),
  requested('requested', 'Asked'),
  invited('invited', 'Portal invite sent'),
  submitted('submitted', 'Submitted'),
  declined('declined', 'Declined');

  const LetterStatus(this.db, this.label);
  final String db;
  final String label;

  /// Still needs chasing.
  bool get isOpen => this == planned || this == requested || this == invited;

  static LetterStatus fromDb(String? value) => values.firstWhere((s) => s.db == value, orElse: () => planned);
}

/// Someone writing letters for you (`recommenders`).
@freezed
abstract class Recommender with _$Recommender {
  const Recommender._();

  const factory Recommender({
    required String id,
    required String name,
    String? academicTitle,
    String? email,

    /// Their institution, free text ("University of Lagos").
    String? institution,

    /// "Final-year project supervisor"
    String? relationship,
    String? notes,
    @Default(0) int letters,
    @Default(0) int submitted,
  }) = _Recommender;

  String get displayName => academicTitle == null ? name : '$academicTitle $name';
}

@freezed
abstract class RecommenderDraft with _$RecommenderDraft {
  const RecommenderDraft._();

  const factory RecommenderDraft({
    @Default('') String name,
    String? academicTitle,
    String? email,
    String? institution,
    String? relationship,
    String? notes,
  }) = _RecommenderDraft;

  factory RecommenderDraft.fromRecommender(Recommender r) => RecommenderDraft(
        name: r.name,
        academicTitle: r.academicTitle,
        email: r.email,
        institution: r.institution,
        relationship: r.relationship,
        notes: r.notes,
      );

  /// Empty = valid. Keys: name, email.
  Map<String, String> validate() => {
        if (name.trim().isEmpty) 'name': 'Enter their name',
        if ((email?.trim() ?? '').isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email!.trim()))
          'email': 'Enter a valid email address',
      };
}

/// One recommender's letter for one application (`letter_requests`).
@freezed
abstract class LetterRequest with _$LetterRequest {
  const factory LetterRequest({
    required String id,
    required String applicationId,
    required String recommenderId,
    required String recommenderName,
    String? recommenderTitle,
    @Default(LetterStatus.planned) LetterStatus status,
    DateTime? statusChangedAt,
    String? notes,
  }) = _LetterRequest;
}

/// Counters shown on the application: declined letters don't count.
({int submitted, int total}) letterProgress(Iterable<LetterRequest> letters) {
  final active = letters.where((l) => l.status != LetterStatus.declined);
  return (submitted: active.where((l) => l.status == LetterStatus.submitted).length, total: active.length);
}
