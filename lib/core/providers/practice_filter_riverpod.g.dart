// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_filter_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PracticeFilterController)
const practiceFilterControllerProvider = PracticeFilterControllerProvider._();

final class PracticeFilterControllerProvider
    extends $NotifierProvider<PracticeFilterController, PracticeFilterState> {
  const PracticeFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'practiceFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$practiceFilterControllerHash();

  @$internal
  @override
  PracticeFilterController create() => PracticeFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PracticeFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PracticeFilterState>(value),
    );
  }
}

String _$practiceFilterControllerHash() =>
    r'3eb3e8ae786981676f850767d7e110f078d40455';

abstract class _$PracticeFilterController
    extends $Notifier<PracticeFilterState> {
  PracticeFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PracticeFilterState, PracticeFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PracticeFilterState, PracticeFilterState>,
              PracticeFilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
