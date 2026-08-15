import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Controller for authentication presentation logic.
class AuthController extends BaseController {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();

  bool get isAuthenticated => user.value != null || _repository.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    user.value = _repository.getCurrentUser();
  }

  Future<void> signIn() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final result = await runAsync(
      () => _repository.signIn(
        username: usernameController.text.trim(),
        password: passwordController.text,
      ),
    );

    if (result == null) return;

    user.value = result;
    Get.snackbar(
      'auth.successTitle'.tr,
      'auth.successBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    _leaveAuthFlow();
  }

  Future<void> signUp() async {
    if (isLoading.value) return;
    if (!(signUpFormKey.currentState?.validate() ?? false)) return;

    final result = await runAsync(
      () => _repository.signUp(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirm: confirmPasswordController.text,
      ),
    );

    if (result == null) return;

    user.value = result;
    Get.snackbar(
      'auth.signUpSuccessTitle'.tr,
      'auth.signUpSuccessBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    _leaveAuthFlow();
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
    await runAsync(_repository.signOut);
    user.value = null;
  }

  void _leaveAuthFlow() {
    // Always replace the stack so snackbar overlays cannot steal Get.back(),
    // and Android Back from Home cannot return to Login/Sign Up.
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
