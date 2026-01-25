import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/buttons/social_buttons.dart';
import 'package:study_aid/common/widgets/mask/loading_mask.dart';
import 'package:study_aid/core/utils/app_logger.dart';
import 'package:study_aid/core/utils/assets/app_vectors.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/core/utils/validators/validators.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/presentation/home/pages/home.dart';
import 'package:study_aid/features/authentication/presentation/pages/revcovery_email.dart';
import 'package:study_aid/features/authentication/presentation/pages/signup.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  final _signInKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildSignupText(context),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset(
              //   AppVectors.logo,
              //   height: 100,
              //   alignment: Alignment(-1, -1),
              // ),
              SvgPicture.asset(AppVectors.signin),
              const SizedBox(height: 10),
              _buildWelcomeText(),
              const SizedBox(height: 30),
              Form(
                key: _signInKey,
                child: Column(
                  children: [
                    _buildEmailField(context),
                    const SizedBox(height: 20),
                    _buildPasswordField(context),
                    _buildForgotPasswordText(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BasicAppButton(
                onPressed: () {
                  if (!_isLoading && _signInKey.currentState!.validate()) {
                    _signInClicked(context, AuthMethod.emailAndPassword);
                  }
                },
                title: "Log In",
              ),
              const SizedBox(height: 20),
              Center(child: _buildAlternativeText()),
              const SizedBox(height: 20),
              _buildSocialLoginButtons(),
            ],
          ),
        ),
        if (_isLoading) buildLoadingMask(),
      ]),
    );
  }

  Future<void> _signInClicked(
      BuildContext context, AuthMethod authMethod) async {
    setState(() {
      _isLoading = true; // Show loading mask
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    dartz.Either result;
    switch (authMethod) {
      case AuthMethod.emailAndPassword:
        if (!_signInKey.currentState!.validate()) return;
        result = await ref.read(signInWithEmailProvider).call(email, password);
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

    setState(() {
      _isLoading = false; // Hide loading mask
    });

    result.fold(
      (failure) {
        AppLogger.e(failure.message);
        CustomToast(context: context).showFailure(description: failure.message);
      },
      (user) async {
        AppLogger.d(user.toString());
        if (user != null) {
          ref.invalidate(userProvider);

          await initUserPref();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => HomePage(user: user),
            ),
            (route) => false,
          );
        }
      },
    );
  }

  Future<void> initUserPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showGuide', false);
  }

  Widget _buildAlternativeText() {
    return const Column(
      children: [
        Text("or",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: AppColors.primary)),
        SizedBox(height: 4),
        Text("Log In using",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.primary)),
      ],
    );
  }

  Widget _buildForgotPasswordText() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const RevcoveryEmailPage()),
          );
        },
        child: const Text(
          "Forgot password?",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello,',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34)),
        SizedBox(height: 2),
        Text('Welcome back!',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        return emailError = isValidEmail(value);
      },
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.mail),
        hintText: 'Email',
        errorText: emailError,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return passwordError = 'Password is required';
        }
        return null;
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon:
              Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        hintText: 'Password',
        errorText: passwordError,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _buildSignupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('First time here? Click to',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const SignupPage()),
              );
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Sign Up',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSocialButton(
          icon: FontAwesomeIcons.google,
          color: AppColors.primary,
          onPressed: () => _signInClicked(context, AuthMethod.google),
        ),
        const SizedBox(width: 10),
        // buildSocialButton(
        //   icon: FontAwesomeIcons.facebookF,
        //   color: AppColors.primary,
        //   onPressed: () => _signInClicked(context, AuthMethod.facebook),
        // ),
        // const SizedBox(width: 10),
        buildSocialButton(
          icon: FontAwesomeIcons.apple,
          color: AppColors.primary,
          onPressed: () => _signInClicked(context, AuthMethod.apple),
        ),
      ],
    );
  }
}
