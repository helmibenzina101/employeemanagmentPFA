// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingUsersStreamHash() =>
    r'7b09557747df613cdf1117b4dd93c486110ef9eb';

/// Provides a stream of users whose status is 'pending'. Requires Firestore index.
///
/// Copied from [pendingUsersStream].
@ProviderFor(pendingUsersStream)
final pendingUsersStreamProvider =
    AutoDisposeStreamProvider<List<UserModel>>.internal(
  pendingUsersStream,
  name: r'pendingUsersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingUsersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingUsersStreamRef = AutoDisposeStreamProviderRef<List<UserModel>>;
String _$userManagementControllerHash() =>
    r'4f31850ff80b9f99ae54924a652f6d2818c02374';

/// See also [UserManagementController].
@ProviderFor(UserManagementController)
final userManagementControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserManagementController, void>.internal(
  UserManagementController.new,
  name: r'userManagementControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userManagementControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserManagementController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
