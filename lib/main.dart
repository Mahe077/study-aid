import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/core/di/injector.dart';
import 'package:study_aid/core/utils/theme/app_theme.dart';
// import 'package:study_aid/pages/editor_page.dart';
// import 'package:study_aid/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/presentation/intro/pages/get_started.dart';
// import 'package:study_aid/widgets/note_taking_canvas.dart';
// import 'package:study_aid/widgets/v3.dart';
// import 'package:study_aid/widgets/v4.dart';
// import 'package:study_aid/widgets/v5.dart';
import 'firebase_options.dart';

void main() async {
  EmailOTP.config(
    appName: 'Study-Aid',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v2,
    appEmail: 'lucky0768546372@gmail.com',
    otpLength: 5,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Hive
  await Hive.initFlutter();

  // Register TypeAdapters
  Hive.registerAdapter(UserModelAdapter());

  // Open the Hive box
  if (!Hive.isBoxOpen('userBox')) {
    await Hive.openBox<UserModel>('userBox');
  }

  setupInjection();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const GetStartedPage());
  }
}
