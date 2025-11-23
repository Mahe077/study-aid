import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class CustomQuillToolbar extends StatelessWidget {
  const CustomQuillToolbar({
    super.key,
    required this.quillController,
  });

  final QuillController quillController;

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
                  imageButtonConfigurations: QuillToolbarImageConfigurations()),
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
            fontSize: QuillToolbarFontSizeButtonOptions(initialValue: '18'),
          ),
        ),
      ),
    );
  }
}
