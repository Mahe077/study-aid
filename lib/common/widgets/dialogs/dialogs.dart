import 'package:flutter/material.dart';

Future<void> showAddTagDialog(BuildContext context, Function(String) onTagAdded) async {
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
