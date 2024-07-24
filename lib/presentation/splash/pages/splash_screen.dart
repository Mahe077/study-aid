import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_aid/features/authentication/data/models/user.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/presentation/home/pages/home.dart';
import 'package:study_aid/presentation/intro/pages/get_started.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    _controller!.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Simulate a splash screen delay

    if (!mounted) return;

    final userBox = Hive.box<UserModel>('userBox');

// To check if the box is already open
    if (!Hive.isBoxOpen('userBox')) {
      // Open the box if it's not already open
      await Hive.openBox<UserModel>('userBox');
    }
    if (userBox.isNotEmpty) {
      final user = userBox.getAt(0);
      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(username: user.username)));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SigninPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation!,
        child: Center(
          child: SvgPicture.asset(
            'assets/vectors/spotify_logo.svg',
          ),
        ),
      ),
    );
  }
}
