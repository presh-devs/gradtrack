import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/backend.dart';
import 'package:gradll/features/applications/presentation/applications_controller.dart';
import 'package:gradll/features/attention/data/attention_repositories.dart';
import 'package:gradll/features/attention/domain/attention_item.dart';
import 'package:gradll/features/attention/domain/attention_repository.dart';
import 'package:gradll/features/checklist/domain/requirement.dart';
import 'package:gradll/features/checklist/presentation/checklist_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

class _MockAttention extends Mock implements AttentionRepository {}

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
    registerFallbackValue(Duration.zero);
  });

  test('kinds and progress', () {
    expect(requirementKindFor('Official academic transcript'), ('transcript', true));
    expect(requirementKindFor('IELTS 7.0'), ('english_test', true));
    expect(requirementKindFor('Study plan'), ('research_statement', false));
    expect(requirementKindFor('Bank statement'), ('other', true));
    const items = [
      Requirement(id: '1', applicationId: 'a', title: 'A', status: RequirementStatus.done),
      Requirement(id: '2', applicationId: 'a', title: 'B'),
      Requirement(id: '3', applicationId: 'a', title: 'C', status: RequirementStatus.notApplicable),
    ];
    expect(checklistProgress(items), (done: 1, total: 2));
  });

  group('Checklist controller (demo backend)', () {
    late ProviderContainer container;

    setUp(() {
      final attention = _MockAttention();
      when(() => attention.feed(horizon: any(named: 'horizon'))).thenAnswer((_) async => <AttentionItem>[]);
      container = ProviderContainer.test(overrides: [
        backendProvider.overrideWithValue(Backend.demo),
        attentionRepositoryProvider.overrideWithValue(attention),
      ]);
    });

    Future<({int done, int total})> listCounts(String id) async {
      final apps = await container.read(applicationsControllerProvider.future);
      final a = apps.firstWhere((a) => a.id == id);
      return (done: a.requirementsDone, total: a.requirementsTotal);
    }

    test('demo checklist matches the sample counters, and edits keep them in sync', () async {
      final before = await listCounts('a1');
      final provider = checklistProvider('a1');
      container.listen(provider, (_, _) {}); // as the checklist card does
      final items = await container.read(provider.future);
      expect(checklistProgress(items), before);

      final open = items.firstWhere((r) => !r.isDone);
      await container.read(provider.notifier).setStatus(open, RequirementStatus.done);
      expect(await listCounts('a1'), (done: before.done + 1, total: before.total));

      await container.read(provider.notifier).setStatus(open, RequirementStatus.notApplicable);
      expect(await listCounts('a1'), (done: before.done, total: before.total - 1));

      final added = await container.read(provider.notifier).addTitles(['Passport scan', ' passport SCAN ', 'GRE']);
      expect(added, 2); // duplicate in the same batch skipped
      final gre = container.read(provider).value!.firstWhere((r) => r.title == 'GRE');
      expect((gre.kind, gre.external), ('standardized_test', true));

      await container.read(provider.notifier).delete(gre);
      expect(container.read(provider).value!.any((r) => r.title == 'GRE'), isFalse);
      expect(await listCounts('a1'), (done: before.done, total: before.total));
    });

    test('add common requirements skips kinds already present', () async {
      final provider = checklistProvider('a2'); // ETH: 6 items incl. all common kinds
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      expect(await container.read(provider.notifier).addCommon(), 0);
    });
  });
}
