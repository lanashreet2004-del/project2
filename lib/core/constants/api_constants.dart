import 'package:flutter/foundation.dart';

/// API-related constants. Update host/paths when integrating backend.
class ApiConstants {
  ApiConstants._();

 static const String baseUrl = 'http://10.65.0.75:8000';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth (Django SimpleJWT)
  static const String signup = '/api/auth/signup/';
  static const String login = '/api/auth/login/';
  static const String logout = '/api/auth/logout/';

  // Placeholders for future features — not wired yet
  static const String upload = '/upload';
  static const String results = '/results';
  static const String history = '/history';
}
