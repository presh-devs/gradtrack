import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../applications/presentation/application_editor.dart';
import '../../applications/presentation/applications_controller.dart';
import '../../attention/presentation/today_controller.dart';
import '../data/import_repositories.dart';
import '../domain/csv_import.dart';
import '../domain/import_repository.dart';
import '../domain/value_parsers.dart';

part 'import_controller.freezed.dart';
part 'import_controller.g.dart';

enum ImportStep { source, columns, review, done }

@freezed
abstract class ImportWizardState with _$ImportWizardState {
  const ImportWizardState._();

  const factory ImportWizardState({
    required String defaultZone,
    @Default(ImportStep.source) ImportStep step,
    String? sourceName,
    CsvTable? table,
    @Default(<int, ImportField>{}) Map<int, ImportField> mapping,
    @Default(DateOrder.dayFirst) DateOrder dateOrder,
    @Default(true) bool seedRequirements,
    String? sourceError,
  }) = _ImportWizardState;

  List<ImportField> get missingRequired => [
        for (final f in ImportField.values)
          if (f.required && !mapping.containsValue(f)) f,
      ];

  ImportOptions get options => ImportOptions(defaultZone: defaultZone, dateOrder: dateOrder);
}

/// Wizard state. Auto-disposed: leaving the import page starts fresh next time.
@riverpod
class ImportWizard extends _$ImportWizard {
  @override
  ImportWizardState build() => ImportWizardState(defaultZone: ref.read(lastDeadlineZoneProvider));

  static const maxRows = 500; // matches the import_applications() limit

  void load(String sourceName, String text) {
    final CsvTable table;
    try {
      table = CsvTable.parse(text);
    } on Object {
      state = state.copyWith(sourceError: "That doesn't look like a CSV or spreadsheet paste.");
      return;
    }
    if (table.isEmpty) {
      state = state.copyWith(sourceError: 'Include a header row and at least one row of data.');
      return;
    }
    if (table.rows.length > maxRows) {
      state = state.copyWith(sourceError: 'Import up to $maxRows rows at a time (this has ${table.rows.length}).');
      return;
    }
    state = state.copyWith(
      sourceName: sourceName,
      table: table,
      mapping: autoMap(table.headers),
      sourceError: null,
      step: ImportStep.columns,
    );
  }

  void sourceFailed(String message) => state = state.copyWith(sourceError: message);

  /// Maps [column] to [field] (null = don't import). A field can only be used
  /// once, so assigning it here unassigns it elsewhere.
  void mapColumn(int column, ImportField? field) {
    final next = {...state.mapping}..removeWhere((c, f) => c == column || f == field);
    if (field != null) next[column] = field;
    state = state.copyWith(mapping: next);
  }

  void setDefaultZone(String zone) => state = state.copyWith(defaultZone: zone);
  void setDateOrder(DateOrder order) => state = state.copyWith(dateOrder: order);
  void setSeedRequirements(bool on) => state = state.copyWith(seedRequirements: on);
  void goTo(ImportStep step) => state = state.copyWith(step: step);
  void reset() => ref.invalidateSelf();
}

/// Parsed rows for the review step. Derived from the wizard plus the cached
/// applications and institutions (for duplicate detection and reuse), so it
/// recomputes whenever the mapping or options change, with no extra fetching.
@riverpod
Future<List<ImportRow>> importPreview(Ref ref) async {
  final wizard = ref.watch(importWizardProvider);
  final table = wizard.table;
  if (table == null) return const [];
  final existing = await ref.watch(applicationsControllerProvider.future);
  final institutions = await ref.watch(institutionsProvider.future);
  return buildImportRows(table, wizard.mapping, wizard.options, existing: existing, institutions: institutions);
}

/// Import submission: idle (null) → loading → summary | error.
@riverpod
class ImportSubmitter extends _$ImportSubmitter {
  @override
  FutureOr<ImportSummary?> build() => null;

  Future<void> submit() async {
    final rows = await ref.read(importPreviewProvider.future);
    final drafts = [
      for (final r in rows)
        if (r.status == RowStatus.ready) r.draft!,
    ];
    if (drafts.isEmpty) return;
    final seed = ref.read(importWizardProvider).seedRequirements;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(importRepositoryProvider).importAll(drafts, seedRequirements: seed),
    );
    if (!ref.mounted) return;
    state = result;
    if (result.hasValue) {
      ref
        ..invalidate(applicationsControllerProvider)
        ..invalidate(todayControllerProvider)
        ..invalidate(institutionsProvider);
      ref.read(importWizardProvider.notifier).goTo(ImportStep.done);
    }
  }
}
