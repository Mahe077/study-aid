import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
            User updatedUser;
            if (user.createdTopics.contains(topicId)) {
              updatedUser = user.copyWith(
                createdTopics: user.createdTopics
                    .where((topic) => topic != topicId)
                    .toList(),
              );
            } else {
              updatedUser = user.copyWith(
                createdTopics: [...user.createdTopics, topicId],
              );
            }
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

      // Compare updatedDate to decide whether to sync
      if (localUser != null &&
          localUser.updatedDate.isAfter(localUser.updatedDate)) {
        // Local topic is newer, update the remote topic
        await remoteDataSource.updateUser(localUser);
        // Update the local copy to ensure sync status is correct
        await localDataSource
            .updateUser(localUser.copyWith(syncStatus: ConstantStrings.synced));
      } else if (localUser != null &&
          localUser.updatedDate.isAfter(localUser.updatedDate)) {
        // Remote topic is newer, update the local topic
        await localDataSource
            .updateUser(localUser.copyWith(syncStatus: ConstantStrings.synced));
      }

      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // Helper method to update recent items
  @override
  Future<void> updateRecentItems(String userId, String itemId, String itemType,
      {bool isDelete = false}) async {
    try {
      var localUser = await localDataSource.getCachedUser(userId);

      if (localUser != null) {
        List<Map<String, dynamic>> recentItems =
            List.from(localUser.recentItems);

        // Remove the item if it already exists in the list
        recentItems.removeWhere(
            (item) => item['id'] == itemId && item['type'] == itemType);

        // If the list exceeds 10 items, remove the oldest (last) item
        if (recentItems.length >= 10) {
          recentItems.removeAt(recentItems.length - 1);
        }

        if (!isDelete) {
          recentItems = [
            {'id': itemId, 'type': itemType},
            ...recentItems
          ];
          // recentItems.insert(0, {'id': itemId, 'type': itemType});
        }

        var newUser = localUser.copyWith(recentItems: recentItems);

        if (await networkInfo.isConnected) {
          newUser = newUser.copyWith(syncStatus: ConstantStrings.synced);
          await remoteDataSource.updateUser(UserModel.fromEntity(newUser));
        } else {
          newUser = newUser.copyWith(syncStatus: ConstantStrings.pending);
        }
        await localDataSource.updateUser(newUser);
      }
    } on Exception catch (e) {
      Logger().e("Error updating recent items: $e");
      // Handle any other specific errors if needed
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String password) async {
    try {
      if (await networkInfo.isConnected) {
        final res = await remoteDataSource.updatePassword(password);
        return res;
      } else {
        return Left(NoInternetFailure());
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateColor(User user) async {
    try {
      var userModel = UserModel.fromEntity(user);
      if (await networkInfo.isConnected) {
        final res = await remoteDataSource.updateColor(userModel);
        return res;
      } else {
        return Left(NoInternetFailure());
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
