import 'package:freezed_annotation/freezed_annotation.dart';

part 'institution.freezed.dart';

@freezed
abstract class Institution with _$Institution {
  const factory Institution({
    required String id,
    required String name,
    String? country,
    String? defaultTz,
  }) = _Institution;
}

abstract interface class InstitutionsRepository {
  Future<List<Institution>> list();
}

/// Best-guess deadline zone for a country (ISO 3166-1 alpha-2). Only a
/// suggestion to prefill the form — countries spanning several zones
/// (US, CA, AU) use their most common university-deadline zone.
const countryDefaultZones = <String, String>{
  'AT': 'Europe/Vienna',
  'AU': 'Australia/Sydney',
  'BE': 'Europe/Brussels',
  'CA': 'America/Toronto',
  'CH': 'Europe/Zurich',
  'CN': 'Asia/Shanghai',
  'DE': 'Europe/Berlin',
  'DK': 'Europe/Copenhagen',
  'ES': 'Europe/Madrid',
  'FI': 'Europe/Helsinki',
  'FR': 'Europe/Paris',
  'GB': 'Europe/London',
  'HK': 'Asia/Hong_Kong',
  'IE': 'Europe/Dublin',
  'IN': 'Asia/Kolkata',
  'IT': 'Europe/Rome',
  'JP': 'Asia/Tokyo',
  'KR': 'Asia/Seoul',
  'NG': 'Africa/Lagos',
  'NL': 'Europe/Amsterdam',
  'NO': 'Europe/Oslo',
  'NZ': 'Pacific/Auckland',
  'SA': 'Asia/Riyadh',
  'SE': 'Europe/Stockholm',
  'SG': 'Asia/Singapore',
  'US': 'America/New_York',
  'ZA': 'Africa/Johannesburg',
};
