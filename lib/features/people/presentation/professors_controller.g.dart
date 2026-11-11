// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professors_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every professor with their outreach status. Kept alive like the
/// applications list. Each change reloads the list (the status comes from a
/// server-side view) and refreshes Today, where follow-ups appear.

@ProviderFor(ProfessorsController)
final professorsControllerProvider = ProfessorsControllerProvider._();

/// Every professor with their outreach status. Kept alive like the
/// applications list. Each change reloads the list (the status comes from a
/// server-side view) and refreshes Today, where follow-ups appear.
final class ProfessorsControllerProvider
    extends $AsyncNotifierProvider<ProfessorsController, List<Professor>> {
  /// Every professor with their outreach status. Kept alive like the
  /// applications list. Each change reloads the list (the status comes from a
  /// server-side view) and refreshes Today, where follow-ups appear.
  ProfessorsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'professorsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$professorsControllerHash();

  @$internal
  @override
  ProfessorsController create() => ProfessorsController();
}

String _$professorsControllerHash() =>
    r'2ebfcd3242175af431695b94ad57e0834f7b39a4';

/// Every professor with their outreach status. Kept alive like the
/// applications list. Each change reloads the list (the status comes from a
/// server-side view) and refreshes Today, where follow-ups appear.

abstract class _$ProfessorsController extends $AsyncNotifier<List<Professor>> {
  FutureOr<List<Professor>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Professor>>, List<Professor>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Professor>>, List<Professor>>,
              AsyncValue<List<Professor>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Professors linked to one application, derived from the cached list.

@ProviderFor(applicationProfessors)
final applicationProfessorsProvider = ApplicationProfessorsFamily._();

/// Professors linked to one application, derived from the cached list.

final class ApplicationProfessorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Professor>>,
          List<Professor>,
          FutureOr<List<Professor>>
        >
    with $FutureModifier<List<Professor>>, $FutureProvider<List<Professor>> {
  /// Professors linked to one application, derived from the cached list.
  ApplicationProfessorsProvider._({
    required ApplicationProfessorsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationProfessorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationProfessorsHash();

  @override
  String toString() {
    return r'applicationProfessorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Professor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Professor>> create(Ref ref) {
    final argument = this.argument as String;
    return applicationProfessors(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ApplicationProfessorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationProfessorsHash() =>
    r'b5d56e147ba15b1479d297dccb6ad04c66b50d30';

/// Professors linked to one application, derived from the cached list.

final class ApplicationProfessorsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Professor>>, String> {
  ApplicationProfessorsFamily._()
    : super(
        retry: null,
        name: r'applicationProfessorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Professors linked to one application, derived from the cached list.

  ApplicationProfessorsProvider call(String applicationId) =>
      ApplicationProfessorsProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'applicationProfessorsProvider';
}
