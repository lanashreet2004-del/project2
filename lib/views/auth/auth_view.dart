import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import 'widgets/auth_form_widgets.dart';

/// Sign-in screen — Django SimpleJWT login.
class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('auth.title'.tr),
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
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthHeader(
                                title: 'auth.welcomeBack'.tr,
                                subtitle: 'auth.signInSubtitle'.tr,
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
                              AuthPasswordField(
                                controller: controller.passwordController,
                                label: 'auth.password'.tr,
                                obscure: controller.obscurePassword.value,
                                onToggleVisibility:
                                    controller.togglePasswordVisibility,
                                validator: Validators.password,
                                enabled: !loading,
                                onSubmitted: (_) => controller.signIn(),
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  onPressed: loading
                                      ? null
                                      : controller
                                          .showForgotPasswordUnavailable,
                                  child: Text('auth.forgotPassword'.tr),
                                ),
                              ),
                              if (error != null) ...[
                                AuthErrorBanner(message: error),
                                const SizedBox(height: 16),
                              ],
                              AuthSubmitButton(
                                label: 'auth.signIn'.tr,
                                isLoading: loading,
                                onPressed: controller.signIn,
                              ),
                              const SizedBox(height: 16),
                              AuthSwitchPrompt(
                                prompt: 'auth.noAccount'.tr,
                                actionLabel: 'auth.signUp'.tr,
                                onAction:
                                    loading ? null : controller.openSignUp,
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
