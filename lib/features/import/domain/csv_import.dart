import 'package:csv/csv.dart';

import '../../../core/time/deadline.dart';
import '../../applications/domain/application.dart';
import '../../applications/domain/application_draft.dart';
import '../../applications/domain/institution.dart';
import 'value_parsers.dart';

/// Columns gradll understands (spec 02 · CSV import mapping).
enum ImportField {
  university('University', required: true, aliases: [
    'university', 'school', 'institution', 'uni', 'college', 'nameofschool', 'schoolname', 'universityname',
    'nameofuniversity', 'nameofinstitution',
  ]),
  programme('Programme', required: true, aliases: [
    'programme', 'program', 'programmename', 'programname', 'course', 'degreeprogram', 'degreeprogramme',
  ]),
  degree('Degree', aliases: ['degree', 'degreetype', 'level', 'qualification']),
  country('Country', aliases: ['country', 'countrycode']),
  location('Location (city, state)', aliases: [
    'location', 'city', 'state', 'citystate', 'city/state', 'campus', 'town', 'province',
  ]),
  professorAcceptance('Needs professor acceptance', aliases: [
    'needsprofessoracceptance', 'professoracceptance', 'requiresprofessoracceptance', 'supervisoracceptance',
    'supervisorrequired', 'needssupervisor', 'requiressupervisor', 'acceptanceletter', 'professorrequired',
    'contactprofessorfirst',
  ]),
  department('Department', aliases: ['department', 'dept', 'faculty', 'school/department']),
  researchArea('Research area', aliases: [
    'researcharea', 'research', 'area', 'specialisation', 'specialization', 'focus', 'researchinterests',
  ]),
  deadline('Deadline', aliases: [
    'deadline', 'applicationdeadline', 'appdeadline', 'duedate', 'due', 'deadlinedate', 'closingdate',
  ]),
  deadlineZone('Deadline time zone', aliases: ['deadlinetimezone', 'timezone', 'tz', 'zone', 'deadlinetz']),
  fundingDeadline('Funding deadline', aliases: [
    'fundingdeadline', 'scholarshipdeadline', 'funding', 'fundingdate', 'scholarship',
  ]),
  opensOn('Applications open', aliases: [
    'applicationopen', 'applicationsopen', 'applicationopens', 'opens', 'opendate', 'opening', 'openingdate',
    'portalopens', 'opensOn',
  ]),
  decisionExpected('Expected decision', aliases: [
    'expecteddateofdecision', 'expecteddecision', 'expecteddecisiondate', 'decisiondate', 'decisionexpected',
    'resultdate', 'decision',
  ]),
  fee('Application fee', aliases: ['fee', 'applicationfee', 'appfee', 'cost']),
  feeCurrency('Fee currency', aliases: ['feecurrency', 'currency']),
  tuition('Tuition', aliases: ['tuition', 'tuitionfee', 'tuitionfees', 'fees', 'tuitionestimate', 'schoolfees']),
  programmeUrl('Programme page', aliases: ['programmeurl', 'programurl', 'url', 'website', 'link', 'programmepage', 'webpage']),
  portalUrl('Application portal', aliases: ['portalurl', 'portal', 'applicationportal', 'applicationlink', 'applylink', 'applyurl']),
  portalUsername('Portal username', aliases: ['username', 'portalusername', 'login', 'loginid', 'userid', 'user', 'portallogin']),
  stage('Stage', aliases: ['stage', 'status', 'progress']),
  priority('Priority', aliases: ['priority', 'rank', 'tier', 'ranking']),
  requirements('Requirements (comma-separated)', aliases: [
    'requirements', 'documents', 'documentsrequired', 'requireddocuments', 'checklist', 'documentsneeded',
  ]),
  notes('Notes', aliases: ['notes', 'note', 'comments', 'comment', 'remarks']);

  const ImportField(this.label, {this.required = false, this.aliases = const []});
  final String label;
  final bool required;
  final List<String> aliases;
}

String _key(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9/]'), '');

/// A parsed sheet: header row + data rows, all cells trimmed strings.
class CsvTable {
  const CsvTable(this.headers, this.rows);

  final List<String> headers;
  final List<List<String>> rows;

  /// Parses CSV/TSV text (comma, semicolon or tab — whichever the header
  /// line uses most; a paste from Google Sheets or Excel is tab-separated).
  factory CsvTable.parse(String text) {
    final normalised = text.replaceFirst('﻿', '').replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final firstLine = normalised.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    final delimiter = _detectDelimiter(firstLine);
    final raw = CsvDecoder(fieldDelimiter: delimiter, skipEmptyLines: true).convert(normalised);
    final cells = [
      for (final r in raw) [for (final c in r) '${c ?? ''}'.trim()],
    ].where((r) => r.any((c) => c.isNotEmpty)).toList();
    if (cells.isEmpty) return const CsvTable([], []);
    final width = cells.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    List<String> pad(List<String> r) => [...r, for (var i = r.length; i < width; i++) ''];
    return CsvTable(pad(cells.first), [for (final r in cells.skip(1)) pad(r)]);
  }

