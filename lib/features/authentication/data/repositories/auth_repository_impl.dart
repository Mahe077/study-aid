import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/exceptions.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_firabse_service.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_local_storage.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User?>> signInWithEmail(
      String email, String password) async {
    try {
      UserModel user = await remoteDataSource.signInWithEmail(email, password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Failed to sign in'));
    }
  }

  @override
  Future<Either<Failure, User?>> signUpWithEmail(
      String email, String password, String username) async {
    try {
      UserModel user =
          await remoteDataSource.signUpWithEmail(email, password, username);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure('Failed to sign up'));
    }
  }

  @override
  Future<Either<Failure, User?>> signInWithGoogle() async {
    // Implement Google sign-in logic
    return Left(ServerFailure('Google sign-in not implemented yet'));
  }

  @override
  Future<Either<Failure, User?>> signInWithFacebook() async {
    // Implement Facebook sign-in logic
    return Left(ServerFailure('Facebook sign-in not implemented yet'));
  }

  @override
  Future<Either<Failure, User?>> signInWithApple() async {
    // Implement Apple sign-in logic
    return Left(ServerFailure('Apple sign-in not implemented yet'));
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(
          unit); // `unit` is used to indicate success with no result
    } catch (e) {
      return Left(ServerFailure('Failed to sign out'));
    }
  }
}
