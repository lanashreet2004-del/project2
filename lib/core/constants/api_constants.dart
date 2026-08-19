/// API-related constants. Update host/paths when integrating backend.
class ApiConstants {
  ApiConstants._();

  //static const String baseUrl = 'http://10.166.10.66:8000'
  static const String baseUrl = 'http://10.230.155.66:8000';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth (Django SimpleJWT)
  static const String signup = '/api/auth/signup/';
  static const String login = '/api/auth/login/';
  static const String logout = '/api/auth/logout/';

  // OCR (Django)
  static const String processOcr = '/api/process-ocr/';
  static const String ocrHistory = '/api/ocr-history/';
  static String ocrStatus(Object id) => '/api/ocr-status/$id/';
  static String ocrExportPdf(Object id) => '/api/export-ocr/$id/pdf/';
  static String ocrExportDocx(Object id) => '/api/export-ocr/$id/docx/';
  static String ocrExportXlsx(Object id) => '/api/export-ocr/$id/xlsx/';

  // Placeholders for future features — not wired yet
  static const String upload = '/upload';
  static const String results = '/results';
  static const String history = '/history';
}
