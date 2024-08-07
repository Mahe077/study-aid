import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/bannerbars/failure_bannerbar.dart';
import 'package:study_aid/common/widgets/bannerbars/success_bannerbar.dart';
import 'package:study_aid/core/utils/helpers/helpers.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

class FAB extends ConsumerStatefulWidget {
  final String userId;
  String? parentId;

  FAB({super.key, this.parentId, required this.userId});

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
    final result = await ref.read(createTopicProvider).call(
        title, description, selectedColor, widget.parentId, widget.userId);
    result.fold(
      (failure) {
        Logger().e(failure.message);
        FailureBannerbar(context, failure.message).show();
        // showSnackBar(context, failure.message);
      },
      (topic) {
        Logger().d(topic.toString());
        setState(() {
          _topicController.clear();
          _descriptionController.clear();
          selectedColor = Colors.black;
        });
        SuccessBannerbar(context, 'Topic Saved!').show();
        Navigator.of(context).pop();
        _fabKey.currentState?.toggle();
      },
    );
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
        const FloatingActionButton.extended(
          label: Row(
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
          onPressed: null, //TODO:implement
          backgroundColor: AppColors.grey,
        ),
        const FloatingActionButton.extended(
          label: Row(
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
          onPressed: null, //TODO:implement
          backgroundColor: AppColors.grey,
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
