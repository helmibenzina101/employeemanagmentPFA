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
import 'package:employeemanagment/core/providers/firebase_providers.dart'; // Remove the hide directive

part 'auth_providers.g.dart';

// Define the missing providers
final authServiceProvider = Provider<AuthService>((ref) {
  final auth = FirebaseAuth.instance;
  return AuthService(auth);
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return FirestoreService(firestore);
});

// --- Login Controller ---
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() => null;

  Future<bool> login(String email, String password) async {
      // Only set state to loading if it's not already in a completed state
      if (state is! AsyncData && state is! AsyncError) {
        state = const AsyncLoading();
      }
      
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      
      try {
        print("LoginController: Attempting Firebase Auth sign-in only...");
        final userCredential = await authService.signInWithEmailPassword(email, password);
        
        if (userCredential?.user == null) {
          // Handle null user case
          state = AsyncError('Authentication failed', StackTrace.current);
          return false;
        }
        
        print("LoginController: Firebase Auth successful for ${userCredential!.user!.uid}");
        
        // Get user data from Firestore - make this non-final so we can modify it
        var userData = await firestoreService.getUserData(userCredential.user!.uid);
        
        // Check user status immediately before proceeding further
        if (userData == null) {
          print("LoginController: User data not found in Firestore, signing out");
          await FirebaseAuth.instance.signOut();
          state = AsyncError('Profil utilisateur introuvable', StackTrace.current);
          return false;
        }
        
        // Debug the user role
        print("LoginController: User role is ${userData.role}");
        
        // For admin users, ensure they can log in regardless of status
        if (userData.role.toString() == 'UserRole.admin') {
          print("LoginController: Admin user detected, bypassing all status checks");
          
          // Force status to 'active' for admin users to prevent redirect issues
          if (userData.status != 'active') {
            print("LoginController: Updating admin status from ${userData.status} to active");
            try {
              // Update the admin user's status to active in Firestore
              await FirebaseFirestore.instance.collection('users')
                .doc(userCredential.user!.uid)
                .update({'status': 'active'});
              
              // Update local userData to reflect the change
              userData = userData.copyWith(status: 'active');
            } catch (e) {
              print("LoginController: Failed to update admin status: $e");
              // Continue anyway since we're bypassing checks for admins
            }
          }
        } else {
          // Regular user checks
          if (userData.status == 'pending') {
            print("LoginController: User has pending status, signing out immediately");
            await FirebaseAuth.instance.signOut();
            state = AsyncError("Votre compte est en attente d'approbation par un administrateur", StackTrace.current);
            return false;
          } else if (userData.status != 'active') {
            print("LoginController: User has non-active status, signing out immediately");
            await FirebaseAuth.instance.signOut();
            state = AsyncError("Votre compte a été rejeté", StackTrace.current);
            return false;
          }
        }
        
        // Add null check before accessing isActive
        if (userData != null && !userData.isActive) {
          print("LoginController: User account is inactive, signing out immediately");
          await FirebaseAuth.instance.signOut();
          state = AsyncError('Compte désactivé par un administrateur', StackTrace.current);
          return false;
        }
        
        // Success case - only set state if not already completed
        if (state is! AsyncData) {
          state = const AsyncData(null);
        }
        return true;
      } on FirebaseAuthException catch (e, stackTrace) {
        print("LoginController: FirebaseAuthException during login: ${e.code} - ${e.message}");
        
        // Sign out if there was an error
        try {
          await authService.signOut();
        } catch (_) {}
        
        // Only set error state if not already completed
        if (state is! AsyncData && state is! AsyncError) {
          state = AsyncError('Erreur: ${e.message ?? e.code}', stackTrace);
        }
        return false;
      } catch (e, stackTrace) {
        // Handle errors
        print("LoginController: Generic error during login auth call: $e");
        
        // Sign out if there was an error
        try {
          await authService.signOut();
        } catch (_) {}
        
        // Only set error state if not already completed
        if (state is! AsyncData && state is! AsyncError) {
          state = AsyncError(e.toString(), stackTrace);
        }
        return false;
      }
    }

  // --- sendPasswordReset and logout methods remain the same as previous correct versions ---
   Future<bool> sendPasswordReset(String email) async {
     final authService = ref.read(authServiceProvider);
     state = const AsyncLoading();
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
        final authService = ref.read(authServiceProvider);
        state = const AsyncLoading();
         try {
            await authService.signOut();
            state = const AsyncData(null);
         } catch (e, stackTrace) {
             state = AsyncError('Erreur déconnexion: ${e.toString()}', stackTrace);
         }
    }
    // --- End unchanged methods ---
}

// Rest of the file remains unchanged

// Add this RegisterController class to your auth_providers.dart file
@riverpod
class RegisterController extends _$RegisterController {
  @override
  FutureOr<void> build() => null;

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String poste,
  }) async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    
    try {
      // Step 1: Create Firebase Auth account - we need to create a new user, not sign in
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      
      if (userCredential.user == null) {
        throw Exception("Échec de création du compte utilisateur.");
      }
      
      final uid = userCredential.user!.uid;
      
      // Step 2: Create Firestore user document with pending status
      final newUser = UserModel(
        uid: uid,
        email: email,
        nom: nom,
        prenom: prenom,
        poste: poste,
        role: UserRole.employe,
        status: 'pending', // Requires admin approval
        isActive: true, // Account is active but pending approval
        dateEmbauche: Timestamp.now(),
      );
      
      // Save the user data to Firestore - use a map directly instead of toMap()
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'poste': poste,
        'role': UserRole.employe.toString(),
        'status': 'pending',
        'isActive': true,
        'dateEmbauche': Timestamp.now(),
      });
      
      // Step 3: Sign out the user (they need to wait for approval)
      await authService.signOut();
      
      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError('Erreur lors de l\'inscription: ${e.toString()}', stackTrace);
      return false;
    }
  }
}