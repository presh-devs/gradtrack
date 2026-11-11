import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/features/import/domain/csv_import.dart';
import 'package:gradll/features/people/domain/professor.dart';
import 'package:gradll/features/people/domain/professor_import.dart';

void main() {
  test('titles are split from names wherever they appear', () {
    expect(parseProfessorName('Prof WANG Qingsong'), (name: 'WANG Qingsong', title: 'Prof.'));
    expect(parseProfessorName('prof Genqiang Zhang'), (name: 'Genqiang Zhang', title: 'Prof.'));
    expect(parseProfessorName('Dr. Shangfeng Yang'), (name: 'Shangfeng Yang', title: 'Dr.'));
    expect(parseProfessorName('Hui Huang Prof.'), (name: 'Hui Huang', title: 'Prof.'));
    expect(parseProfessorName('Li Xiaoyi Ph. D. Professor'), (name: 'Li Xiaoyi', title: 'Prof.'));
    expect(parseProfessorName('Chen Chunhua professor'), (name: 'Chen Chunhua', title: 'Prof.'));
    expect(parseProfessorName('An Zhenguo'), (name: 'An Zhenguo', title: null));
    expect(parseProfessorName('Associate Professor Jane Doe'), (name: 'Jane Doe', title: 'Prof.'));
  });

  test('sheet-style paste: fill-down school, emails and links found anywhere, status', () {
    const paste = 'school\tsupervisors\tArea of interest\trelated paper\temail\twebsite\tStatus\tPassword\n'
        'USTC\tProf WANG Qingsong\tLithium ion battery fire safety\tPaper A\twq@example.edu.cn\t\t\tx\n'
        '\tprof Ren Xiaodi\tEnergy storage\t\tXR@Example.edu.cn\thttps://lab.example.edu.cn\t\t\n'
        '\t\t2. Second interest line only\t\t\t\t\t\n'
        'Dalian Institute\tProf CHENG Mojie\thttp://english.example.cn/cheng\t\tmj@example.cn\t\tsent\t\n'
        '\tJIANG Peng\tThermoelectric materials\t\tcontact: jp@example.cn\t\tSent\t\n'
        '\tLU Xiaowei\t\t\t\t\tcheck back in May\t\n';
    final table = CsvTable.parse(paste);
    final mapping = autoMapProfessors(table.headers);
    expect(mapping.values, isNot(contains(null)));
    expect(mapping.containsKey(7), isFalse); // password column never mapped
    final rows = buildProfessorRows(table, mapping);

    expect(rows, hasLength(5)); // the name-less continuation row is skipped
    expect(rows.every((r) => r.ok), isTrue);
    final d = [for (final r in rows) r.import!.draft];

    expect(d.map((x) => x.institutionName), ['USTC', 'USTC', 'Dalian Institute', 'Dalian Institute', 'Dalian Institute']);
    expect(d[0].academicTitle, 'Prof.');
    expect(d[0].notes, 'Related paper: Paper A');
    expect(d[1].email, 'xr@example.edu.cn');
    expect(d[1].profileUrl, 'https://lab.example.edu.cn');
    // A link in the research-area column becomes the website.
    expect(d[2].profileUrl, 'http://english.example.cn/cheng');
    expect(d[2].researchInterests, isNull);
    expect(d[3].email, 'jp@example.cn');
    expect(rows.map((r) => r.import!.contacted), [false, false, true, true, false]);
    expect(d[4].notes, 'Status: check back in May');
  });

  test('rows before any school are reported', () {
    final table = CsvTable.parse('school,name\n,Jane Doe\nMIT,John Roe');
    final rows = buildProfessorRows(table, autoMapProfessors(table.headers));
    expect(rows.first.ok, isFalse);
    expect(rows.last.ok, isTrue);
  });

  test('draft validation', () {
    expect(const ProfessorDraft().validate().keys, containsAll(['institution', 'name']));
    expect(
      const ProfessorDraft(institutionName: 'MIT', name: 'Jo', email: 'nope', profileUrl: 'lab page').validate().keys,
      ['email', 'profileUrl'],
    );
    expect(const ProfessorDraft(institutionName: 'MIT', name: 'Jo', email: 'jo@mit.edu').validate(), isEmpty);
  });
}
