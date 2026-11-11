import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradtrack/core/theme/app_theme.dart';
import 'package:gradtrack/features/auth/data/auth_repositories.dart';
import 'package:gradtrack/features/auth/domain/auth_repository.dart';
import 'package:gradtrack/features/auth/presentation/offline_banner.dart';

class _FakeAuth implements AuthRepository {
  final reachable = StreamController<bool>.broadcast();
  int retries = 0;

  @override
  Stream<bool> watchReachable() => reachable.stream;

  @override
  Future<void> retryConnection() async => retries++;

  @override
  bool get isSignedIn => true;

  @override
  Stream<bool> watchSignedIn() => const Stream.empty();

  @override
  String? get displayName => null;

  @override
  Future<void> sendMagicLink(String email, {required Uri redirectTo}) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('shows a retry strip while the auth server is unreachable', (tester) async {
    final auth = _FakeAuth();
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => OfflineBanner(child: child!),
        home: const Scaffold(body: Text('app')),
      ),
    ));

    expect(find.text('app'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    auth.reachable.add(false);
    await tester.pump();
    expect(find.textContaining("Can't reach the server"), findsOneWidget);
    expect(find.text('app'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(auth.retries, 1);

    auth.reachable.add(true);
    await tester.pump();
    expect(find.text('Retry'), findsNothing);
  });
}
