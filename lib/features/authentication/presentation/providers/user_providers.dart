import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/core/utils/app_logger.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_firabse_service.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:study_aid/features/authentication/data/datasources/auth_local_storage.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';
import 'package:study_aid/features/authentication/domain/usecases/load_user.dart';
import 'package:study_aid/features/authentication/presentation/notifiers/user_notifire.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Data source providers for UserRepository
final userRemoteDataSourceProvider =
    Provider<RemoteDataSource>((ref) => RemoteDataSourceImpl());
final userLocalDataSourceProvider = Provider<LocalDataSource>(
    (ref) => LocalDataSourceImpl(Hive.box<UserModel>('userBox')));
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());
final userBoxProvider = FutureProvider<Box<UserModel>>((ref) async {
  // Check if the box is already open
  if (Hive.isBoxOpen('userBox')) {
    AppLogger.d("userBox is already open");
    return Hive.box<UserModel>('userBox');
  }

  // If the box is not open, open it
  AppLogger.d("Opening userBox...");
  final box = await Hive.openBox<UserModel>('userBox');
  return box;
});

// User Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  final localDataSource = ref.read(localDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return UserRepositoryImpl(
    networkInfo: networkInfo,
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final userProvider = FutureProvider<UserModel?>((ref) async {
  try {
    // Retrieve the user box from the provider
    final userBox = await ref.watch(userBoxProvider.future);

    // Return the first user in the box if it exists
    if (userBox.isNotEmpty) {
      final user = userBox.get(userBox.keys.first);
      return user;
    }

    // No user found in the box
    return null;
  } catch (e, stackTrace) {
    // Log the error with a stack trace for debugging purposes
    AppLogger.e('Error fetching user from Hive: $e', stackTrace: stackTrace);
    return null;
  }
});

final loadUserProvider = Provider<LoadUser>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return LoadUser(repository);
});

final syncUserUseCaseProvider = Provider<SyncUserUseCase>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return SyncUserUseCase(repository);
});

final userNotifierProvider =
    AsyncNotifierProvider<UserNotifier, UserModel?>(() {
  return UserNotifier();
});
