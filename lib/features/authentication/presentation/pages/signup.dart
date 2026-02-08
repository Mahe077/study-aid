import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/gestures.dart';
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
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/app_logger.dart';
import 'package:study_aid/core/utils/assets/app_vectors.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/core/utils/validators/validators.dart';
import 'package:study_aid/features/authentication/domain/entities/user.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/presentation/home/pages/home.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  final _signUpKey = GlobalKey<FormState>();

  String? _emailError;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildSignupText(context),
      body: Stack(
        children: [
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
                SvgPicture.asset(AppVectors.signup),
                const SizedBox(height: 10),
                _buildWelcomeText(),
                const SizedBox(height: 25),
                Form(
                  key: _signUpKey,
                  child: Column(
                    children: [
                      _buildUsernameField(context),
                      const SizedBox(height: 15),
                      _buildEmailField(context),
                      const SizedBox(height: 15),
                      _buildPasswordField(context),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                _buildAgreementText(context),
                const SizedBox(height: 25),
                BasicAppButton(
                  onPressed: () =>
                      _signUpClicked(context, AuthMethod.emailAndPassword),
                  title: "Sign Up",
                ),
                const SizedBox(height: 10),
                Center(child: _buildAlternativeText()),
                const SizedBox(height: 15),
                _buildSocialLoginButtons(),
              ],
            ),
          ),
          if (_isLoading) buildLoadingMask(),
        ],
      ),
    );
  }

  Future<void> _signUpClicked(
      BuildContext context, AuthMethod authMethod) async {
    setState(() {
      _isLoading = true; // Show loading mask
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();

    dartz.Either<Failure, User?> result;

    switch (authMethod) {
      case AuthMethod.emailAndPassword:
        if (_signUpKey.currentState!.validate()) {
          result = await ref
              .read(signUpWithEmailProvider)
              .call(email, password, username);
        } else {
          // If validation fails, show an error and return early
          setState(() {
            _isLoading = false; // Hide loading mask
          });
          return; // Exit early if form is not valid
        }
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
        result = dartz.Left(ServerFailure('Invalid authentication method'));
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
            MaterialPageRoute(builder: (context) => HomePage(user: user)),
            (route) => false,
          );
        }
      },
    );
  }


  Future<void> initUserPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showGuide', true);
  }

  Widget _buildAlternativeText() {
    return const Column(
      children: [
        Text(
          "or",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 3),
        Text(
          "Sign Up using",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's,",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 34,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Get yourself registered!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return TextFormField(
      controller: _usernameController,
      validator: (value) {
        _usernameError = isValidUsername(value);
        return _usernameError;
      },
      onChanged: (_) {
        setState(() {
          _usernameError =
              null; // Clear the error message when the user starts typing
        });
      },
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.person),
        hintText: 'Username',
        errorText: _usernameError,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        _emailError = isValidEmail(value);
        return _emailError;
      },
      onChanged: (_) {
        setState(() {
          _emailError =
              null; // Clear the error message when the user starts typing
        });
      },
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.mail),
        hintText: 'Email Address',
        errorText: _emailError,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      validator: (value) {
        _passwordError = validatePassword(value);
        return _passwordError;
      },
      onChanged: (_) {
        setState(() {
          _passwordError =
              null; // Clear the error message when the user starts typing
        });
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        hintText: 'Password',
        errorText: _passwordError,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _buildSignupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? Click to',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SigninPage()),
              );
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              'Log In',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'By registering, you agree with our ',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: 'Terms of Use',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppLogger.i("Terms of Use clicked");
                //TODO: Navigate to Terms of Use page
              },
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
          onPressed: () => _signUpClicked(context, AuthMethod.google),
        ),
        const SizedBox(width: 10),
        // buildSocialButton(
        //   icon: FontAwesomeIcons.facebookF,
        //   color: AppColors.primary,
        //   onPressed: () => _signUpClicked(context, AuthMethod.facebook),
        // ),
        // const SizedBox(width: 10),
        buildSocialButton(
          icon: FontAwesomeIcons.apple,
          color: AppColors.primary,
          onPressed: () => _signUpClicked(context, AuthMethod.apple),
        ),
      ],
    );
  }
}
