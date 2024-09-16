import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_firabse_service.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_local_storage.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.networkInfo,
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User?>> getUser(String userId) async {
    try {
      // Try to get the user from local storage
      UserModel? user = await localDataSource.getCachedUser(userId);
      if (user != null) {
        return Right(user);
      } else if (await networkInfo.isConnected) {
        // If not found locally, fetch from Firestore
        user = await remoteDataSource.getUserById(userId);
        if (user != null) {
          // Cache the user locally
          await localDataSource.cacheUser(user);
          return Right(user);
        } else {
          return Left(
              Failure("Unable to find the user. Please try again later!"));
        }
      } else {
        return Left(Failure("No internet connection. Please try again later!"));
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(User user) async {
    try {
      if (await networkInfo.isConnected) {
        user = user.copyWith(syncStatus: ConstantStrings.synced);
        await remoteDataSource.updateUser(UserModel.fromEntity(user));
      } else {
        user = user.copyWith(syncStatus: ConstantStrings.pending);
      }
      await localDataSource.updateUser(user);

      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCreatedTopic(
      String userId, String topicId) async {
    try {
      final userResult = await getUser(userId);
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user != null) {
            final updatedUser = user.copyWith(
              createdTopics: [...user.createdTopics, topicId],
            );
            final updateResult = await updateUser(updatedUser);
            return updateResult.fold(
              (failure) => Left(failure),
              (_) => const Right(null),
            );
          } else {
            return Left(Failure("User not found."));
          }
        },
      );
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncUser(String userId) async {
    try {
      var localUser = await localDataSource.getCachedUser(userId);

      if (localUser != null &&
          localUser.syncStatus == ConstantStrings.pending) {
        localUser = localUser.copyWith(syncStatus: ConstantStrings.synced);
        await remoteDataSource.updateUser(localUser);
        await localDataSource.updateUser(localUser);
      }

      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
