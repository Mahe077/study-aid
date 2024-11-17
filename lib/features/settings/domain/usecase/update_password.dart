import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';

class UpdateUserPasswordUseCase {
  final UserRepository userRepository;

  UpdateUserPasswordUseCase(this.userRepository);

  Future<Either<Failure, void>> call(String password) async {
    return await userRepository.updatePassword(password);
  }
}
