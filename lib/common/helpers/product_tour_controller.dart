import 'package:flutter/material.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'package:study_aid/common/helpers/progress_controller.dart';

ProductTourController get productTourController =>
    ProductTourController._instance;

class ProductTourController {
  static final ProductTourController _instance = ProductTourController._();
  ProductTourController._();

  Future<void> init() async {
    await progressController.init();
  }

  bool shouldShowWelcomePopup() => progressController.currentStep == 0;
  bool shouldShowFirstTooltip() => progressController.currentStep == 1;
  bool shouldShowSecondTooltip() => progressController.currentStep == 2;
  bool shouldShowThanksPopup() => progressController.currentStep == 3;

  void nextStep({BuildContext? context}) {
    progressController.progress();
    if (context != null) {
      // ShowCaseWidget.of(context).next();
    }
  }
}