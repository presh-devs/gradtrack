import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Looks up an IANA zone, falling back to UTC for names the bundled database
/// doesn't know (e.g. stored by a newer client), so display never throws.
tz.Location zoneLocation(String zone) =>
    tz.timeZoneDatabase.locations[zone] ?? tz.UTC;

/// Abbreviations clearer than the database's for some zones.
const _zoneLabels = {'Etc/GMT+12': 'AoE'};

/// How much of a deadline is known. Spreadsheets often only say "Dec-26".
enum DeadlinePrecision {
  exact('exact'),

  /// Only the month is known. Stored as the 1st of the month, 23:59 in the
  /// zone, so reminders fire early rather than late.
  month('month');

  const DeadlinePrecision(this.db);
  final String db;

  static DeadlinePrecision fromDb(String? value) => value == 'month' ? month : exact;
}

/// A deadline as published by a university: an exact instant plus the IANA
/// zone it was announced in, so "1 Dec 23:59 ET" is shown faithfully next to
/// the user's own local time.
class Deadline {
  const Deadline({required this.instant, required this.zone, this.precision = DeadlinePrecision.exact});

  /// A deadline known only to the month (see [DeadlinePrecision.month]).
  factory Deadline.month(String zone, int year, int month) {
    final d = Deadline.wallClock(zone, year, month, 1);
    return Deadline(instant: d.instant, zone: zone, precision: DeadlinePrecision.month);
  }

  /// Builds a deadline from wall-clock fields in [zone]
  /// (e.g. 1 Dec 2026 23:59 in America/Toronto).
  factory Deadline.wallClock(
    String zone,
    int year,
    int month,
    int day, {
    int hour = 23,
    int minute = 59,
  }) {
    final local = tz.TZDateTime(zoneLocation(zone), year, month, day, hour, minute);
    return Deadline(instant: local.toUtc(), zone: zone);
  }

  /// UTC instant.
  final DateTime instant;

  /// IANA zone name, e.g. `America/Toronto`.
  final String zone;

  final DeadlinePrecision precision;

  bool get isMonthOnly => precision == DeadlinePrecision.month;

  tz.TZDateTime get inZone => tz.TZDateTime.from(instant, zoneLocation(zone));

  /// "1 Dec, 23:59 EST", or "Dec 2026 · date not confirmed" when only the
  /// month is known.
  String get zoneLabel {
    final t = inZone;
    if (isMonthOnly) return '${DateFormat('MMM yyyy').format(t)} · date not confirmed';
    return '${DateFormat('d MMM, HH:mm').format(t)} ${_zoneLabels[zone] ?? t.timeZoneName}';
  }

  /// "2 Dec, 05:59" in the viewer's local time.
  String get localLabel => DateFormat('d MMM, HH:mm').format(instant.toLocal());

  /// True when the viewer's zone shows a different wall-clock time.
  bool get differsFromLocal =>
      !isMonthOnly && inZone.timeZoneOffset != instant.toLocal().timeZoneOffset;

  /// Relative wording for chips. A month-only deadline counts down to the 1st
  /// (the earliest it could be), then reads "Due this month" during that
  /// month rather than "Overdue".
  String dueLabel({DateTime? now}) {
    final n = now ?? DateTime.now();
    if (isMonthOnly && !n.isBefore(instant)) {
      final start = inZone;
      final end = tz.TZDateTime(start.location, start.year, start.month + 1);
      return n.isBefore(end) ? 'Due this month' : 'Month passed';
    }
    return DueText.relative(instant, now: n);
  }
}

enum DatePrecision {
  day('day'),
  month('month');

  const DatePrecision(this.db);
  final String db;

  static DatePrecision? fromDb(String? value) => switch (value) {
        'day' => day,
        'month' => month,
        _ => null,
      };
}

/// A calendar date that may only be known to the month ("Opens Oct 2026").
/// Used for when applications open and when a decision is expected.
class ApproxDate {
  ApproxDate(DateTime date, this.precision)
      : date = DateTime(date.year, date.month, precision == DatePrecision.month ? 1 : date.day);

  final DateTime date;
  final DatePrecision precision;

  bool get isMonthOnly => precision == DatePrecision.month;

  /// "16 Jan 2027" or "Jan 2027".
  String get label => DateFormat(isMonthOnly ? 'MMM yyyy' : 'd MMM yyyy').format(date);

  /// `yyyy-MM-dd` for a Postgres `date` column.
  String get dbDate =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static ApproxDate? fromDb(Object? date, Object? precision) {
    final p = DatePrecision.fromDb(precision as String?);
    if (date == null || p == null) return null;
    return ApproxDate(DateTime.parse(date as String), p);
  }

  @override
  bool operator ==(Object other) =>
      other is ApproxDate && other.date == date && other.precision == precision;

  @override
  int get hashCode => Object.hash(date, precision);
}

enum DueBucket { overdue, today, thisWeek, later }

/// Relative wording and bucketing for anything with a due instant.
abstract final class DueText {
  static DueBucket bucket(DateTime due, {DateTime? now}) {
    final n = now ?? DateTime.now();
    if (due.isBefore(n)) return DueBucket.overdue;
    final localDue = due.toLocal();
    final startOfToday = DateTime(n.year, n.month, n.day);
    final days = DateTime(localDue.year, localDue.month, localDue.day)
        .difference(startOfToday)
        .inDays;
    if (days <= 0) return DueBucket.today;
    if (days <= 7) return DueBucket.thisWeek;
    return DueBucket.later;
  }

  /// "Overdue by 2 days" · "Due in 5 h" · "Due tomorrow" · "In 12 days"
  static String relative(DateTime due, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = due.difference(n);
    if (diff.isNegative) {
      final d = diff.abs();
      if (d.inHours < 24) return 'Overdue by ${_plural(d.inHours.clamp(1, 23), 'hour')}';
      return 'Overdue by ${_plural(d.inDays, 'day')}';
    }
    if (diff.inHours < 24) {
      if (diff.inHours < 1) return 'Due in ${diff.inMinutes.clamp(1, 59)} min';
      return 'Due in ${diff.inHours} h';
    }
    // Count calendar days (local), matching how [bucket] groups items.
    final localDue = due.toLocal();
    final days = DateTime(localDue.year, localDue.month, localDue.day)
        .difference(DateTime(n.year, n.month, n.day))
        .inDays;
    if (days <= 1) return 'Due tomorrow';
    return 'In $days days';
  }

  static String _plural(int n, String unit) => '$n $unit${n == 1 ? '' : 's'}';
}
