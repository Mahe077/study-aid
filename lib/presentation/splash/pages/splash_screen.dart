// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
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
    // _checkLoginStatus();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    userState.when(
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user == null) {
            // If user is null, check if the box exists
            final userBox = ref.watch(userBoxProvider).value;
            if (userBox == null || userBox.isEmpty) {
              // If the userBox is empty, navigate to the Welcome page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GetStartedPage()),
              );
            } else {
              // If userBox exists but no user, navigate to the Sign-In page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SigninPage()),
              );
            }
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePage(user: user)));
          }
        });
      },
      loading: () => {
        const Center(child: CircularProgressIndicator()),
        // Logger().i('Loading user data...')
      },
      error: (e, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GetStartedPage()),
          );
        });
        Logger().e('Error loading user data: $e');
      },
    );

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
