import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/core/utils/assets/app_vectors.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';
import 'package:study_aid/presentation/home/pages/home.dart';
import 'package:study_aid/features/authentication/presentation/pages/revcovery_email.dart';
import 'package:study_aid/features/authentication/presentation/pages/signup.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _password = TextEditingController();

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
      // appBar: const BasicAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(AppVectors.logo),
                  const SizedBox(
                    height: 15,
                  ),
                  _welcomeText(),
                ],
              ),
            ),
            const SizedBox(height: 35),
            _emailField(context),
            const SizedBox(height: 20),
            _passwordField(context),
            _forgotpassword(),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: () =>
                  _signInClicked(context, AuthMethod.emailAndPassword),
              title: "Log In",
            ),
            const SizedBox(height: 20),
            _alternative(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  onPressed: () => _signInClicked(context, AuthMethod.google),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.facebookF,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  onPressed: () => _signInClicked(context, AuthMethod.facebook),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.apple,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: () => _signInClicked(context, AuthMethod.apple),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signInClicked(BuildContext context, AuthMethod authType) async {
    dartz.Either result;

    switch (authType) {
      case AuthMethod.emailAndPassword:
        result = await ref.read(signInWithEmailProvider).call(
              _email.text.toString(),
              _password.text.toString(),
            );
        break;
      case AuthMethod.google:
        result = await ref.read(signInWithGoogleProvider).call();
        break;
      case AuthMethod.facebook:
        result = await ref.read(signInWithFacebookProvider).call();
        break;
      case AuthMethod.apple:
        result = await ref.read(signInWithAppleProvider).call();
        break;
      default:
        result = const dartz.Left('Invalid authentication method');
    }

    result.fold(
      (l) {
        Logger().e(l);
        var snackbar = SnackBar(
          content: Text(l.message),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      (r) {
        Logger().d(r);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                HomePage(username: r?.username.toString()),
          ),
          (route) => false,
        );
      },
    );
  }

  Column _alternative() {
    return const Column(
      children: [
        Text("or",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppColors.primary)),
        SizedBox(
          height: 4,
        ),
        Text("Log In using",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.primary))
      ],
    );
  }

  Align _forgotpassword() {
    return Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const RevcoveryEmailPage()));
          },
          child: const Text(
            "Forgot password?",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary),
            textAlign: TextAlign.right,
          ),
        ));
  }

  Widget _welcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello,',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Welcome back!,',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration:
          const InputDecoration(suffixIcon: Icon(Icons.mail), hintText: 'Email')
              .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextField(
      controller: _password,
      obscureText: passwordVisible,
      decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      passwordVisible = !passwordVisible;
                    },
                  );
                },
              ),
              hintText: 'Password')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'First time here? Click to',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SignupPage()));
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Sign Up',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.primary)))
        ],
      ),
    );
  }
}
