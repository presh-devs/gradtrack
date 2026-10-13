import 'package:timezone/timezone.dart' as tz;

import '../../applications/domain/application.dart';

/// Parsers for the messy values people keep in application spreadsheets.
/// Pure Dart; each returns null (or a fallback plus a warning) instead of
/// throwing, so one odd cell never blocks a whole import.

enum DateOrder {
  dayFirst('Day first (31/12/2026)'),
  monthFirst('Month first (12/31/2026)');

  const DateOrder(this.label);
  final String label;
}

class ParsedDateTime {
  const ParsedDateTime(this.date, {this.hour, this.minute, this.zoneHint});

  /// Calendar date (time fields zero).
  final DateTime date;
  final int? hour;
  final int? minute;

  /// Zone named inside the cell, e.g. "11:59 PM EST" or "AoE".
  final String? zoneHint;

  bool get hasTime => hour != null;
}

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, //
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// Common abbreviations in published deadlines → a representative IANA zone.
/// "AoE" (anywhere on Earth, UTC−12) is common for scholarship deadlines.
const zoneAbbreviations = <String, String>{
  'aoe': 'Etc/GMT+12',
  'utc': 'UTC',
  'gmt': 'Europe/London',
  'bst': 'Europe/London',
  'cet': 'Europe/Berlin',
  'cest': 'Europe/Berlin',
  'est': 'America/New_York',
  'edt': 'America/New_York',
  'et': 'America/New_York',
  'cst': 'America/Chicago',
  'cdt': 'America/Chicago',
  'ct': 'America/Chicago',
  'mst': 'America/Denver',
  'mdt': 'America/Denver',
  'mt': 'America/Denver',
  'pst': 'America/Los_Angeles',
  'pdt': 'America/Los_Angeles',
  'pt': 'America/Los_Angeles',
  'aest': 'Australia/Sydney',
  'aedt': 'Australia/Sydney',
  'wat': 'Africa/Lagos',
  'sgt': 'Asia/Singapore',
  'jst': 'Asia/Tokyo',
  'kst': 'Asia/Seoul',
};

/// Parses dates such as `2026-12-01`, `2026-12-01 17:00`, `01/12/2026`,
/// `1 Dec 2026`, `Dec 1, 2026 11:59 PM EST`, `December 1st 2026 (AoE)`.
/// Numeric day/month order follows [order] unless one part is > 12.
ParsedDateTime? parseDateTime(String raw, {DateOrder order = DateOrder.dayFirst}) {
  var s = raw.trim().toLowerCase().replaceAll(RegExp(r'[()]'), ' ');
  if (s.isEmpty) return null;

  // Trailing zone abbreviation.
  String? zoneHint;
  final zoneMatch = RegExp(r'\b([a-z]{2,4})\s*$').firstMatch(s);
  if (zoneMatch != null && zoneAbbreviations.containsKey(zoneMatch[1])) {
    zoneHint = zoneAbbreviations[zoneMatch[1]];
    s = s.substring(0, zoneMatch.start).trim();
  }

  // Time: "23:59", "11:59 pm", "11.59pm", "5pm", "noon", "midnight"
  int? hour, minute;
  final timeMatch = RegExp(r'(?:\s|t|,|^)(\d{1,2})(?:[:.](\d{2}))?\s*(am|pm)?\s*$').firstMatch(s);
  final hasClock = timeMatch != null && (timeMatch[2] != null || timeMatch[3] != null);
  if (hasClock) {
    var h = int.parse(timeMatch[1]!);
    final m = int.parse(timeMatch[2] ?? '0');
    final ampm = timeMatch[3];
    if (ampm == 'pm' && h < 12) h += 12;
    if (ampm == 'am' && h == 12) h = 0;
    if (h > 23 || m > 59) return null;
    hour = h;
    minute = m;
    s = s.substring(0, timeMatch.start).trim();
  } else if (s.endsWith('midnight')) {
    (hour, minute) = (23, 59); // "midnight on 1 Dec" in admissions means the end of that day
    s = s.substring(0, s.length - 'midnight'.length).trim();
  } else if (s.endsWith('noon')) {
    (hour, minute) = (12, 0);
    s = s.substring(0, s.length - 'noon'.length).trim();
  }
  s = s.replaceAll(RegExp(r'[,\s]+(at)?$'), '').trim();

  DateTime? build(int y, int m, int d) {
    if (y < 100) y += 2000;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final dt = DateTime(y, m, d);
    return dt.month == m && dt.day == d ? dt : null; // rejects 31 Feb
  }

  DateTime? date;
  // ISO: 2026-12-01
  final iso = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$').firstMatch(s);
  // Numeric: 01/12/2026, 12-01-26
  final numeric = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2}|\d{4})$').firstMatch(s);
  // Text month, either order: "1 dec 2026", "dec 1 2026", "1st december, 2026"
  final dayMonth = RegExp(r'^(\d{1,2})(?:st|nd|rd|th)?\s+([a-z]{3})[a-z]*\.?,?\s+(\d{4})$').firstMatch(s);
  final monthDay = RegExp(r'^([a-z]{3})[a-z]*\.?\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{4})$').firstMatch(s);

  if (iso != null) {
    date = build(int.parse(iso[1]!), int.parse(iso[2]!), int.parse(iso[3]!));
  } else if (numeric != null) {
    final a = int.parse(numeric[1]!), b = int.parse(numeric[2]!), y = int.parse(numeric[3]!);
    final dayFirst = a > 12 ? true : (b > 12 ? false : order == DateOrder.dayFirst);
    date = dayFirst ? build(y, b, a) : build(y, a, b);
  } else if (dayMonth != null && _months.containsKey(dayMonth[2])) {
    date = build(int.parse(dayMonth[3]!), _months[dayMonth[2]]!, int.parse(dayMonth[1]!));
  } else if (monthDay != null && _months.containsKey(monthDay[1])) {
    date = build(int.parse(monthDay[3]!), _months[monthDay[1]]!, int.parse(monthDay[2]!));
  }
  if (date == null) return null;
  return ParsedDateTime(date, hour: hour, minute: minute, zoneHint: zoneHint);
}

