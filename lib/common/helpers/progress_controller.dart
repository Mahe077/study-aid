import 'package:shared_preferences/shared_preferences.dart';

ProgressController get progressController => ProgressController._instance;

class ProgressController {
  static final ProgressController _instance = ProgressController._();
  ProgressController._();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  Future<void> init() async {
    _currentStep = await _ProgressRepository.getCurrentStep();
  }

  Future<void> progress() async {
    _currentStep++;
    await _ProgressRepository.saveCurrentStep(_currentStep);
  }
}

class _ProgressRepository {
  static const _currentStepKey = '_productTourCurrentStep';

  static Future<int> getCurrentStep() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(_currentStepKey) ?? 0;
  }

  static Future<void> saveCurrentStep(int currentStep) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(_currentStepKey, currentStep);
  }
}