import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';
import 'package:study_aid/core/error/exceptions.dart';

class SignUpWithEmail {
  final AuthRepository _authRepository;

  SignUpWithEmail(this._authRepository);

  Future<Either<Failure, User?>> call(
      String email, String password, String username) async {
    try {
      // Assuming signUpWithEmail returns User? directly
      final result =
          await _authRepository.signUpWithEmail(email, password, username);
      return result.fold(
        (failure) => Left(failure), // If it's a Left, propagate the Failure
        (user) => Right(user), // If it's a Right, propagate the User
      );
    } on ServerException {
      return Left(ServerFailure('Failed to sign up'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
