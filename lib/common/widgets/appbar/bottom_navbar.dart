import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';

class BottomNavbar extends StatefulWidget {
  final Function(int) onItemTapped;
  final Function(Color) onColorChanged;
  Color itemColor;

  BottomNavbar({
    super.key,
    required this.onItemTapped,
    required this.itemColor,
    required this.onColorChanged,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
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
              color: AppColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              availableColors: AppColors.colors,
              pickerColor: widget.itemColor,
              onColorChanged: (Color color) {
                setState(() {
                  widget.itemColor = color; // Update local color
                });
                widget.onColorChanged(color); // Notify parent widget
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.toolbar,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolbarItem(Icons.share, "Share", 0),
          _buildToolbarItem(Icons.favorite_border, "Favorites", 1),
          _buildToolbarItem(Icons.edit, "Edit", 2),
          _buildToolbarItem(Icons.delete, "Delete", 3),
          SpeedDial(
            mini: true,
            icon: Icons.more_vert,
            buttonSize: const Size(24, 24),
            childrenButtonSize: const Size(24, 24),
            backgroundColor: AppColors.toolbar,
            elevation: 0,
            overlayColor: Colors.black,
            overlayOpacity: 0.4,
            spacing: 8,
            children: [
              SpeedDialChild(
                label: 'Change color',
                onTap: _showColorPickerDialog,
                backgroundColor: AppColors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarItem(IconData icon, String label, int index,
      [Function? onTap]) {
    return GestureDetector(
      onTap: () => onTap != null ? onTap() : widget.onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
        ],
      ),
    );
  }
}
