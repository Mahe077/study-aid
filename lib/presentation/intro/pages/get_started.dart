import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:study_aid/common/widgets/buttons/basic_app_button.dart';
import 'package:study_aid/common/widgets/headings/headings.dart';
import 'package:study_aid/common/widgets/headings/sub_headings.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/authentication/presentation/pages/signup.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final PageController _pageController = PageController();

  List images = ["1.svg", "2.svg", "3.svg"];
  List headings = ["Stay Organized", "Make Voice", "Sync Everything"];
  List subHeadings = [
    'Organize your notes in a way they are welcoming you every time you see them.',
    'Record your own audio clips while you are studying to save time to enjoy your life.',
    'Forgot your usual device? Nothing to worry, we keep everything in sync across your devices.',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        itemBuilder: (_, index) {
          return Container(
            width: double.maxFinite,
            height: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
            child: Column(
              children: [
                const Spacer(),
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset("assets/vectors/${images[index]}"),
                ),
                const Spacer(),
                AppHeadings(
                  text: headings[index],
                ),
                const SizedBox(
                  height: 20,
                ),
                AppSubHeadings(
                  text: subHeadings[index],
                ),
                const SizedBox(
                  height: 30,
                ),
                if (index == images.length - 1)
                  BasicAppButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const SignupPage()));
                      },
                      title: 'Get Started'),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (indexDots) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                height: 10,
                                width: 8,
                                decoration: BoxDecoration(
                                  color: index == indexDots
                                      ? AppColors.primary
                                      : AppColors.grey,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                          // Right-align the Next button
                          if (index != (images.length - 1))
                            Positioned(
                              right: 0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8), // Add sufficient padding
                                  backgroundColor: Colors
                                      .white, // Adjust to your desired color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  elevation:
                                      0, // Optional: Remove shadow for a flat look
                                ),
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Next',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 15),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.primary,
                                      size: 17,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
