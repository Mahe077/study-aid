import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildSocialButton(
    {required IconData icon,
    required Color color,
    required VoidCallback onPressed}) {
  return IconButton(
    icon: FaIcon(icon, color: color),
    onPressed: onPressed,
    iconSize: 25,
  );
}
