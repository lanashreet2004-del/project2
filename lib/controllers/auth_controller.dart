import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Controller for authentication presentation logic (frontend-only session).
class AuthController extends BaseController {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool obscurePassword = true.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();

  bool get isAuthenticated => user.value != null || _repository.isLoggedIn;

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final result = await runAsync(
      () => _repository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );

    if (result != null) {
      user.value = result;
      Get.snackbar(
        'auth.successTitle'.tr,
        'auth.successBody'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (Get.key.currentState?.canPop() ?? false) {
        Get.back(result: true);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    user.value = null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
