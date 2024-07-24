import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/common/widgets/mask/loading_mask.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/presentation/pages/create_password.dart';
import 'package:study_aid/features/authentication/presentation/providers/auth_providers.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppHeadings(
                        text: 'Email Sent',
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                      AppSubHeadings(
                        text:
                            'We have sent a password reset email to ${widget.email}. Please click on the link to reset your password.',
                        alignment: TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
              _resendEmailText(context)
            ],
          ),
        ),
        if (_isLoading) buildLoadingMask(),
      ]),
    );
  }

  Widget _resendEmailText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Didn’t receive the email?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          TextButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Show loading mask
                });
                var result = await ref
                    .read(sendPasswordResetEmailProvider)
                    .call(widget.email);

                setState(() {
                  _isLoading = false; // Hide loading mask
                });

                result.fold(
                  (failure) {
                    Logger().e(failure.message);
                    showSnackBar(
                      context,
                      failure is ServerFailure
                          ? failure.message
                          : 'An unknown error occurred',
                    );
                  },
                  (user) {
                    showSnackBar(
                      context,
                      'Email send',
                    );
                  },
                );
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
