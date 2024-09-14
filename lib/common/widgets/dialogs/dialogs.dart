import 'package:flutter/material.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

Future<void> showAddTagDialog(
    BuildContext context, Function(String) onTagAdded) async {
  TextEditingController _tagController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(hintText: 'Enter tag'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              final newTag = _tagController.text.trim();
              if (newTag.isNotEmpty) {
                onTagAdded(newTag);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      content: content,
      actions: actions,
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontSize: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.lightBackground,
      actionsPadding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      titlePadding: const EdgeInsets.fromLTRB(20, 10, 5, 0),
    );
  }
}
