import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

/// Central Dio HTTP client configuration.
/// All API requests must go through repositories using this service.
class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? _createDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthEndpoint = path.contains('/api/auth/login') ||
              path.contains('/api/auth/signup') ||
              path.contains('/api/auth/logout');

          if (status == 401 && !isAuthEndpoint && !_handlingUnauthorized) {
            _handlingUnauthorized = true;
            try {
              await onUnauthorized?.call();
            } finally {
              _handlingUnauthorized = false;
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  final Dio _dio;
  bool _handlingUnauthorized = false;

  /// Invoked once when a non-auth request returns 401.
  Future<void> Function()? onUnauthorized;

  Dio get client => _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) {
    return _dio.post<T>(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}
