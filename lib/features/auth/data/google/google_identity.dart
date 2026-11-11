// Google Identity Services (Google's own sign-in button). Web only; other
// platforms get a stub so tests and non-web builds still compile.
export 'google_identity_stub.dart' if (dart.library.js_interop) 'google_identity_web.dart';
