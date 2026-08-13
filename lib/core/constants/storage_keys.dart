/// GetStorage key constants for local persistence.
class StorageKeys {
  StorageKeys._();

  static const String darkMode = 'dark_mode'; // legacy bool — migrated to themeMode
  static const String themeMode = 'theme_mode'; // light | dark | system
  static const String locale = 'locale'; // ar | en
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String onboardingComplete = 'onboarding_complete';
  static const String documentHistory = 'document_history';
  static const String pdfFilesLibrary = 'pdf_files_library';
  static const String jsonFilesLibrary = 'json_files_library';
  static const String wordFilesLibrary = 'word_files_library';
}
