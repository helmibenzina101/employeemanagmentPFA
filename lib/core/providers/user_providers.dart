import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
import 'package:employeemanagment/core/providers/firebase_providers.dart';
import 'package:employeemanagment/core/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

part 'user_providers.g.dart';

// Define the authStateChangesProvider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provides the FirestoreService instance
@Riverpod(keepAlive: true)
FirestoreService firestoreService(FirestoreServiceRef ref) {
  return FirestoreService(ref.watch(firestoreProvider));
}

// Provides the UserModel stream for the currently logged-in user
@riverpod
Stream<UserModel?> currentUserStream(CurrentUserStreamRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  final service = ref.watch(firestoreServiceProvider); // Use the generated provider

  final user = authState.value;
  if (user != null) {
    // Listen to the user's document in Firestore
    return service.getUserStream(user.uid).map((snapshot) => snapshot.data());
  }
  return Stream.value(null); // No user logged in
}

// Provides the current UserModel data (snapshot) - useful for synchronous access
@riverpod
UserModel? currentUserData(CurrentUserDataRef ref) {
   // Watch the stream provider and return its latest data value
   return ref.watch(currentUserStreamProvider).value;
}

// Provider to get a specific user's data by UID (useful for managers/HR viewing profiles)
@riverpod
Stream<UserModel?> userStreamById(UserStreamByIdRef ref, String userId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getUserStream(userId).map((snapshot) => snapshot.data());
}

// Provider to get ALL active users (for Admin/HR lists)
// WARNING: Be mindful of large datasets in production. Implement pagination/filtering if needed.
@riverpod
Stream<List<UserModel>> allActiveUsersStream(AllActiveUsersStreamRef ref) {
   final service = ref.watch(firestoreServiceProvider);
   return service.getAllActiveUsersStream();
}

// Provider to get users managed by the current user (if they are a manager)
@riverpod
Stream<List<UserModel>> managedUsersStream(ManagedUsersStreamRef ref) {
  final currentUser = ref.watch(currentUserDataProvider);
  final service = ref.watch(firestoreServiceProvider);
  if (currentUser != null) {
    return service.getUsersByManagerIdStream(currentUser.uid);
  }
  return Stream.value([]); // Return empty list if no current user or not a manager implicitly
}