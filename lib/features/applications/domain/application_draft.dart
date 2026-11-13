import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/time/deadline.dart';
import 'application.dart';

part 'application_draft.freezed.dart';

/// A deadline as typed into the form: wall-clock date and time in a zone.
/// Converted to an exact instant only on save.
@freezed
abstract class DeadlineInput with _$DeadlineInput {
  const DeadlineInput._();

  const factory DeadlineInput({
    DateTime? date, // calendar date only; time fields ignored
    @Default(23) int hour,
    @Default(59) int minute,
    String? zone,

    /// Only the month is known; day and time are ignored.
    @Default(false) bool monthOnly,
  }) = _DeadlineInput;

  factory DeadlineInput.fromDeadline(Deadline? d, {String? fallbackZone}) {
    if (d == null) return DeadlineInput(zone: fallbackZone);
    final t = d.inZone;
    return DeadlineInput(
      date: DateTime(t.year, t.month, t.day),
      hour: t.hour,
      minute: t.minute,
      zone: d.zone,
      monthOnly: d.isMonthOnly,
    );
  }

  bool get isSet => date != null;

  Deadline? toDeadline() {
    if (date == null || zone == null) return null;
    if (monthOnly) return Deadline.month(zone!, date!.year, date!.month);
    return Deadline.wallClock(zone!, date!.year, date!.month, date!.day, hour: hour, minute: minute);
  }
}

/// A checklist item to create with a new application (from import).
class RequirementSeed {
  const RequirementSeed(this.kind, this.title, {this.external = false});

  /// `requirements.kind` value, e.g. `transcript`.
  final String kind;
  final String title;

  /// Depends on someone else (registrar, test agency, embassy).
  final bool external;

  Map<String, dynamic> toJson() => {'kind': kind, 'title': title, 'depends_on': external ? 'external' : 'self'};

  @override
  bool operator ==(Object other) =>
      other is RequirementSeed && other.kind == kind && other.title == title && other.external == external;

  @override
  int get hashCode => Object.hash(kind, title, external);

  @override
  String toString() => 'RequirementSeed($kind, $title)';
}

enum DraftField {
  institution,
  programmeName,
  deadline,
  fundingDeadline,
  programmeUrl,
  portalUrl,
  fundingUrl,
  fee,
  feeCurrency,
  tuition,
  tuitionCurrency,
}

/// Everything the application form edits. Pure Dart: validation and
/// conversion are unit-tested without widgets or a backend.
@freezed
abstract class ApplicationDraft with _$ApplicationDraft {
  const ApplicationDraft._();

  const factory ApplicationDraft({
    /// Existing institution, or null to create one named [institutionName].
    String? institutionId,
    @Default('') String institutionName,
    String? institutionCountry,
    @Default('') String programmeName,
    @Default(DegreeType.phd) DegreeType degree,
    @Default(ApplicationStage.researching) ApplicationStage stage,
    @Default(2) int priority,
    @Default(DeadlineInput()) DeadlineInput deadline,
    @Default(DeadlineInput()) DeadlineInput fundingDeadline,
    String? location,
    String? department,
    String? researchArea,
    String? programmeUrl,
    String? portalUrl,
    String? portalUsername,
    String? fundingUrl,
    String? feeAmount, // as typed; parsed on validate/save
    String? feeCurrency,
    @Default(FeeWaiver.none) FeeWaiver feeWaiver,
    String? tuitionAmount, // as typed; parsed on validate/save
    String? tuitionCurrency,
    ApproxDate? opensOn,
    ApproxDate? decisionExpected,
    String? notes,

    /// Checklist to create along with the application. Only used on create
    /// (import); the form doesn't edit it.
    @Default(<RequirementSeed>[]) List<RequirementSeed> requirements,
  }) = _ApplicationDraft;

  /// [fallbackZone] prefills the zone of deadlines that aren't set yet.
  factory ApplicationDraft.fromApplication(Application a, {String? fallbackZone}) => ApplicationDraft(
        institutionId: a.institutionId,
        institutionName: a.institutionName,
        institutionCountry: a.country,
        programmeName: a.programmeName,
        degree: a.degree,
        stage: a.stage,
        priority: a.priority,
        deadline: DeadlineInput.fromDeadline(a.deadline, fallbackZone: fallbackZone),
        fundingDeadline: DeadlineInput.fromDeadline(
          a.fundingDeadline,
          fallbackZone: a.deadline?.zone ?? fallbackZone,
        ),
        location: a.location,
        department: a.department,
        researchArea: a.researchArea,
        programmeUrl: a.programmeUrl,
        portalUrl: a.portalUrl,
        portalUsername: a.portalUsername,
        fundingUrl: a.fundingUrl,
        feeAmount: a.feeAmount == null ? null : _formatAmount(a.feeAmount!),
        feeCurrency: a.feeCurrency,
        feeWaiver: a.feeWaiver,
        tuitionAmount: a.tuitionAmount == null ? null : _formatAmount(a.tuitionAmount!),
        tuitionCurrency: a.tuitionCurrency,
        opensOn: a.opensOn,
        decisionExpected: a.decisionExpected,
        notes: a.notes,
      );

  bool get createsInstitution => institutionId == null;

  double? get parsedFee => _parseAmount(feeAmount);

  double? get parsedTuition => _parseAmount(tuitionAmount);

  static double? _parseAmount(String? v) {
    final raw = v?.replaceAll(',', '').trim();
    return raw == null || raw.isEmpty ? null : double.tryParse(raw);
  }

  /// Empty map = valid.
  Map<DraftField, String> validate() {
    final errors = <DraftField, String>{};
    if (institutionName.trim().isEmpty) errors[DraftField.institution] = 'Choose or add a university';
    if (programmeName.trim().isEmpty) errors[DraftField.programmeName] = 'Enter the programme name';
    if (deadline.isSet && deadline.zone == null) {
      errors[DraftField.deadline] = 'Choose the time zone the deadline is published in';
    }
    if (fundingDeadline.isSet && fundingDeadline.zone == null) {
      errors[DraftField.fundingDeadline] = 'Choose a time zone';
    }
    for (final (field, value) in [
      (DraftField.programmeUrl, programmeUrl),
      (DraftField.portalUrl, portalUrl),
      (DraftField.fundingUrl, fundingUrl),
    ]) {
      if (!_isBlankOrUrl(value)) errors[field] = 'Enter a full link starting with https://';
    }
    for (final (raw, parsed, currency, field, currencyField) in [
      (feeAmount, parsedFee, feeCurrency, DraftField.fee, DraftField.feeCurrency),
      (tuitionAmount, parsedTuition, tuitionCurrency, DraftField.tuition, DraftField.tuitionCurrency),
    ]) {
      if ((raw?.trim() ?? '').isEmpty) continue;
      if (parsed == null || parsed < 0) errors[field] = 'Enter an amount, e.g. 125 or 125.50';
      if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(currency?.trim() ?? '')) {
        errors[currencyField] = '3-letter code, e.g. CAD';
      }
    }
    return errors;
  }

  static bool _isBlankOrUrl(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return true;
    final uri = Uri.tryParse(s);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.contains('.');
  }

  static String _formatAmount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

/// Trims and turns empty strings into null for storage.
String? blankToNull(String? v) {
  final s = v?.trim();
  return s == null || s.isEmpty ? null : s;
}
