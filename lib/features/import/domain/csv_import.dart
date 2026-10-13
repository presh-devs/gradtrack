import 'package:csv/csv.dart';

import '../../applications/domain/application.dart';
import '../../applications/domain/application_draft.dart';
import '../../applications/domain/institution.dart';
import 'value_parsers.dart';

/// Columns GradTrack understands (spec 02 · CSV import mapping).
enum ImportField {
  university('University', required: true, aliases: ['university', 'school', 'institution', 'uni', 'college']),
  programme('Programme', required: true, aliases: [
    'programme', 'program', 'programmename', 'programname', 'course', 'degreeprogram', 'degreeprogramme',
  ]),
  degree('Degree', aliases: ['degree', 'degreetype', 'level', 'qualification']),
  country('Country', aliases: ['country', 'countrycode', 'location']),
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
  fee('Application fee', aliases: ['fee', 'applicationfee', 'appfee', 'cost', 'fees']),
  feeCurrency('Fee currency', aliases: ['feecurrency', 'currency']),
  programmeUrl('Programme page', aliases: ['programmeurl', 'programurl', 'url', 'website', 'link', 'programmepage', 'webpage']),
  portalUrl('Application portal', aliases: ['portalurl', 'portal', 'applicationportal', 'applicationlink', 'applylink', 'applyurl']),
  stage('Stage', aliases: ['stage', 'status', 'progress']),
  priority('Priority', aliases: ['priority', 'rank', 'tier', 'ranking']),
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
ColumnMapping autoMap(List<String> headers) {
  final mapping = <int, ImportField>{};
  final used = <ImportField>{};
  for (var i = 0; i < headers.length; i++) {
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
  'University', 'Country', 'Programme', 'Degree', 'Department', 'Research area',
  'Deadline', 'Deadline time zone', 'Funding deadline', 'Application fee', 'Fee currency',
  'Programme page', 'Application portal', 'Stage', 'Priority', 'Notes',
];
const templateExample = [
  'University of Toronto', 'CA', 'Computer Science', 'PhD', 'Computer Science', 'Machine learning',
  '2026-12-01 23:59', 'America/Toronto', '2026-11-15', '125', 'CAD',
  'https://web.cs.toronto.edu/graduate', 'https://sgs.utoronto.ca', 'Shortlisted', 'Top', '',
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
    final country = parseCountry(countryRaw) ?? known?.country;
    if (countryRaw.isNotEmpty && parseCountry(countryRaw) == null) {
      warnings.add('Country "$countryRaw" not recognised, so it was left blank');
    }

    final (degree, degreeOk) = parseDegree(cell(ImportField.degree));
    if (!degreeOk) warnings.add('Degree "${cell(ImportField.degree)}" saved as Other');
    final (stage, stageOk) = parseStage(cell(ImportField.stage));
    if (!stageOk) warnings.add('Stage "${cell(ImportField.stage)}" not recognised, so it was set to Researching');
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
    final deadlineRaw = cell(ImportField.deadline);
    final deadline = parseDateTime(deadlineRaw, order: options.dateOrder);
    if (deadlineRaw.isNotEmpty && deadline == null) errors.add('Deadline "$deadlineRaw" isn\'t a date I can read');
    final fundingRaw = cell(ImportField.fundingDeadline);
    final funding = parseDateTime(fundingRaw, order: options.dateOrder);
    if (fundingRaw.isNotEmpty && funding == null) errors.add('Funding deadline "$fundingRaw" isn\'t a date I can read');
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

    DeadlineInput toInput(ParsedDateTime? p) => p == null
        ? DeadlineInput(zone: zone)
        : DeadlineInput(
            date: p.date,
            hour: p.hour ?? 23,
            minute: p.minute ?? 59,
            zone: p.zoneHint ?? zone,
          );

    // Fee
    final fee = parseFee(cell(ImportField.fee));
    var feeCurrency = cell(ImportField.feeCurrency).isNotEmpty
        ? cell(ImportField.feeCurrency).toUpperCase()
        : fee.currency;
    var feeAmount = fee.amount;
    if (feeAmount != null && (feeCurrency == null || !RegExp(r'^[A-Z]{3}$').hasMatch(feeCurrency))) {
      warnings.add('Fee skipped: no currency (add a Fee currency column, e.g. CAD)');
      feeAmount = null;
      feeCurrency = null;
    }

    final draft = ApplicationDraft(
      institutionId: known?.id,
      institutionName: known?.name ?? universityName,
      institutionCountry: country,
      programmeName: cell(ImportField.programme),
      degree: degree,
      stage: stage,
      priority: priority,
      deadline: toInput(deadline),
      fundingDeadline: toInput(funding),
      department: _blank(cell(ImportField.department)),
      researchArea: _blank(cell(ImportField.researchArea)),
      programmeUrl: normaliseUrl(cell(ImportField.programmeUrl)),
      portalUrl: normaliseUrl(cell(ImportField.portalUrl)),
      feeAmount: feeAmount,
      feeCurrency: feeCurrency,
      notes: _blank(cell(ImportField.notes)),
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
      zoneSource: deadline == null ? null : zoneSource,
    ));
  }
  return result;
}

String? _blank(String s) => s.isEmpty ? null : s;
