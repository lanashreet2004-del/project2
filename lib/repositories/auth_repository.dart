import '../core/constants/storage_keys.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Handles authentication API calls and token persistence.
class AuthRepository extends BaseRepository {
  AuthRepository({
    required super.apiService,
    required super.storageService,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Placeholder — replace with Dio call when backend is ready
  // final response = await apiService.post(
  //   ApiConstants.auth,
  //   data: {'email': email, 'password': password},
  // );
  // final user = UserModel.fromJson(response.data);
    final user = UserModel(id: '0', email: email);
    await _persistSession(user, token: 'placeholder_token');
    return user;
  }

  Future<void> signOut() async {
    apiService.setAuthToken(null);
    await storageService.remove(StorageKeys.authToken);
    await storageService.remove(StorageKeys.userId);
  }

  String? get storedToken => storageService.read<String>(StorageKeys.authToken);

  bool get isLoggedIn => storedToken != null;

  Future<void> _persistSession(UserModel user, {required String token}) async {
    apiService.setAuthToken(token);
    await storageService.write(StorageKeys.authToken, token);
    await storageService.write(StorageKeys.userId, user.id);
  }
}
