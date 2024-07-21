import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';

import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';

class SignInWithEmail {
  final AuthRepository _authRepository;

  SignInWithEmail(this._authRepository);

  Future<Either<Failure, User?>> call(String email, String password) async {
    try {
      final result = await _authRepository.signInWithEmail(email, password);
      return result.fold(
        (failure) => Left(failure), // If it's a Left, propagate the Failure
        (user) => Right(user), // If it's a Right, propagate the User
      );
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    }
  }
}
