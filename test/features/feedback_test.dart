import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/backend.dart';
import 'package:gradll/features/feedback/domain/feedback.dart';
import 'package:gradll/features/feedback/presentation/feedback_controller.dart';

void main() {
  test('message validation', () {
    expect(feedbackError('  '), 'Write a message first');
    expect(feedbackError('x' * (feedbackMaxLength + 1)), isNotNull);
    expect(feedbackError(' Please add dark mode '), isNull);
  });

  test('db values round-trip, unknown values fall back', () {
    for (final k in FeedbackKind.values) {
      expect(FeedbackKind.fromDb(k.db), k);
    }
    expect(FeedbackStatus.fromDb('new'), FeedbackStatus.received);
    expect(FeedbackStatus.fromDb('weird'), FeedbackStatus.received);
  });

  test('sending adds to the top of the history (demo backend)', () async {
    final container = ProviderContainer.test(overrides: [backendProvider.overrideWithValue(Backend.demo)]);
    container.listen(feedbackHistoryProvider, (_, _) {});
    final before = await container.read(feedbackHistoryProvider.future);

    await container.read(feedbackHistoryProvider.notifier).send(FeedbackKind.problem, '  Import skipped a row  ');
    final after = container.read(feedbackHistoryProvider).value!;
    expect(after, hasLength(before.length + 1));
    expect((after.first.kind, after.first.message, after.first.status),
        (FeedbackKind.problem, 'Import skipped a row', FeedbackStatus.received));

    expect(() => container.read(feedbackHistoryProvider.notifier).send(FeedbackKind.other, ' '), throwsArgumentError);
  });
}
