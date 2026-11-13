// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'links_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One application's extra links. Edits and deletes are optimistic and roll
/// back (rethrowing for the caller to show) if the save fails.

@ProviderFor(ApplicationLinks)
final applicationLinksProvider = ApplicationLinksFamily._();

/// One application's extra links. Edits and deletes are optimistic and roll
/// back (rethrowing for the caller to show) if the save fails.
final class ApplicationLinksProvider
    extends $AsyncNotifierProvider<ApplicationLinks, List<ApplicationLink>> {
  /// One application's extra links. Edits and deletes are optimistic and roll
  /// back (rethrowing for the caller to show) if the save fails.
  ApplicationLinksProvider._({
    required ApplicationLinksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'applicationLinksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicationLinksHash();

  @override
  String toString() {
    return r'applicationLinksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ApplicationLinks create() => ApplicationLinks();

  @override
  bool operator ==(Object other) {
    return other is ApplicationLinksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicationLinksHash() => r'ea33cbfe51a1e45812108ce7bbcbe536d4c5b230';

/// One application's extra links. Edits and deletes are optimistic and roll
/// back (rethrowing for the caller to show) if the save fails.

final class ApplicationLinksFamily extends $Family
    with
        $ClassFamilyOverride<
          ApplicationLinks,
          AsyncValue<List<ApplicationLink>>,
          List<ApplicationLink>,
          FutureOr<List<ApplicationLink>>,
          String
        > {
  ApplicationLinksFamily._()
    : super(
        retry: null,
        name: r'applicationLinksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One application's extra links. Edits and deletes are optimistic and roll
  /// back (rethrowing for the caller to show) if the save fails.

  ApplicationLinksProvider call(String applicationId) =>
      ApplicationLinksProvider._(argument: applicationId, from: this);

  @override
  String toString() => r'applicationLinksProvider';
}

/// One application's extra links. Edits and deletes are optimistic and roll
/// back (rethrowing for the caller to show) if the save fails.

abstract class _$ApplicationLinks
    extends $AsyncNotifier<List<ApplicationLink>> {
  late final _$args = ref.$arg as String;
  String get applicationId => _$args;

  FutureOr<List<ApplicationLink>> build(String applicationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ApplicationLink>>, List<ApplicationLink>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ApplicationLink>>,
                List<ApplicationLink>
              >,
              AsyncValue<List<ApplicationLink>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
