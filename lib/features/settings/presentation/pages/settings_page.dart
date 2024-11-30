import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/common/widgets/appbar/basic_app_bar.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart'
    as UserProvider;
import 'package:study_aid/features/authentication/presentation/notifiers/auth_notifier.dart';
import 'package:study_aid/features/authentication/presentation/pages/signin.dart';
import 'package:study_aid/features/settings/presentation/pages/account_page.dart';
import 'package:widgets_easier/widgets_easier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const BasicAppbar(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppHeadings(
                          text: 'Settings',
                          alignment: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: const ShapeDecoration(
                      shape: DashedBorder(color: AppColors.primary)),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const AccountPage(),
                            ),
                          )
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            backgroundColor: AppColors.grey.withOpacity(0.81)),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 25,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Account settings',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => {Logger().i("Apperance")},
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            backgroundColor: AppColors.grey.withOpacity(0.81)),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.brush,
                              size: 25,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Apperance',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => {Logger().i("Notifications")},
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            backgroundColor: AppColors.grey.withOpacity(0.81)),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              size: 25,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Notifications',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: BasicAppButton(
                      onPressed: () async {
                        final userNotifier = ref.read(userProvider.notifier);
                        await userNotifier.signOut();

                        ref.invalidate(UserProvider.userProvider);

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const SigninPage()),
                            (route) => false);
                      },
                      icon: Icons.logout,
                      title: 'Sign Out'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
