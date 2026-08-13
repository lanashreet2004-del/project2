import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/processing_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/wavy_app_bar.dart';

/// OCR processing screen with processing / failure / retry states.
class ProcessingView extends GetView<ProcessingController> {
  const ProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final failed = controller.hasFailed.value;
      final loading = controller.isLoading.value;

      return PopScope(
        canPop: failed || !loading,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (failed) {
            controller.goBack();
          }
        },
        child: Scaffold(
          backgroundColor: context.colors.surfaceContainerLowest,
          appBar: failed
              ? WavyAppBar(
                  title: Text('processing.title'.tr),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.goBack,
                  ),
                )
              : null,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProcessingAnimation(
                      isLoading: loading && !failed,
                      hasFailed: failed,
                    ),
                    const SizedBox(height: 32),
                    Icon(
                      failed
                          ? Icons.error_outline
                          : Icons.document_scanner_outlined,
                      size: 72,
                      color: failed
                          ? context.colors.error.withValues(alpha: 0.85)
                          : context.colors.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      controller.statusText.value.tr,
                      style: context.texts.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      failed
                          ? 'processing.errorBody'.tr
                          : 'processing.wait'.tr,
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (failed) ...[
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value ?? 'processing.failed'.tr,
                        style: TextStyle(color: context.colors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: controller.retry,
                          icon: const Icon(Icons.refresh),
                          label: Text('common.retry'.tr),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: controller.goBack,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text('common.goBack'.tr),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ProcessingAnimation extends StatefulWidget {
  const _ProcessingAnimation({
    required this.isLoading,
    required this.hasFailed,
  });

  final bool isLoading;
  final bool hasFailed;

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
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _ProcessingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasFailed) {
      return Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.error.withValues(alpha: 0.1),
        ),
        child: Icon(Icons.close, color: context.colors.error, size: 40),
      );
    }

    return SizedBox(
      width: 88,
      height: 88,
      child: CircularProgressIndicator(
        value: widget.isLoading ? null : 1,
        strokeWidth: 5,
        color: context.colors.primary,
        backgroundColor: context.colors.primary.withValues(alpha: 0.15),
      ),
    );
  }
}
