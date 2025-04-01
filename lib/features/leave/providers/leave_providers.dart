import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:uuid/uuid.dart'; // Not strictly needed if Firestore generates IDs

// Core Imports
import 'package:employeemanagment/core/models/leave_request_model.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
import 'package:employeemanagment/core/enums/user_role.dart'; // Ensure this is imported


part 'leave_providers.g.dart'; // For Riverpod Generator

// --- Leave Requests for Current User ---
/// Provides a real-time stream of leave requests submitted by the currently logged-in user.
@riverpod
Stream<List<LeaveRequestModel>> currentUserLeaveRequests(CurrentUserLeaveRequestsRef ref) {
  // Watch the current user's data. If it changes (e.g., login/logout), this provider rebuilds.
  final currentUser = ref.watch(currentUserDataProvider);
  // Get the Firestore service instance.
  final service = ref.watch(firestoreServiceProvider);
  // If a user is logged in, return the stream of their leave requests.
  if (currentUser != null) {
    return service.getLeaveRequestsStream(currentUser.uid);
  }
  // If no user is logged in, return a stream with an empty list.
  return Stream.value([]);
}

// --- Pending Leave Requests for HR/Admin ---
/// Provides a real-time stream of leave requests that are currently pending approval.
/// This stream is intended for users with HR or Admin roles.
@riverpod
Stream<List<LeaveRequestModel>> pendingLeaveRequests(PendingLeaveRequestsRef ref) {
  // Watch the current user's data to check their role.
  final currentUser = ref.watch(currentUserDataProvider);
   final service = ref.watch(firestoreServiceProvider);
   // Only fetch pending requests if the user has the necessary permissions.
   if (currentUser != null && (currentUser.role == UserRole.admin || currentUser.role == UserRole.rh)) {
      return service.getPendingLeaveRequestsStream();
   }
   // If the user is not authorized or not logged in, return an empty stream.
   return Stream.value([]);
}

// --- Leave Balance Calculation ---
/// Calculates the remaining leave balance for the current user for different leave types.
/// This provider depends on the user's leave requests to calculate used balances.
/// Note: The initial balance calculation is a placeholder and needs real business logic.
@riverpod
Future<Map<LeaveType, double>> leaveBalance(LeaveBalanceRef ref) async {
  // Watch the current user data.
  final currentUser = ref.watch(currentUserDataProvider);
  // Watch the provider that supplies the user's leave requests.
  // This establishes a dependency, ensuring this balance provider recalculates
  // when the user's leave requests change.
  final requestsAsync = ref.watch(currentUserLeaveRequestsProvider);

  // If no user is logged in, return an empty balance map.
  if (currentUser == null) return {};

  // --- Placeholder: Initial Balances ---
  // TODO: Replace this with logic fetching balances based on hire date, company policy, accrual rules etc.
  final Map<LeaveType, double> initialBalance = {
    LeaveType.paid: 25.0,
    LeaveType.sick: 10.0,
    LeaveType.special: 5.0,
    LeaveType.unpaid: double.infinity, // Usually not tracked or unlimited.
  };
  // --- End Placeholder ---

  // Initialize map to track used days for each leave type.
  final Map<LeaveType, double> usedBalance = { for (var v in LeaveType.values) v : 0.0 };
  // Determine the relevant period for calculation (e.g., current calendar year).
  final currentYear = DateTime.now().year;

  // --- Correctly handle the AsyncValue from the requests provider ---
  // Use 'await requestsAsync.whenData' to ensure we only process the list
  // once the data is available. This will wait if requestsAsync is loading,
  // and propagate errors if requestsAsync is in an error state.
  requestsAsync.whenData((requests) {
      // Iterate through the fetched leave requests.
      for (var req in requests) {
        // Only count APPROVED requests within the relevant period (current year).
        // Adjust the period logic (e.g., req.startDate.toDate().year == currentYear)
        // based on actual company policy (fiscal year, rolling year, etc.).
        if (req.status == LeaveStatus.approved && req.startDate.toDate().year == currentYear) {
          // Add the number of days from the request to the used balance for that type.
          usedBalance[req.type] = (usedBalance[req.type] ?? 0) + req.days;
        }
      }
  });
  // --- End AsyncValue Handling ---

  // Calculate the final remaining balance.
  final Map<LeaveType, double> remainingBalance = {};
  initialBalance.forEach((type, initial) {
    // Subtract used days from the initial amount.
    double remaining = initial - (usedBalance[type] ?? 0);
    // Prevent negative balances (unless allowed by policy), except for unpaid leave.
    if (remaining < 0 && type != LeaveType.unpaid) remaining = 0;
    // Keep unpaid leave as infinity if it was initially set that way.
    if (type == LeaveType.unpaid) remaining = double.infinity;
    remainingBalance[type] = remaining;
  });

  // Return the calculated map of remaining balances.
  return remainingBalance;
}


// --- Leave Request Controller ---
/// Manages actions related to leave requests: submitting, approving, rejecting, cancelling.
/// Uses AsyncValueNotifier to track the state of these actions (loading, error, success).
@riverpod
class LeaveRequestController extends _$LeaveRequestController {
  @override
  FutureOr<void> build() {
    // Controllers for actions typically don't need initial data loading.
    return null;
  }

