import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/time/deadline.dart';
import 'package:gradll/features/applications/domain/application.dart';
import 'package:gradll/features/applications/domain/institution.dart';
import 'package:gradll/features/import/domain/csv_import.dart';
import 'package:gradll/features/import/domain/value_parsers.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('parseDateTime', () {
    (DateTime, int?, int?, String?) p(String s, [DateOrder o = DateOrder.dayFirst]) {
      final r = parseDateTime(s, order: o)!;
      return (r.date, r.hour, r.minute, r.zoneHint);
    }

    test('ISO with and without time', () {
      expect(p('2026-12-01'), (DateTime(2026, 12, 1), null, null, null));
      expect(p('2026-12-01 17:00'), (DateTime(2026, 12, 1), 17, 0, null));
      expect(p('2026-12-01T23:59'), (DateTime(2026, 12, 1), 23, 59, null));
    });

    test('numeric dates honour day/month order unless unambiguous', () {
      expect(p('01/12/2026').$1, DateTime(2026, 12, 1));
      expect(p('01/12/2026', DateOrder.monthFirst).$1, DateTime(2026, 1, 12));
      expect(p('12/31/2026').$1, DateTime(2026, 12, 31)); // 31 can't be a month
      expect(p('31.12.26').$1, DateTime(2026, 12, 31));
      expect(isAmbiguousNumericDate('01/12/2026'), isTrue);
      expect(isAmbiguousNumericDate('31/12/2026'), isFalse);
    });

    test('month names, 12-hour times and zone abbreviations', () {
      expect(p('1 Dec 2026'), (DateTime(2026, 12, 1), null, null, null));
      expect(p('December 1st, 2026 11:59 PM EST'), (DateTime(2026, 12, 1), 23, 59, 'America/New_York'));
      expect(p('Jan 15, 2027 (AoE)'), (DateTime(2027, 1, 15), null, null, 'Etc/GMT+12'));
      expect(p('15 January 2027 5pm GMT'), (DateTime(2027, 1, 15), 17, 0, 'Europe/London'));
      expect(p('1 Dec 2026 midnight'), (DateTime(2026, 12, 1), 23, 59, null));
    });

    test('rejects nonsense and impossible dates', () {
      expect(parseDateTime('rolling'), isNull);
      expect(parseDateTime('31/02/2026'), isNull);
      expect(parseDateTime('2026-13-01'), isNull);
      expect(parseDateTime(''), isNull);
    });
  });

  test('value parsers', () {
    expect(parseDegree('Ph.D.'), (DegreeType.phd, true));
    expect(parseDegree('M.Sc'), (DegreeType.msc, true));
    expect(parseDegree('Masters'), (DegreeType.msc, true));
    expect(parseDegree('MBA'), (DegreeType.other, false));
    expect(parseStage('Applied'), (ApplicationStage.submitted, true));
    expect(parseStage('Ready to submit'), (ApplicationStage.ready, true));
    expect(parseStage('accepted'), (ApplicationStage.decided, true));
    expect(parseStage('???'), (ApplicationStage.researching, false));
    expect(parsePriority('Dream'), (1, true));
    expect(parsePriority('safety'), (3, true));
    expect(parseFee('CAD 125'), (amount: '125', currency: 'CAD'));
    expect(parseFee('£80'), (amount: '80', currency: 'GBP'));
    expect(parseFee(r'$1,250.50'), (amount: '1,250.50', currency: null));
    expect(parseCountry('United Kingdom'), 'GB');
    expect(parseCountry('uk'), 'GB');
    expect(parseCountry('ca'), 'CA');
    expect(parseZone('Toronto'), 'America/Toronto');
    expect(parseZone('PST'), 'America/Los_Angeles');
    expect(parseZone('Europe/Zurich'), 'Europe/Zurich');
    expect(normaliseUrl('apply.utoronto.ca/grad'), 'https://apply.utoronto.ca/grad');
  });

  group('CsvTable', () {
    test('detects tab-separated pastes from a spreadsheet', () {
      final t = CsvTable.parse('University\tProgramme\nMcGill\tCS\n\n');
      expect(t.headers, ['University', 'Programme']);
      expect(t.rows, [
        ['McGill', 'CS'],
      ]);
    });

    test('handles quoted commas, BOM, CRLF and ragged rows', () {
      final t = CsvTable.parse('﻿University,Notes,Fee\r\n"ETH, Zürich","a, b"\r\n');
      expect(t.headers, ['University', 'Notes', 'Fee']);
      expect(t.rows.single, ['ETH, Zürich', 'a, b', '']);
    });

    test('auto-maps common header spellings once each', () {
      final m = autoMap(['School', 'Program', 'Due date', 'Status', 'Currency', 'Website', 'Ignored col', 'program']);
      expect(m, {
        0: ImportField.university,
        1: ImportField.programme,
        2: ImportField.deadline,
        3: ImportField.stage,
        4: ImportField.feeCurrency,
        5: ImportField.programmeUrl,
      });
    });

    test('the template round-trips through the parser and mapper', () {
      final t = CsvTable.parse(buildTemplateCsv());
      expect(autoMap(t.headers).length, ImportField.values.length);
    });
  });

  group('buildImportRows', () {
    const options = ImportOptions(defaultZone: 'Africa/Lagos');

    List<ImportRow> rows(String csv, {List<Application> existing = const [], List<Institution> inst = const []}) {
      final t = CsvTable.parse(csv);
      return buildImportRows(t, autoMap(t.headers), options, existing: existing, institutions: inst);
    }

    test('resolves the deadline zone in priority order', () {
      final r = rows('''University,Country,Programme,Deadline,Timezone
A,CA,X,2026-12-01,Europe/Paris
B,CA,X,2026-12-01 11:59 PM PST,
C,CA,X,2026-12-01,
D,,X,2026-12-01,
E,,X,,''');
      expect(r.map((e) => e.draft!.deadline.zone), [
        'Europe/Paris',
        'America/Los_Angeles',
        'America/Toronto',
        'Africa/Lagos',
        'Africa/Lagos',
      ]);
      expect(r.map((e) => e.zoneSource), ['from the sheet', 'from the date', 'from the country', 'default', null]);
      expect(r[0].draft!.deadline.toDeadline()!.zoneLabel, '1 Dec, 23:59 CET');
    });

    test('reuses known universities and their saved zone', () {
      final r = rows(
        'University,Programme,Deadline\nmcgill university,Math,2026-12-01',
        inst: [const Institution(id: 'i1', name: 'McGill University', country: 'CA', defaultTz: 'America/Toronto')],
      );
      expect(r.single.draft!.institutionId, 'i1');
      expect(r.single.draft!.institutionName, 'McGill University');
      expect(r.single.draft!.deadline.zone, 'America/Toronto');
    });

    test('flags errors, duplicates (existing and in-file) and soft warnings', () {
      final r = rows(
        '''University,Programme,Degree,Deadline,Fee,Stage
,Missing uni,,,,
McGill,CS,PhD,not a date,,
McGill,Math,PhD,,,
Toronto,CS,PhD,,,
Toronto,CS,Ph.D.,,,
Waterloo,CS,MBA,,\$90,Whatever''',
        existing: [
          const Application(
            id: 'a1',
            institutionId: 'i',
            institutionName: 'McGill',
            programmeName: 'Math',
            degree: DegreeType.phd,
            stage: ApplicationStage.researching,
          ),
        ],
      );
      expect(r.map((e) => e.status), [
        RowStatus.invalid, // no university
        RowStatus.ready, // unreadable date: kept in notes, not blocking
        RowStatus.duplicate, // already in gradll
        RowStatus.ready,
        RowStatus.duplicate, // same as the row above
        RowStatus.ready,
      ]);
      expect(r.map((e) => e.line), [2, 3, 4, 5, 6, 7]);
      expect(r[1].draft!.notes, 'Deadline: not a date');
      expect(r[1].draft!.deadline.isSet, isFalse);
      expect(r.last.warnings, hasLength(3)); // degree, stage, fee without currency
      expect(r.last.draft!.feeAmount, isNull);
    });
  });

  group('spreadsheet formats', () {
    const options = ImportOptions(defaultZone: 'Africa/Lagos');

    test('month-only dates, ranges and month-year parsing', () {
      expect(parseMonthYear('Dec-26'), DateTime(2026, 12));
      expect(parseMonthYear('October 2026'), DateTime(2026, 10));
      expect(parseMonthYear('2027-01'), DateTime(2027, 1));
      expect(parseMonthYear('03/2027'), DateTime(2027, 3));
      expect(parseMonthYear('Dec 1'), isNull);
      final range = parseWhen('16 December 2026 - 22 January 2027')!;
      expect(range.date, DateTime(2027, 1, 22));
      expect(range.rangeStart!.date, DateTime(2026, 12, 16));
      expect(parseWhen('Oct-26')!.isMonthOnly, isTrue);
    });

    test('fees in words, k-notation, and text that is not an amount', () {
      expect(parseFee('35 euros'), (amount: '35', currency: 'EUR'));
      expect(parseFee('€ 90'), (amount: '90', currency: 'EUR'));
      expect(parseFee('7k5 euros tuition'), (amount: '7500', currency: 'EUR'));
      expect(parseFee('800'), (amount: '800', currency: null));
      expect(parseFee('RMB 800'), (amount: '800', currency: 'CNY'));
      expect(parseFee('fee waiver code is: ABC2025'), (amount: null, currency: null));
      expect(parseFee('Opens Jan 16'), (amount: null, currency: null));
    });

    test('degree from the programme title', () {
      expect(degreeFromProgramme('Master of Finance'), DegreeType.msc);
      expect(degreeFromProgramme('Master of science in financial technology'), DegreeType.msc);
      expect(degreeFromProgramme('International MBA'), DegreeType.other);
      expect(degreeFromProgramme('PhD in Chemistry'), DegreeType.phd);
      expect(degreeFromProgramme('Finance'), isNull);
    });

    test('free-text statuses, regions and cities', () {
      expect(parseStage('applied, so check'), (ApplicationStage.submitted, true));
      expect(parseStage('APPLIED'), (ApplicationStage.submitted, true));
      expect(isPlainStage('APPLIED'), isTrue);
      expect(isPlainStage('applied. Wait for responses'), isFalse);
      expect(parseCountry('Chinese'), 'CN');
      expect(parseCountry('American'), 'US');
      expect(parseCountry('Beijing'), 'CN');
      expect(parseCountry('Europe'), isNull);
    });

    test('requirement lists become checklist items', () {
      final r = parseRequirements(
        'Bsc, int passport, official academic transcript, cv, personal stat/study plan, two recomm, english prof, degree auth',
      );
      expect(r.map((e) => e.title), [
        'BSc certificate',
        'International passport',
        'Official academic transcript',
        'CV',
        'Personal statement/study plan',
        'Two recommendation letters',
        'English proficiency',
        'Degree authentication',
      ]);
      expect(r.map((e) => e.kind), [
        'certificate',
        'other',
        'transcript',
        'cv',
        'research_statement',
        'other',
        'english_test',
        'certificate',
      ]);
      expect(r.where((e) => e.external).map((e) => e.kind), ['transcript', 'english_test', 'certificate']);
    });

    test('reads yes/no cells', () {
      for (final v in ['Yes', 'y', 'Required', 'yes, email first', '✓']) {
        expect(parseYesNo(v), isTrue, reason: v);
      }
      for (final v in ['No', 'n/a', 'Not required', 'optional']) {
        expect(parseYesNo(v), isFalse, reason: v);
      }
      expect(parseYesNo(''), isNull);
      expect(parseYesNo('maybe'), isNull);
    });

    test('imports whether a professor must accept first', () {
      const csv = 'University,Programme,Needs supervisor\n'
          'Tsinghua,Computer Science,Yes\n'
          'ETH,Data Science,No\n'
          'TUM,Informatics,\n';
      final t = CsvTable.parse(csv);
      final m = autoMap(t.headers);
      expect(m[2], ImportField.professorAcceptance);
      final r = buildImportRows(t, m, options);
      expect(r.map((e) => e.draft!.requiresProfessorAcceptance), [true, false, false]);
    });

    test('takes the country from a location only when it names one', () {
      expect(countryFromLocation('Boston, USA'), 'US');
      expect(countryFromLocation('Toronto, Canada'), 'CA');
      expect(countryFromLocation('finland'), 'FI');
      expect(countryFromLocation('Boston, MA'), isNull);
      expect(countryFromLocation('Springfield'), isNull);
      expect(countryFromLocation(''), isNull);
    });

    test('maps an application sheet and never maps passwords', () {
      final headers = [
        'S/N', 'NAME OF SCHOOL', 'PROGRAM', 'WEBSITE', 'LOCATION', 'FEES(﹩)', 'FUNDING', 'APPLICATION FEE',
        'APPLICATION OPEN', 'DEADLINE', 'NOTES', 'APPLICATION LINK', 'Username', 'PASSWORD', 'STATUS',
        'EXPECTED DATE OF DECISION',
      ];
      final m = autoMap(headers);
      expect(m[1], ImportField.university);
      expect(m[2], ImportField.programme);
      expect(m[3], ImportField.programmeUrl);
      expect(m[4], ImportField.location);
      expect(m[5], ImportField.tuition);
      expect(m[6], ImportField.fundingDeadline); // user can unmap; it's an alias
      expect(m[7], ImportField.fee);
      expect(m[8], ImportField.opensOn);
      expect(m[9], ImportField.deadline);
      expect(m[10], ImportField.notes);
      expect(m[11], ImportField.portalUrl);
      expect(m[12], ImportField.portalUsername);
      expect(m.containsKey(13), isFalse);
      expect(m[14], ImportField.stage);
      expect(m[15], ImportField.decisionExpected);
      expect(isSecretHeader('PASSWORD'), isTrue);
    });

    test('imports sheet-style rows without losing information', () {
      const csv = 'School\tProgram\tLocation\tApplication fee\tApplication open\tDeadline\tRequirements\tUsername\tStatus\n'
          'Peking university\tGlobal master in management\tBeijing\t800\tOct-26\tDec-26\tBsc, cv, two recomm\t\t\n'
          'Northeastern University\tChemical Engineering\tAmerican\tfee waiver code is: ABC2025\t\t\t\tjdoe\tApplied\n'
          'LUT\tEnergy\tfinland\t\t\t16 December 2026 - 22 January 2027\t\t\tapplied, so check\n'
          'UNB\tChemistry\tCanada\t\$75\t\tMarch 31st\t\t\t\n';
      final t = CsvTable.parse(csv);
      final r = buildImportRows(t, autoMap(t.headers), options);
      expect(r.map((e) => e.status), everyElement(RowStatus.ready));

      final pku = r[0].draft!;
      expect(pku.degree, DegreeType.msc); // "Global master in management"
      expect(r[1].draft!.degree, DegreeType.phd); // nothing in the title: default
      expect(pku.institutionCountry, 'CN'); // from the location
      expect(pku.location, 'Beijing');
      expect((pku.feeAmount, pku.feeCurrency), ('800', 'CNY'));
      expect(pku.opensOn!.label, 'Oct 2026');
      final d = pku.deadline.toDeadline()!;
      expect(d.isMonthOnly, isTrue);
      expect(d.zone, 'Asia/Shanghai');
      expect(d.zoneLabel, 'Dec 2026 · date not confirmed');
      expect(pku.requirements, hasLength(3));

      final neu = r[1].draft!;
      expect(neu.institutionCountry, 'US');
      expect(neu.feeAmount, isNull);
      expect(neu.feeWaiver, FeeWaiver.eligible);
      expect(neu.notes, contains('fee waiver code is: ABC2025'));
      expect(neu.portalUsername, 'jdoe');
      expect(neu.stage, ApplicationStage.submitted);

      final lut = r[2].draft!;
      expect(lut.deadline.date, DateTime(2027, 1, 22));
      expect(lut.opensOn!.label, '16 Dec 2026');
      expect(lut.stage, ApplicationStage.submitted);
      expect(lut.notes, 'Status: applied, so check');

      final unb = r[3].draft!;
      expect((unb.feeAmount, unb.feeCurrency), ('75', 'CAD')); // bare \$ in Canada
      expect(unb.deadline.isSet, isFalse);
      expect(unb.notes, 'Deadline: March 31st');
    });
  });

  group('Deadline precision', () {
    test('month-only deadlines count to the 1st, then read "this month"', () {
      final d = Deadline.month('Asia/Shanghai', 2026, 12);
      expect(d.dueLabel(now: DateTime.utc(2026, 11, 20)), 'In 11 days');
      expect(d.dueLabel(now: DateTime.utc(2026, 12, 10)), 'Due this month');
      expect(d.dueLabel(now: DateTime.utc(2027, 1, 2)), 'Month passed');
      expect(d.differsFromLocal, isFalse);
    });
  });
}
