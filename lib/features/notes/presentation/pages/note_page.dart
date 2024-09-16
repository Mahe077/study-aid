import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/appbar/bottom_navbar.dart';
import 'package:study_aid/common/widgets/bannerbars/success_bannerbar.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/tiles/note_tag.dart';
import 'package:study_aid/common/widgets/toolbars/custom_quill_toolbar.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';

class NotePage extends ConsumerStatefulWidget {
  final String topicId;
  final String? topicTitle;
  Note? entity;
  bool isNewNote;
  Color? noteColor;

  NotePage({
    super.key,
    this.topicTitle,
    this.entity,
    required this.isNewNote,
    this.noteColor,
    required this.topicId,
  });

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  late final TextEditingController tagController;
  late final TextEditingController titleController;
  late final QuillController quillController;
  late final FocusNode focusNode;
  late final Note note;
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entity?.title ?? '');
    tagController = TextEditingController();
    // quillController = QuillController.basic();
    focusNode = FocusNode();
    note = widget.entity ?? getNote();
    quillController = widget.isNewNote || widget.entity!.contentJson == ""
        ? QuillController.basic()
        : QuillController(
            document: Document.fromJson(jsonDecode(widget.entity!.contentJson)),
            selection: const TextSelection.collapsed(offset: 0),
          );
    quillController.readOnly = !widget.isNewNote;
    isSaved = !widget.isNewNote;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.isNewNote) {
        focusNode.requestFocus();
      }
    });
  }

  void _handleToolbarAction(int index) {
    switch (index) {
      case 0:
        _share();
        break;
      case 1:
        _addToFavorites();
        break;
      case 2:
        _changeToEditMode();
        break;
      case 3:
        _confirmDelete();
        break;
    }
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature is coming soon')),
    );
  }

  void _addToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Added to favorites feature is coming soon')),
    );
  }

  void _changeToEditMode() {
    focusNode.requestFocus();
    setState(() {
      widget.isNewNote = false;
      quillController.readOnly = false; // Set to false to allow editing
      isSaved = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit mode activated')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SuccessBannerbar(context, "Item deleted").show();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Item deleted')),
                // );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Note getNote() {
    return Note(
      id: '',
      title: '',
      content: '',
      contentJson: '',
      createdDate: DateTime.now(),
      color: widget.noteColor ?? AppColors.grey,
      remoteChangeTimestamp: DateTime.now(),
      tags: [],
      updatedDate: DateTime.now(),
      syncStatus: ConstantStrings.pending,
      localChangeTimestamp: DateTime.now(),
    );
  }

  void addTag(String tag) {
    if (tag.isNotEmpty) {
      tagController.clear();
      setState(() {
        note.tags.add(tag);
      });
      // Navigator.of(context).pop();
    }
  }

  // void removeTag(int index) {
  //   _tags.removeAt(index);
  // }

  // void updateTag(String tag, int index) {
  //   _tags[index] = tag;
  // }

  void _saveNote(BuildContext context, WidgetRef ref) {
    final noteTemp = Note(
      id: note.id,
      title: titleController.text.trim(),
      content: quillController.document.toPlainText().trim(),
      contentJson: jsonEncode(quillController.document.toDelta().toJson()),
      createdDate: note.createdDate,
      color: widget.noteColor ?? note.color,
      remoteChangeTimestamp: note.remoteChangeTimestamp,
      tags: note.tags,
      updatedDate: DateTime.now(),
      syncStatus: ConstantStrings.pending,
      localChangeTimestamp: DateTime.now(),
    );

    Logger().i(noteTemp.toString());
    Logger().i(noteTemp.title);

    final noteNotifier = ref.read(notesProvider(widget.topicId).notifier);
    if (widget.isNewNote) {
      noteNotifier.createNote(noteTemp, widget.topicId);
    } else {
      noteNotifier.updateNote(noteTemp, widget.topicId);
    }

    if (!mounted) return;

    SuccessBannerbar(context, 'Topic Saved.').show();

    // Switch toolbar to BottomNavbar
    setState(() {
      widget.entity = noteTemp;
      widget.isNewNote = false;
      quillController.readOnly = true; // Make the editor read-only after saving
      isSaved = true;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(hideBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                AppHeadings(
                  text: widget.topicTitle ?? '',
                  alignment: TextAlign.left,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 5, 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                color: widget.noteColor ??
                    widget.entity?.color ??
                    AppColors.darkGrey,
              ),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                            isDense: true,
                            icon: FaIcon(FontAwesomeIcons.solidNoteSticky,
                                size: 20),
                            hintText: 'Enter note title',
                            hintStyle: TextStyle(
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            focusedBorder: InputBorder.none),
                        canRequestFocus: !quillController.readOnly,
                      ),
                    ),
                    if (!isSaved) _saveButton(context),
                    const SizedBox(width: 2),
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _discardNote();
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 24,
                        )),
                  ]),
                  Row(
                    children: [
                      if (note.tags.isNotEmpty)
                        ...note.tags.map((tag) => Row(
                              children: [
                                Tag(
                                    text: tag,
                                    onTap: () {
                                      _confirmRemoveTag(tag);
                                    }),
                                const SizedBox(width: 5),
                              ],
                            )),
                      if (!quillController.readOnly)
                        GestureDetector(
                          onTap: () {
                            _addTagDialog(context);
                          },
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                children: [
                                  const Icon(Icons.add,
                                      size: 10, color: AppColors.primary),
                                  if (widget.entity?.tags == null) ...[
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Add a tag',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ]
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                  if (!widget.isNewNote) ...[
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
                  ],
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
                  quillController.readOnly
                      ? BottomNavbar(
                          onItemTapped: _handleToolbarAction,
                          itemColor: widget.noteColor ??
                              widget.entity?.color ??
                              AppColors.grey,
                          onColorChanged: (color) {
                            setState(() {
                              widget.noteColor = color; // Update note color
                              isSaved = false;
                            });
                          },
                        )
                      : CustomQuillToolbar(quillController: quillController),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton _saveButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          visualDensity: VisualDensity.compact,
          fixedSize: const Size.fromHeight(10),
          backgroundColor: AppColors.primary,
          iconColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: () => _saveNote(context, ref),
      child: const Row(
        children: [
          Icon(
            Icons.save,
            size: 17,
          ),
          SizedBox(width: 5),
          Text(
            'Save',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.white,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  void _addTagDialog(BuildContext context) {
    showCustomDialog(
      context,
      DialogMode.add,
      'Tag',
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tagController,
            decoration: const InputDecoration(
              hintText: "Enter tag here",
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
          ),
        ],
      ),
      () => addTag(tagController.text.trim()),
    );
  }

  void _discardNote() {
    isSaved
        ? {
            quillController.clear(), // Clear content on discard
            titleController.clear(),
            Navigator.of(context).pop(),
          }
        : showCustomDialog(context, DialogMode.gen, "Confirm Discard",
            const Text('Are you sure you want to discard changes?'), () {
            quillController.clear(); // Clear content on discard
            titleController.clear(); // Clear title on discard
            Navigator.of(context).pop();
          });
  }

  void _confirmRemoveTag(String tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Tag'),
          content: Text('Are you sure you want to remove the tag "$tag"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  note.tags.remove(tag);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tag "$tag" removed')),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
