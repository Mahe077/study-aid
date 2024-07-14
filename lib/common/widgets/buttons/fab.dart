import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:study_aid/core/configs/theme/app_colors.dart';

class FAB extends StatelessWidget {
  const FAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      // key: _key,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.4),
        // blur: 6
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
      children: const [
        FloatingActionButton.extended(
          label: Row(
            children: [
              Text(
                'Record an Audio',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5), // Adjust spacing between icon and text
              Icon(Icons.mic, size: 28, color: AppColors.primary),
            ],
          ),
          heroTag: null,
          onPressed: null, //TODO:implement
          backgroundColor: AppColors.grey,
          // icon: Icon(Icons.mic, size: 26, color: AppColors.primary),
        ),
        FloatingActionButton.extended(
          label: Row(
            children: [
              Text(
                'Create a New Note',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5),
              Icon(Icons.note_add, size: 26, color: AppColors.primary),
            ],
          ),
          heroTag: null,
          onPressed: null, //TODO:implement
          backgroundColor: AppColors.grey,
        ),
        FloatingActionButton.extended(
          label: Row(
            children: [
              Text(
                'Add a Topic',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.topic,
                size: 26,
                color: AppColors.primary,
              )
            ],
          ),
          heroTag: null,
          onPressed: null, //TODO:implement
          backgroundColor: AppColors.grey,
        ),
      ],
    );
  }
}
