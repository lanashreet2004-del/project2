import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../core/navigation/main_navigation.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Frontend-only account/profile presentation logic.
class ProfileController extends BaseController {
  ProfileController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshSession();
  }

  void refreshSession() {
    isLoggedIn.value = _authRepository.isLoggedIn;
    user.value = _authRepository.getCurrentUser();
  }

  Future<void> openSignIn() async {
    await Get.toNamed(AppRoutes.auth);
    refreshSession();
  }

  Future<void> openSettings() async {
    MainNavigation.openTab(MainNavigation.settings);
  }

  Future<void> signOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('profile.signOutTitle'.tr),
        content: Text('profile.signOutBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('drawer.signOut'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await runAsync(() => _authRepository.signOut());
    refreshSession();

    Get.snackbar(
      'profile.signedOutTitle'.tr,
      'profile.signedOutBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
