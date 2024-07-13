import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';
import 'package:study_aid/presentation/auth/create_password.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  const OTPVerificationPage({super.key, required this.email});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<String> _otp = List.filled(5, '');

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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeadings(
                      text: 'Verification',
                      alignment: TextAlign.left,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    AppSubHeadings(
                      text:
                          'Enter the verification that we sent to your_name@example.com to verify your account.',
                      alignment: TextAlign.left,
                    )
                  ]),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return _textFieldOTP(
                    index: index,
                  );
                }),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            BasicAppButton(
              onPressed:
                  _verifyOTP, //TODO:implement correctly adding logic onPrecessd
              title: "Verify",
            ),
            const SizedBox(
              height: 20,
            ),
            _resendOTPText(context)
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    String otp = _otp.join();
    if (await EmailOTP.verifyOTP(otp: otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP verification success")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const CreatePasswordPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP verification failed")),
      );
    }
  }

  Widget _textFieldOTP({required int index}) {
    return Container(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: TextField(
          autofocus: index == 0,
          onChanged: (value) {
            setState(() {
              _otp[index] = value;
            });

            if (value.length == 1 && index < 4) {
              FocusScope.of(context).nextFocus();
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: const Offstage(),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: AppColors.darkGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: AppColors.primary),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resendOTPText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Didn’t receive the code?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
              onPressed: () async {
                if (await EmailOTP.sendOTP(email: widget.email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP has been sent")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP failed sent")));
                }
              },
              child: const Text('Send again.',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary)))
        ],
      ),
    );
  }
}
