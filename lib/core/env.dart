/// Build-time configuration, passed with --dart-define (or --dart-define-from-file).
///
///   flutter run -d chrome \
///     --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
///
/// Without SUPABASE_URL the app runs in demo mode against in-memory data,
/// which keeps UI work unblocked before the backend exists.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const _forceDemo = bool.fromEnvironment('GT_DEMO');

  static bool get demo => _forceDemo || supabaseUrl.isEmpty || supabaseKey.isEmpty;
}
