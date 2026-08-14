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
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();

  bool get isAuthenticated => user.value != null || _repository.isLoggedIn;

  Future<void> signIn() async {
    if (isLoading.value) return;
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
      _leaveAuthFlow();
      return;
    }

    if (hasError) {
      setError('auth.errorGeneric'.tr);
    }
  }

  Future<void> signUp() async {
    if (isLoading.value) return;
    if (!(signUpFormKey.currentState?.validate() ?? false)) return;

    final result = await runAsync(
      () => _repository.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );

    if (result != null) {
      user.value = result;
      Get.snackbar(
        'auth.signUpSuccessTitle'.tr,
        'auth.signUpSuccessBody'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      _leaveAuthFlow();
      return;
    }

    if (hasError) {
      setError('auth.signUpErrorGeneric'.tr);
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void openSignUp() {
    clearError();
    Get.toNamed(AppRoutes.signUp);
  }

  void openSignIn() {
    clearError();
    if (Get.previousRoute == AppRoutes.auth) {
      Get.back();
      return;
    }
    Get.offNamed(AppRoutes.auth);
  }

  void showForgotPasswordUnavailable() {
    Get.snackbar(
      'auth.forgotPassword'.tr,
      'auth.forgotUnavailable'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    user.value = null;
  }

  void _leaveAuthFlow() {
    if (Get.currentRoute == AppRoutes.signUp) {
      Get.back();
    }

    if (Get.key.currentState?.canPop() ?? false) {
      Get.back(result: true);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
