import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// A deadline as published by a university: an exact instant plus the IANA
/// zone it was announced in, so "1 Dec 23:59 ET" is shown faithfully next to
/// the user's own local time.
class Deadline {
  const Deadline({required this.instant, required this.zone});

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
    final local = tz.TZDateTime(tz.getLocation(zone), year, month, day, hour, minute);
    return Deadline(instant: local.toUtc(), zone: zone);
  }

  /// UTC instant.
  final DateTime instant;

  /// IANA zone name, e.g. `America/Toronto`.
  final String zone;

  tz.TZDateTime get inZone => tz.TZDateTime.from(instant, tz.getLocation(zone));

  /// "1 Dec, 23:59 EST"
  String get zoneLabel {
    final t = inZone;
    return '${DateFormat('d MMM, HH:mm').format(t)} ${t.timeZoneName}';
  }

  /// "2 Dec, 05:59" in the viewer's local time.
  String get localLabel => DateFormat('d MMM, HH:mm').format(instant.toLocal());

  /// True when the viewer's zone shows a different wall-clock time.
  bool get differsFromLocal =>
      inZone.timeZoneOffset != instant.toLocal().timeZoneOffset;
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
