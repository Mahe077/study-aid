import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/common/widgets/mask/loading_mask.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/validators/validators.dart';
import 'package:study_aid/features/authentication/presentation/pages/verfication.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';

class RevcoveryEmailPage extends ConsumerStatefulWidget {
  const RevcoveryEmailPage({super.key});

  @override
  ConsumerState<RevcoveryEmailPage> createState() => _RevcoveryEmailPageState();
}

class _RevcoveryEmailPageState extends ConsumerState<RevcoveryEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final _recoveryEmailKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? emailError;

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: Stack(children: [
        SingleChildScrollView(
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
                key: _recoveryEmailKey,
                child: _emailField(context),
              ),
              const SizedBox(
                height: 20,
              ),
              BasicAppButton(
                onPressed: () async {
                  if (_recoveryEmailKey.currentState!.validate()) {
                    final String email = _emailController.text.trim();
                    setState(() {
                      _isLoading = true; // Show loading mask
                    });
                    var result = await ref
                        .read(sendPasswordResetEmailProvider)
                        .call(email);

                    setState(() {
                      _isLoading = false; // Hide loading mask
                    });

                    result.fold(
                      (failure) {
                        Logger().e(failure.message);
                        CustomToast(context: context)
                            .showFailure(description: failure.message);
                      },
                      (user) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    VerificationPage(email: email)));
                      },
                    );
                  }
                }, //TODO:implement correctly adding logic onPrecessd
                title: "Send Verification Code",
              )
            ],
          ),
        ),
        if (_isLoading) buildLoadingMask(),
      ]),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        return emailError = isValidEmail(value);
      },
      onChanged: (_) {
        _recoveryEmailKey.currentState?.validate();
      },
      decoration: InputDecoration(
              suffixIcon: const Icon(Icons.mail),
              hintText: 'Email Address',
              errorText: emailError)
          .applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }
}
