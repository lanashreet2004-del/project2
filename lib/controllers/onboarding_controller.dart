import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../repositories/onboarding_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Manages onboarding PageView state and navigation.
class OnboardingController extends BaseController {
  OnboardingController({required OnboardingRepository repository})
      : _repository = repository;

  final OnboardingRepository _repository;

  static const int pageCount = 3;

  static const List<String> pageImages = [
    AppConstants.onboardingImage1,
    AppConstants.onboardingImage2,
    AppConstants.onboardingImage3,
  ];

  late final PageController pageController;
  final RxInt currentPage = 0.obs;

  bool get isLastPage => currentPage.value == pageCount - 1;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
      return;
    }

    pageController.nextPage(
      duration: AppConstants.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void skip() => completeOnboarding();

  Future<void> completeOnboarding() async {
    await runAsync(() async {
      await _repository.markOnboardingComplete();
      Get.offAllNamed(AppRoutes.home);
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
