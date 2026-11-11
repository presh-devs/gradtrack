import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

const bool googleIdentitySupported = true;

/// Sets up Google's button. Google signs the person in on gradll's own page
/// (so its prompt names gradll's address, not the backend's) and hands back
/// an ID token, which [onIdToken] exchanges for a Supabase session.
Future<void> initGoogleIdentity({
  required String clientId,
  required String hashedNonce,
  required void Function(String idToken) onIdToken,
  required void Function(Object error) onError,
}) async {
  final gsi = GoogleSignIn.instance;
  await gsi.initialize(clientId: clientId, nonce: hashedNonce);
  gsi.authenticationEvents.listen(
    (event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final token = event.user.authentication.idToken;
        if (token != null) onIdToken(token);
      }
    },
    onError: (Object e) {
      // Closing Google's window isn't an error worth showing.
      if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) return;
      onError(e);
    },
  );
}

Widget googleButton({required double width}) => web.renderButton(
      configuration: web.GSIButtonConfiguration(
        type: web.GSIButtonType.standard,
        theme: web.GSIButtonTheme.outline,
        size: web.GSIButtonSize.large,
        text: web.GSIButtonText.continueWith,
        shape: web.GSIButtonShape.rectangular,
        logoAlignment: web.GSIButtonLogoAlignment.center,
        minimumWidth: width,
      ),
    );
