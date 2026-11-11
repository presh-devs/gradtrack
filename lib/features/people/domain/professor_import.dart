import '../../import/domain/csv_import.dart';
import '../../import/domain/value_parsers.dart';
import 'professor.dart';

/// Columns the professor paste understands.
enum ProfessorField {
  school('School', aliases: [
    'school', 'university', 'institution', 'institute', 'uni', 'nameofschool', 'schoolname', 'universityname',
  ]),
  name('Name', aliases: [
    'name', 'supervisor', 'supervisors', 'professor', 'professors', 'prof', 'supervisorname', 'professorname',
    'contact', 'faculty',
  ]),
  department('Department', aliases: ['department', 'dept', 'faculty/department', 'lab', 'group']),
  researchArea('Research area', aliases: [
    'areaofinterest', 'areasofinterest', 'researcharea', 'research', 'interests', 'researchinterests', 'area',
    'focus',
  ]),
  paper('Related paper', aliases: ['relatedpaper', 'paper', 'papers', 'publication', 'publications']),
  email('Email', aliases: ['email', 'mail', 'emailaddress', 'e-mail']),
  website('Website', aliases: ['website', 'link', 'url', 'homepage', 'profile', 'page', 'webpage', 'site']),
  status('Status', aliases: ['status', 'contacted', 'emailed', 'sent', 'comment', 'progress']),
  notes('Notes', aliases: ['notes', 'note', 'remarks']);

  const ProfessorField(this.label, {this.aliases = const []});
  final String label;
  final List<String> aliases;
}

String _key(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9/-]'), '');

/// Header → field by alias, each field at most once.
Map<int, ProfessorField> autoMapProfessors(List<String> headers) {
  final mapping = <int, ProfessorField>{};
  final used = <ProfessorField>{};
  for (var i = 0; i < headers.length; i++) {
    if (isSecretHeader(headers[i])) continue;
    final k = _key(headers[i]);
    for (final f in ProfessorField.values) {
      if (!used.contains(f) && f.aliases.contains(k)) {
        mapping[i] = f;
        used.add(f);
        break;
      }
    }
  }
  return mapping;
}

/// Splits "Prof WANG Qingsong", "Dr. Shangfeng Yang", "Hui Huang Prof.",
/// "Li Xiaoyi Ph. D. Professor" into a title and a name.
({String name, String? title}) parseProfessorName(String raw) {
  var s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  String? title;
  final patterns = <(RegExp, String)>[
    (RegExp(r'\b(associate|assistant|asst\.?|assoc\.?)\s+prof(essor)?\.?(?=\s|$)', caseSensitive: false), 'Prof.'),
    (RegExp(r'\bprof(essor)?\.?(?=\s|$)', caseSensitive: false), 'Prof.'),
    (RegExp(r'\bdr\.?(?=\s|$)', caseSensitive: false), 'Dr.'),
    (RegExp(r'\bph\.?\s?d\.?(?=\s|$)', caseSensitive: false), 'Dr.'),
  ];
  for (final (pattern, label) in patterns) {
    if (pattern.hasMatch(s)) {
      title ??= label;
      s = s.replaceAll(pattern, ' ');
    }
  }
  s = s.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'^[\s,.\-]+|[\s,.\-]+$'), '');
  return (name: s, title: title);
}

final _emailPattern = RegExp(r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}');
final _urlPattern = RegExp(r'^(https?://|www\.)\S+$', caseSensitive: false);

bool _isContacted(String raw) {
  final s = raw.trim().toLowerCase();
  return RegExp(r'^(sent|contacted|emailed|e-mailed|mailed|yes|y|done|replied|responded|✓|x)\b').hasMatch(s);
}

class ProfessorImportRow {
  const ProfessorImportRow({required this.line, this.import, this.errors = const []});

  /// 1-based line in the pasted text (header = 1).
  final int line;
  final ProfessorImport? import;
  final List<String> errors;

  bool get ok => import != null && errors.isEmpty;
}

/// Turns pasted rows into professors. A blank School cell repeats the one
/// above it, because sheets usually write the university once per group.
/// Emails and links are picked up from whichever column they ended up in.
List<ProfessorImportRow> buildProfessorRows(CsvTable table, Map<int, ProfessorField> mapping) {
  final columnOf = {for (final e in mapping.entries) e.value: e.key};
  String? currentSchool;
  final rows = <ProfessorImportRow>[];
  for (var r = 0; r < table.rows.length; r++) {
    final row = table.rows[r];
    String cell(ProfessorField f) => columnOf[f] == null ? '' : row[columnOf[f]!].trim();

    final school = cell(ProfessorField.school);
    if (school.isNotEmpty) currentSchool = school;

    final rawName = cell(ProfessorField.name);
    if (rawName.isEmpty) continue; // section headers, blank spacer rows
    final (:name, :title) = parseProfessorName(rawName);

    // Email: its own column, else anywhere in the row.
    var email = _emailPattern.firstMatch(cell(ProfessorField.email))?[0];
    email ??= row.map((c) => _emailPattern.firstMatch(c)?[0]).nonNulls.firstOrNull;

    // Website: its own column, else a link in the research-area column.
    var website = cell(ProfessorField.website);
    var area = cell(ProfessorField.researchArea);
    if (!_urlPattern.hasMatch(website)) website = '';
    if (website.isEmpty && _urlPattern.hasMatch(area)) {
      website = area;
      area = '';
    }

    final paper = cell(ProfessorField.paper);
    final notes = [
      if (cell(ProfessorField.notes).isNotEmpty) cell(ProfessorField.notes),
      if (paper.isNotEmpty) 'Related paper: $paper',
      if (cell(ProfessorField.status).isNotEmpty && !_isContacted(cell(ProfessorField.status)))
        'Status: ${cell(ProfessorField.status)}',
    ].join('\n');

    final errors = [
      if (currentSchool == null) 'No school for this row (add a School column)',
      if (name.isEmpty) 'Couldn’t read a name from “$rawName”',
    ];
    rows.add(ProfessorImportRow(
      line: r + 2,
      errors: errors,
      import: ProfessorImport(
        contacted: _isContacted(cell(ProfessorField.status)),
        draft: ProfessorDraft(
          institutionName: currentSchool ?? '',
          name: name,
          academicTitle: title,
          department: _blank(cell(ProfessorField.department)),
          email: email?.toLowerCase(),
          profileUrl: website.isEmpty ? null : normaliseUrl(website),
          researchInterests: _blank(area.replaceAll(RegExp(r'\s*\n\s*'), '; ')),
          notes: _blank(notes),
        ),
      ),
    ));
  }
  return rows;
}

String? _blank(String s) => s.trim().isEmpty ? null : s.trim();
