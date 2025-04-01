import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:employeemanagment/core/models/announcement_model.dart'; // Corrected import
import 'package:employeemanagment/core/providers/user_providers.dart'; // Corrected import
// Corrected import
import 'package:employeemanagment/core/enums/user_role.dart'; // Corrected import

part 'communication_providers.g.dart'; // For Riverpod Generator


// --- Announcements Stream Provider ---
// Fetches announcements visible to the current user (respecting targetRoles)
@riverpod
Stream<List<AnnouncementModel>> announcementsStream(AnnouncementsStreamRef ref) {
   final currentUser = ref.watch(currentUserDataProvider); // Need user role for filtering
   final service = ref.watch(firestoreServiceProvider);
   // Pass the current user model to the service method for filtering
   return service.getAnnouncementsStream(currentUser);
}


// --- Announcement Controller ---
@riverpod
class AnnouncementController extends _$AnnouncementController {
   @override
   FutureOr<void> build() {
      // No initial state
      return null;
   }

   // Create a new announcement (Admin/HR only)
   Future<bool> createAnnouncement({
       required String title,
       required String content,
       required bool isPinned,
       required List<UserRole>? targetRoles, // List of roles or null for all
   }) async {
       state = const AsyncLoading();
       final currentUser = ref.read(currentUserDataProvider);
       final service = ref.read(firestoreServiceProvider);

       if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
           state = AsyncError("Action non autorisée.", StackTrace.current);
           return false;
       }

       // Convert UserRole enum list to string list for Firestore
       final List<String>? targetRoleStrings = targetRoles?.map((role) => role.name).toList();

       final newAnnouncement = AnnouncementModel(
           id: '', // Firestore generates ID
           title: title,
           content: content,
           authorId: currentUser.uid,
           authorName: currentUser.nomComplet, // Store author name
           createdAt: Timestamp.now(),
           isPinned: isPinned,
           targetRoles: targetRoleStrings,
       );

        try {
          await service.addAnnouncement(newAnnouncement);
          // Invalidate the stream to show the new announcement
          ref.invalidate(announcementsStreamProvider);
          state = const AsyncData(null);
          return true;
        } catch (e, stack) {
           state = AsyncError("Erreur création annonce: $e", stack);
           return false;
        }
   }

    // TODO: Add methods for deleting or editing announcements if needed (Admin/HR)
     Future<bool> deleteAnnouncement(String announcementId) async {
         state = const AsyncLoading();
         final currentUser = ref.read(currentUserDataProvider);
         final service = ref.read(firestoreServiceProvider);

          if (currentUser == null || (currentUser.role != UserRole.admin && currentUser.role != UserRole.rh)) {
            state = AsyncError("Action non autorisée.", StackTrace.current);
            return false;
         }

         try {
           // Need a method in FirestoreService to delete by ID
           // await service.deleteAnnouncement(announcementId);
           print("Placeholder: Delete announcement $announcementId - Implement in FirestoreService");
           // Example: await ref.read(firestoreProvider).collection(FirestoreCollections.announcements).doc(announcementId).delete();

           ref.invalidate(announcementsStreamProvider);
           state = const AsyncData(null);
           return true;
         } catch (e, stack) {
           state = AsyncError("Erreur suppression annonce: $e", stack);
           return false;
         }
     }

}