// Define custom exception classes
class CustomException implements Exception {
  final String message;
  CustomException(this.message);

  @override
  String toString() => 'study_app:: $message';
}

class NetworkException extends CustomException {
  NetworkException(super.message);
}

class DatabaseException extends CustomException {
  DatabaseException(super.message);
}

class ServerException extends CustomException {
  ServerException(super.message);
}

class CacheException extends CustomException {
  CacheException(super.message);
}
