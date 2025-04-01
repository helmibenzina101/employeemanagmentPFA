import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeemanagment/core/enums/user_role.dart'; // Ensure this path is correct

/// Represents the data structure for a user in Firestore.
class UserModel {
  final String uid;
  final String email;
  final String nom; // Last Name
  final String prenom; // First Name
  final String poste; // Job Title
  final String? telephone; // Optional phone number
  final UserRole role; // Final role assigned (Employe, RH, Admin)
  final String? managerUid; // Optional UID of direct manager
  final Timestamp dateEmbauche; // Hiring/Creation date
  final bool isActive; // Is the account allowed to log in? (Set by Admin)
  final String status; // Approval status: 'pending', 'active', 'rejected'

  UserModel({
    required this.uid,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.poste,
    this.telephone,
    this.role = UserRole.employe, // Default initial role before approval
    this.managerUid,
    required this.dateEmbauche,
    this.isActive = false, // Users start as inactive
    this.status = 'pending', // Users start as pending approval
  });

  /// Returns the user's full name.
  String get nomComplet => '$prenom $nom';

  /// Returns the user's initials (e.g., "PN" for "Pierre Nom").
  String get initials => (prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : '');

  /// Creates a UserModel instance from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    // Throw an error if data is unexpectedly null.
    if (data == null) throw Exception("User data is null for ID: ${snapshot.id}");

    return UserModel(
      uid: snapshot.id,
      email: data['email'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      poste: data['poste'] ?? '',
      telephone: data['telephone'], // Nullable
      role: UserRole.fromString(data['role']), // Use enum helper
      managerUid: data['managerUid'], // Nullable
      // Ensure dateEmbauche is a Timestamp, provide default if missing/wrong type.
      dateEmbauche: data['dateEmbauche'] is Timestamp ? data['dateEmbauche'] : Timestamp.now(),
      isActive: data['isActive'] ?? false, // Default to false if missing
      status: data['status'] ?? 'pending', // Default to 'pending' if missing
    );
  }

  /// Converts the UserModel instance to a Map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      // uid is the document ID, not usually stored as a field within the doc
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'poste': poste,
      if (telephone != null) 'telephone': telephone,
      'role': role.toJson(), // Convert enum to string using helper
      if (managerUid != null) 'managerUid': managerUid,
      'dateEmbauche': dateEmbauche,
      'isActive': isActive,
      'status': status,
    };
  }

  /// Creates a copy of the UserModel with optional updated field values.
  UserModel copyWith({
    String? uid, String? email, String? nom, String? prenom, String? poste,
    String? telephone, UserRole? role, String? managerUid,
    Timestamp? dateEmbauche, bool? isActive, String? status,
  }) {
    return UserModel(
      uid: uid ?? this.uid, email: email ?? this.email, nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom, poste: poste ?? this.poste,
      telephone: telephone ?? this.telephone, role: role ?? this.role,
      managerUid: managerUid ?? this.managerUid, dateEmbauche: dateEmbauche ?? this.dateEmbauche,
      isActive: isActive ?? this.isActive, status: status ?? this.status,
    );
  }
}