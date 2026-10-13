import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/features/applications/data/applications_repository_provider.dart';
import 'package:gradtrack/features/applications/domain/application.dart';
import 'package:gradtrack/features/applications/domain/applications_repository.dart';
import 'package:gradtrack/features/applications/domain/application_draft.dart';
import 'package:gradtrack/features/applications/presentation/application_editor.dart';
import 'package:gradtrack/features/applications/presentation/applications_controller.dart';
import 'package:gradtrack/features/attention/data/attention_repositories.dart';
import 'package:gradtrack/features/attention/domain/attention_item.dart';
import 'package:gradtrack/features/attention/domain/attention_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockApps extends Mock implements ApplicationsRepository {}

class _MockAttention extends Mock implements AttentionRepository {}

const _app = Application(
  id: 'a1',
  institutionId: 'i1',
  institutionName: 'University of Toronto',
  programmeName: 'Computer Science',
  degree: DegreeType.phd,
  stage: ApplicationStage.preparing,
);

void main() {
  setUpAll(() {
    registerFallbackValue(ApplicationStage.researching);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(const ApplicationDraft());
  });

  late _MockApps apps;
  late _MockAttention attention;
  late ProviderContainer container;

  setUp(() {
    apps = _MockApps();
    attention = _MockAttention();
    when(() => apps.list()).thenAnswer((_) async => [_app]);
    when(() => attention.feed(horizon: any(named: 'horizon'))).thenAnswer((_) async => <AttentionItem>[]);
    container = ProviderContainer.test(overrides: [
      applicationsRepositoryProvider.overrideWithValue(apps),
      attentionRepositoryProvider.overrideWithValue(attention),
    ]);
  });

  test('detail is derived from the cached list (no extra fetch)', () async {
    final a = await container.read(applicationByIdProvider('a1').future);
    expect(a?.programmeName, 'Computer Science');
    await container.read(applicationByIdProvider('a1').future);
    verify(() => apps.list()).called(1);
  });

  test('stage change is optimistic and visible through derived providers', () async {
    await container.read(applicationsControllerProvider.future);
    when(() => apps.updateStage('a1', ApplicationStage.submitted)).thenAnswer((_) async {});

    final pending = container
        .read(applicationsControllerProvider.notifier)
        .updateStage('a1', ApplicationStage.submitted);

    // Updated before the repository call completes.
    expect(container.read(applicationsControllerProvider).value!.single.stage, ApplicationStage.submitted);
    await pending;
    final detail = await container.read(applicationByIdProvider('a1').future);
    expect(detail!.stage, ApplicationStage.submitted);
  });

  test('stage change rolls back and rethrows on failure', () async {
    await container.read(applicationsControllerProvider.future);
    when(() => apps.updateStage(any(), any())).thenThrow(Exception('offline'));

    await expectLater(
      container.read(applicationsControllerProvider.notifier).updateStage('a1', ApplicationStage.ready),
      throwsException,
    );
    expect(container.read(applicationsControllerProvider).value!.single.stage, ApplicationStage.preparing);
  });

  group('ApplicationEditor', () {
    const draft = ApplicationDraft(institutionName: 'ETH Zürich', programmeName: 'Data Science');

    test('create refreshes the cached list so the new application appears', () async {
      await container.read(applicationsControllerProvider.future);
      final sub = container.listen(applicationEditorProvider, (_, _) {});
      addTearDown(sub.close);
      when(() => apps.create(any())).thenAnswer((_) async => 'a2');
      when(() => apps.list()).thenAnswer((_) async => [_app, _app.copyWith(id: 'a2')]);

      final id = await container.read(applicationEditorProvider.notifier).save(draft);

      expect(id, 'a2');
      expect(container.read(applicationEditorProvider).value, 'a2');
      final list = await container.read(applicationsControllerProvider.future);
      expect(list.map((a) => a.id), ['a1', 'a2']);
    });

    test('invalid drafts never reach the repository', () async {
      final sub = container.listen(applicationEditorProvider, (_, _) {});
      addTearDown(sub.close);
      final id = await container.read(applicationEditorProvider.notifier).save(const ApplicationDraft());
      expect(id, isNull);
      expect(container.read(applicationEditorProvider).hasError, isTrue);
      verifyNever(() => apps.create(any()));
    });

    test('backend errors surface as AsyncError', () async {
      final sub = container.listen(applicationEditorProvider, (_, _) {});
      addTearDown(sub.close);
      when(() => apps.update(any(), any())).thenThrow(Exception('offline'));
      final id = await container.read(applicationEditorProvider.notifier).save(draft, id: 'a1');
      expect(id, isNull);
      expect(container.read(applicationEditorProvider).error.toString(), contains('offline'));
    });
  });
}
