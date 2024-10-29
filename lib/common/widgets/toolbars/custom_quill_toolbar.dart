import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class CustomQuillToolbar extends StatelessWidget {
  const CustomQuillToolbar({
    super.key,
    required this.quillController,
  });

  final QuillController quillController;

  /// Function to Insert an Image at the Current Cursor Position.
  Future<void> insertImage(String imageUrl) async {
    final index = quillController.selection.baseOffset;
    final length = quillController.selection.extentOffset - index;

    quillController.replaceText(
      index,
      length,
      BlockEmbed.image(imageUrl), // Embed the image.
      TextSelection.collapsed(offset: index + 1),
    );
  }

  Future<String?> uploadImage(String imagePath) async {
    if (imagePath.isEmpty) return null;

    final storageRef = FirebaseStorage.instance.ref();
    final fileRef =
        storageRef.child('Images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await fileRef.putFile(File(imagePath));
    final downloadUrl = await fileRef.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
      // padding: EdgeInsets.symmetric(horizontal: 10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: QuillToolbar.simple(
        controller: quillController,
        configurations: QuillSimpleToolbarConfigurations(
          embedButtons: FlutterQuillEmbeds.toolbarButtons(
              imageButtonOptions: QuillToolbarImageButtonOptions(
                  imageButtonConfigurations: QuillToolbarImageConfigurations(
                onImageInsertCallback: (image, controller) async {
                  final imageUrl = await uploadImage(image);
                  if (imageUrl != null) {
                    insertImage(imageUrl);
                  }
                },
              )),
              videoButtonOptions: null),
          decoration: BoxDecoration(
            color: AppColors.toolbar,
            borderRadius: BorderRadius.circular(8),
          ),
          color: AppColors.black,
          fontSizesValues: const {
            "24": "24",
            "20": "20",
            "18": "18",
            "16": "16",
            "14": "14",
            "13": "13",
            "12": "12",
            "11": "11",
            "10": "10",
          },
          controller: quillController,
          multiRowsDisplay: false,
          showUndo: false,
          showRedo: false,
          showFontFamily: false,
          showStrikeThrough: false,
          showUnderLineButton: false,
          showCodeBlock: false,
          showSubscript: false,
          showSuperscript: false,
          showInlineCode: false,
          showLink: false,
          showHeaderStyle: false,
          // showFontSize: false,
          showListCheck: false,
          showQuote: false,
          showIndent: false,
          showLeftAlignment: false,
          showRightAlignment: false,
          showDividers: false,
          showClearFormat: false,
          showBackgroundColorButton: false,
          buttonOptions: const QuillSimpleToolbarButtonOptions(
            fontSize: QuillToolbarFontSizeButtonOptions(initialValue: '16'),
          ),
        ),
      ),
    );
  }
}
