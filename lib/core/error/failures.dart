class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class NoInternetFailure extends Failure {
  NoInternetFailure()
      : super(
            'No internet connection. Please connect to the internet and try again.');
}
