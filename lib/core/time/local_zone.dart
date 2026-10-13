import 'local_zone_stub.dart' if (dart.library.js_interop) 'local_zone_web.dart' as impl;

/// The viewer's IANA time zone (e.g. `Africa/Lagos`), or null if unknown.
String? localZoneName() => impl.localZoneName();
