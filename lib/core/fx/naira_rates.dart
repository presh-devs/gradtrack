import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'naira_rates.g.dart';

/// Today's exchange rates into Nigerian naira, used to show fees and tuition
/// in naira next to the university's own currency.
///
/// Source: ExchangeRate-API's free open endpoint (no key, CORS-enabled,
/// refreshed daily). Google's rates have no public API; these are the same
/// kind of mid-market rate and normally within a fraction of a percent.
class NairaRates {
  const NairaRates({required this.nairaPerUnit, required this.updatedAt});

  /// Currency code → naira for one unit of it (e.g. 'CAD' → 947.27).
  final Map<String, double> nairaPerUnit;

  /// When the source last refreshed the rates.
  final DateTime updatedAt;

  static final endpoint = Uri.parse('https://open.er-api.com/v6/latest/USD');

  /// Parses the endpoint's JSON (rates per 1 USD) into naira per unit.
  factory NairaRates.fromJson(Map<String, dynamic> json) {
    if (json['result'] != 'success') throw const FormatException('exchange rates unavailable');
    final perUsd = (json['rates'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble()));
    final ngn = perUsd['NGN'];
    if (ngn == null || ngn <= 0) throw const FormatException('no naira rate');
    return NairaRates(
      nairaPerUnit: {
        for (final MapEntry(:key, :value) in perUsd.entries)
          if (value > 0) key: ngn / value,
      },
      updatedAt: DateTime.fromMillisecondsSinceEpoch((json['time_last_update_unix'] as num).toInt() * 1000, isUtc: true),
    );
  }

  /// [amount] in [currency] converted to naira; null if the currency is unknown.
  double? toNaira(double amount, String? currency) {
    final rate = nairaPerUnit[currency?.trim().toUpperCase()];
    return rate == null ? null : amount * rate;
  }

  static Future<NairaRates> fetch([http.Client? client]) async {
    final c = client ?? http.Client();
    try {
      final res = await c.get(endpoint).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw http.ClientException('exchange rates: HTTP ${res.statusCode}', endpoint);
      return NairaRates.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } finally {
      if (client == null) c.close();
    }
  }
}

/// Fetched once per app session. On failure the UI just leaves naira out.
@Riverpod(keepAlive: true)
Future<NairaRates> nairaRates(Ref ref) => NairaRates.fetch();
