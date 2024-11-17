import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User?>> getUser(String userId);
  Future<Either<Failure, void>> updateUser(User user);
  Future<Either<Failure, void>> updateCreatedTopic(
      String userId, String topicId);
  Future<Either<Failure, void>> syncUser(String userId);
  Future<void> updateRecentItems(String userId, String itemId, String itemType,
      {bool isDelete = false});
  Future<Either<Failure, void>> updatePassword(String password);
}
