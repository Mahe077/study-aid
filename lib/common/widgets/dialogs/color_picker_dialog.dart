import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

Future<Color?> showAppColorPicker(BuildContext context, Color initialColor) async {
  Color tempSelectedColor = initialColor;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
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
              availableColors: AppColors.colors,
              pickerColor: tempSelectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  tempSelectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop(tempSelectedColor);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      });
    },
  );
}
