import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/core/time/deadline.dart';
import 'package:gradtrack/features/applications/domain/application.dart';
import 'package:gradtrack/features/applications/domain/application_draft.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  const valid = ApplicationDraft(institutionName: 'University of Toronto', programmeName: 'Computer Science');

  group('validate', () {
    test('only university and programme are required', () {
      expect(valid.validate(), isEmpty);
      expect(const ApplicationDraft().validate().keys,
          containsAll([DraftField.institution, DraftField.programmeName]));
    });

    test('a deadline date needs a time zone', () {
      final d = valid.copyWith(deadline: DeadlineInput(date: DateTime(2026, 12, 1)));
      expect(d.validate().keys, contains(DraftField.deadline));
    });

    test('links must be absolute http(s) URLs', () {
      expect(valid.copyWith(portalUrl: 'apply.utoronto.ca').validate().keys, contains(DraftField.portalUrl));
      expect(valid.copyWith(portalUrl: 'https://apply.utoronto.ca').validate(), isEmpty);
      expect(valid.copyWith(portalUrl: '   ').validate(), isEmpty);
    });

    test('a fee needs a valid amount and a 3-letter currency', () {
      expect(valid.copyWith(feeAmount: '125').validate().keys, contains(DraftField.feeCurrency));
      expect(valid.copyWith(feeAmount: 'abc', feeCurrency: 'CAD').validate().keys, contains(DraftField.fee));
      final ok = valid.copyWith(feeAmount: '1,125.50', feeCurrency: 'cad');
      expect(ok.validate(), isEmpty);
      expect(ok.parsedFee, 1125.5);
    });
  });

  group('DeadlineInput', () {
    test('defaults to 23:59 and converts in the chosen zone', () {
      final input = DeadlineInput(date: DateTime(2026, 12, 1), zone: 'America/Toronto');
      expect(input.toDeadline()!.instant, DateTime.utc(2026, 12, 2, 4, 59));
    });

    test('round-trips an existing deadline through the form', () {
      final original = Deadline.wallClock('Europe/London', 2027, 1, 15, hour: 12, minute: 0);
      final input = DeadlineInput.fromDeadline(original);
      expect((input.date, input.hour, input.minute, input.zone), (DateTime(2027, 1, 15), 12, 0, 'Europe/London'));
      expect(input.toDeadline()!.instant, original.instant);
    });
  });

  test('fromApplication keeps fields and formats the fee', () {
    final app = Application(
      id: 'a1',
      institutionId: 'i1',
      institutionName: 'ETH Zürich',
      programmeName: 'Data Science',
      degree: DegreeType.msc,
      stage: ApplicationStage.ready,
      feeAmount: 150,
      feeCurrency: 'CHF',
      deadline: Deadline.wallClock('Europe/Zurich', 2026, 12, 15),
    );
    final d = ApplicationDraft.fromApplication(app);
    expect(d.institutionId, 'i1');
    expect(d.createsInstitution, isFalse);
    expect(d.feeAmount, '150');
    expect(d.fundingDeadline.zone, 'Europe/Zurich'); // falls back to the main deadline's zone
    expect(d.validate(), isEmpty);
  });

  test('unset deadlines take the fallback zone when editing', () {
    const app = Application(
      id: 'a2',
      institutionId: 'i9',
      institutionName: 'McGill University',
      programmeName: 'Computer Science',
      degree: DegreeType.phd,
      stage: ApplicationStage.researching,
    );
    final d = ApplicationDraft.fromApplication(app, fallbackZone: 'America/Toronto');
    expect(d.deadline.zone, 'America/Toronto');
    expect(d.fundingDeadline.zone, 'America/Toronto');
    expect(d.deadline.isSet, isFalse);
  });
}
