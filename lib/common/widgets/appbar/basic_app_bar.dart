import 'package:flutter/material.dart';
import 'package:study_aid/presentation/intro/pages/get_started.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? action;
  final Color? backgroundColor;
  final bool hideBack;
  const BasicAppbar(
      {this.title,
      this.hideBack = false,
      this.action,
      this.backgroundColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      actions: [
        if (hideBack)
          IconButton(
            onPressed: () {
              // TODO: implement suffix icon action
            },
            icon: const Icon(
              Icons.person,
              size: 25,
              color: Colors.black,
            ),
          ),
        if (action != null) action!
      ],
      leadingWidth: hideBack ? 56 : 100,
      leading: hideBack
          ? IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const GetStartedPage()));
              }, //TODO: implement the menu
              icon: const Icon(
                Icons.menu,
                size: 25,
                color: Colors.black,
              ),
            )
          : IconButton(
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
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
