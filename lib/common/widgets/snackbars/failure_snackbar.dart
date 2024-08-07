import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/snackbars/base_snackbar.dart';

class FailureSnackBar extends BaseSnackBar {
  FailureSnackBar(BuildContext context, String title, String message)
      : super(context, title, message, ContentType.failure);
}


//usage
// void showFailure(BuildContext context) {
//   FailureSnackBar(context, 'Failure', 'This is a failure message').show();
// }
