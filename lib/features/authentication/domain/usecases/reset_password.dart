import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';

class ResetPassword {
  final AuthRepository _repository;

  ResetPassword(this._repository);

  Future<Either<Failure, void>> call(String newPassword) async {
    return await _repository.resetPassword(newPassword);
  }
}
