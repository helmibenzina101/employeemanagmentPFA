import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employeemanagment/core/services/firebase/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this import is present

// Define the firestoreServiceProvider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  // Provide the necessary argument(s) for FirestoreService
  return FirestoreService(FirebaseFirestore.instance); // Assuming FirebaseFirestore is the required argument
});