import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/offline_banner.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'router.dart';

class GradllApp extends ConsumerWidget {
  const GradllApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'gradll',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeModeSettingProvider),
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) => OfflineBanner(child: child!),
      );
}
