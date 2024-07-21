import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_firabse_service.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_local_storage.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:study_aid/features/authentication/domain/repositories/auth.dart';
import 'package:study_aid/features/authentication/domain/usecases/signin.dart';
import 'package:study_aid/features/authentication/domain/usecases/signout.dart';
import 'package:study_aid/features/authentication/domain/usecases/signup.dart';

// Data source providers
final remoteDataSourceProvider =
    Provider<RemoteDataSource>((ref) => RemoteDataSourceImpl());
final localDataSourceProvider = Provider<LocalDataSource>(
    (ref) => LocalDataSourceImpl(Hive.box<UserModel>('userBox')));

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  final localDataSource = ref.read(localDataSourceProvider);
  return AuthRepositoryImpl(
      remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

// Use case providers
final signInWithEmailProvider =
    Provider((ref) => SignInWithEmail(ref.read(authRepositoryProvider)));
final signUpWithEmailProvider =
    Provider((ref) => SignUpWithEmail(ref.read(authRepositoryProvider)));

final signOutProvider = Provider<SignOut>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SignOut(authRepository);
});

// Providers for other use cases
