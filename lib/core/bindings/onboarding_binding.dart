import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';
import '../../repositories/onboarding_repository.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        repository: Get.find<OnboardingRepository>(),
      ),
    );
  }
}
