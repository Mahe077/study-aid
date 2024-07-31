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

class SignInWithGoogle {
  final AuthRepository _authRepository;

  SignInWithGoogle(this._authRepository);

  Future<Either<Failure, User?>> call() async {
    try {
      final result = await _authRepository.signInWithGoogle();
      return result.fold(
        (failure) => Left(failure), // If it's a Left, propagate the Failure
        (user) => Right(user), // If it's a Right, propagate the User
      );
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    }
  }
}

class SignInWithFacebook {
  final AuthRepository _authRepository;

  SignInWithFacebook(this._authRepository);

  Future<Either<Failure, User?>> call() async {
    try {
      final result = await _authRepository.signInWithFacebook();
      return result.fold(
        (failure) => Left(failure), // If it's a Left, propagate the Failure
        (user) => Right(user), // If it's a Right, propagate the User
      );
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    }
  }
}

class SignInWithApple {
  final AuthRepository _authRepository;

  SignInWithApple(this._authRepository);

  Future<Either<Failure, User?>> call() async {
    try {
      final result = await _authRepository.signInWithApple();
      return result.fold(
        (failure) => Left(failure), // If it's a Left, propagate the Failure
        (user) => Right(user), // If it's a Right, propagate the User
      );
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    }
  }
}
