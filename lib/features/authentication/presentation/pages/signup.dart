import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/assets/app_vectors.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';
import 'package:study_aid/presentation/home/pages/home.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  Logger log = Logger();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();

  final TextEditingController _password = TextEditingController();

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _signupText(context),
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
                  const SizedBox(height: 10),
                  _welcomeText(),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _usenameField(context),
            const SizedBox(height: 15),
            _emailField(context),
            const SizedBox(height: 15),
            _passwordField(context),
            const SizedBox(height: 15),
            _aggrementText(context),
            const SizedBox(height: 25),
            BasicAppButton(
              onPressed: () =>
                  _signUpClicked(context, AuthMethod.emailAndPassword),
              title: "Sign Up",
            ),
            const SizedBox(height: 10),
            _alternative(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  onPressed: () => _signUpClicked(context, AuthMethod.google),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.facebookF,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  onPressed: () =>
                      _signUpClicked(context, AuthMethod.facebook), //TODO:Check
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.apple,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: () =>
                      _signUpClicked(context, AuthMethod.apple), //TODO:Check
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signUpClicked(BuildContext context, AuthMethod authType) async {
    dartz.Either<Failure, User?> result;

    switch (authType) {
      case AuthMethod.emailAndPassword:
        result = await ref.read(signUpWithEmailProvider).call(
            _email.text.toString(),
            _password.text.toString(),
            _username.text.toString());
      //   result = await ref.read(signupUseCase).call(
      //       params: CreateUserReq(
      //           userName: _username.text.toString(),
      //           email: _email.text.toString(),
      //           password: _password.text.toString()));
      //   break;
      // case AuthMethod.google:
      //   result = await sl<SignInWithGoogleUseCase>().call();
      //   break;
      // case AuthMethod.facebook:
      //   result = await sl<SignInWithFacebookUseCase>().call();
      //   break;
      // case AuthMethod.apple:
      //   result = await sl<SignInWithAppleUseCase>().call();
      //   break;
      default:
        result = dartz.Left(ServerFailure('Invalid authentication method'));
    }

    result.fold(
      (l) {
        Logger().e(l.message);
        String message;
        if (l is ServerFailure) {
          message = l.message;
        } else {
          message = 'An unknown error occurred';
        }
        final snackbar = SnackBar(
          content: Text(message),
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
                fontSize: 16,
                color: AppColors.primary)),
        SizedBox(
          height: 3,
        ),
        Text("Sign Up using",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.primary))
      ],
    );
  }

  Widget _welcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's,",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Get yourself registered!,',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _usenameField(BuildContext context) {
    return TextField(
      controller: _username,
      decoration: const InputDecoration(
              suffixIcon: Icon(Icons.person), hintText: 'Username')
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
              suffixIcon: Icon(Icons.mail), hintText: 'Email Address')
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
            'Already have an account? Click to',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SigninPage()));
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Log In',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.primary)))
        ],
      ),
    );
  }

  Widget _aggrementText(BuildContext context) {
    //   return Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         children: [
    //           const Text(
    //             'By registering, you agree with our',
    //             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    //           ),
    //           TextButton(
    //               style: TextButton.styleFrom(
    //                   padding: const EdgeInsets.fromLTRB(0, 0, 2, 0)),
    //               onPressed: () {
    //                 // Navigator.push(
    //                 // context,
    //                 // MaterialPageRoute(
    //                 //     builder: (BuildContext context) => const SigninPage()));
    //               },
    //               child: const Text(' Terms of Use',
    //                   style: TextStyle(
    //                       fontWeight: FontWeight.w600,
    //                       fontSize: 14,
    //                       color: AppColors.primary))),
    //           const Text(
    //             'and',
    //             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    //           ),
    //         ],
    //       ),
    //       Row(
    //         children: [
    //           TextButton(
    //               style: TextButton.styleFrom(padding: EdgeInsets.zero),
    //               onPressed: () {
    //                 // Navigator.push(
    //                 //     context,
    //                 //     MaterialPageRoute(
    //                 //         builder: (BuildContext context) => const SigninPage()));
    //               },
    //               child: const Text('Privacy Policy.',
    //                   style: TextStyle(
    //                       fontWeight: FontWeight.w600,
    //                       fontSize: 14,
    //                       color: AppColors.primary))),
    //         ],
    //       ),
    //     ],
    //   );
    // }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'By registering, you agree with our ',
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
            children: [
              TextSpan(
                text: 'Terms of Use',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    log.i("Terms of Use clicked");
                    // Your onPressed action for Terms of Use here
                  },
              ),
              const TextSpan(
                text: ' and ',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black),
              ),
              TextSpan(
                text: 'Privacy Policy.',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    log.i("Privacy Policy clicked");
                    // Your onPressed action for Privacy Policy here
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
