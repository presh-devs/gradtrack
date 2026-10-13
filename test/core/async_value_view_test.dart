import 'dart:async';

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
    // A real provider refetch produces "loading with previous data".
    final loads = <Completer<String>>[];
    final provider = FutureProvider<String>((ref) {
      final c = Completer<String>();
      loads.add(c);
      return c.future;
    });
    final container = ProviderContainer.test();
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => AsyncValueView<String>(
              value: ref.watch(provider),
              data: (_) => const TextField(key: Key('field')),
            ),
          ),
        ),
      ),
    ));
    loads.last.complete('a');
    await tester.pump();
    await tester.enterText(find.byKey(const Key('field')), 'typed');

    container.invalidate(provider);
    await tester.pump();
    expect(container.read(provider).isLoading, isTrue);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('typed'), findsOneWidget);

    loads.last.complete('b');
    await tester.pump();
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