/// True when [raw] uses an all-numeric date whose day/month order can't be
/// inferred (both parts ≤ 12), so the wizard's order setting decides.
bool isAmbiguousNumericDate(String raw) {
  final m = RegExp(r'^\s*(\d{1,2})[-/.](\d{1,2})[-/.]').firstMatch(raw);
  if (m == null) return false;
  final a = int.parse(m[1]!), b = int.parse(m[2]!);
  return a <= 12 && b <= 12 && a != b;
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// (value, recognised). Unrecognised non-empty values fall back to `other`.
(DegreeType, bool) parseDegree(String raw) {
  final n = _norm(raw);
  if (raw.trim().isEmpty) return (DegreeType.phd, true);
  if (n.contains('phd') || n.contains('dphil') || n.contains('doctor')) return (DegreeType.phd, true);
  if (n.contains('mphil')) return (DegreeType.mphil, true);
  if (n.contains('mres')) return (DegreeType.mres, true);
  if (const {'msc', 'ms', 'mse', 'mcs', 'masters', 'master', 'mscs', 'smaster'}.contains(n) ||
      n.startsWith('msc') ||
      n.startsWith('masterof')) {
    return (DegreeType.msc, true);
  }
  if (n == 'ma' || n.startsWith('masterofarts')) return (DegreeType.ma, true);
  return (DegreeType.other, false);
}

/// (value, recognised). Final outcomes map to `decided`.
(ApplicationStage, bool) parseStage(String raw) {
  final n = _norm(raw);
  if (raw.trim().isEmpty) return (ApplicationStage.researching, true);
  for (final s in ApplicationStage.values) {
    if (n == _norm(s.label) || n == _norm(s.db)) return (s, true);
  }
  const synonyms = {
    'research': ApplicationStage.researching,
    'considering': ApplicationStage.researching,
    'idea': ApplicationStage.researching,
    'shortlist': ApplicationStage.shortlisted,
    'planned': ApplicationStage.shortlisted,
    'planning': ApplicationStage.shortlisted,
    'inprogress': ApplicationStage.preparing,
    'drafting': ApplicationStage.preparing,
    'started': ApplicationStage.preparing,
    'awaitingdocuments': ApplicationStage.preparing,
    'readytosubmit': ApplicationStage.ready,
    'applied': ApplicationStage.submitted,
    'sent': ApplicationStage.submitted,
    'done': ApplicationStage.submitted,
    'pending': ApplicationStage.underReview,
    'inreview': ApplicationStage.underReview,
    'review': ApplicationStage.underReview,
    'interviewing': ApplicationStage.interview,
    'interviewed': ApplicationStage.interview,
    'accepted': ApplicationStage.decided,
    'admitted': ApplicationStage.decided,
    'offer': ApplicationStage.decided,
    'rejected': ApplicationStage.decided,
    'declined': ApplicationStage.decided,
    'waitlisted': ApplicationStage.decided,
    'withdrawn': ApplicationStage.decided,
  };
  final hit = synonyms[n];
  return hit == null ? (ApplicationStage.researching, false) : (hit, true);
}

/// (1 top · 2 normal · 3 backup, recognised).
(int, bool) parsePriority(String raw) {
  final n = _norm(raw);
  if (raw.trim().isEmpty) return (2, true);
  if (const {'1', 'top', 'high', 'dream', 'reach', 'first', 'topchoice'}.contains(n)) return (1, true);
  if (const {'2', 'normal', 'medium', 'mid', 'target'}.contains(n)) return (2, true);
  if (const {'3', 'low', 'backup', 'safety', 'safe'}.contains(n)) return (3, true);
  return (2, false);
}

/// Splits "CAD 125", "$125.00", "125 GBP", "€90" into amount + currency.
({String? amount, String? currency}) parseFee(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return (amount: null, currency: null);
  const symbols = {'£': 'GBP', '€': 'EUR', '₦': 'NGN', '¥': 'JPY', '₹': 'INR'};
  String? currency;
  for (final e in symbols.entries) {
    if (s.contains(e.key)) currency = e.value;
  }
  final code = RegExp(r'\b([A-Za-z]{3})\b').firstMatch(s);
  if (code != null) currency = code[1]!.toUpperCase();
  final number = RegExp(r'\d[\d,]*(?:\.\d+)?').firstMatch(s);
  return (amount: number?[0], currency: currency);
}

const _countryNames = <String, String>{
  'australia': 'AU', 'austria': 'AT', 'belgium': 'BE', 'canada': 'CA', 'china': 'CN',
  'denmark': 'DK', 'finland': 'FI', 'france': 'FR', 'germany': 'DE', 'hongkong': 'HK',
  'india': 'IN', 'ireland': 'IE', 'italy': 'IT', 'japan': 'JP', 'southkorea': 'KR',
  'korea': 'KR', 'netherlands': 'NL', 'thenetherlands': 'NL', 'newzealand': 'NZ',
  'nigeria': 'NG', 'norway': 'NO', 'saudiarabia': 'SA', 'singapore': 'SG',
  'southafrica': 'ZA', 'spain': 'ES', 'sweden': 'SE', 'switzerland': 'CH',
  'uk': 'GB', 'unitedkingdom': 'GB', 'england': 'GB', 'scotland': 'GB', 'wales': 'GB',
  'greatbritain': 'GB', 'us': 'US', 'usa': 'US', 'unitedstates': 'US',
  'unitedstatesofamerica': 'US', 'america': 'US',
};

/// ISO alpha-2 code from a code or a common country name; null if unknown.
String? parseCountry(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  if (RegExp(r'^[A-Za-z]{2}$').hasMatch(s)) {
    final upper = s.toUpperCase();
    return upper == 'UK' ? 'GB' : upper;
  }
  return _countryNames[_norm(s)];
}

/// IANA zone from an exact name ("America/Toronto"), an abbreviation ("EST",
/// "AoE") or a unique city ("Toronto"); null if not resolvable.
String? parseZone(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final db = tz.timeZoneDatabase.locations;
  if (db.containsKey(s)) return s;
  final abbr = zoneAbbreviations[s.toLowerCase()];
  if (abbr != null) return abbr;
  final city = '/${s.replaceAll(' ', '_').toLowerCase()}';
  final matches = db.keys.where((z) => z.toLowerCase().endsWith(city)).toList();
  return matches.length == 1 ? matches.single : null;
}

/// Adds https:// to bare domains ("apply.utoronto.ca/grad").
String? normaliseUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  if (RegExp(r'^https?://', caseSensitive: false).hasMatch(s)) return s;
  if (RegExp(r'^[\w-]+(\.[\w-]+)+(/.*)?$').hasMatch(s)) return 'https://$s';
  return s; // left as-is; validation reports it
}
