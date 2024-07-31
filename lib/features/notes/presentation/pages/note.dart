import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/dialogs/dialogs.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/common/widgets/toolbars/custom_quill_toolbar.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';

class NotePage extends StatefulWidget {
  final String? topicTitle;
  Note? entity;
  final bool isNewNote;

  NotePage({
    super.key,
    this.topicTitle,
    this.entity,
    required this.isNewNote,
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late final QuillController quillController;
  late final FocusNode focusNode;

  void _addTag(String tag) {
    setState(() {
      widget.entity!.tags.add(tag);
    });
  }

  @override
  void initState() {
    super.initState();
    quillController = QuillController.basic();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.isNewNote) {
        focusNode.requestFocus();
        // newNoteController.readOnly = false;
      } else {
        // newNoteController.readOnly = true;

        // quillController.document = newNoteController.content;
        // Note(id: '', title: '', content: '', createdDate: Timestamp.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BasicAppbar(
          hideBack: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  AppHeadings(
                    text: "${widget.topicTitle ?? 'Add a Topic'},",
                    alignment: TextAlign.left,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                color: AppColors.darkGrey,
                child: Column(
                  children: [
                    Row(children: [
                      const TextField(
                        // controller: _email,
                        decoration: InputDecoration(
                            icon: FaIcon(FontAwesomeIcons.solidNoteSticky,
                                size: 20),
                            hintText: 'Enter note title',
                            hintStyle: TextStyle(
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            focusedBorder: InputBorder.none),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Save button action
                        },
                        child: const Icon(Icons.save),
                      ),
                      const SizedBox(
                          width: 10), // Space between Save and Close buttons
                      // Close Button
                      ElevatedButton(
                        onPressed: () {
                          // Close button action
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.close),
                            SizedBox(width: 5),
                            Text('Save')
                          ],
                        ),
                      ),
                    ]),
                    // Row(
                    //   children: [
                    //     const FaIcon(FontAwesomeIcons.solidNoteSticky,
                    //         size: 20),
                    //     const SizedBox(width: 10),
                    //     AppSubHeadings(
                    //       text: widget.entity!.title,
                    //       size: 20,
                    //       alignment: TextAlign.left,
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (widget.entity?.tags != null)
                          ...widget.entity!.tags.map((tag) => Row(
                                children: [
                                  Tag(text: tag),
                                  const SizedBox(width: 5),
                                ],
                              )),
                        GestureDetector(
                          onTap: () {
                            showAddTagDialog(context, _addTag);
                          },
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(
                                Icons.add,
                                size: 10,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Created: ${widget.entity?.createdDate}",
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: QuillEditor.basic(
                        configurations: QuillEditorConfigurations(
                          controller: quillController,
                          expands: true,
                        ),
                        focusNode: focusNode,
                      ),
                    ),
                    // if (!readOnly)
                    CustomQuillToolbar(quillController: quillController)
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
