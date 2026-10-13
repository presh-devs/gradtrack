import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/features/applications/data/applications_repository_provider.dart';
import 'package:gradtrack/features/applications/domain/application.dart';
import 'package:gradtrack/features/applications/domain/applications_repository.dart';
import 'package:gradtrack/features/applications/presentation/applications_controller.dart';
import 'package:gradtrack/features/attention/data/attention_repositories.dart';
import 'package:gradtrack/features/attention/domain/attention_item.dart';
import 'package:gradtrack/features/attention/domain/attention_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockApps extends Mock implements ApplicationsRepository {}

class _MockAttention extends Mock implements AttentionRepository {}

const _app = Application(
  id: 'a1',
  institutionName: 'University of Toronto',
  programmeName: 'Computer Science',
  degreeType: 'phd',
  stage: ApplicationStage.preparing,
);

void main() {
  setUpAll(() {
    registerFallbackValue(ApplicationStage.researching);
    registerFallbackValue(Duration.zero);
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
}
