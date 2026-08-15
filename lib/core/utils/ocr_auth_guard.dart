import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

/// Shared gate so Camera and Gallery cannot start OCR without a session.
class OcrAuthGuard {
  OcrAuthGuard._();

  /// Returns true when [authRepository.isLoggedIn]; otherwise shows dialog.
  static Future<bool> ensureAuthenticated(AuthRepository authRepository) async {
    if (authRepository.isLoggedIn) return true;

    final action = await Get.dialog<String>(
      AlertDialog(
        title: Text('ocr.authRequiredTitle'.tr),
        content: Text('ocr.authRequiredBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: 'cancel'),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: 'signup'),
            child: Text('auth.signUp'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: 'login'),
            child: Text('auth.signIn'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (action == 'login') {
      await Get.toNamed(AppRoutes.auth);
    } else if (action == 'signup') {
      await Get.toNamed(AppRoutes.signUp);
    }

    return authRepository.isLoggedIn;
  }
}
