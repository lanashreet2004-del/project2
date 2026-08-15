import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import 'widgets/auth_form_widgets.dart';

/// Sign-up screen — Django SimpleJWT registration.
class SignUpView extends GetView<AuthController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('auth.signUp'.tr),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: AuthFadeIn(
                    child: Obx(() {
                      final loading = controller.isLoading.value;
                      final error = controller.errorMessage.value;

                      return AutofillGroup(
                        child: Form(
                          key: controller.signUpFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthHeader(
                                title: 'auth.signUpTitle'.tr,
                                subtitle: 'auth.signUpSubtitle'.tr,
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: controller.usernameController,
                                decoration: InputDecoration(
                                  labelText: 'auth.username'.tr,
                                  hintText: 'auth.usernameHint'.tr,
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                validator: Validators.username,
                                enabled: !loading,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: controller.emailController,
                                decoration: InputDecoration(
                                  labelText: 'auth.email'.tr,
                                  hintText: 'auth.emailHint'.tr,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: Validators.email,
                                enabled: !loading,
                              ),
                              const SizedBox(height: 16),
                              AuthPasswordField(
                                controller: controller.passwordController,
                                label: 'auth.password'.tr,
                                obscure: controller.obscurePassword.value,
                                onToggleVisibility:
                                    controller.togglePasswordVisibility,
                                validator: Validators.password,
                                enabled: !loading,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              AuthPasswordField(
                                controller: controller.confirmPasswordController,
                                label: 'auth.confirmPassword'.tr,
                                obscure:
                                    controller.obscureConfirmPassword.value,
                                onToggleVisibility: controller
                                    .toggleConfirmPasswordVisibility,
                                validator: (value) =>
                                    Validators.confirmPassword(
                                  value,
                                  controller.passwordController.text,
                                ),
                                enabled: !loading,
                                onSubmitted: (_) => controller.signUp(),
                              ),
                              const SizedBox(height: 24),
                              if (error != null) ...[
                                AuthErrorBanner(message: error),
                                const SizedBox(height: 16),
                              ],
                              AuthSubmitButton(
                                label: 'auth.createAccount'.tr,
                                isLoading: loading,
                                onPressed: controller.signUp,
                              ),
                              const SizedBox(height: 16),
                              AuthSwitchPrompt(
                                prompt: 'auth.hasAccount'.tr,
                                actionLabel: 'auth.signIn'.tr,
                                onAction:
                                    loading ? null : controller.openSignIn,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
