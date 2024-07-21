import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';

class SignOut {
  final AuthRepository _authRepository;

  SignOut(this._authRepository);

  Future<Either<Failure, Unit>> call() async {
    try {
      await _authRepository.signOut();
      return const Right(
          unit); // `unit` is a special value used for methods that return no result.
    } on Exception {
      return Left(ServerFailure('Failed to sign out'));
    }
  }
}
