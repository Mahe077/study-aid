import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/authentication/presentation/notifiers/auth_notifier.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/presentation/intro/pages/get_started.dart';

class BasicAppbar extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      actions: [
        if (hideBack)
          IconButton(
            onPressed: () async {
              final userNotifier = ref.read(userProvider.notifier);
              await userNotifier.signOut();

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SigninPage()),
                  (route) => false);
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
                // TODO:menu implementation add here
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
