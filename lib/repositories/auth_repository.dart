import '../core/constants/storage_keys.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Handles authentication session persistence (frontend-only for now).
/// Real API calls are deferred until the backend is available.
class AuthRepository extends BaseRepository {
  AuthRepository({
    required super.apiService,
    required super.storageService,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Backend-dependent — replace with Dio when the login contract is ready.
    // final response = await apiService.post(
    //   ApiConstants.auth,
    //   data: {'email': email, 'password': password},
    // );
    final trimmedEmail = email.trim();
    final name = _displayNameFromEmail(trimmedEmail);
    final user = UserModel(id: 'local_user', email: trimmedEmail, name: name);
    await _persistSession(user, token: 'placeholder_token');
    return user;
  }

  /// Local demo registration. Persists the same frontend session as [signIn].
  /// Backend-dependent: do not invent an endpoint until the contract exists.
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Backend-dependent — plug in when the registration contract is available.
    // final response = await apiService.post(
    //   ApiConstants.auth,
    //   data: {'name': name, 'email': email, 'password': password},
    // );
    final trimmedEmail = email.trim();
    final trimmedName = name.trim();
    final user = UserModel(
      id: 'local_user',
      email: trimmedEmail,
      name: trimmedName.isEmpty
          ? _displayNameFromEmail(trimmedEmail)
          : trimmedName,
    );
    await _persistSession(user, token: 'placeholder_token');
    return user;
  }

  Future<void> signOut() async {
    apiService.setAuthToken(null);
    await storageService.remove(StorageKeys.authToken);
    await storageService.remove(StorageKeys.userId);
    await storageService.remove(StorageKeys.userEmail);
    await storageService.remove(StorageKeys.userName);
  }

  String? get storedToken => storageService.read<String>(StorageKeys.authToken);

  bool get isLoggedIn => storedToken != null;

  UserModel? getCurrentUser() {
    if (!isLoggedIn) return null;

    final email = storageService.read<String>(StorageKeys.userEmail);
    if (email == null || email.isEmpty) {
      return const UserModel(id: 'local_user', email: 'user@local', name: 'User');
    }

    final id = storageService.read<String>(StorageKeys.userId) ?? 'local_user';
    final name = storageService.read<String>(StorageKeys.userName) ??
        _displayNameFromEmail(email);

    return UserModel(id: id, email: email, name: name);
  }

  Future<void> _persistSession(UserModel user, {required String token}) async {
    apiService.setAuthToken(token);
    await storageService.write(StorageKeys.authToken, token);
    await storageService.write(StorageKeys.userId, user.id);
    await storageService.write(StorageKeys.userEmail, user.email);
    if (user.name != null) {
      await storageService.write(StorageKeys.userName, user.name);
    }
  }

  String _displayNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}