  static String _detectDelimiter(String line) {
    final counts = {
      '\t': '\t'.allMatches(line).length,
      ';': ';'.allMatches(line).length,
      ',': ','.allMatches(line).length,
    };
    final best = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
    return best.value == 0 ? ',' : best.key;
  }

  bool get isEmpty => headers.isEmpty || rows.isEmpty;

  /// First non-empty value in a column, for the mapping step's preview.
  String sample(int column) =>
      rows.map((r) => r[column]).firstWhere((v) => v.isNotEmpty, orElse: () => '');
}

/// column index → field (absent = ignored).
typedef ColumnMapping = Map<int, ImportField>;

/// Matches headers to fields by alias; each field is used at most once.
/// Password columns are never mapped (see [isSecretHeader]).
ColumnMapping autoMap(List<String> headers) {
  final mapping = <int, ImportField>{};
  final used = <ImportField>{};
  for (var i = 0; i < headers.length; i++) {
    if (isSecretHeader(headers[i])) continue;
    final k = _key(headers[i]);
    for (final f in ImportField.values) {
      if (!used.contains(f) && f.aliases.contains(k)) {
        mapping[i] = f;
        used.add(f);
        break;
      }
    }
  }
  return mapping;
}

/// Spreadsheet headers for the downloadable template, plus one example row.
const templateHeaders = [
  'University', 'Country', 'Location', 'Programme', 'Degree', 'Department', 'Research area',
  'Deadline', 'Deadline time zone', 'Funding deadline', 'Applications open', 'Expected decision',
  'Application fee', 'Fee currency', 'Tuition', 'Programme page', 'Application portal', 'Portal username',
  'Stage', 'Priority', 'Needs professor acceptance', 'Requirements', 'Notes',
];
const templateExample = [
  'University of Toronto', 'CA', 'Toronto, ON', 'Computer Science', 'PhD', 'Computer Science', 'Machine learning',
  '2026-12-01 23:59', 'America/Toronto', '2026-11-15', 'Oct 2026', 'Mar 2027',
  '125', 'CAD', 'CAD 7k5', 'https://web.cs.toronto.edu/graduate', 'https://sgs.utoronto.ca', 'jdoe',
  'Shortlisted', 'Top', 'No', 'Transcript, CV, SOP, IELTS', '',
];

String buildTemplateCsv() => Csv(autoDetect: false).encode([templateHeaders, templateExample]);

class ImportOptions {
  const ImportOptions({required this.defaultZone, this.dateOrder = DateOrder.dayFirst});

  final String defaultZone;
  final DateOrder dateOrder;
}

enum RowStatus { ready, invalid, duplicate }

/// One spreadsheet row after parsing: a draft ready to save, or the reasons
/// it can't be imported. [line] is the 1-based line in the file (header = 1).
class ImportRow {
  const ImportRow({
    required this.line,
    required this.status,
    this.draft,
    this.errors = const [],
    this.warnings = const [],
    this.zoneSource,
  });

  final int line;
  final RowStatus status;
  final ApplicationDraft? draft;
  final List<String> errors;
  final List<String> warnings;

  /// How the deadline zone was chosen, for the review step.
  final String? zoneSource;
}

String _dupKey(String institution, String programme, DegreeType degree) =>
    '${_key(institution)}|${_key(programme)}|${degree.db}';

