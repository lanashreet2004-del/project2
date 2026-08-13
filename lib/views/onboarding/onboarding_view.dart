import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/page_indicator.dart';

/// Onboarding screen with swipeable pages — UI only.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPageView(),
          _buildSkipButton(context),
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: controller.pageController,
      itemCount: OnboardingController.pageCount,
      onPageChanged: controller.onPageChanged,
      itemBuilder: (context, index) {
        final width = MediaQuery.sizeOf(context).width;
        final cacheWidth =
            (width * MediaQuery.devicePixelRatioOf(context)).round();
        return Image.asset(
          OnboardingController.pageImages[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.medium,
        );
      },
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Obx(() {
      if (controller.isLastPage) return const SizedBox.shrink();

      return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: controller.isLoading.value ? null : controller.skip,
              style: TextButton.styleFrom(
                // Photo overlay chrome — stays high-contrast on any image.
                foregroundColor: Colors.white,
                backgroundColor: Colors.black.withValues(alpha: 0.25),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('onboarding.skip'.tr),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomControls(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PageIndicator(
                  count: OnboardingController.pageCount,
                  activeIndex: controller.currentPage.value,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.nextPage,
                    style: FilledButton.styleFrom(
                      disabledBackgroundColor:
                          context.colors.primary.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.colors.onPrimary,
                            ),
                          )
                        : Text(
                            controller.isLastPage
                                ? 'onboarding.startNow'.tr
                                : 'onboarding.next'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
