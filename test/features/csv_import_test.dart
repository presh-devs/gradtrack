import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/features/applications/domain/application.dart';
import 'package:gradtrack/features/applications/domain/institution.dart';
import 'package:gradtrack/features/import/domain/csv_import.dart';
import 'package:gradtrack/features/import/domain/value_parsers.dart';
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
        RowStatus.invalid, // bad date
        RowStatus.duplicate, // already in GradTrack
        RowStatus.ready,
        RowStatus.duplicate, // same as the row above
        RowStatus.ready,
      ]);
      expect(r.map((e) => e.line), [2, 3, 4, 5, 6, 7]);
      expect(r.last.warnings, hasLength(3)); // degree, stage, fee without currency
      expect(r.last.draft!.feeAmount, isNull);
    });
  });
}
