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

  void _checkLoginStatus() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Simulate a splash screen delay

    if (!mounted) return;

    final userState = ref.watch(userProvider);

    userState.when(
      data: (user) {
        if (user != null) {
          const Text("User not logged in");
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             HomePage(user:user)));
        } else {
          Logger().i(user);
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const SigninPage()),
          // );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const GetStartedPage()),
        // );
        Logger().e(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    userState.when(
      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user != null) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomePage(user: user)));
          } else {
            Logger().i(user);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SigninPage()),
            );
          }
        });
      },
      loading: () => Logger().i('Loading user data...'),
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
