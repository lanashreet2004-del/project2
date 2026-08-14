import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../routes/app_pages.dart';
import 'base_controller.dart';

/// Brief branded splash, then the existing onboarding/home destination.
class SplashController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void onReady() {
    super.onReady();
    _continueToApp();
  }

  Future<void> _continueToApp() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (isClosed) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (isClosed) return;
    Get.offAllNamed(AppPages.afterSplash);
  }

  @override
  void onClose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}
