import 'package:flutter/widgets.dart';

const bool googleIdentitySupported = false;

Future<void> initGoogleIdentity({
  required String clientId,
  required String hashedNonce,
  required void Function(String idToken) onIdToken,
  required void Function(Object error) onError,
}) async =>
    throw UnsupportedError('Google sign-in button is web-only');

Widget googleButton({required double width}) => const SizedBox.shrink();
