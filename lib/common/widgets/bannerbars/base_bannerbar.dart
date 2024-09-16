import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

abstract class BaseBanner {
  final BuildContext context;
  final String title;
  final String message;
  final ContentType contentType;

  BaseBanner(this.context, this.title, this.message, this.contentType);

  void show() {
    final materialBanner = MaterialBanner(
      margin: EdgeInsets.zero,
      leadingPadding: EdgeInsets.zero,

      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 5,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: contentType,
        // to configure for material banner
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    // Automatically close the MaterialBanner after the duration
    Timer(const Duration(milliseconds: 2000), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }
}

class SuccessBaseBanner extends BaseBanner {
  SuccessBaseBanner(BuildContext context, String title, String message)
      : super(context, title, message, ContentType.success);
}

class FailureBaseBanner extends BaseBanner {
  FailureBaseBanner(BuildContext context, String title, String message)
      : super(context, title, message, ContentType.failure);
}

class InfoBaseBanner extends BaseBanner {
  InfoBaseBanner(BuildContext context, String title, String message)
      : super(context, title, message, ContentType.help);
}
