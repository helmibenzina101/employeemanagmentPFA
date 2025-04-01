import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Only needed if deleting Auth user

// Core Imports
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
// Don't need direct firebase_provider import if not doing rollback

part 'admin_providers.g.dart';

// --- Provider to get pending users ---
/// Provides a stream of users whose status is 'pending'. Requires Firestore index.
@riverpod
Stream<List<UserModel>> pendingUsersStream(PendingUsersStreamRef ref) {
  // TODO: Add authorization check - only Admin/HR should access this
  final service = ref.watch(firestoreServiceProvider);
  // Call the new service method (ensure Firestore index exists)
  return service.getUsersByStatusStream('pending');
}

// --- Controller for Admin actions on users ---
@riverpod
class UserManagementController extends _$UserManagementController {
    bool _isOperationInProgress = false; // Mutex flag

    @override
    FutureOr<void> build() {
      // Listen to self to reset mutex on completion/error
      ref.listenSelf((previous, next) {
          if (previous is AsyncLoading && next is! AsyncLoading) {
              _isOperationInProgress = false;
              print("Admin operation finished, mutex released.");
          }
      });
      return null;
    }

    // --- Update Existing User Method (Admin/HR) ---
    Future<void> updateUserAdmin({
        required String userId, required UserRole newRole, required bool isActive,
        required String? managerUid, required String poste,
    }) async {
        if (_isOperationInProgress) return; _isOperationInProgress = true;
        state = const AsyncLoading();
        final currentUser = ref.read(currentUserDataProvider);
        final service = ref.read(firestoreServiceProvider);
        try {
            // Authorization Checks
           if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
              throw Exception("Action non autorisée.");
           }
           if (currentUser.uid == userId && (!isActive || newRole != currentUser.role)) {
               throw Exception("Vous ne pouvez pas désactiver ou changer votre propre rôle ici.");
           }
           // Prepare and execute update
           final Map<String, dynamic> updateData = {
               'role': newRole.name, 'isActive': isActive,
               'managerUid': managerUid, 'poste': poste,
           };
           await service.updateUserPartial(userId, updateData);
           // Invalidate caches
           ref.invalidate(allActiveUsersStreamProvider);
           ref.invalidate(userStreamByIdProvider(userId));
           if (userId == currentUser.uid) {
              ref.invalidate(currentUserStreamProvider);
              ref.invalidate(currentUserDataProvider);
           }
           state = const AsyncData(null); // Set success state
        } catch (e, stack) {
            state = AsyncError("Erreur mise à jour: $e", stack);
        } finally {
             // Ensure mutex is released if listenSelf didn't catch it (e.g., immediate error)
             // However, listenSelf should handle this when state changes from loading.
             // _isOperationInProgress = false; // Usually handled by listenSelf
        }
    }

    // --- Approve Pending User Method (Admin/HR) ---
    /// Approves a pending user, activating their account and assigning the final role.
    Future<void> approveUser(String userId, UserRole assignedRole) async {
        if (_isOperationInProgress) return; _isOperationInProgress = true;
        state = const AsyncLoading();
        final currentUser = ref.read(currentUserDataProvider); // User performing approval
        final service = ref.read(firestoreServiceProvider);
        try {
            // Authorization Check
            if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
                throw Exception("Approbation non autorisée.");
            }
            // Prepare data for approval update
            final Map<String, dynamic> approvalData = {
               'status': 'active',   // Change status
               'isActive': true,    // Activate the account
               'role': assignedRole.name, // Assign the final role chosen by admin
               // Optionally update dateEmbauche to approval date? Or keep registration date?
               // 'dateEmbauche': Timestamp.now(),
            };
            // Update the user document in Firestore
            await service.updateUserPartial(userId, approvalData);
            // Invalidate providers to refresh lists
            ref.invalidate(pendingUsersStreamProvider); // Remove from pending list
            ref.invalidate(allActiveUsersStreamProvider); // Should now appear in active list
            ref.invalidate(userStreamByIdProvider(userId)); // Update specific user view if open
            state = const AsyncData(null); // Success state
        } catch (e, stack) {
            state = AsyncError("Erreur approbation: $e", stack);
        }
        // Mutex reset by listenSelf
    }

     // --- Reject Pending User Method (Admin/HR) ---
     /// Rejects a pending user registration. Keeps account inactive.
     Future<void> rejectUser(String userId, {String reason = "Demande rejetée."}) async {
          if (_isOperationInProgress) return; _isOperationInProgress = true;
          state = const AsyncLoading();
          final currentUser = ref.read(currentUserDataProvider);
          final service = ref.read(firestoreServiceProvider);
           try {
               // Authorization Check
              if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
                 throw Exception("Rejet non autorisé.");
              }
              // Prepare data for rejection update
              final Map<String, dynamic> rejectionData = {
                 'status': 'rejected', // Change status
                 'isActive': false, // Ensure account remains inactive
                 // Optionally add a rejection reason field if needed in UserModel/Firestore
                 // 'rejectionReason': reason,
              };
              await service.updateUserPartial(userId, rejectionData);
              // Invalidate pending list to remove the user
              ref.invalidate(pendingUsersStreamProvider);
              ref.invalidate(userStreamByIdProvider(userId)); // Update specific view
              state = const AsyncData(null); // Success state
           } catch (e, stack) {
              state = AsyncError("Erreur rejet: $e", stack);
           }
           // Mutex reset by listenSelf
     }

     // --- Create User Method - REMOVED ---
     // The insecure client-side creation method is removed in favor of the approval flow.
     // Keep the method signature commented out if needed for reference to Cloud Function migration.
     /*
     Future<void> createUser({ ... }) async {
        // Implementation replaced by Admin Approval Flow + User Self-Registration
     }
     */

     // TODO: Implement User Deletion securely (likely requires Cloud Function / Admin SDK)
}