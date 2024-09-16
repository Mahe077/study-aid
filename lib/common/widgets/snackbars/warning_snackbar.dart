import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/snackbars/base_snackbar.dart';

class WarningSnackBar extends BaseSnackBar {
  WarningSnackBar(BuildContext context, String title, String message)
      : super(context, title, message, ContentType.warning);
}


//usage
// void showSuccess(BuildContext context) {
//   SuccessSnackBar(context, 'Success', 'This is a success message').show();
// }
//