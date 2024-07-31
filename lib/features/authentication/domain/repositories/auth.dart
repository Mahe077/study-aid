// auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User?>> signInWithEmail(String email, String password);
  Future<Either<Failure, User?>> signUpWithEmail(
      String email, String password, String username);
  Future<Either<Failure, User?>> signInWithGoogle();
  Future<Either<Failure, User?>> signInWithFacebook();
  Future<Either<Failure, User?>> signInWithApple();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, void>> resetPassword(String newPassword);
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
