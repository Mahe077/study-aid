import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

abstract class BaseSnackBar {
  final BuildContext context;
  final String title;
  final String message;
  final ContentType contentType;

  BaseSnackBar(this.context, this.title, this.message, this.contentType);

  void show() {
    final snackBar = SnackBar(
      elevation: 1,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(10),
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
