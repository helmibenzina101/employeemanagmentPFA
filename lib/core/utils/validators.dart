class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse e-mail est requise.';
    }
    // Basic email regex (consider a more robust one for production)
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse e-mail valide.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis.';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    // Add more complexity rules if needed (uppercase, number, symbol)
    return null;
  }

   static String? confirmPassword(String? password, String? confirmPassword) {
     if (confirmPassword == null || confirmPassword.isEmpty) {
       return 'Veuillez confirmer le mot de passe.';
     }
     if (password != confirmPassword) {
       return 'Les mots de passe ne correspondent pas.';
     }
     return null;
   }

  static String? notEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ne peut pas être vide.';
    }
    return null;
  }

   static String? isNumber(String? value, String fieldName) {
     if (value == null || value.isEmpty) {
        return '$fieldName est requis.';
     }
     if (double.tryParse(value) == null) {
       return '$fieldName doit être un nombre.';
     }
     return null;
   }

    static String? isPositiveNumber(String? value, String fieldName) {
     final numberError = isNumber(value, fieldName);
     if (numberError != null) return numberError;

     if (double.parse(value!) <= 0) {
        return '$fieldName doit être un nombre positif.';
     }
     return null;
   }
}