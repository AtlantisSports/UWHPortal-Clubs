// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavigationController)
const navigationControllerProvider = NavigationControllerProvider._();

final class NavigationControllerProvider
    extends $NotifierProvider<NavigationController, NavigationState> {
  const NavigationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationControllerHash();

  @$internal
  @override
  NavigationController create() => NavigationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationState>(value),
    );
  }
}

String _$navigationControllerHash() =>
    r'9e050d07de2098dc6cb51b704f1e676b66646eb3';

abstract class _$NavigationController extends $Notifier<NavigationState> {
  NavigationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NavigationState, NavigationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationState, NavigationState>,
              NavigationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
