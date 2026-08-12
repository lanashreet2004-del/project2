/// API-related constants. Update base URL when integrating backend.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints — extend as features are implemented
  static const String auth = '/auth';
  static const String upload = '/upload';
  static const String results = '/results';
  static const String history = '/history';
}
