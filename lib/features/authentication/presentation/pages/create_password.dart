import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
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
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool passwordVisible1 = true;
  bool passwordVisible2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Column(children: [
                AppHeadings(
                  text: 'Recover Password',
                  alignment: TextAlign.left,
                ),
                AppSubHeadings(
                  text:
                      'Let us send you a verification code to your email to get your password reset.',
                  alignment: TextAlign.left,
                )
              ]),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    _passwordField(
                        context, _password1, "Password", passwordVisible1,
                        (value) {
                      setState(() {
                        passwordVisible1 = value;
                      });
                    }),
                    const SizedBox(
                      height: 20,
                    ),
                    _passwordField(context, _password2, "Confirm Password",
                        passwordVisible2, (value) {
                      setState(() {
                        passwordVisible2 = value;
                      });
                    }, isConfirm: true),
                  ],
                )),
            const SizedBox(
              height: 20,
            ),
            BasicAppButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  dartz.Either result =
                      await ref.read(resetPasswordProvider).call(
                            _password2.text.toString(),
                          );

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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const SigninPage(),
                        ),
                      );
                    },
                  );
                }
              },
              title: "Set Password",
            )
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: passwordVisible,
      validator: (value) {
        if (isConfirm) {
          return validateConfirmPassword(value, _password1.text);
        }
        return validatePassword(value);
      },
      decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  onVisibilityChanged(!passwordVisible);
                },
              ),
              hintText: hintText)
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}
