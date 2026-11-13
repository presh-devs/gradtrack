import 'package:timezone/timezone.dart' as tz;

import '../../applications/domain/application.dart';
import '../../applications/domain/application_draft.dart';
import '../../checklist/domain/requirement.dart';

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

/// Parses month-only dates: `Dec-26` (a spreadsheet's mmm-yy), `Dec 2026`,
/// `December, 2026`, `2026-12`, `12/2026`. Returns the 1st of that month.
DateTime? parseMonthYear(String raw) {
  final s = raw.trim().toLowerCase().replaceAll(RegExp(r'[()]'), ' ').trim();
  final named = RegExp(r"^([a-z]{3})[a-z]*\.?[\s\-/,']+(\d{2}|\d{4})$").firstMatch(s);
  final isoMonth = RegExp(r'^(\d{4})[-/.](\d{1,2})$').firstMatch(s);
  final numMonth = RegExp(r'^(\d{1,2})[-/.](\d{4})$').firstMatch(s);
  int? y, m;
  if (named != null && _months.containsKey(named[1])) {
    (y, m) = (int.parse(named[2]!), _months[named[1]]!);
  } else if (isoMonth != null) {
    (y, m) = (int.parse(isoMonth[1]!), int.parse(isoMonth[2]!));
  } else if (numMonth != null) {
    (y, m) = (int.parse(numMonth[2]!), int.parse(numMonth[1]!));
  }
  if (y == null || m == null || m < 1 || m > 12) return null;
  return DateTime(y < 100 ? y + 2000 : y, m);
}

/// A date cell read as an exact date/time or a month, optionally the end of
/// a range ("16 Dec 2026 - 22 Jan 2027"), in which case [rangeStart] is set.
class ParsedWhen {
  const ParsedWhen({this.exact, this.month, this.rangeStart});

  final ParsedDateTime? exact;

  /// 1st of the month when only the month is known.
  final DateTime? month;

  final ParsedWhen? rangeStart;

  bool get isMonthOnly => exact == null;
  DateTime get date => exact?.date ?? month!;
}

/// Exact date, month-only date, or a range of either (the range's end is
/// returned, with its start in [ParsedWhen.rangeStart]).
ParsedWhen? parseWhen(String raw, {DateOrder order = DateOrder.dayFirst}) {
  final parts = raw.trim().split(RegExp(r'\s+(?:-|–|—|to|until)\s+', caseSensitive: false));
  if (parts.length == 2) {
    final start = _parseSingleWhen(parts[0], order);
    final end = _parseSingleWhen(parts[1], order);
    if (start != null && end != null) {
      return ParsedWhen(exact: end.exact, month: end.month, rangeStart: start);
    }
  }
  return _parseSingleWhen(raw, order);
}

