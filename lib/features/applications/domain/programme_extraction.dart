import '../../../core/time/deadline.dart';
import '../../checklist/domain/requirement.dart';
import 'application.dart';
import 'application_draft.dart';
import 'institution.dart';

/// What the extract-programme function read from a programme page. Every
/// field may be missing; [applyTo] only fills what was found.
class ProgrammeExtraction {
  const ProgrammeExtraction(this.json);

  factory ProgrammeExtraction.fromJson(Map<String, dynamic> json) => ProgrammeExtraction(json);

  final Map<String, dynamic> json;

  String? _s(String key) {
    final v = json[key];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  double? _n(String key) => (json[key] as num?)?.toDouble();
  bool _b(String key) => json[key] == true;

  static DateTime? _date(String? v) => v == null ? null : DateTime.tryParse(v);

  String? get institutionName => _s('institution_name');
  String? get programmeName => _s('programme_name');
  String? get notes => _s('notes');
  String? get sourceUrl => _s('source_url');
  bool get truncated => _b('truncated');
  bool get cached => _b('cached');
  List<String> get requirements => [
        for (final r in (json['requirements'] as List? ?? const [])) if (r is String && r.trim().isNotEmpty) r.trim(),
      ];

  /// Fields the model inferred or wasn't sure about, plus deadlines whose
  /// time zone had to be assumed.
  Set<String> get checkFields => {
        for (final f in (json['check_fields'] as List? ?? const [])) if (f is String) f,
        if (_s('deadline_date') != null && _s('deadline_timezone') == null) 'deadline_timezone',
      };

  /// How many form fields this fills (for the "Filled 9 fields" message).
  int get filledCount => [
        'institution_name', 'programme_name', 'degree', 'location', 'department', 'research_area',
        'deadline_date', 'funding_deadline_date', 'opens_on', 'decision_expected', 'fee_amount',
        'tuition_amount', 'portal_url', 'requires_professor_acceptance',
      ].where((k) => json[k] != null && json[k] != '').length +
      (requirements.isEmpty ? 0 : 1);

  /// [base] with everything found filled in. Values the page didn't give keep
  /// whatever [base] had (so anything typed first survives).
  ApplicationDraft applyTo(ApplicationDraft base, {List<Institution> institutions = const []}) {
    var d = base;

    final name = institutionName;
    if (name != null) {
      final known = institutions.where((i) => i.name.toLowerCase() == name.toLowerCase()).firstOrNull;
      d = known != null
          ? d.copyWith(institutionId: known.id, institutionName: known.name, institutionCountry: known.country)
          : d.copyWith(institutionId: null, institutionName: name, institutionCountry: _s('country_code') ?? d.institutionCountry);
    }
    final country = d.institutionCountry;
    // Zone: as stated → the university's saved zone → its country's usual zone → what the form had.
    final knownZone = institutions.where((i) => i.id == d.institutionId).firstOrNull?.defaultTz;
    final zone = _s('deadline_timezone') ?? knownZone ?? countryDefaultZones[country] ?? d.deadline.zone;

    DeadlineInput? deadline(String prefix, DeadlineInput current, {bool monthOnly = false}) {
      final date = _date(_s('${prefix}_date'));
      if (date == null) return null;
      final time = _s('${prefix}_time')?.split(':');
      return current.copyWith(
        date: DateTime(date.year, date.month, date.day),
        hour: time == null ? 23 : int.parse(time[0]),
        minute: time == null ? 59 : int.parse(time[1]),
        zone: zone,
        monthOnly: monthOnly,
      );
    }

    ApproxDate? approx(String key, String monthKey) {
      final date = _date(_s(key));
      return date == null ? null : ApproxDate(date, _b(monthKey) ? DatePrecision.month : DatePrecision.day);
    }

    String? amount(double? v) => v == null ? null : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2));

    final degree = _s('degree');
    final fee = _n('fee_amount');
    final tuition = _n('tuition_amount');
    final acceptance = json['requires_professor_acceptance'];

    return d.copyWith(
      programmeName: programmeName ?? d.programmeName,
      degree: degree == null ? d.degree : DegreeType.fromDb(degree),
      location: _s('location') ?? d.location,
      department: _s('department') ?? d.department,
      researchArea: _s('research_area') ?? d.researchArea,
      programmeUrl: sourceUrl ?? d.programmeUrl,
      portalUrl: _s('portal_url') ?? d.portalUrl,
      deadline: deadline('deadline', d.deadline, monthOnly: _b('deadline_month_only')) ?? d.deadline,
      fundingDeadline: deadline('funding_deadline', d.fundingDeadline) ?? d.fundingDeadline,
      opensOn: approx('opens_on', 'opens_month_only') ?? d.opensOn,
      decisionExpected: approx('decision_expected', 'decision_month_only') ?? d.decisionExpected,
      feeAmount: amount(fee) ?? d.feeAmount,
      feeCurrency: fee == null ? d.feeCurrency : (_s('fee_currency') ?? d.feeCurrency),
      feeWaiver: _b('fee_waiver_available') && d.feeWaiver == FeeWaiver.none ? FeeWaiver.eligible : d.feeWaiver,
      tuitionAmount: amount(tuition) ?? d.tuitionAmount,
      tuitionCurrency: tuition == null ? d.tuitionCurrency : (_s('tuition_currency') ?? d.tuitionCurrency),
      requiresProfessorAcceptance: acceptance is bool ? acceptance : d.requiresProfessorAcceptance,
      notes: notes == null
          ? d.notes
          : [if ((d.notes ?? '').trim().isNotEmpty) d.notes!.trim(), notes].join('\n'),
      requirements: requirements.isEmpty
          ? d.requirements
          : [
              for (final title in requirements)
                () {
                  final (kind, external) = requirementKindFor(title);
                  return RequirementSeed(kind, title, external: external);
                }(),
            ],
    );
  }
}

/// A sentence the app can show as-is ("Couldn't read that page. …").
class ExtractionException implements Exception {
  const ExtractionException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

abstract interface class ProgrammeExtractor {
  /// Reads a programme page by link, or from [text] pasted from it.
  Future<ProgrammeExtraction> extract({String? url, String? text});
}
