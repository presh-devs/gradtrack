import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/features/applications/domain/application.dart';
import 'package:gradll/features/applications/domain/application_draft.dart';
import 'package:gradll/features/applications/domain/institution.dart';
import 'package:gradll/features/applications/domain/programme_extraction.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

Map<String, dynamic> _page([Map<String, dynamic> overrides = const {}]) => {
      'is_programme_page': true,
      'institution_name': 'Technical University of Munich',
      'country_code': 'DE',
      'location': 'Munich, Bavaria',
      'programme_name': 'Informatics',
      'degree': 'msc',
      'department': null,
      'research_area': null,
      'deadline_date': '2027-05-31',
      'deadline_time': null,
      'deadline_timezone': null,
      'deadline_month_only': false,
      'funding_deadline_date': null,
      'funding_deadline_time': null,
      'opens_on': '2027-02-01',
      'opens_month_only': true,
      'decision_expected': null,
      'decision_month_only': false,
      'fee_amount': 0,
      'fee_currency': 'EUR',
      'fee_waiver_available': false,
      'tuition_amount': 6000,
      'tuition_currency': 'EUR',
      'portal_url': 'https://campus.tum.de/apply',
      'requires_professor_acceptance': false,
      'requirements': ['Transcript of records', 'CV', 'GRE'],
      'notes': 'Winter intake only.',
      'check_fields': <String>[],
      'source_url': 'https://www.tum.de/en/studies/informatics',
      'truncated': false,
      'cached': false,
      ...overrides,
    };

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('fills a blank draft and assumes the country’s zone for the deadline', () {
    final x = ProgrammeExtraction.fromJson(_page());
    final d = x.applyTo(const ApplicationDraft(deadline: DeadlineInput(zone: 'Africa/Lagos')));

    expect((d.institutionId, d.institutionName, d.institutionCountry), (null, 'Technical University of Munich', 'DE'));
    expect((d.programmeName, d.degree, d.location), ('Informatics', DegreeType.msc, 'Munich, Bavaria'));
    expect(d.programmeUrl, 'https://www.tum.de/en/studies/informatics');
    expect(d.portalUrl, 'https://campus.tum.de/apply');
    expect(d.deadline.date, DateTime(2027, 5, 31));
    expect((d.deadline.hour, d.deadline.minute), (23, 59)); // no time on the page: end of day
    expect(d.deadline.zone, 'Europe/Berlin');
    expect(d.opensOn!.label, 'Feb 2027');
    expect((d.feeAmount, d.feeCurrency), ('0', 'EUR'));
    expect((d.tuitionAmount, d.tuitionCurrency), ('6000', 'EUR'));
    expect(d.requirements.map((r) => r.kind), ['transcript', 'cv', 'standardized_test']);
    expect(d.notes, 'Winter intake only.');
    expect(d.validate(), isEmpty);
    expect(x.checkFields, contains('deadline_timezone'));
  });

  test('reuses a saved university and its zone; keeps what the page lacks', () {
    final x = ProgrammeExtraction.fromJson(_page({
      'institution_name': 'technical university of munich',
      'deadline_time': '12:00',
      'portal_url': null,
      'requires_professor_acceptance': true,
    }));
    const saved = Institution(id: 'i9', name: 'Technical University of Munich', country: 'DE', defaultTz: 'Europe/Berlin');
    final d = x.applyTo(
      const ApplicationDraft(portalUrl: 'https://typed.example.edu', notes: 'My note'),
      institutions: [saved],
    );
    expect(d.institutionId, 'i9');
    expect(d.institutionName, 'Technical University of Munich');
    expect((d.deadline.hour, d.deadline.minute, d.deadline.zone), (12, 0, 'Europe/Berlin'));
    expect(d.portalUrl, 'https://typed.example.edu');
    expect(d.requiresProfessorAcceptance, isTrue);
    expect(d.notes, 'My note\nWinter intake only.');
  });

  test('a stated time zone wins and month-only deadlines stay month-only', () {
    final x = ProgrammeExtraction.fromJson(_page({
      'deadline_date': '2026-12-01',
      'deadline_timezone': 'America/Toronto',
      'deadline_month_only': true,
    }));
    final d = x.applyTo(const ApplicationDraft());
    final deadline = d.deadline.toDeadline()!;
    expect(deadline.zone, 'America/Toronto');
    expect(deadline.isMonthOnly, isTrue);
    expect(x.checkFields, isNot(contains('deadline_timezone')));
  });

  test('counts what it filled', () {
    expect(ProgrammeExtraction.fromJson(_page()).filledCount, 11);
    expect(ProgrammeExtraction.fromJson(const {'programme_name': 'X'}).filledCount, 1);
  });
}
