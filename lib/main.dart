import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'app/app.dart';
import 'core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // /applications/123 instead of /#/applications/123
  tzdata.initializeTimeZones();

  if (Env.demoByAccident && kDebugMode) {
    debugPrint(
      '⚠️  GradTrack is using DEMO data: SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY were not provided.\n'
      '    Run: flutter run -d chrome --dart-define-from-file=env.json --web-port 8080\n'
      '    (or the "GradTrack (Supabase)" launch configuration in VS Code).',
    );
  }

  if (!Env.demo) {
    await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseKey);
  }

  runApp(const ProviderScope(child: GradTrackApp()));
}
