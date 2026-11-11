import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradll/core/backend.dart';
import 'package:gradll/core/theme/app_theme.dart';
import 'package:gradll/features/people/presentation/professor_dialogs.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester, void Function(BuildContext) open) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [backendProvider.overrideWithValue(Backend.demo)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(child: TextButton(onPressed: () => open(context), child: const Text('open'))),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('paste dialog opens, reads a paste and shows the summary', (tester) async {
    await pumpHost(tester, showProfessorPasteDialog);
    expect(find.text('Paste professors'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'school\tsupervisors\temail\tStatus\nUSTC\tProf Wang Qingsong\twq@example.cn\tsent\n\tRen Xiaodi\txr@example.cn\t',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 professors ready'), findsOneWidget);
    expect(find.text('Import 2'), findsOneWidget);
  });

  testWidgets('editor opens', (tester) async {
    await pumpHost(tester, (c) => showProfessorEditor(c));
    expect(find.text('Add professor'), findsOneWidget);
  });
}
