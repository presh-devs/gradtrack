import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/icons.dart';
import '../../../core/env.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/gt_widgets.dart';
import '../../auth/presentation/auth_controllers.dart';

part 'settings_screen.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeSetting extends _$ThemeModeSetting {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = MediaQuery.sizeOf(context).width < GtBreakpoints.medium ? GtSpace.lg : GtSpace.xxl;
    final mode = ref.watch(themeModeSettingProvider);
    final t = Theme.of(context).textTheme;
    final gt = context.gt;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: pad),
      children: [
        PageBody(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: 'Settings'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(GtSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appearance', style: t.titleMedium),
                      const SizedBox(height: GtSpace.md),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: GtIcon(GtIcons.themeSystem)),
                          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: GtIcon(GtIcons.themeLight)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: GtIcon(GtIcons.themeDark)),
                        ],
                        selected: {mode},
                        onSelectionChanged: (s) => ref.read(themeModeSettingProvider.notifier).set(s.first),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GtSpace.lg),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: GtSpace.xs),
                  leading: IconWell(icon: GtIcons.digest, tone: gt.info, size: 40),
                  title: Text('Daily digest', style: t.titleSmall),
                  subtitle: const Text('Timezone, send hour and test email arrive in week 3.'),
                ),
              ),
              const SizedBox(height: GtSpace.lg),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: GtSpace.xs),
                  leading: IconWell(icon: GtIcons.signOut, tone: gt.danger, size: 40),
                  title: Text('Sign out', style: t.titleSmall),
                  subtitle: Text(Env.demo ? 'Demo mode · sample data' : 'Connected to Supabase'),
                  onTap: () => ref.read(authStatusProvider.notifier).signOut(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
