// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clubs_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClubsController)
const clubsControllerProvider = ClubsControllerProvider._();

final class ClubsControllerProvider
    extends $NotifierProvider<ClubsController, ClubsState> {
  const ClubsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubsControllerHash();

  @$internal
  @override
  ClubsController create() => ClubsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClubsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClubsState>(value),
    );
  }
}

String _$clubsControllerHash() => r'b0823354183f65e9658e4807c137ce53ae54eb5c';

abstract class _$ClubsController extends $Notifier<ClubsState> {
  ClubsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ClubsState, ClubsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClubsState, ClubsState>,
              ClubsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
