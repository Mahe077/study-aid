// lib/core/di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

final GetIt getIt = GetIt.instance;

void setupInjection() {
  // Register NetworkInfo (required by files_providers.dart)
  if (!getIt.isRegistered<NetworkInfo>()) {
    getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  }
}
