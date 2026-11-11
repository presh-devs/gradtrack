import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/backend.dart';
import 'package:gradll/features/applications/presentation/applications_controller.dart';
import 'package:gradll/features/attention/data/attention_repositories.dart';
import 'package:gradll/features/attention/domain/attention_item.dart';
import 'package:gradll/features/attention/domain/attention_repository.dart';
import 'package:gradll/features/letters/domain/letters.dart';
import 'package:gradll/features/letters/presentation/letters_controller.dart';
import 'package:gradll/features/people/presentation/professors_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

class _MockAttention extends Mock implements AttentionRepository {}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
    registerFallbackValue(Duration.zero);
  });

  late ProviderContainer container;

  setUp(() {
    final attention = _MockAttention();
    when(() => attention.feed(horizon: any(named: 'horizon'))).thenAnswer((_) async => <AttentionItem>[]);
    container = ProviderContainer.test(overrides: [
      backendProvider.overrideWithValue(Backend.demo),
      attentionRepositoryProvider.overrideWithValue(attention),
    ]);
  });

  test('progress ignores declined letters', () {
    const ls = [
      LetterRequest(id: '1', applicationId: 'a', recommenderId: 'r1', recommenderName: 'A', status: LetterStatus.submitted),
      LetterRequest(id: '2', applicationId: 'a', recommenderId: 'r2', recommenderName: 'B', status: LetterStatus.declined),
      LetterRequest(id: '3', applicationId: 'a', recommenderId: 'r3', recommenderName: 'C'),
    ];
    expect(letterProgress(ls), (submitted: 1, total: 2));
  });

  test('letters keep application and recommender counts in sync', () async {
    Future<({int s, int t})> appCounts() async {
      final a = (await container.read(applicationsControllerProvider.future)).firstWhere((a) => a.id == 'a1');
      return (s: a.lettersSubmitted, t: a.lettersTotal);
    }

    final before = await appCounts();
    final provider = applicationLettersProvider('a1');
    container.listen(provider, (_, _) {});
    final letters = await container.read(provider.future);
    expect(letterProgress(letters), (submitted: before.s, total: before.t));

    final open = letters.firstWhere((l) => l.status.isOpen);
    await container.read(provider.notifier).setStatus(open, LetterStatus.submitted);
    expect(await appCounts(), (s: before.s + 1, t: before.t));

    // A new recommender, added to the application.
    final id = await container
        .read(recommendersControllerProvider.notifier)
        .create(const RecommenderDraft(name: 'New Person', email: 'np@example.com'));
    await container.read(provider.notifier).add(id);
    expect(await appCounts(), (s: before.s + 1, t: before.t + 1));
    final recs = await container.read(recommendersControllerProvider.future);
    expect(recs.firstWhere((r) => r.id == id).letters, 1);

    // Deleting them removes their letter everywhere.
    await container.read(recommendersControllerProvider.notifier).delete(id);
    expect(await appCounts(), (s: before.s + 1, t: before.t));
  });

  test('recommender draft validation', () {
    expect(const RecommenderDraft().validate().keys, ['name']);
    expect(const RecommenderDraft(name: 'A', email: 'x').validate().keys, ['email']);
  });

  test('professors link to applications', () async {
    final linked = await container.read(applicationProfessorsProvider('a1').future);
    expect(linked.map((p) => p.id), ['p2']);
    await container.read(professorsControllerProvider.notifier).link('p3', 'a1');
    final after = await container.read(applicationProfessorsProvider('a1').future);
    expect(after.map((p) => p.id).toSet(), {'p2', 'p3'});
    await container.read(professorsControllerProvider.notifier).unlink('p2', 'a1');
    expect((await container.read(applicationProfessorsProvider('a1').future)).map((p) => p.id), ['p3']);
  });
}