ParsedWhen? _parseSingleWhen(String raw, DateOrder order) {
  final exact = parseDateTime(raw, order: order);
  if (exact != null) return ParsedWhen(exact: exact);
  final month = parseMonthYear(raw);
  return month == null ? null : ParsedWhen(month: month);
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

/// Degree named inside a programme title, when there's no degree column:
/// "Master of Finance" → MSc, "PhD in Chemistry" → PhD, "International MBA" →
/// Other. Null when the title doesn't say.
DegreeType? degreeFromProgramme(String programme) {
  final p = programme.toLowerCase();
  bool has(String pattern) => RegExp(pattern).hasMatch(p);
  if (has(r'\b(ph\.?d|dphil|doctor)')) return DegreeType.phd;
  if (has(r'\bmphil\b')) return DegreeType.mphil;
  if (has(r'\bmres\b')) return DegreeType.mres;
  if (has(r'\b(mba|emba|mpa|mpp|llm|meng|m\.eng)\b')) return DegreeType.other;
  if (has(r'\b(m\.?a\.?|master of arts)\b')) return DegreeType.ma;
  if (has(r'\b(master|masters|msc|m\.sc|ms)\b')) return DegreeType.msc;
  return null;
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
  if (hit != null) return (hit, true);
  // Free-text statuses like "applied, so check" or "Applied. Wait for responses":
  // use the first word when it is a known stage.
  final first = raw.toLowerCase().split(RegExp('[^a-z]+')).firstWhere((w) => w.isNotEmpty, orElse: () => '');
  for (final st in ApplicationStage.values) {
    if (first == _norm(st.label) || first == _norm(st.db)) return (st, true);
  }
  final firstHit = synonyms[first];
  return firstHit == null ? (ApplicationStage.researching, false) : (firstHit, true);
}

/// True when [raw] is exactly a stage name or synonym, so nothing is lost by
/// storing only the stage. Longer statuses are also kept in notes.
bool isPlainStage(String raw) {
  if (raw.trim().isEmpty) return true;
  final words = raw.trim().split(RegExp(r'\s+'));
  return words.length <= 3 && !raw.contains(RegExp(r'[.,;:!]')) && parseStage(raw).$2;
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

const _currencyCodes = {
  'AUD', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP', 'GHS', 'HKD', 'HUF', 'INR', 'JPY',
  'KES', 'KRW', 'MYR', 'NGN', 'NOK', 'NZD', 'PLN', 'RMB', 'SAR', 'SEK', 'SGD', 'TRY', 'TWD', 'USD', 'ZAR',
};

const _currencyWords = {
  'euro': 'EUR', 'euros': 'EUR', 'pound': 'GBP', 'pounds': 'GBP', 'naira': 'NGN', 'yuan': 'CNY',
  'renminbi': 'CNY', 'rmb': 'CNY', 'cedi': 'GHS', 'cedis': 'GHS', 'rupees': 'INR', 'yen': 'JPY',
  'won': 'KRW', 'francs': 'CHF', 'usd': 'USD',
};

/// Words that may sit next to an amount without making it unreadable.
const _amountFillers = {
  'fee', 'fees', 'tuition', 'application', 'app', 'per', 'year', 'yr', 'annual', 'annually', 'approx',
  'about', 'only', 'total', 'a', 'pa', 'k', 'dollars', 'dollar',
};

/// Splits "CAD 125", "$125.00", "125 GBP", "€90", "35 euros", "7k5 euros" into
/// amount + currency. A bare "$" gives no currency (it may be USD, CAD, AUD…).
/// Text that isn't just an amount ("fee waiver code is: X", "Opens Jan 16")
/// gives no amount, so it isn't mistaken for one.
({String? amount, String? currency}) parseFee(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return (amount: null, currency: null);
  const symbols = {'£': 'GBP', '€': 'EUR', '₦': 'NGN', '¥': 'CNY', '₹': 'INR', '₵': 'GHS'};
  String? currency;
  for (final e in symbols.entries) {
    if (s.contains(e.key)) currency = e.value;
  }
  var leftover = false;
  for (final m in RegExp(r'[A-Za-z]+').allMatches(s.replaceAll(RegExp(r'\d+(?:\.\d+)?\s*k\d?', caseSensitive: false), ' '))) {
    final w = m[0]!;
    final upper = w.toUpperCase();
    if (w.length == 3 && _currencyCodes.contains(upper)) {
      currency = upper == 'RMB' ? 'CNY' : upper;
    } else if (_currencyWords.containsKey(w.toLowerCase())) {
      currency = _currencyWords[w.toLowerCase()];
    } else if (!_amountFillers.contains(w.toLowerCase())) {
      leftover = true;
    }
  }
  if (leftover) return (amount: null, currency: null);

  // "7k5" = 7,500 · "7.5k" = 7,500 · "12k" = 12,000
  final k = RegExp(r'(\d+(?:\.\d+)?)\s*k(\d)?\b', caseSensitive: false).firstMatch(s);
  if (k != null) {
    final value = double.parse(k[1]!) * 1000 + (k[2] == null ? 0 : int.parse(k[2]!) * 100);
    return (amount: value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value', currency: currency);
  }
  final number = RegExp(r'\d[\d,]*(?:\.\d+)?').firstMatch(s);
  return (amount: number?[0], currency: currency);
}

/// Local currency for a country (ISO alpha-2), used when a fee has none.
const countryCurrencies = <String, String>{
  'AT': 'EUR', 'AU': 'AUD', 'BE': 'EUR', 'CA': 'CAD', 'CH': 'CHF', 'CN': 'CNY', 'DE': 'EUR',
  'DK': 'DKK', 'ES': 'EUR', 'FI': 'EUR', 'FR': 'EUR', 'GB': 'GBP', 'HK': 'HKD', 'IE': 'EUR',
  'IN': 'INR', 'IT': 'EUR', 'JP': 'JPY', 'KR': 'KRW', 'NG': 'NGN', 'NL': 'EUR', 'NO': 'NOK',
  'NZ': 'NZD', 'SA': 'SAR', 'SE': 'SEK', 'SG': 'SGD', 'US': 'USD', 'ZA': 'ZAR',
};

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
  // Adjectives people use as a region column
  'american': 'US', 'canadian': 'CA', 'british': 'GB', 'chinese': 'CN', 'german': 'DE',
  'french': 'FR', 'italian': 'IT', 'dutch': 'NL', 'swedish': 'SE', 'danish': 'DK',
  'finnish': 'FI', 'belgian': 'BE', 'swiss': 'CH', 'irish': 'IE', 'australian': 'AU',
  'japanese': 'JP', 'korean': 'KR', 'singaporean': 'SG', 'nigerian': 'NG', 'macau': 'MO',
  // Cities and provinces common in grad-school sheets (a city column is often
  // the only location given)
  'beijing': 'CN', 'shanghai': 'CN', 'hangzhou': 'CN', 'nanjing': 'CN', 'chengdu': 'CN',
  'wuhan': 'CN', 'hefei': 'CN', 'tianjin': 'CN', 'xiamen': 'CN', 'fujian': 'CN',
  'guangzhou': 'CN', 'shenzhen': 'CN', 'harbin': 'CN', 'xian': 'CN', 'dalian': 'CN',
  'ningbo': 'CN', 'qingdao': 'CN', 'changsha': 'CN', 'zhenjiang': 'CN', 'suzhou': 'CN',
  'toronto': 'CA', 'montreal': 'CA', 'vancouver': 'CA', 'london': 'GB', 'edinburgh': 'GB',
  'boston': 'US', 'newyork': 'US', 'copenhagen': 'DK', 'stockholm': 'SE', 'helsinki': 'FI',
  'lappeenranta': 'FI', 'padua': 'IT', 'padova': 'IT', 'milan': 'IT', 'munich': 'DE',
  'berlin': 'DE', 'paris': 'FR', 'zurich': 'CH', 'leuven': 'BE', 'brussels': 'BE',
  'delft': 'NL', 'amsterdam': 'NL', 'aalborg': 'DK', 'lagos': 'NG',
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

/// Yes/no cell ("Yes", "y", "required", "✓", "No", "n/a"); null if unclear or empty.
bool? parseYesNo(String raw) {
  final s = raw.trim().toLowerCase().replaceAll(RegExp(r'[.!]+$'), '');
  if (s.isEmpty) return null;
  const yes = {'yes', 'y', 'true', '1', 'required', 'needed', 'must', 'mandatory', '✓', '✔', 'x'};
  const no = {'no', 'n', 'false', '0', 'not required', 'not needed', 'none', 'n/a', 'na', '-', 'optional'};
  if (yes.contains(s)) return true;
  if (no.contains(s)) return false;
  if (s.startsWith('yes')) return true;
  if (s.startsWith('no ') || s.startsWith('not ')) return false;
  return null;
}

/// Country from a free-text location: the whole cell ("Beijing", "finland")
/// or its last comma-separated part ("Boston, USA"); null if neither matches.
String? countryFromLocation(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final whole = parseCountry(s);
  if (whole != null) return whole;
  final parts = s.split(',');
  if (parts.length < 2) return null;
  final last = parts.last.trim();
  // A 2-letter tail is usually a state or province ("Boston, MA"), not a country.
  return last.length == 2 ? null : parseCountry(last);
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


/// Splits a sheet's free-text requirement list ("Bsc, int passport, official
/// academic transcript, cv, personal stat/study plan, two recomm, english
/// prof, degree auth") into checklist items with a kind and a readable title.
List<RequirementSeed> parseRequirements(String raw) {
  final items = <RequirementSeed>[];
  for (final part in raw.split(RegExp(r'[,;\n•]+|\s+and\s+'))) {
    final token = part.trim().replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'[.]+$'), '');
    if (token.isEmpty) continue;
    final (kind, external) = requirementKindFor(token);
    final title = _requirementTitle(token);
    if (items.any((i) => i.title.toLowerCase() == title.toLowerCase())) continue;
    items.add(RequirementSeed(kind, title, external: external));
  }
  return items;
}

const _requirementWords = {
  'int': 'international',
  'intl': 'international',
  'stat': 'statement',
  'recomm': 'recommendation letters',
  'recom': 'recommendation letters',
  'rec': 'recommendation',
  'recs': 'recommendation letters',
  'prof': 'proficiency',
  'auth': 'authentication',
  'cert': 'certificate',
  'bsc': 'BSc certificate',
  'msc': 'MSc certificate',
  'cv': 'CV',
  'sop': 'SOP',
  'ielts': 'IELTS',
  'toefl': 'TOEFL',
  'gre': 'GRE',
  'gmat': 'GMAT',
  'hsk': 'HSK',
};

String _requirementTitle(String token) {
  final words = token.split(' ').map((w) {
    final m = RegExp(r'^([A-Za-z.]+)(.*)$').firstMatch(w);
    if (m == null) return w;
    final key = m[1]!.toLowerCase().replaceAll('.', '');
    final rest = m[2]!;
    final rep = _requirementWords[key];
    return rep == null ? w : '$rep$rest';
  }).join(' ');
  return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
}

/// Column headers that hold secrets gradll never imports.
bool isSecretHeader(String header) =>
    RegExp(r'pass\s*word|passcode|\bpwd\b|\bpin\b', caseSensitive: false).hasMatch(header);
