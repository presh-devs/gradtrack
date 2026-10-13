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
  }) = _DeadlineInput;

  factory DeadlineInput.fromDeadline(Deadline? d, {String? fallbackZone}) {
    if (d == null) return DeadlineInput(zone: fallbackZone);
    final t = d.inZone;
    return DeadlineInput(
      date: DateTime(t.year, t.month, t.day),
      hour: t.hour,
      minute: t.minute,
      zone: d.zone,
    );
  }

  bool get isSet => date != null;

  Deadline? toDeadline() => date == null || zone == null
      ? null
      : Deadline.wallClock(zone!, date!.year, date!.month, date!.day, hour: hour, minute: minute);
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
    String? department,
    String? researchArea,
    String? programmeUrl,
    String? portalUrl,
    String? portalUsername,
    String? fundingUrl,
    String? feeAmount, // as typed; parsed on validate/save
    String? feeCurrency,
    @Default(FeeWaiver.none) FeeWaiver feeWaiver,
    String? notes,
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
        department: a.department,
        researchArea: a.researchArea,
        programmeUrl: a.programmeUrl,
        portalUrl: a.portalUrl,
        portalUsername: a.portalUsername,
        fundingUrl: a.fundingUrl,
        feeAmount: a.feeAmount == null ? null : _formatAmount(a.feeAmount!),
        feeCurrency: a.feeCurrency,
        feeWaiver: a.feeWaiver,
        notes: a.notes,
      );

  bool get createsInstitution => institutionId == null;

  double? get parsedFee {
    final raw = feeAmount?.replaceAll(',', '').trim();
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
    final rawFee = feeAmount?.trim() ?? '';
    if (rawFee.isNotEmpty) {
      final fee = parsedFee;
      if (fee == null || fee < 0) errors[DraftField.fee] = 'Enter an amount, e.g. 125 or 125.50';
      final cur = feeCurrency?.trim() ?? '';
      if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(cur)) {
        errors[DraftField.feeCurrency] = '3-letter code, e.g. CAD';
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
