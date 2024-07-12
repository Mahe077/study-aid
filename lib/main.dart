import 'package:flutter/material.dart';
import 'package:study_aid/core/configs/theme/app_theme.dart';
// import 'package:study_aid/pages/editor_page.dart';
// import 'package:study_aid/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_aid/presentation/intro/pages/get_started.dart';
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
  runApp(const MyApp());
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
