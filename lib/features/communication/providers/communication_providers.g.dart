// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$announcementsStreamHash() =>
    r'5b05134f394bed5e5d67850d1140c4947340629d';

/// See also [announcementsStream].
@ProviderFor(announcementsStream)
final announcementsStreamProvider =
    AutoDisposeStreamProvider<List<AnnouncementModel>>.internal(
  announcementsStream,
  name: r'announcementsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$announcementsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnnouncementsStreamRef
    = AutoDisposeStreamProviderRef<List<AnnouncementModel>>;
String _$announcementControllerHash() =>
    r'963975f46bb7b4117b1143bb79bf0f9c07e27d87';

/// See also [AnnouncementController].
@ProviderFor(AnnouncementController)
final announcementControllerProvider =
    AutoDisposeAsyncNotifierProvider<AnnouncementController, void>.internal(
  AnnouncementController.new,
  name: r'announcementControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$announcementControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AnnouncementController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
