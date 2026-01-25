import 'package:dartz/dartz.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.deleteAccount();
  }
}
