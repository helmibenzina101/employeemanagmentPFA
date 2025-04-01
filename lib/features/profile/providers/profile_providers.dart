import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp

// Core imports
import 'package:employeemanagment/core/models/document_metadata_model.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';

part 'profile_providers.g.dart'; // For Riverpod Generator

// --- Profile Editing Controller ---
@riverpod
class ProfileEditController extends _$ProfileEditController {
  @override
  FutureOr<void> build() {
    // No initial state needed
    return null;
  }

  Future<bool> updateUserProfile(String userId, {
    required String nom,
    required String prenom,
    required String poste,
    required String? telephone,
  }) async {
    state = const AsyncLoading();
    final firestoreService = ref.read(firestoreServiceProvider);

    final Map<String, dynamic> updateData = {
      'nom': nom,
      'prenom': prenom,
      'poste': poste,
      'telephone': telephone, // Handles null correctly
    };

    try {
      // Use the correctly named method from FirestoreService
      await firestoreService.updateUserPartial(userId, updateData);
      ref.invalidate(currentUserStreamProvider);
      ref.invalidate(currentUserDataProvider);
      // Also invalidate the specific user stream if it might be watched elsewhere
      ref.invalidate(userStreamByIdProvider(userId));
      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      state = AsyncError("Erreur lors de la mise à jour du profil: $e", stack);
      return false;
    }
  }
}


// --- Document Metadata Providers ---

// Provider to get document metadata stream for a specific user
@riverpod
Stream<List<DocumentMetadataModel>> userDocumentsStream(UserDocumentsStreamRef ref, String userId) {
  final service = ref.watch(firestoreServiceProvider);
  // Use the correctly named method from FirestoreService
  return service.getDocumentsForUserStream(userId);
}

// Controller for managing document metadata (Add/Delete - Primarily for HR/Admin)
@riverpod
class DocumentMetadataController extends _$DocumentMetadataController {
   @override
   FutureOr<void> build() {
     // No initial state needed
     return null;
   }

   // Add document metadata entry
   Future<bool> addDocumentMetadata({
        required String userId,
        required String documentName,
        required DocumentType type,
        required String uploadedByUid, // Log who added the entry
        Timestamp? expiryDate, // Optional expiry date
   }) async {
      state = const AsyncLoading();
      final service = ref.read(firestoreServiceProvider);
      final newDoc = DocumentMetadataModel(
        id: '', // Placeholder ID for creation, Firestore generates it
        userId: userId,
        documentName: documentName,
        type: type,
        uploadDate: Timestamp.now(), // Use imported Timestamp
        uploadedByUid: uploadedByUid,
        expiryDate: expiryDate, // Pass expiry date if provided
      );

       try {
         // Use the correctly named method from FirestoreService
         await service.addDocumentMetadata(newDoc);
         ref.invalidate(userDocumentsStreamProvider(userId));
         state = const AsyncData(null);
         return true;
       } catch (e, stack) {
          state = AsyncError("Erreur ajout métadonnée: $e", stack);
          return false;
       }
   }

   // Delete document metadata entry
    Future<bool> deleteDocumentMetadata(String docId, String userId) async {
      state = const AsyncLoading();
      final service = ref.read(firestoreServiceProvider);
        try {
         // Use the correctly named method from FirestoreService
         await service.deleteDocumentMetadata(docId);
         ref.invalidate(userDocumentsStreamProvider(userId));
         state = const AsyncData(null);
         return true;
       } catch (e, stack) {
          state = AsyncError("Erreur suppression métadonnée: $e", stack);
          return false;
       }
    }
}