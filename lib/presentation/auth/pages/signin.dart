import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/core/configs/assets/app_vectors.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';
import 'package:study_aid/presentation/home/pages/home.dart';
import 'package:study_aid/presentation/auth/pages/revcovery_email.dart';
import 'package:study_aid/presentation/auth/pages/signup.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
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
            const SizedBox(
              height: 35,
            ),
            _emailField(context),
            const SizedBox(
              height: 20,
            ),
            _passwordField(context),
            _forgotpassword(),
            const SizedBox(
              height: 20,
            ),
            BasicAppButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const HomePage()));
              }, //TODO:implement correctly adding logic onPrecessd
              title: "Log In",
            ),
            const SizedBox(
              height: 20,
            ),
            _alternative(),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    AppVectors.google,
                    width: 25,
                    height: 25,
                  ),
                  onPressed: () {}, //TODO:implement onPrecessd
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    AppVectors.facebook,
                    width: 25,
                    height: 25,
                  ),
                  onPressed: () {}, //TODO:implement onPrecessd
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    AppVectors.apple,
                    width: 30,
                    height: 30,
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

  Column _alternative() {
    return const Column(
      children: [
        Text("or",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.primary)),
        SizedBox(
          height: 4,
        ),
        Text("Log In using",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Welcome back!,',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _emailField(BuildContext context) {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
              suffixIcon: Icon(Icons.mail), hintText: 'Email or Username')
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
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SignupPage()));
              },
              child: const Text('Sign Up',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary)))
        ],
      ),
    );
  }
}
