// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserLeaveRequestsHash() =>
    r'8f7a034ce1c3993b29174d36e45f2980a7081fe5';

/// Provides a real-time stream of leave requests submitted by the currently logged-in user.
///
/// Copied from [currentUserLeaveRequests].
@ProviderFor(currentUserLeaveRequests)
final currentUserLeaveRequestsProvider =
    AutoDisposeStreamProvider<List<LeaveRequestModel>>.internal(
  currentUserLeaveRequests,
  name: r'currentUserLeaveRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserLeaveRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserLeaveRequestsRef
    = AutoDisposeStreamProviderRef<List<LeaveRequestModel>>;
String _$pendingLeaveRequestsHash() =>
    r'f41e4f58df6a491e658696eaaff7d63d2ae563b1';

/// Provides a real-time stream of leave requests that are currently pending approval.
/// This stream is intended for users with HR or Admin roles.
///
/// Copied from [pendingLeaveRequests].
@ProviderFor(pendingLeaveRequests)
final pendingLeaveRequestsProvider =
    AutoDisposeStreamProvider<List<LeaveRequestModel>>.internal(
  pendingLeaveRequests,
  name: r'pendingLeaveRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingLeaveRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingLeaveRequestsRef
    = AutoDisposeStreamProviderRef<List<LeaveRequestModel>>;
String _$leaveBalanceHash() => r'11e10aef11d33745f8945d2efc3bd5326610afbe';

/// Calculates the remaining leave balance for the current user for different leave types.
/// This provider depends on the user's leave requests to calculate used balances.
/// Note: The initial balance calculation is a placeholder and needs real business logic.
///
/// Copied from [leaveBalance].
@ProviderFor(leaveBalance)
final leaveBalanceProvider =
    AutoDisposeFutureProvider<Map<LeaveType, double>>.internal(
  leaveBalance,
  name: r'leaveBalanceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$leaveBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaveBalanceRef = AutoDisposeFutureProviderRef<Map<LeaveType, double>>;
String _$leaveRequestControllerHash() =>
    r'a1ceae01095fa365cf478f3f46b028ce5c19aed1';

/// Manages actions related to leave requests: submitting, approving, rejecting, cancelling.
/// Uses AsyncValueNotifier to track the state of these actions (loading, error, success).
///
/// Copied from [LeaveRequestController].
@ProviderFor(LeaveRequestController)
final leaveRequestControllerProvider =
    AutoDisposeAsyncNotifierProvider<LeaveRequestController, void>.internal(
  LeaveRequestController.new,
  name: r'leaveRequestControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaveRequestControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LeaveRequestController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
