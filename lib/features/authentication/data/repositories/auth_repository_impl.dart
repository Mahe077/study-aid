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
    } catch (e) {
      return Left(Failure(e.toString()));
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
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> signInWithGoogle() async {
    try {
      UserModel? user = await remoteDataSource.signInWithGoogle();

      if (user != null) {
        if (await localDataSource.getCachedUser(user.id) == null) {
          // Cache the user data in local storage if not already cached
          await localDataSource.cacheUser(user);
        }
        return Right(user);
      } else {
        return const Right(null);
      }
    } on ServerException {
      return Left(ServerFailure('Failed the google sign-in'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> signInWithFacebook() async {
    try {
      UserModel? user = await remoteDataSource.signInWithFacebook();

      if (user != null) {
        if (await localDataSource.getCachedUser(user.id) == null) {
          // Cache the user data in local storage
          await localDataSource.cacheUser(user);
        }
        return Right(user);
      } else {
        return const Right(null);
      }
    } on ServerException {
      return Left(ServerFailure('Failed to google sign-in'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> signInWithApple() async {
    try {
      UserModel? user = await remoteDataSource.signInWithApple();

      if (user != null) {
        if (await localDataSource.getCachedUser(user.id) == null) {
          // Cache the user data in local storage
          await localDataSource.cacheUser(user);
        }
        return Right(user);
      } else {
        return const Right(null);
      }
    } on ServerException {
      return Left(ServerFailure('Failed the Apple sign-in'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      // Clear the cached user data from local storage
      await localDataSource.clearUser();
      return const Right(
          unit); // `unit` is used to indicate success with no result
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String newPassword) async {
    try {
      await remoteDataSource.resetPassword(newPassword);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
