// lib/core/di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
final GetIt getIt = GetIt.instance;

void setupInjection() {
  // Register NetworkInfo (required by files_providers.dart)
  if (!getIt.isRegistered<NetworkInfo>()) {
    getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  }
}
