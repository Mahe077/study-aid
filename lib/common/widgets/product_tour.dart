// import 'package:flutter/material.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:study_aid/common/helpers/product_tour_controller.dart';

// class ProductTour extends StatefulWidget {
//   final WidgetBuilder builder;
//   final GlobalKey firstTooltip;
//   final GlobalKey secondTooltip;

//   const ProductTour(
//       {super.key, required this.builder,
//       required this.firstTooltip,
//       required this.secondTooltip});

//   @override
//   State<ProductTour> createState() => _ProductTourState();
// }

// class _ProductTourState extends State<ProductTour> {
//   bool _isShowingStep = false;

//   @override
//   Widget build(BuildContext context) {
//   return ShowCaseWidget(
//     builder: (BuildContext showcaseContext) {
//       WidgetsBinding.instance.addPostFrameCallback(
//         (timeStamp) => handleProductTour(showcaseContext),
//       );
//       return widget.builder(context);
//     },
//   );
// }


//   void handleProductTour(BuildContext context) {
//     if (_isShowingStep) return;
//     if (productTourController.shouldShowWelcomePopup()) {
//       openWelcomePopup(context);
//     } else if (productTourController.shouldShowThanksPopup()) {
//       _openThanksPopup(context);
//     } else if (productTourController.shouldShowFirstTooltip()) {
//       ShowCaseWidget.of(context)
//           .startShowCase([widget.firstTooltip, widget.secondTooltip]);
//     } else if (productTourController.shouldShowSecondTooltip()) {
//       ShowCaseWidget.of(context).startShowCase([widget.secondTooltip]);
//     }
//   }

//   void openWelcomePopup(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _isShowingStep = true;
//       showDialog(
//           context: context,
//           builder: (ctx) => _MyPopup(
//               title: 'Welcome',
//               content: 'Welcome to the app!',
//               buttonText: 'Next')).then((value) {
//         _isShowingStep = false;
//         handleProductTour(context);
//       });
//     });
//   }

//   void _openThanksPopup(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _isShowingStep = true;
//       showDialog(
//           context: context,
//           builder: (ctx) => _MyPopup(
//                 title: 'Thanks',
//                 content: 'Thanks for using the app!',
//                 buttonText: 'Close',
//               )).then((value) {
//         _isShowingStep = false;
//         handleProductTour(context);
//       });
//     });
//   }
// }

// class _MyPopup extends StatelessWidget {
//   final String title;
//   final String content;
//   final String buttonText;

//   const _MyPopup(
//       {required this.title, required this.content, required this.buttonText});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(title),
//       content: Text(content),
//       actions: [
//         TextButton(
//           onPressed: () {
//             productTourController.nextStep();
//             Navigator.of(context).pop();
//           },
//           child: Text(buttonText),
//         ),
//       ],
//     );
//   }
// }