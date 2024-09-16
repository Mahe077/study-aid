import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/common/providers/sync_provider.dart';
import 'package:study_aid/core/di/injector.dart';
import 'package:study_aid/core/hive/hive_adapters.dart';
import 'package:study_aid/core/utils/theme/app_theme.dart';
// import 'package:study_aid/pages/editor_page.dart';
// import 'package:study_aid/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/topics/data/models/topic.dart';
import 'package:study_aid/presentation/splash/pages/splash_screen.dart';
// import 'package:study_aid/widgets/note_taking_canvas.dart';
// import 'package:study_aid/widgets/v3.dart';
// import 'package:study_aid/widgets/v4.dart';
// import 'package:study_aid/widgets/v5.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Hive
  await Hive.initFlutter();

  // Register TypeAdapters
  HiveAdapters.registerAdapters();

  // Initialize Hive boxes
  if (!Hive.isBoxOpen('userBox')) {
    await Hive.openBox<UserModel>('userBox');
  }

  if (!Hive.isBoxOpen('topicBox')) {
    await Hive.openBox<TopicModel>('topicBox');
  }

  setupInjection();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Triggering sync on app startup
    final userAsyncValue = ref.watch(userProvider);

    userAsyncValue.whenData((user) {
      if (user != null) {
        ref.read(syncProvider).syncAll(user.id);
      }
    });

    return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen());
  }
}
