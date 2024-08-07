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
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      backgroundColor: Colors.transparent,
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
