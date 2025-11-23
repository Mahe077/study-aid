import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/validators/validators.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';

class CreatePasswordPage extends ConsumerStatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  ConsumerState<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends ConsumerState<CreatePasswordPage> {
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? password1Error;
  String? password2Error;

  bool passwordVisible1 = true;
  bool passwordVisible2 = true;

  @override
  void dispose() {
    _password1Controller.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeadings(
              text: 'Recover Password',
              alignment: TextAlign.left,
            ),
            const AppSubHeadings(
              text: 'Enter your new password below to reset your password.',
              alignment: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _passwordField(
                    context,
                    _password1Controller,
                    "Password",
                    passwordVisible1,
                    (value) {
                      setState(() {
                        passwordVisible1 = value;
                        password1Error = null;
                      });
                    },
                    errorText: password1Error,
                  ),
                  const SizedBox(height: 20),
                  _passwordField(
                    context,
                    _password2Controller,
                    "Confirm Password",
                    passwordVisible2,
                    (value) {
                      setState(() {
                        passwordVisible2 = value;
                        password2Error = null;
                      });
                    },
                    isConfirm: true,
                    errorText: password2Error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BasicAppButton(
              onPressed: _onSetPassword,
              title: "Set Password",
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(
    BuildContext context,
    TextEditingController controller,
    String hintText,
    bool passwordVisible,
    ValueChanged<bool> onVisibilityChanged, {
    bool isConfirm = false,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: passwordVisible,
      validator: (value) {
        if (isConfirm) {
          password2Error =
              validateConfirmPassword(value, _password1Controller.text);
          return password2Error;
        }
        password1Error = validatePassword(value);
        return password1Error;
      },
      onChanged: (_) {
        // Clear the error message when the user starts typing
        setState(() {
          if (isConfirm) {
            password2Error = null;
          } else {
            password1Error = null;
          }
        });
        _formKey.currentState?.validate();
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            onVisibilityChanged(!passwordVisible);
          },
        ),
        hintText: hintText,
        errorText: errorText,
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Future<void> _onSetPassword() async {
    if (_formKey.currentState!.validate()) {
      final result =
          await ref.read(resetPasswordProvider).call(_password2Controller.text);

      result.fold(
        (l) {
          Logger().e(l.message);
          CustomToast(context: context).showFailure(description: l.message);
        },
        (r) {
          Logger().d('password reset success');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const SigninPage(),
            ),
          );
        },
      );
    }
  }
}
