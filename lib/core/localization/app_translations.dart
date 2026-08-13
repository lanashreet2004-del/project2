import 'package:get/get.dart';

import 'translations/ar.dart';
import 'translations/en.dart';

/// GetX translation dictionaries for English and Arabic.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': enTranslations,
        'ar': arTranslations,
      };
}
