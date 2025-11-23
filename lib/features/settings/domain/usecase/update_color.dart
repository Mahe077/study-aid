import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';

class UpdateUserColorUseCase {
  final UserRepository userRepository;

  UpdateUserColorUseCase(this.userRepository);

  Future<Either<Failure, void>> call(User user) async {
    return await userRepository.updateUser(user);
  }
}
