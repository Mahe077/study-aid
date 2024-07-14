import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/presentation/auth/pages/otp_verfication.dart';

class RevcoveryEmailPage extends StatefulWidget {
  const RevcoveryEmailPage({super.key});

  @override
  State<RevcoveryEmailPage> createState() => _RevcoveryEmailPageState();
}

class _RevcoveryEmailPageState extends State<RevcoveryEmailPage> {
  final TextEditingController _email = TextEditingController();

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
            _emailField(context),
            const SizedBox(
              height: 20,
            ),
            BasicAppButton(
              onPressed: () async {
                if (await EmailOTP.sendOTP(email: _email.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP has been sent")));

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              OTPVerificationPage(email: _email.text)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP failed sent")));
                }
              }, //TODO:implement correctly adding logic onPrecessd
              title: "Send Verification Code",
            )
          ],
        ),
      ),
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
}
