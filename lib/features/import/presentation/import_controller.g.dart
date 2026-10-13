// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wizard state. Auto-disposed: leaving the import page starts fresh next time.

@ProviderFor(ImportWizard)
final importWizardProvider = ImportWizardProvider._();

/// Wizard state. Auto-disposed: leaving the import page starts fresh next time.
final class ImportWizardProvider
    extends $NotifierProvider<ImportWizard, ImportWizardState> {
  /// Wizard state. Auto-disposed: leaving the import page starts fresh next time.
  ImportWizardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importWizardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importWizardHash();

  @$internal
  @override
  ImportWizard create() => ImportWizard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportWizardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportWizardState>(value),
    );
  }
}

String _$importWizardHash() => r'b8780a2e6055437cbadae3ce6043684216ff9e4b';

/// Wizard state. Auto-disposed: leaving the import page starts fresh next time.

abstract class _$ImportWizard extends $Notifier<ImportWizardState> {
  ImportWizardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ImportWizardState, ImportWizardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImportWizardState, ImportWizardState>,
              ImportWizardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Parsed rows for the review step. Derived from the wizard plus the cached
/// applications and institutions (for duplicate detection and reuse), so it
/// recomputes whenever the mapping or options change, with no extra fetching.

@ProviderFor(importPreview)
final importPreviewProvider = ImportPreviewProvider._();

/// Parsed rows for the review step. Derived from the wizard plus the cached
/// applications and institutions (for duplicate detection and reuse), so it
/// recomputes whenever the mapping or options change, with no extra fetching.

final class ImportPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ImportRow>>,
          List<ImportRow>,
          FutureOr<List<ImportRow>>
        >
    with $FutureModifier<List<ImportRow>>, $FutureProvider<List<ImportRow>> {
  /// Parsed rows for the review step. Derived from the wizard plus the cached
  /// applications and institutions (for duplicate detection and reuse), so it
  /// recomputes whenever the mapping or options change, with no extra fetching.
  ImportPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importPreviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importPreviewHash();

  @$internal
  @override
  $FutureProviderElement<List<ImportRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ImportRow>> create(Ref ref) {
    return importPreview(ref);
  }
}

String _$importPreviewHash() => r'f44ba579bab35807ee91457b8c781315c5eb9c74';

/// Import submission: idle (null) → loading → summary | error.

@ProviderFor(ImportSubmitter)
final importSubmitterProvider = ImportSubmitterProvider._();

/// Import submission: idle (null) → loading → summary | error.
final class ImportSubmitterProvider
    extends $AsyncNotifierProvider<ImportSubmitter, ImportSummary?> {
  /// Import submission: idle (null) → loading → summary | error.
  ImportSubmitterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importSubmitterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importSubmitterHash();

  @$internal
  @override
  ImportSubmitter create() => ImportSubmitter();
}

String _$importSubmitterHash() => r'9da7f6f72676669e8c8fc963998f18b937230bfd';

/// Import submission: idle (null) → loading → summary | error.

abstract class _$ImportSubmitter extends $AsyncNotifier<ImportSummary?> {
  FutureOr<ImportSummary?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ImportSummary?>, ImportSummary?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ImportSummary?>, ImportSummary?>,
              AsyncValue<ImportSummary?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
