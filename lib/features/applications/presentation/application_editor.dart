import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/time/local_zone.dart';
import '../../attention/presentation/today_controller.dart';
import '../data/applications_repository_provider.dart';
import '../domain/application_draft.dart';
import '../domain/institution.dart';
import 'applications_controller.dart';

part 'application_editor.g.dart';

/// Institutions for the form's autocomplete. Cached; refreshed after a save
/// that may have created one.
@Riverpod(keepAlive: true)
Future<List<Institution>> institutions(Ref ref) =>
    ref.watch(institutionsRepositoryProvider).list();

/// Default zone for new deadlines: the last zone used in this session, else
/// the browser's zone, else UTC.
@Riverpod(keepAlive: true)
class LastDeadlineZone extends _$LastDeadlineZone {
  @override
  String build() {
    final local = localZoneName();
    return local != null && tz.timeZoneDatabase.locations.containsKey(local) ? local : 'UTC';
  }

  void remember(String zone) => state = zone;
}

/// Save state for the application form: idle (null) → loading → saved id | error.
@riverpod
class ApplicationEditor extends _$ApplicationEditor {
  @override
  FutureOr<String?> build() => null;

  /// Creates (when [id] is null) or updates. Returns the saved id, or null if
  /// validation or the backend failed (the error is in [state]).
  Future<String?> save(ApplicationDraft draft, {String? id}) async {
    final errors = draft.validate();
    if (errors.isNotEmpty) {
      state = AsyncError(ArgumentError(errors.values.first), StackTrace.current);
      return null;
    }
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(applicationsRepositoryProvider);
      final savedId = id ?? await repo.create(draft);
      if (id != null) await repo.update(id, draft);
      return savedId;
    });
    if (!ref.mounted) return result.value;
    state = result;
    if (result.hasValue) {
      final zone = draft.deadline.zone;
      if (zone != null) ref.read(lastDeadlineZoneProvider.notifier).remember(zone);
      // Server-computed data changed: counts, feed, maybe a new institution.
      ref
        ..invalidate(applicationsControllerProvider)
        ..invalidate(todayControllerProvider)
        ..invalidate(institutionsProvider);
    }
    return result.value;
  }
}
