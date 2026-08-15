import 'package:dio/dio.dart';

/// Normalized API failure for controllers/UI.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  static ApiException fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Request timed out. Please try again.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Unable to reach the server. Check your connection.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
        return ApiException('Secure connection failed.');
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled.');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    final status = error.response?.statusCode;
    final parsed = _parseResponseBody(error.response?.data);
    if (parsed != null && parsed.isNotEmpty) {
      return ApiException(parsed, statusCode: status);
    }

    switch (status) {
      case 400:
        return ApiException('Invalid request.', statusCode: status);
      case 401:
        return ApiException(
          'Authentication failed. Please sign in again.',
          statusCode: status,
        );
      case 403:
        return ApiException(
          'You do not have permission to perform this action.',
          statusCode: status,
        );
      case 404:
        return ApiException('Requested resource was not found.', statusCode: status);
      case 500:
      case 502:
      case 503:
        return ApiException(
          'Server error. Please try again later.',
          statusCode: status,
        );
      default:
        return ApiException(
          error.message ?? 'Something went wrong. Please try again.',
          statusCode: status,
        );
    }
  }

  /// Parses DRF `detail` strings and field-error maps.
  static String? _parseResponseBody(dynamic data) {
    if (data == null) return null;

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);

    final detail = map['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    if (detail is List && detail.isNotEmpty) {
      return detail.map((e) => e.toString()).join('\n');
    }

    final messages = <String>[];
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is List) {
        for (final item in value) {
          final text = item.toString().trim();
          if (text.isNotEmpty) messages.add(text);
        }
      } else if (value is String && value.trim().isNotEmpty) {
        messages.add(value.trim());
      }
    }

    if (messages.isEmpty) return null;
    return messages.join('\n');
  }
}
