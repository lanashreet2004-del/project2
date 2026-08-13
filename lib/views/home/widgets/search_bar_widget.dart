import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

/// Reusable rounded search bar with optional clear action.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.showClear = false,
    this.readOnly = false,
    this.autofocus = false,
    this.hintText,
    this.glassStyle = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool showClear;
  final bool readOnly;
  final bool autofocus;
  final String? hintText;
  final bool glassStyle;

  @override
  Widget build(BuildContext context) {
    final fill = glassStyle
        ? Colors.white.withValues(alpha: context.isDark ? 0.92 : 0.88)
        : context.colors.surface;
    final borderColor = glassStyle
        ? Colors.white.withValues(alpha: 0.55)
        : context.appColors.cardBorder;
    final hintColor = context.colors.onSurfaceVariant.withValues(alpha: 0.75);

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      style: context.texts.bodyMedium?.copyWith(color: context.colors.onSurface),
      decoration: InputDecoration(
        hintText: hintText ?? 'home.searchHint'.tr,
        hintStyle: context.texts.bodyMedium?.copyWith(color: hintColor),
        prefixIcon: Icon(
          Icons.search,
          color: hintColor,
        ),
        suffixIcon: showClear
            ? IconButton(
                tooltip: 'home.clearSearch'.tr,
                onPressed: onClear,
                icon: Icon(
                  Icons.close,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              )
            : null,
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: glassStyle ? borderColor : context.colors.primary,
            width: glassStyle ? 1 : 1.5,
          ),
        ),
      ),
    );

    if (!glassStyle) return field;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: field,
    );
  }
}
