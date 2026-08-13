import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

/// Editing tools: crop, rotate, retake, and brightness slider.
class ImageEditorToolbar extends StatelessWidget {
  const ImageEditorToolbar({
    super.key,
    required this.brightness,
    required this.minBrightness,
    required this.maxBrightness,
    required this.onCrop,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onRetake,
    required this.onBrightnessChanged,
    required this.isBusy,
  });

  final double brightness;
  final double minBrightness;
  final double maxBrightness;
  final VoidCallback onCrop;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onRetake;
  final ValueChanged<double> onBrightnessChanged;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(
                icon: Icons.crop,
                label: 'editor.crop'.tr,
                onTap: isBusy ? null : onCrop,
              ),
              _ToolButton(
                icon: Icons.rotate_left,
                label: 'editor.rotateLeft'.tr,
                onTap: isBusy ? null : onRotateLeft,
              ),
              _ToolButton(
                icon: Icons.rotate_right,
                label: 'editor.rotateRight'.tr,
                onTap: isBusy ? null : onRotateRight,
              ),
              _ToolButton(
                icon: Icons.refresh,
                label: 'editor.retake'.tr,
                onTap: isBusy ? null : onRetake,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.brightness_6_outlined, size: 20),
              Expanded(
                child: Slider(
                  value: brightness,
                  min: minBrightness,
                  max: maxBrightness,
                  divisions: 15,
                  label: brightness.toStringAsFixed(1),
                  onChanged: isBusy ? null : onBrightnessChanged,
                  activeColor: context.colors.primary,
                ),
              ),
              Text(
                brightness.toStringAsFixed(1),
                style: context.texts.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap == null
                  ? context.colors.onSurface.withValues(alpha: 0.38)
                  : context.colors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.texts.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
