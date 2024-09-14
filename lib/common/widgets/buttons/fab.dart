import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/bannerbars/failure_bannerbar.dart';
import 'package:study_aid/common/widgets/bannerbars/info_bannerbar.dart';
import 'package:study_aid/common/widgets/bannerbars/success_bannerbar.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/notes/presentation/pages/note.dart';
import 'package:study_aid/features/topics/presentation/notifiers/topic_notifire.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

class FAB extends ConsumerStatefulWidget {
  final String userId;
  final String? parentId;
  final String? topicTitle;
  final Color? topicColor;

  FAB(
      {super.key,
      this.parentId,
      required this.userId,
      this.topicTitle,
      this.topicColor});

  @override
  ConsumerState<FAB> createState() => _FABState();
}

class _FABState extends ConsumerState<FAB> {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color selectedColor = Colors.black;

  @override
  void dispose() {
    _topicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showColorPickerDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select a color',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Future<void> _handleCreateTopic(WidgetRef ref) async {
    final String title = _topicController.text.trim();
    final String description = _descriptionController.text.trim();

    // Get the TopicsNotifier instance using ref
    AsyncValue<TopicsState> currentState;
    if (widget.parentId == null) {
      final topicsNotifier = ref.read(topicsProvider(widget.userId).notifier);

      // Call the createTopic method from the TopicsNotifier
      await topicsNotifier.createTopic(
        title,
        description,
        selectedColor,
        widget.parentId,
        widget.userId,
      );

      if (!mounted) return;

      // Check the state after attempting to create the topic
      currentState = ref.read(topicsProvider(widget.userId));
    } else {
      final topicChildNotifier =
          ref.read(topicChildProvider(widget.parentId).notifier);

      await topicChildNotifier.createTopic(
        title,
        description,
        selectedColor,
        widget.parentId,
        widget.userId,
      );

      currentState = ref.read(topicsProvider(widget.userId));

      // Invalidate topicChildProvider to refresh the subtopics
      ref.invalidate(topicChildProvider(widget.parentId));
    }

    if (currentState.hasError) {
      FailureBannerbar(context, currentState.error.toString()).show();
    } else if (currentState.isLoading) {
      const Center(child: CircularProgressIndicator());
    } else {
      // Handle success, show success banner, clear input fields
      setState(() {
        _topicController.clear();
        _descriptionController.clear();
        selectedColor = Colors.black;
      });

      SuccessBannerbar(context, 'Topic Saved.').show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: _fabKey,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.4),
      ),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(
          Icons.add,
          size: 26,
          color: AppColors.icon,
        ),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: AppColors.primary,
      ),
      closeButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(
          Icons.close,
          size: 26,
          color: AppColors.icon,
        ),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: AppColors.primary,
      ),
      children: [
        FloatingActionButton.extended(
          label: const Row(
            children: [
              Text(
                'Record an Audio',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              FaIcon(FontAwesomeIcons.microphone,
                  size: 20, color: AppColors.primary),
            ],
          ),
          heroTag: null,
          onPressed: () {
            widget.parentId != null
                ? {
                    _fabKey.currentState?.toggle(),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => NotePage(
                            topicId: widget.parentId ?? '',
                            topicTitle: widget.topicTitle,
                            entity: null,
                            isNewNote: true,
                            noteColor: widget.topicColor,
                          ),
                        ))
                  }
                : {
                    _fabKey.currentState?.toggle(),
                    InfoBannerbar(context, 'Please add a Topic').show()
                  };
          }, //TODO:implement
          backgroundColor:
              widget.parentId != null ? AppColors.grey : Colors.red,
        ),
        FloatingActionButton.extended(
          label: const Row(
            children: [
              Text(
                'Create a New Note',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              FaIcon(FontAwesomeIcons.solidNoteSticky,
                  size: 20, color: AppColors.primary),
            ],
          ),
          heroTag: null,
          onPressed: () {
            widget.parentId != null
                ? {
                    _fabKey.currentState?.toggle(),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => NotePage(
                            topicId: widget.parentId ?? '',
                            topicTitle: widget.topicTitle,
                            entity: null,
                            isNewNote: true,
                            noteColor: widget.topicColor,
                          ),
                        ))
                  }
                : {
                    _fabKey.currentState?.toggle(),
                    InfoBannerbar(context, 'Please add a Topic').show()
                  };
          }, //TODO:implement
          backgroundColor:
              widget.parentId != null ? AppColors.grey : Colors.red,
        ),
        FloatingActionButton.extended(
          label: const Row(
            children: [
              Text(
                'Add a Topic',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.bookOpen,
                size: 20,
                color: AppColors.primary,
              )
            ],
          ),
          heroTag: null,
          onPressed: () {
            _fabKey.currentState?.toggle();
            showCustomDialog(
              context,
              DialogMode.add,
              'Topic',
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      hintText: "Enter title here",
                    ).applyDefaults(Theme.of(context).inputDecorationTheme),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Enter description here",
                    ).applyDefaults(Theme.of(context).inputDecorationTheme),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text(
                        "Pick a color:",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black),
                      ),
                      const SizedBox(height: 5),
                      IconButton(
                        onPressed: _showColorPickerDialog,
                        icon: const Icon(Icons.color_lens),
                      ),
                    ],
                  ),
                ],
              ),
              () => _handleCreateTopic(ref),
            );
          },
          backgroundColor: AppColors.grey,
        ),
      ],
    );
  }
}
