enum UserRole {
  employe, // Employee
  rh,      // Human Resources
  admin;   // Administrator

  // Helper to convert string from Firestore to enum
  static UserRole fromString(String? role) { // Make nullable for safety
    switch (role?.toLowerCase()) {
      case 'rh':
        return UserRole.rh;
      case 'admin':
        return UserRole.admin;
      case 'employe':
      default: // Default to employee if null or unrecognized
        return UserRole.employe;
    }
  }

  // Helper to convert enum to string for Firestore
  String toJson() => name;

  // Helper for display name (French)
   String get displayName {
    switch (this) {
      case UserRole.employe:
        return 'Employé';
      case UserRole.rh:
        return 'Ressources Humaines';
      case UserRole.admin:
        return 'Administrateur';
    }
  }
}