import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/processing_controller.dart';
import '../../core/theme/app_colors.dart';

/// OCR processing screen with animated status — UI only.
class ProcessingView extends GetView<ProcessingController> {
  const ProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProcessingAnimation(isLoading: controller.isLoading.value),
                    const SizedBox(height: 32),
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 72,
                      color: AppColors.accent.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      controller.statusText.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please wait while we process your document',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (controller.hasError) ...[
                      const SizedBox(height: 24),
                      Text(
                        controller.errorMessage.value ?? 'Processing failed',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingAnimation extends StatefulWidget {
  const _ProcessingAnimation({required this.isLoading});

  final bool isLoading;

  @override
  State<_ProcessingAnimation> createState() => _ProcessingAnimationState();
}

class _ProcessingAnimationState extends State<_ProcessingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CircularProgressIndicator(
            value: widget.isLoading ? null : 1,
            strokeWidth: 5,
            color: AppColors.accent,
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
          );
        },
      ),
    );
  }
}
