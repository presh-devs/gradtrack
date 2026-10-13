import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'router.dart';

class GradTrackApp extends ConsumerWidget {
  const GradTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'GradTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeModeSettingProvider),
        routerConfig: ref.watch(routerProvider),
      );
}