/// Turns sheet rows into drafts using [mapping]. Rows matching an existing
/// application (same university, programme and degree) or an earlier row in
/// the file are marked duplicate rather than imported twice.
List<ImportRow> buildImportRows(
  CsvTable table,
  ColumnMapping mapping,
  ImportOptions options, {
  List<Application> existing = const [],
  List<Institution> institutions = const [],
}) {
  final seen = {for (final a in existing) _dupKey(a.institutionName, a.programmeName, a.degree)};
  final knownInstitutions = {for (final i in institutions) _key(i.name): i};
  final columnOf = {for (final e in mapping.entries) e.value: e.key};

  final result = <ImportRow>[];
  for (var r = 0; r < table.rows.length; r++) {
    final row = table.rows[r];
    String cell(ImportField f) => columnOf[f] == null ? '' : row[columnOf[f]!];
    final errors = <String>[];
    final warnings = <String>[];

    // University (reuse an existing one by name, case-insensitively)
    final universityName = cell(ImportField.university);
    final known = knownInstitutions[_key(universityName)];
    final countryRaw = cell(ImportField.country);
    final location = cell(ImportField.location);
    // Many sheets only have a location ("Beijing", "Boston, USA"): take the country from it too.
    final country = parseCountry(countryRaw) ?? countryFromLocation(location) ?? known?.country;
    if (countryRaw.isNotEmpty && parseCountry(countryRaw) == null) {
      warnings.add('Country "$countryRaw" not recognised, so it was left blank');
    }

    final acceptanceRaw = cell(ImportField.professorAcceptance);
    final needsAcceptance = parseYesNo(acceptanceRaw);
    if (acceptanceRaw.isNotEmpty && needsAcceptance == null) {
      warnings.add('Needs professor acceptance "$acceptanceRaw" not understood, so it was left as No');
    }

    final degreeRaw = cell(ImportField.degree);
    var (degree, degreeOk) = parseDegree(degreeRaw);
    if (!degreeOk) warnings.add('Degree "$degreeRaw" saved as Other');
    if (degreeRaw.isEmpty) {
      // No degree column: "Master of Finance", "International MBA" say it.
      final inferred = degreeFromProgramme(cell(ImportField.programme));
      if (inferred != null) degree = inferred;
    }
    // Text that couldn't go in a field is kept in notes rather than lost.
    final extraNotes = <String>[];

    final stageRaw = cell(ImportField.stage);
    final (stage, stageOk) = parseStage(stageRaw);
    if (!stageOk) warnings.add('Stage "$stageRaw" not recognised, so it was set to Researching');
    if (!isPlainStage(stageRaw)) extraNotes.add('Status: $stageRaw');
    if (stage == ApplicationStage.decided && stageOk) {
      warnings.add('Marked as Decided. Set the outcome on the application');
    }
    final (priority, priorityOk) = parsePriority(cell(ImportField.priority));
    if (!priorityOk) warnings.add('Priority "${cell(ImportField.priority)}" saved as Normal');

    // Deadline zone: explicit column → zone named in the date → university's
    // saved zone → country → wizard default.
    final zoneRaw = cell(ImportField.deadlineZone);
    final zoneColumn = parseZone(zoneRaw);
    if (zoneRaw.isNotEmpty && zoneColumn == null) {
      warnings.add('Time zone "$zoneRaw" not recognised');
    }
    // An unreadable date doesn't block the row: it's kept in notes so it can
    // be set by hand after import.
    ParsedWhen? readWhen(ImportField f, String label) {
      final raw = cell(f);
      if (raw.isEmpty) return null;
      final parsed = parseWhen(raw, order: options.dateOrder);
      if (parsed == null) {
        warnings.add('$label "$raw" isn\'t a date I can read, so it was kept in notes');
        extraNotes.add('$label: $raw');
      } else if (parsed.isMonthOnly && (f == ImportField.deadline || f == ImportField.fundingDeadline)) {
        warnings.add('$label has no day: saved as ${_monthLabel(parsed.date)}, date not confirmed');
      }
      return parsed;
    }

    final deadlineRaw = cell(ImportField.deadline);
    final deadlineWhen = readWhen(ImportField.deadline, 'Deadline');
    final fundingRaw = cell(ImportField.fundingDeadline);
    final fundingWhen = readWhen(ImportField.fundingDeadline, 'Funding deadline');
    final opensWhen = readWhen(ImportField.opensOn, 'Applications open');
    final decisionWhen = readWhen(ImportField.decisionExpected, 'Expected decision');
    final deadline = deadlineWhen?.exact;
    if (deadlineWhen?.rangeStart != null) {
      warnings.add('Deadline is a range: saved the closing date');
    }
    if (isAmbiguousNumericDate(deadlineRaw) || isAmbiguousNumericDate(fundingRaw)) {
      warnings.add('Read as ${options.dateOrder == DateOrder.dayFirst ? 'day/month' : 'month/day'}. Check the date');
    }

    final String zone;
    final String zoneSource;
    if (zoneColumn != null) {
      (zone, zoneSource) = (zoneColumn, 'from the sheet');
    } else if (deadline?.zoneHint != null) {
      (zone, zoneSource) = (deadline!.zoneHint!, 'from the date');
    } else if (known?.defaultTz != null) {
      (zone, zoneSource) = (known!.defaultTz!, 'university’s saved zone');
    } else if (countryDefaultZones[country] != null) {
      (zone, zoneSource) = (countryDefaultZones[country]!, 'from the country');
    } else {
      (zone, zoneSource) = (options.defaultZone, 'default');
    }

    DeadlineInput toInput(ParsedWhen? w) {
      final p = w?.exact;
      if (w == null) return DeadlineInput(zone: zone);
      if (p == null) return DeadlineInput(date: w.month, zone: zone, monthOnly: true);
      return DeadlineInput(
        date: p.date,
        hour: p.hour ?? 23,
        minute: p.minute ?? 59,
        zone: p.zoneHint ?? zone,
      );
    }

    ApproxDate? toApprox(ParsedWhen? w) {
      if (w == null) return null;
      // For an opening window "16 Dec - 22 Jan", the portal opens at the start.
      final v = identical(w, opensWhen) && w.rangeStart != null ? w.rangeStart! : w;
      return ApproxDate(v.date, v.isMonthOnly ? DatePrecision.month : DatePrecision.day);
    }

    // A deadline range's start is when applications open, if not given.
    final opensOn = toApprox(opensWhen) ??
        (deadlineWhen?.rangeStart == null
            ? null
            : ApproxDate(
                deadlineWhen!.rangeStart!.date,
                deadlineWhen.rangeStart!.isMonthOnly ? DatePrecision.month : DatePrecision.day,
              ));

    // Money: currency from the cell, a currency column, or the country.
    ({String? amount, String? currency}) money(ImportField f, String label, {String? currencyColumn}) {
      final raw = cell(f);
      if (raw.isEmpty) return (amount: null, currency: null);
      final parsed = parseFee(raw);
      if (parsed.amount == null) {
        warnings.add('$label "$raw" isn\'t an amount, so it was kept in notes');
        extraNotes.add('$label: $raw');
        return (amount: null, currency: null);
      }
      var currency = currencyColumn?.isNotEmpty == true ? currencyColumn!.toUpperCase() : parsed.currency;
      if (currency == null && raw.contains(RegExp(r'[$﹩＄]')) && country != null && !_dollarCountries.contains(country)) {
        currency = 'USD';
      }
      if (currency == null && countryCurrencies[country] != null) {
        currency = countryCurrencies[country];
        warnings.add('$label "$raw" has no currency: assumed $currency from the country');
      }
      if (currency == null || !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
        warnings.add('$label skipped: no currency (add a Fee currency column, e.g. CAD)');
        extraNotes.add('$label: $raw');
        return (amount: null, currency: null);
      }
      return (amount: parsed.amount, currency: currency);
    }

    final feeRaw = cell(ImportField.fee);
    final mentionsWaiver = feeRaw.toLowerCase().contains('waiver');
    final fee = money(ImportField.fee, 'Application fee', currencyColumn: cell(ImportField.feeCurrency));
    final tuition = money(ImportField.tuition, 'Tuition');

    final requirements = parseRequirements(cell(ImportField.requirements));

    final notes = [
      if (cell(ImportField.notes).isNotEmpty) cell(ImportField.notes),
      ...extraNotes,
    ].join('\n');

    final draft = ApplicationDraft(
      institutionId: known?.id,
      institutionName: known?.name ?? universityName,
      institutionCountry: country,
      programmeName: cell(ImportField.programme),
      degree: degree,
      stage: stage,
      priority: priority,
      deadline: toInput(deadlineWhen),
      fundingDeadline: toInput(fundingWhen),
      opensOn: opensOn,
      decisionExpected: toApprox(decisionWhen),
      location: _blank(location),
      requiresProfessorAcceptance: needsAcceptance ?? false,
      department: _blank(cell(ImportField.department)),
      researchArea: _blank(cell(ImportField.researchArea)),
      programmeUrl: normaliseUrl(cell(ImportField.programmeUrl)),
      portalUrl: normaliseUrl(cell(ImportField.portalUrl)),
      portalUsername: _blank(cell(ImportField.portalUsername)),
      feeAmount: fee.amount,
      feeCurrency: fee.currency,
      feeWaiver: mentionsWaiver ? FeeWaiver.eligible : FeeWaiver.none,
      tuitionAmount: tuition.amount,
      tuitionCurrency: tuition.currency,
      requirements: requirements,
      notes: _blank(notes),
    );
    errors.addAll(draft.validate().values);

    final key = _dupKey(draft.institutionName, draft.programmeName, degree);
    final status = errors.isNotEmpty
        ? RowStatus.invalid
        : seen.contains(key)
            ? RowStatus.duplicate
            : RowStatus.ready;
    if (status == RowStatus.ready) seen.add(key);

    result.add(ImportRow(
      line: r + 2,
      status: status,
      draft: draft,
      errors: errors,
      warnings: warnings,
      zoneSource: deadline == null && deadlineWhen == null ? null : zoneSource,
    ));
  }
  return result;
}

String? _blank(String s) => s.isEmpty ? null : s;

String _monthLabel(DateTime d) =>
    '${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';

/// Where a bare "$" means the local dollar, not USD.
const _dollarCountries = {'US', 'CA', 'AU', 'NZ', 'SG', 'HK'};
