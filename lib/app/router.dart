import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/applications/presentation/application_detail_screen.dart';
import '../features/applications/presentation/applications_screen.dart';
import '../features/applications/presentation/form/application_form_screen.dart';
import '../features/attention/presentation/today_screen.dart';
import '../features/auth/presentation/auth_controllers.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/people/presentation/people_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import 'shell.dart';

part 'router.g.dart';

/// URL map (spec 04). Every screen has a real path so browser back/forward,
/// refresh and shared links all work.
abstract final class Routes {
  static const signIn = '/sign-in';
  static const today = '/';
  static const applications = '/applications';
  static const newApplication = '/applications/new';
  static String application(String id) => '/applications/$id';
  static String editApplication(String id) => '/applications/$id/edit';
  static const people = '/people';
  static const tasks = '/tasks';
  static const settings = '/settings';
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Bridge Riverpod → Listenable so go_router re-runs redirect on auth changes
  // without rebuilding the router (which would reset navigation state).
  final signedIn = ValueNotifier<bool>(ref.read(authStatusProvider));
  ref.listen(authStatusProvider, (_, next) => signedIn.value = next);
  ref.onDispose(signedIn.dispose);

  return GoRouter(
    initialLocation: Routes.today,
    refreshListenable: signedIn,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final atSignIn = state.matchedLocation == Routes.signIn;
      if (!signedIn.value) {
        if (atSignIn) return null;
        final from = state.uri.toString();
        return from == Routes.today ? Routes.signIn : '${Routes.signIn}?from=${Uri.encodeComponent(from)}';
      }
      if (atSignIn) return state.uri.queryParameters['from'] ?? Routes.today;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signIn,
        pageBuilder: (context, state) => const NoTransitionPage(child: SignInScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.today,
              pageBuilder: (context, state) => const NoTransitionPage(child: TodayScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.applications,
              pageBuilder: (context, state) => const NoTransitionPage(child: ApplicationsScreen()),
              routes: [
                // Listed before ':id' so "new" isn't read as an id.
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const ApplicationFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      ApplicationDetailScreen(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) =>
                          ApplicationFormScreen(id: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.people,
              pageBuilder: (context, state) => const NoTransitionPage(child: PeopleScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.tasks,
              pageBuilder: (context, state) => const NoTransitionPage(child: TasksScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.settings,
              pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
            ),
          ]),
        ],
      ),
    ],
  );
}
