import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Ties Google's ID token to this page load: Google embeds [hashed] in the
/// token, and Supabase checks it against [raw], so a token lifted from
/// elsewhere can't be replayed here.
class GoogleNonce {
  const GoogleNonce(this.raw);

  factory GoogleNonce.generate([Random? random]) {
    final r = random ?? Random.secure();
    return GoogleNonce(base64Url.encode(List<int>.generate(32, (_) => r.nextInt(256))));
  }

  final String raw;
  String get hashed => sha256.convert(utf8.encode(raw)).toString();
}
