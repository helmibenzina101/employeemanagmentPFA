import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  // Stream to listen for authentication changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user (synchronous)
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., user-not-found, wrong-password)
      print("Erreur de connexion: ${e.message}"); // Log or show user-friendly message
      rethrow; // Rethrow to allow proper error handling in the calling code
    }
  }

  // Sign up with email and password (Basic - needs linking to user profile creation)
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
     try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // IMPORTANT: After successful sign up, you MUST create a corresponding
      // user document in Firestore (in FirestoreService) with role, name, etc.
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Erreur d'inscription: ${e.code} - ${e.message}");
      rethrow; // Rethrow to allow proper error handling in the calling code
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Erreur de déconnexion: $e");
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      // Optionally show a confirmation message
    } on FirebaseAuthException catch (e) {
      print("Erreur de réinitialisation mdp: ${e.code} - ${e.message}");
      rethrow; // Rethrow to allow proper error handling in the calling code
    }
  }
}