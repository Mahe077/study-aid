import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/presentation/settings/pages/settings_page.dart';

class BasicAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? action;
  final Color? backgroundColor;
  final bool hideBack;
  final bool showMenu;

  const BasicAppbar(
      {this.title,
      this.hideBack = false,
      this.showMenu = false,
      this.action,
      this.backgroundColor,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      actions: [
        if (showMenu)
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SettingsPage()));
            },
            icon: const Icon(
              Icons.menu,
              size: 25,
              color: Colors.black,
            ),
          )
      ],
      leadingWidth: hideBack ? 56 : 100,
      leading: !hideBack
          ? IconButton(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 17,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
