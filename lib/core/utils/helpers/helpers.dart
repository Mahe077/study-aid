import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/dialogs/dialogs.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

void showSnackBar(BuildContext context, String message) {
  final snackbar = SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

void showCustomDialog(
  BuildContext context,
  DialogMode mode,
  String component,
  Widget content,
  VoidCallback onConfirm, {
  GlobalKey<FormState>? formKey, // Make formKey optional
  Color? initialColor, // Optional initial color
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: _getDialogTitle(mode, component),
        content: content,
        actions:
            _getDialogActions(context, mode, component, onConfirm, formKey),
      );
    },
  );
}

String _getDialogTitle(DialogMode mode, String component) {
  switch (mode) {
    case DialogMode.add:
      return "Add $component";
    case DialogMode.edit:
      return "Edit $component";
    case DialogMode.view:
      return "View $component";
    default:
      return component;
  }
}

List<Widget> _getDialogActions(
  BuildContext context,
  DialogMode mode,
  String component,
  VoidCallback onConfirm,
  GlobalKey<FormState>? formKey,
) {
  switch (mode) {
    case DialogMode.view:
      return [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ];
    case DialogMode.edit:
      return [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Handle update topic logic here if needed
          },
          child: Text("Update $component"),
        ),
      ];
    case DialogMode.add:
      return [
        Center(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // minimumSize: Size.fromWidth(100),
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  // visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.black,
                  iconColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                if (formKey == null ||
                    formKey.currentState?.validate() == true) {
                  onConfirm();
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: Text(
                "Add $component",
                style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500),
              )),
        ),
      ];
    default:
      return [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primary,
                iconColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop(true); // Close dialog
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500),
            )),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.grey,
                iconColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500),
            )),
      ];
  }
}

String formatDateTime(DateTime date) {
  // Create a DateFormat instance with the required format
  final DateFormat formatter = DateFormat('hh:mm a dd/MM/yyyy');

  // Format the date
  return formatter.format(date);
}
