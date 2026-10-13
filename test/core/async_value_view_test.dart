import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/core/theme/app_theme.dart';
import 'package:gradtrack/core/widgets/async_value_view.dart';

void main() {
  Widget host(AsyncValue<String> value) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AsyncValueView<String>(
            value: value,
            data: (_) => const TextField(key: Key('field')),
          ),
        ),
      );

  testWidgets('content keeps its state while refreshing and after', (tester) async {
    await tester.pumpWidget(host(const AsyncData('a')));
    await tester.enterText(find.byKey(const Key('field')), 'typed');

    const refreshing = AsyncLoading<String>();
    await tester.pumpWidget(host(refreshing.copyWithPrevious(const AsyncData('a'))));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('typed'), findsOneWidget);

    await tester.pumpWidget(host(const AsyncData('a')));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('typed'), findsOneWidget);
  });

  testWidgets('first load shows a skeleton, errors show a retry card', (tester) async {
    await tester.pumpWidget(host(const AsyncLoading()));
    expect(find.byType(SkeletonList), findsOneWidget);

    var retried = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: AsyncValueView<String>(
          value: AsyncError('boom', StackTrace.empty),
          onRetry: () => retried = true,
          data: Text.new,
        ),
      ),
    ));
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });
}
