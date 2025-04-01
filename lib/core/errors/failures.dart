// Base class for failures
abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

// Specific Failures
class ServerFailure extends Failure {
  ServerFailure(String message) : super('Erreur Serveur: $message');
}

class CacheFailure extends Failure {
  CacheFailure() : super('Erreur de Cache');
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('Erreur Réseau: Veuillez vérifier votre connexion.');
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure(String message) : super('Erreur d\'Authentification: $message');
}

class PermissionFailure extends Failure {
  PermissionFailure(String message) : super('Erreur de Permissions: $message');
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure(String message) : super('Erreur Inattendue: $message');
}