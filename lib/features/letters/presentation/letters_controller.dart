import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../applications/presentation/applications_controller.dart';
import '../../attention/presentation/today_controller.dart';
import '../data/letters_repositories.dart';
import '../domain/letters.dart';

part 'letters_controller.g.dart';

/// Everyone writing letters for you, with their letter counts.
@Riverpod(keepAlive: true)
class RecommendersController extends _$RecommendersController {
  @override
  Future<List<Recommender>> build() => ref.watch(lettersRepositoryProvider).recommenders();

  Future<void> _reload() async => state = AsyncData(await ref.read(lettersRepositoryProvider).recommenders());

  Future<String> create(RecommenderDraft d) async {
    final id = await ref.read(lettersRepositoryProvider).createRecommender(d);
    await _reload();
    return id;
  }

  Future<void> save(String id, RecommenderDraft d) async {
    await ref.read(lettersRepositoryProvider).updateRecommender(id, d);
    await _reload();
    // Their name shows on letters already loaded.
    ref.invalidate(applicationLettersProvider);
  }

  Future<void> delete(String id) async {
    await ref.read(lettersRepositoryProvider).deleteRecommender(id);
    await _reload();
    ref.invalidate(applicationLettersProvider);
    // Counters on every application they wrote for may change.
    await ref.read(applicationsControllerProvider.notifier).refresh();
    ref.invalidate(todayControllerProvider);
  }
}

/// One application's letters. Status changes are optimistic; every change
/// updates the application's letter counters, the recommender counts and
/// Today.
@riverpod
class ApplicationLetters extends _$ApplicationLetters {
  @override
  Future<List<LetterRequest>> build(String applicationId) =>
      ref.watch(lettersRepositoryProvider).forApplication(applicationId);

  Future<void> add(String recommenderId) async {
    final letter = await ref.read(lettersRepositoryProvider).addLetter(applicationId, recommenderId);
    state = AsyncData([...?state.value, letter]);
    _afterChange();
  }

  Future<void> setStatus(LetterRequest letter, LetterStatus status) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData([
      for (final l in previous) l.id == letter.id ? l.copyWith(status: status, statusChangedAt: DateTime.now()) : l,
    ]);
    try {
      await ref.read(lettersRepositoryProvider).setStatus(letter.id, status);
      _afterChange();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> remove(LetterRequest letter) async {
    await ref.read(lettersRepositoryProvider).removeLetter(letter.id);
    state = AsyncData([for (final l in state.value ?? const <LetterRequest>[]) if (l.id != letter.id) l]);
    _afterChange();
  }

  void _afterChange() {
    final p = letterProgress(state.value ?? const []);
    ref.read(applicationsControllerProvider.notifier).setLetterCounts(applicationId, p.submitted, p.total);
    ref.invalidate(recommendersControllerProvider);
    ref.invalidate(todayControllerProvider);
  }
}
