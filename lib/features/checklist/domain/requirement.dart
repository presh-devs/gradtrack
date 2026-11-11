import 'package:freezed_annotation/freezed_annotation.dart';

part 'requirement.freezed.dart';

enum RequirementStatus {
  notStarted('not_started', 'Not started'),
  inProgress('in_progress', 'In progress'),
  done('done', 'Done'),
  notApplicable('not_applicable', 'Not needed');

  const RequirementStatus(this.db, this.label);
  final String db;
  final String label;

  /// Still needs doing (counts towards "outstanding").
  bool get isOpen => this == notStarted || this == inProgress;

  static RequirementStatus fromDb(String? value) =>
      values.firstWhere((s) => s.db == value, orElse: () => notStarted);
}

/// One item on an application's checklist (`requirements` table).
@freezed
abstract class Requirement with _$Requirement {
  const Requirement._();

  const factory Requirement({
    required String id,
    required String applicationId,
    required String title,

    /// `requirements.kind`, e.g. `transcript`. See [requirementKindFor].
    @Default('other') String kind,
    @Default(RequirementStatus.notStarted) RequirementStatus status,

    /// Depends on someone else: registrar, test agency, embassy.
    @Default(false) bool external,
    @Default(0) int sortOrder,
    String? notes,
  }) = _Requirement;

  bool get isDone => status == RequirementStatus.done;
}

/// Progress as the app shows it: "not needed" items don't count.
({int done, int total}) checklistProgress(Iterable<Requirement> items) {
  final counted = items.where((r) => r.status != RequirementStatus.notApplicable);
  return (done: counted.where((r) => r.isDone).length, total: counted.length);
}

/// The "common requirements" set. Matches `public.default_requirements()`
/// (migration 20261014000004) so the import and the checklist add the same.
const commonRequirements = <(String kind, String title, bool external)>[
  ('transcript', 'Official transcript', true),
  ('cv', 'CV', false),
  ('sop', 'Statement of purpose', false),
  ('english_test', 'English test scores', true),
  ('fee', 'Application fee', false),
];

/// Best-guess `requirements.kind` and whether it depends on someone else,
/// from a free-text title ("official academic transcript", "IELTS", "degree
/// auth").
(String kind, bool external) requirementKindFor(String title) {
  final t = title.toLowerCase();
  bool has(String pattern) => RegExp(pattern).hasMatch(t);
  if (has(r'transcript')) return ('transcript', true);
  if (has(r'\b(ielts|toefl|pte|duolingo|english)\b')) return ('english_test', true);
  if (has(r'\b(gre|gmat|hsk)\b')) return ('standardized_test', true);
  if (has(r'\b(cv|resume|résumé)\b')) return ('cv', false);
  if (has(r'statement of purpose|\bsop\b|motivation')) return ('sop', false);
  if (has(r'study plan|research (plan|proposal|statement)')) return ('research_statement', false);
  if (has(r'personal stat')) return ('personal_statement', false);
  if (has(r'writing sample')) return ('writing_sample', false);
  if (has(r'portfolio')) return ('portfolio', false);
  if (has(r'\bauth')) return ('certificate', true); // degree authentication
  if (has(r'\b(bsc|b\.sc|degree|diploma|certificate|msc|ba)\b')) return ('certificate', false);
  if (has(r'\bfee\b')) return ('fee', false);
  if (has(r'bank|police|medical|physical exam')) return ('other', true);
  return ('other', false);
}
