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

enum DegreeType {
  phd('phd', 'PhD'),
  msc('msc', 'MSc'),
  ma('ma', 'MA'),
  mphil('mphil', 'MPhil'),
  mres('mres', 'MRes'),
  other('other', 'Other');

  const DegreeType(this.db, this.label);
  final String db;
  final String label;

  static DegreeType fromDb(String value) =>
      values.firstWhere((d) => d.db == value, orElse: () => other);
}

enum FeeWaiver {
  none('none', 'Not applicable'),
  eligible('eligible', 'Eligible'),
  requested('requested', 'Requested'),
  granted('granted', 'Granted'),
  denied('denied', 'Denied');

  const FeeWaiver(this.db, this.label);
  final String db;
  final String label;

  static FeeWaiver fromDb(String? value) =>
      values.firstWhere((w) => w.db == value, orElse: () => none);
}

/// Programme + application combined (decision D3).
@freezed
abstract class Application with _$Application {
  const Application._();

  const factory Application({
    required String id,
    required String institutionId,
    required String institutionName,
    required String programmeName,
    required DegreeType degree,
    required ApplicationStage stage,
    String? department,
    String? researchArea,
    String? country,
    String? programmeUrl,
    String? portalUrl,
    String? portalUsername,
    String? fundingUrl,
    Deadline? deadline,
    Deadline? fundingDeadline,
    ApplicationOutcome? outcome,
    double? feeAmount,
    String? feeCurrency,
    @Default(FeeWaiver.none) FeeWaiver feeWaiver,
    @Default(2) int priority,
    @Default(0) int requirementsDone,
    @Default(0) int requirementsTotal,
    @Default(0) int lettersSubmitted,
    @Default(0) int lettersTotal,
    String? notes,
  }) = _Application;

  String get degreeLabel => degree.label;
  bool get isTopChoice => priority == 1;

  /// 0..1 across checklist items and letters; null when nothing is tracked.
  double? get readiness {
    final total = requirementsTotal + lettersTotal;
    if (total == 0) return null;
    return (requirementsDone + lettersSubmitted) / total;
  }
}
