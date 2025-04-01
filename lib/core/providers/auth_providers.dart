import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Core Imports
import 'package:employeemanagment/core/models/user_model.dart';
import 'package:employeemanagment/core/enums/user_role.dart';
import 'package:employeemanagment/core/providers/user_providers.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
import 'package:employeemanagment/core/services/firebase/auth_service.dart';
// Remove circular import
// import 'package:employeemanagment/core/providers/auth_providers.dart';
import 'package:employeemanagment/core/providers/firebase_providers.dart' hide firebaseAuthProvider;

part 'auth_providers.g.dart';

// Define the authServiceProvider
final authServiceProvider = Provider<AuthService>((ref) {
  final auth = FirebaseAuth.instance;
  return AuthService(auth);
});

// --- Login Controller ---
@riverpod
class LoginController extends _$LoginController {
  // No mutex needed for this simplified version

  @override
  FutureOr<void> build() {
    // No specific build logic needed here. Initial state is determined by first call.
    return null;
  }

  // --- SIMPLIFIED Login Method ---
  /// Attempts ONLY Firebase Authentication. Returns true on Auth success, false on Auth failure.
  /// DOES NOT check Firestore status here. That check is moved to GoRouter redirect/DashboardScreen.
  Future<bool> login(String email, String password) async { // Return bool
    state = const AsyncLoading(); // Set loading state
    final authService = ref.read(authServiceProvider);

    try {
      print("LoginController: Attempting Firebase Auth sign-in only...");
      final userCredential = await authService.signInWithEmailPassword(email, password);

      // Check ONLY if Firebase Auth returned a user
      if (userCredential?.user != null) {
        print("LoginController: Firebase Auth successful for ${userCredential!.user!.uid}");
        state = const AsyncData(null); // Indicate Auth success in provider state
        return true; // Return true: Auth succeeded
      } else {
         print("LoginController: Firebase Auth returned null user credential without throwing.");
         state = AsyncError('Auth failed (null credential).', StackTrace.current);
         return false; // Return false: Auth failed
      }
    } on FirebaseAuthException catch(e, stackTrace) {
        // Catch specific Firebase Auth errors
        print("LoginController: FirebaseAuthException during login: ${e.code} - ${e.message}");
        state = AsyncError('Erreur: ${e.message ?? e.code}', stackTrace);
        return false; // Return false: Auth failed
    } catch (e, stackTrace) {
      // Catch any other unexpected errors during the auth call itself
      print("LoginController: Generic error during login auth call: $e");
      state = AsyncError('Erreur de connexion inconnue: ${e.toString()}', stackTrace);
      return false; // Return false: Auth failed
    }
    // No finally needed here
  }
  // --- End SIMPLIFIED Login Method ---


  // --- sendPasswordReset and logout methods ---
   Future<bool> sendPasswordReset(String email) async {
     state = const AsyncLoading();
     final authService = ref.read(authServiceProvider);
     try {
       await authService.sendPasswordResetEmail(email);
       state = const AsyncData(null);
       return true;
     } catch (e, stackTrace) {
       state = AsyncError('Erreur envoi e-mail: ${e.toString()}', stackTrace);
       return false;
     }
   }

    Future<void> logout() async {
        state = const AsyncLoading();
        final authService = ref.read(authServiceProvider);
         try {
            print("LoginController: Attempting sign out.");
            await authService.signOut();
            print("LoginController: Sign out successful.");
            state = const AsyncData(null);
         } catch (e, stackTrace) {
             print("LoginController: Error during sign out: $e");
             state = AsyncError('Erreur déconnexion: ${e.toString()}', stackTrace);
         }
    }
}


// --- Registration Controller (Unchanged from previous correct version) ---
@riverpod
class RegisterController extends _$RegisterController {
  bool _isOperationInProgress = false; // Mutex

  @override
  FutureOr<void> build() {
    ref.listenSelf((previous, next) {
        if (previous is AsyncLoading && next is! AsyncLoading) {
            _isOperationInProgress = false; print("Registration finished.");
        }
    });
    return null;
  }

  Future<void> register({ // Returns void
    required String email, required String password, required String nom,
    required String prenom, required String poste,
  }) async {
    if (_isOperationInProgress) { print("Registration already in progress."); return; }
    _isOperationInProgress = true; print("Registration started.");
    state = const AsyncLoading();

    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    User? createdUser;

    try {
      final userCredential = await authService.signUpWithEmailPassword(email, password);
      if (userCredential?.user == null) throw FirebaseAuthException(code: 'user-creation-failed');
      createdUser = userCredential!.user!;
      print("Auth user created: ${createdUser.uid}");

      final newUser = UserModel(
          uid: createdUser.uid, email: email, nom: nom, prenom: prenom, poste: poste,
          role: UserRole.employe, dateEmbauche: Timestamp.now(), isActive: false, status: 'pending',
          managerUid: null, telephone: null,
      );
      await firestoreService.setUserData(newUser);
      print("Firestore document created for pending user: ${createdUser.uid}");

      // Attempt immediate sign-out
      try { if (FirebaseAuth.instance.currentUser?.uid == createdUser.uid) await authService.signOut(); } catch (_) {}

      state = const AsyncData(null); // Success (pending created)
    } catch (error, stack) {
      print("Registration Error: $error");
      if (createdUser != null) { // Basic Rollback Attempt
          try { await createdUser.delete(); print("Auth user deleted after error.");}
          catch (e) { print("Failed delete: $e");}
      }
      state = AsyncError("Erreur d'inscription: ${error.toString()}", stack); // Final error state
    } finally {
        _isOperationInProgress = false; // Reset mutex in finally
        print("Registration operation finished, mutex released.");
    }
  }
}