  // --- Submit a new leave request ---
  Future<bool> submitLeaveRequest({
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    state = const AsyncLoading(); // Indicate operation started
    final currentUser = ref.read(currentUserDataProvider);
    final service = ref.read(firestoreServiceProvider);

    // --- Input Validation ---
    if (currentUser == null) {
      state = AsyncError("Utilisateur non connecté.", StackTrace.current);
      return false;
    }
    if (endDate.isBefore(startDate)) {
       state = AsyncError("La date de fin ne peut pas être antérieure à la date de début.", StackTrace.current);
       return false;
    }
    if (reason.trim().isEmpty) {
       state = AsyncError("La raison de la demande est obligatoire.", StackTrace.current);
       return false;
    }
    // --- End Validation ---

    // --- Day Calculation (Needs Improvement) ---
    // TODO: Implement accurate business day calculation excluding weekends/holidays.
    int daysDifference = endDate.difference(startDate).inDays + 1;
    double calculatedDays = daysDifference.toDouble();
    // --- End Day Calculation ---

    // --- Optional: Balance Check ---
     try {
        // Await the result of the leaveBalanceProvider future.
        final balanceData = await ref.read(leaveBalanceProvider.future);
        final remaining = balanceData[type] ?? 0;
        // Check if sufficient balance exists (excluding unpaid type).
        if (type != LeaveType.unpaid && calculatedDays > remaining) {
           state = AsyncError("Solde insuffisant (${remaining.toStringAsFixed(1)}j restants).", StackTrace.current);
           return false;
        }
     } catch (e) {
         // Log error if balance check fails, decide whether to proceed.
         print("Avertissement: Impossible de vérifier le solde avant la soumission: $e");
     }
    // --- End Balance Check ---

    // Prepare the new leave request model.
    final newRequest = LeaveRequestModel(
      id: '', // Firestore generates ID.
      userId: currentUser.uid,
      userName: currentUser.nomComplet, // Denormalize for convenience.
      type: type,
      startDate: Timestamp.fromDate(startDate),
      endDate: Timestamp.fromDate(endDate),
      days: calculatedDays,
      reason: reason,
      status: LeaveStatus.pending, // Initial status.
      requestedAt: Timestamp.now(),
    );

    try {
      // Add the request to Firestore.
      await service.addLeaveRequest(newRequest);
      // Invalidate relevant providers to trigger UI updates.
      ref.invalidate(currentUserLeaveRequestsProvider);
      ref.invalidate(leaveBalanceProvider);
      ref.invalidate(pendingLeaveRequestsProvider);
      state = const AsyncData(null); // Indicate success.
      return true;
    } catch (e, stack) {
      state = AsyncError("Erreur lors de la soumission de la demande: $e", stack);
      return false;
    }
  }

   // --- Action a leave request (Approve/Reject) - For Admin/HR ---
   Future<bool> actionLeaveRequest({
        required String requestId,
        required LeaveStatus newStatus, // Must be approved or rejected
        String? rejectionReason, // Required if rejecting
   }) async {
       state = const AsyncLoading();
       final currentUser = ref.read(currentUserDataProvider);
       final service = ref.read(firestoreServiceProvider);

       // --- Authorization and Validation ---
       if (currentUser == null) {
         state = AsyncError("Action impossible: Utilisateur non connecté.", StackTrace.current);
         return false;
       }
       if (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh) {
          state = AsyncError("Action non autorisée.", StackTrace.current);
          return false;
       }
       if (newStatus != LeaveStatus.approved && newStatus != LeaveStatus.rejected) {
         state = AsyncError("Action de statut invalide.", StackTrace.current);
         return false;
       }
        if (newStatus == LeaveStatus.rejected && (rejectionReason == null || rejectionReason.trim().isEmpty)) {
          state = AsyncError("La raison du rejet est obligatoire.", StackTrace.current);
         return false;
        }
        // --- End Authorization and Validation ---

      try {
        // Update the request status in Firestore.
        await service.updateLeaveRequestStatus(
            requestId,
            newStatus,
            currentUser.uid, // Log approver/rejecter ID.
            rejectionReason: rejectionReason
        );
         // Invalidate providers to update UI.
         ref.invalidate(pendingLeaveRequestsProvider); // Request should disappear from pending list.
         ref.invalidate(leaveBalanceProvider); // Balance will change.
         // Consider invalidating the specific user's request list if necessary.
         // ref.invalidate(currentUserLeaveRequestsProvider(userIdOfRequest));

         state = const AsyncData(null); // Indicate success.
         return true;
      } catch (e, stack) {
         state = AsyncError("Erreur lors de l'action sur la demande: $e", stack);
         return false;
      }
   }

    // --- Cancel a PENDING leave request (by the request owner) ---
    Future<bool> cancelLeaveRequest(LeaveRequestModel request) async {
         state = const AsyncLoading();
         final currentUser = ref.read(currentUserDataProvider);
         final service = ref.read(firestoreServiceProvider);

         // --- Authorization and Validation ---
         // Ensure user is logged in and owns the request.
         if (currentUser == null || request.userId != currentUser.uid) {
             state = AsyncError("Annulation non autorisée.", StackTrace.current);
             return false;
         }
         // Ensure the request is actually pending.
         if (request.status != LeaveStatus.pending) {
             state = AsyncError("Seules les demandes en attente peuvent être annulées.", StackTrace.current);
              return false;
         }
         // --- End Authorization and Validation ---

         try {
            // Update status to 'cancelled' in Firestore.
            await service.updateLeaveRequestStatus(
                request.id,
                LeaveStatus.cancelled,
                currentUser.uid, // Log who cancelled.
            );
            // Invalidate relevant providers.
            ref.invalidate(currentUserLeaveRequestsProvider);
            ref.invalidate(leaveBalanceProvider);
            ref.invalidate(pendingLeaveRequestsProvider);

            state = const AsyncData(null); // Indicate success.
            return true;
         } catch (e, stack) {
             state = AsyncError("Erreur lors de l'annulation: $e", stack);
            return false;
         }
    }
}