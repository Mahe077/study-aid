import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:study_aid/common/widgets/snackbars/base_snackbar.dart';

class InfoSnackBar extends BaseSnackBar {
  InfoSnackBar(BuildContext context, String message)
      : super(context, 'Info', message, ContentType.help);
}

//usage
// void showInfo(BuildContext context) {
//   InfoSnackBar(context, 'Info', 'This is an info message').show();
// }
//