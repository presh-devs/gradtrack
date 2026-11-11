import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/backend.dart';
import 'package:gradll/features/attention/domain/attention_item.dart';
import 'package:gradll/features/attention/presentation/today_controller.dart';
import 'package:gradll/features/people/domain/professor.dart';
import 'package:gradll/features/people/presentation/professors_controller.dart';
import 'package:gradll/features/settings/domain/profile.dart';
import 'package:gradll/features/settings/presentation/profile_controller.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late ProviderContainer container;
  setUp(() => container = ProviderContainer.test(overrides: [backendProvider.overrideWithValue(Backend.demo)]));

  test('one-tap actions per item type', () {
    expect(TodayAction.forType(AttentionType.requirement), [TodayAction.requirementDone]);
    expect(TodayAction.forType(AttentionType.followUp), [TodayAction.replied, TodayAction.followedUp]);
    expect(TodayAction.forType(AttentionType.applicationDeadline), isEmpty);
  });

  test('logging a reply from Today clears the follow-up everywhere', () async {
    final feed = await container.read(todayControllerProvider.future);
    final followUp = feed.firstWhere((i) => i.type == AttentionType.followUp);
    await container.read(todayControllerProvider.notifier).act(followUp, TodayAction.replied);

    final after = await container.read(todayControllerProvider.future);
    expect(after.any((i) => i.type == AttentionType.followUp && i.itemId == followUp.itemId), isFalse);
    final prof = (await container.read(professorsControllerProvider.future)).firstWhere((p) => p.id == followUp.professorId);
    expect(prof.state, OutreachState.replied);
    expect(prof.followUpDue(), isFalse);
  });

  test('settings save and the demo test digest explains itself', () async {
    final p = await container.read(profileControllerProvider.future);
    await container.read(profileControllerProvider.notifier).save(p.copyWith(digestHour: 6, timezone: 'Africa/Lagos'));
    final saved = container.read(profileControllerProvider).value!;
    expect((saved.digestHour, saved.timezone, saved.neverEdited), (6, 'Africa/Lagos', false));
    final r = await container.read(profileControllerProvider.notifier).sendTestDigest();
    expect(r.sent, isFalse);
    expect(r.message, contains('Demo mode'));
  });

  test('profile defaults', () {
    const p = Profile();
    expect((p.timezone, p.digestHour, p.digestEnabled), ('UTC', 7, true));
  });
}
