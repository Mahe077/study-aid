import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/core/configs/assets/app_vectors.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';
import 'package:study_aid/data/models/auth/create_user_req.dart';
import 'package:study_aid/domain/usecases/auth/signup.dart';
import 'package:study_aid/presentation/auth/pages/signin.dart';
import 'package:study_aid/presentation/home/pages/home.dart';
import 'package:study_aid/service_locator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
              onPressed: () async {
                await signUpClicked(context);
              },
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
                  onPressed: () {}, //TODO:implement onPrecessd
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.facebookF,
                    color: AppColors.primary,
                    size: 25,
                  ),
                  onPressed: () {}, //TODO:implement onPrecessd
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.apple,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: () {}, //TODO:implement onPrecessd
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> signUpClicked(BuildContext context) async {
    var result = await sl<SignupUseCase>().call(
        params: CreateUserReq(
            useName: _username.text.toString(),
            email: _email.text.toString(),
            password: _password.text.toString()));
    result.fold((l) {
      var snackbar = SnackBar(
        content: Text(l),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }, (r) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          (route) => false);
    });
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
