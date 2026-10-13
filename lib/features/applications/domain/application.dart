import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/time/deadline.dart';

part 'application.freezed.dart';

/// Not a strict sequence: any stage can move to any other (spec 02).
enum ApplicationStage {
  researching('researching', 'Researching'),
  shortlisted('shortlisted', 'Shortlisted'),
  preparing('preparing', 'Preparing'),
  ready('ready', 'Ready to submit'),
  submitted('submitted', 'Submitted'),
  underReview('under_review', 'Under review'),
  interview('interview', 'Interview'),
  decided('decided', 'Decided');

  const ApplicationStage(this.db, this.label);
  final String db;
  final String label;

  bool get isPreSubmission => index <= ApplicationStage.ready.index;

  static ApplicationStage fromDb(String value) =>
      values.firstWhere((s) => s.db == value, orElse: () => researching);
}

enum ApplicationOutcome {
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected'),
  waitlisted('waitlisted', 'Waitlisted'),
  withdrawn('withdrawn', 'Withdrawn');

  const ApplicationOutcome(this.db, this.label);
  final String db;
  final String label;

  static ApplicationOutcome? fromDb(String? value) =>
      value == null ? null : values.firstWhere((o) => o.db == value);
}

/// Programme + application combined (decision D3).
@freezed
abstract class Application with _$Application {
  const Application._();

  const factory Application({
    required String id,
    required String institutionName,
    required String programmeName,
    required String degreeType,
    required ApplicationStage stage,
    String? department,
    String? researchArea,
    String? country,
    String? programmeUrl,
    String? portalUrl,
    Deadline? deadline,
    Deadline? fundingDeadline,
    ApplicationOutcome? outcome,
    @Default(2) int priority,
    @Default(0) int requirementsDone,
    @Default(0) int requirementsTotal,
    @Default(0) int lettersSubmitted,
    @Default(0) int lettersTotal,
    String? notes,
  }) = _Application;

  String get degreeLabel => switch (degreeType) {
        'phd' => 'PhD',
        'msc' => 'MSc',
        'ma' => 'MA',
        'mphil' => 'MPhil',
        'mres' => 'MRes',
        _ => 'Other',
      };
  bool get isTopChoice => priority == 1;

  /// 0..1 across checklist items and letters; null when nothing is tracked.
  double? get readiness {
    final total = requirementsTotal + lettersTotal;
    if (total == 0) return null;
    return (requirementsDone + lettersSubmitted) / total;
  }
}
