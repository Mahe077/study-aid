import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';

final ProviderContainer providerContainer = ProviderContainer(
  overrides: [],
);

void setupInjection() {
  authRepositoryProvider;
  // Initialization code if needed
}
