import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/storage_keys.dart';
import '../core/utils/api_exception.dart';
import '../models/auth_tokens_response.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import 'base_repository.dart';

/// Authentication against Django SimpleJWT endpoints.
class AuthRepository extends BaseRepository {
  AuthRepository({
    required super.apiService,
    required super.storageService,
  });

  String? get storedAccessToken =>
      storageService.read<String>(StorageKeys.authToken);

  String? get storedRefreshToken =>
      storageService.read<String>(StorageKeys.refreshToken);

  bool get isLoggedIn {
    final token = storedAccessToken;
    return token != null && token.isNotEmpty;
  }

  /// Restores Bearer token into Dio after app restart.
  void restoreSession() {
    final access = storedAccessToken;
    if (access != null && access.isNotEmpty) {
      apiService.setAuthToken(access);
    } else {
      apiService.setAuthToken(null);
    }
  }

  /// Clears local session and navigates to login. Used on 401.
  Future<void> handleUnauthorized() async {
    await clearLocalSession();
    if (Get.currentRoute != AppRoutes.auth &&
        Get.currentRoute != AppRoutes.signUp) {
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  Future<UserModel> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        ApiConstants.login,
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      final data = _asMap(response.data);
      final tokens = AuthTokensResponse.fromJson(data);
      final user = UserModel(
        id: username.trim(),
        email: '',
        name: username.trim(),
      );
      await _persistSession(user, tokens: tokens);
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserModel> signUp({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await apiService.post(
        ApiConstants.signup,
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirm': passwordConfirm,
        },
      );

      final data = _asMap(response.data);
      final tokens = AuthTokensResponse.fromJson(data);
      final user = UserModel(
        id: username.trim(),
        email: email.trim(),
        name: username.trim(),
      );
      await _persistSession(user, tokens: tokens);
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Calls logout when a refresh token exists, then always clears local state.
  Future<void> signOut() async {
    final refresh = storedRefreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await apiService.post(
          ApiConstants.logout,
          data: {'refresh': refresh},
        );
      } on DioException {
        // Invalid/expired refresh still ends the local session.
      } catch (_) {
        // Swallow unexpected errors; local logout must complete.
      }
    }
    await clearLocalSession();
  }

  Future<void> clearLocalSession() async {
    apiService.setAuthToken(null);
    await storageService.remove(StorageKeys.authToken);
    await storageService.remove(StorageKeys.refreshToken);
    await storageService.remove(StorageKeys.userId);
    await storageService.remove(StorageKeys.userEmail);
    await storageService.remove(StorageKeys.userName);
  }

  UserModel? getCurrentUser() {
    if (!isLoggedIn) return null;

    final username = storageService.read<String>(StorageKeys.userName);
    final email = storageService.read<String>(StorageKeys.userEmail) ?? '';
    final id = storageService.read<String>(StorageKeys.userId) ??
        username ??
        'user';

    if ((username == null || username.isEmpty) && email.isEmpty) {
      return UserModel(id: id, email: email, name: id);
    }

    return UserModel(
      id: id,
      email: email,
      name: (username != null && username.isNotEmpty) ? username : id,
    );
  }

  Future<void> _persistSession(
    UserModel user, {
    required AuthTokensResponse tokens,
  }) async {
    apiService.setAuthToken(tokens.access);
    await storageService.write(StorageKeys.authToken, tokens.access);
    await storageService.write(StorageKeys.refreshToken, tokens.refresh);
    await storageService.write(StorageKeys.userId, user.id);
    await storageService.write(StorageKeys.userEmail, user.email);
    if (user.name != null) {
      await storageService.write(StorageKeys.userName, user.name);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException('Unexpected authentication response.');
  }
}
