import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'app/app.dart';
import 'core/env.dart';
import 'features/auth/domain/auth_redirect.dart';
import 'features/auth/presentation/auth_controllers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // /applications/123 instead of /#/applications/123
  tzdata.initializeTimeZones();
  // Read before Supabase and the router rewrite the URL.
  final authRedirect = AuthRedirect(Uri.base);

  if (Env.demoByAccident && kDebugMode) {
    debugPrint(
      '⚠️  gradll is using DEMO data: SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY were not provided.\n'
      '    Run: flutter run -d chrome --dart-define-from-file=env.json --web-port 8080\n'
      '    (or the "gradll (Supabase)" launch configuration in VS Code).',
    );
  }

  if (!Env.demo) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseKey,
    );
  }

  runApp(ProviderScope(
    overrides: [authRedirectProvider.overrideWithValue(authRedirect)],
    child: const GradllApp(),
  ));
}
