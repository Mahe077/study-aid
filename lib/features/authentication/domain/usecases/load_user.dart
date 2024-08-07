import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';

class LoadUser {
  final UserRepository repository;

  LoadUser(this.repository);

  Future<Either<Failure, User?>> call(String userId) async {
    return await repository.getUser(userId);
  }
}

class SyncUserUseCase {
  final UserRepository repository;

  SyncUserUseCase(this.repository);

  Future<void> call(String userId) async {
    final result = await repository.syncUser(userId);
    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}
