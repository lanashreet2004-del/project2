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
}
