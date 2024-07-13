import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/presentation/auth/signin.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();

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
            _passwordField(context, _password1, "Password", passwordVisible1),
            const SizedBox(
              height: 20,
            ),
            _passwordField(
                context, _password2, "Confirm Password", passwordVisible2),
            const SizedBox(
              height: 20,
            ),
            BasicAppButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SigninPage()));
              }, //TODO:implement correctly adding logic onPrecessd
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
  ) {
    return TextField(
      controller: controller,
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
              hintText: hintText)
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}
