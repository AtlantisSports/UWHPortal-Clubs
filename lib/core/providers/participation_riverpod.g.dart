// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participation_riverpod.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ParticipationController)
const participationControllerProvider = ParticipationControllerProvider._();

final class ParticipationControllerProvider
    extends $NotifierProvider<ParticipationController, ParticipationState> {
  const ParticipationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'participationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$participationControllerHash();

  @$internal
  @override
  ParticipationController create() => ParticipationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParticipationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParticipationState>(value),
    );
  }
}

String _$participationControllerHash() =>
    r'0920bebadd0f786a28557a4c1384d37566476e28';

abstract class _$ParticipationController extends $Notifier<ParticipationState> {
  ParticipationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ParticipationState, ParticipationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ParticipationState, ParticipationState>,
              ParticipationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
