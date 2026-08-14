import 'package:get/get.dart';

/// Form validation helpers with localized messages.
class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.validation.fieldRequired'.trParams({'field': fieldName});
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.validation.emailRequired'.tr;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'auth.validation.emailInvalid'.tr;
    }
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value == null || value.length < min) {
      return 'auth.validation.minLength'.trParams({
        'field': fieldName,
        'min': '$min',
      });
    }
    return null;
  }

  static String? fullName(String? value, {int min = 2}) {
    final requiredError = required(value, fieldName: 'auth.fullName'.tr);
    if (requiredError != null) return requiredError;
    return minLength(value?.trim(), min, fieldName: 'auth.fullName'.tr);
  }

  static String? password(String? value, {int min = 8}) {
    final requiredError = required(value, fieldName: 'auth.password'.tr);
    if (requiredError != null) return requiredError;
    return minLength(value, min, fieldName: 'auth.password'.tr);
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = required(value, fieldName: 'auth.confirmPassword'.tr);
    if (requiredError != null) return requiredError;
    if (value != password) {
      return 'auth.validation.passwordMismatch'.tr;
    }
    return null;
  }
}
