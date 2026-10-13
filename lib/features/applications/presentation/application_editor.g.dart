// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Institutions for the form's autocomplete. Cached; refreshed after a save
/// that may have created one.

@ProviderFor(institutions)
final institutionsProvider = InstitutionsProvider._();

/// Institutions for the form's autocomplete. Cached; refreshed after a save
/// that may have created one.

final class InstitutionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Institution>>,
          List<Institution>,
          FutureOr<List<Institution>>
        >
    with
        $FutureModifier<List<Institution>>,
        $FutureProvider<List<Institution>> {
  /// Institutions for the form's autocomplete. Cached; refreshed after a save
  /// that may have created one.
  InstitutionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'institutionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$institutionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Institution>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Institution>> create(Ref ref) {
    return institutions(ref);
  }
}

String _$institutionsHash() => r'a9e22aeb142a1c57ed6d365e21e6e5f8bdbcf6a6';

/// Default zone for new deadlines: the last zone used in this session, else
/// the browser's zone, else UTC.

@ProviderFor(LastDeadlineZone)
final lastDeadlineZoneProvider = LastDeadlineZoneProvider._();

/// Default zone for new deadlines: the last zone used in this session, else
/// the browser's zone, else UTC.
final class LastDeadlineZoneProvider
    extends $NotifierProvider<LastDeadlineZone, String> {
  /// Default zone for new deadlines: the last zone used in this session, else
  /// the browser's zone, else UTC.
  LastDeadlineZoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastDeadlineZoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastDeadlineZoneHash();

  @$internal
  @override
  LastDeadlineZone create() => LastDeadlineZone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$lastDeadlineZoneHash() => r'62f20b553d5897115b0244aaedfd7b6971a082b7';

/// Default zone for new deadlines: the last zone used in this session, else
/// the browser's zone, else UTC.

abstract class _$LastDeadlineZone extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Save state for the application form: idle (null) → loading → saved id | error.

@ProviderFor(ApplicationEditor)
final applicationEditorProvider = ApplicationEditorProvider._();

/// Save state for the application form: idle (null) → loading → saved id | error.
final class ApplicationEditorProvider
    extends $AsyncNotifierProvider<ApplicationEditor, String?> {
  /// Save state for the application form: idle (null) → loading → saved id | error.
  ApplicationEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicationEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicationEditorHash();

  @$internal
  @override
  ApplicationEditor create() => ApplicationEditor();
}

String _$applicationEditorHash() => r'9857d02ecbb91459c5b3d19d6c6720246555f6d6';

/// Save state for the application form: idle (null) → loading → saved id | error.

abstract class _$ApplicationEditor extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
