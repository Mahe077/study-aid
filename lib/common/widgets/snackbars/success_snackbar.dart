import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/snackbars/base_snackbar.dart';

class SuccessSnackBar extends BaseSnackBar {
  SuccessSnackBar(BuildContext context, String title, String message)
      : super(context, title, message, ContentType.success);
}


//usage
// void showSuccess(BuildContext context) {
//   SuccessSnackBar(context, 'Success', 'This is a success message').show();
// }
//