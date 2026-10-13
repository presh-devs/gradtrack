import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/core/time/deadline.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('Deadline', () {
    test('wall clock in the university zone maps to the right instant', () {
      // 1 Dec 2026 23:59 in Toronto (EST, UTC-5) = 2 Dec 04:59 UTC.
      final d = Deadline.wallClock('America/Toronto', 2026, 12, 1);
      expect(d.instant, DateTime.utc(2026, 12, 2, 4, 59));
      expect(d.zoneLabel, '1 Dec, 23:59 EST');
    });

    test('respects daylight saving in the source zone', () {
      // 15 Oct 2026 is still EDT (UTC-4).
      final d = Deadline.wallClock('America/Toronto', 2026, 10, 15, hour: 12, minute: 0);
      expect(d.instant, DateTime.utc(2026, 10, 15, 16));
    });
  });

  group('DueText', () {
    final now = DateTime(2026, 10, 13, 9);

    test('relative wording', () {
      expect(DueText.relative(now.subtract(const Duration(days: 2)), now: now), 'Overdue by 2 days');
      expect(DueText.relative(now.subtract(const Duration(hours: 3)), now: now), 'Overdue by 3 hours');
      expect(DueText.relative(now.add(const Duration(hours: 5)), now: now), 'Due in 5 h');
      expect(DueText.relative(now.add(const Duration(hours: 30)), now: now), 'Due tomorrow');
      expect(DueText.relative(now.add(const Duration(days: 12)), now: now), 'In 12 days');
    });

    test('buckets', () {
      expect(DueText.bucket(now.subtract(const Duration(minutes: 1)), now: now), DueBucket.overdue);
      expect(DueText.bucket(DateTime(2026, 10, 13, 22), now: now), DueBucket.today);
      expect(DueText.bucket(now.add(const Duration(days: 7)), now: now), DueBucket.thisWeek);
      expect(DueText.bucket(now.add(const Duration(days: 8)), now: now), DueBucket.later);
    });
  });
}
