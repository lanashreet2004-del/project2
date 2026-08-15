import '../core/utils/api_exception.dart';

/// JWT payload returned by signup/login (and optional detail from signup/logout).
class AuthTokensResponse {
  const AuthTokensResponse({
    required this.access,
    required this.refresh,
    this.detail,
  });

  final String access;
  final String refresh;
  final String? detail;

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    final access = json['access'] as String?;
    final refresh = json['refresh'] as String?;
    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty) {
      throw ApiException('Auth response missing access or refresh token');
    }

    return AuthTokensResponse(
      access: access,
      refresh: refresh,
      detail: json['detail'] as String?,
    );
  }
}
