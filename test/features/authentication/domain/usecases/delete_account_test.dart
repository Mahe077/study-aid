import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';
import 'package:study_aid/features/authentication/domain/usecases/delete_account.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';

// Manual Mock for AuthRepository
class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    if (shouldFail) {
      return Left(ServerFailure('Delete failed'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String newPassword) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> signInWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> signInWithFacebook() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User?>> signUpWithEmail(String email, String password, String username) async {
    throw UnimplementedError();
  }
}

void main() {
  late DeleteAccountUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = DeleteAccountUseCase(mockAuthRepository);
  });

  test('should call deleteAccount on the repository', () async {
    // act
    final result = await usecase();

    // assert
    expect(result, const Right(unit));
  });

  test('should return failure when deleteAccount fails', () async {
    // arrange
    mockAuthRepository.shouldFail = true;

    // act
    final result = await usecase();

    // assert
    expect(result, isA<Left<Failure, Unit>>());
  });
}
