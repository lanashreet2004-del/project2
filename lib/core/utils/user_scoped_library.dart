import '../constants/storage_keys.dart';
import '../services/storage_service.dart';

/// GetStorage keys for generated-file libraries, scoped to the signed-in user.
///
/// Unscoped keys (e.g. `pdf_files_library`) leaked exports across accounts.
/// Libraries are stored as `{baseKey}__{userId}`. Unsigned sessions see
/// an empty list and cannot write a global catalog.
class UserScopedLibrary {
  UserScopedLibrary._();

  static const libraryKeys = [
    StorageKeys.pdfFilesLibrary,
    StorageKeys.wordFilesLibrary,
    StorageKeys.excelFilesLibrary,
    StorageKeys.jsonFilesLibrary,
  ];

  static String? currentUserId(StorageService storage) {
    final id = storage.read<String>(StorageKeys.userId)?.trim();
    if (id == null || id.isEmpty) return null;
    return id;
  }

  static String keyFor(String baseKey, String userId) => '${baseKey}__$userId';

  static Future<List<dynamic>> read(
    StorageService storage,
    String baseKey,
  ) async {
    final userId = currentUserId(storage);
    if (userId == null) return const [];

    final scopedKey = keyFor(baseKey, userId);
    final scoped = storage.read<List<dynamic>>(scopedKey);
    if (scoped != null) return scoped;

    final legacy = storage.read<List<dynamic>>(baseKey);
    if (legacy == null || legacy.isEmpty) return const [];

    await storage.write(scopedKey, legacy);
    await storage.remove(baseKey);
    return legacy;
  }

  static Future<void> write(
    StorageService storage,
    String baseKey,
    List<dynamic> items,
  ) async {
    final userId = currentUserId(storage);
    if (userId == null) return;
    await storage.write(keyFor(baseKey, userId), items);
  }

  /// Moves leftover unscoped catalogs onto the signed-in user (logout / first load).
  static Future<void> migrateLegacyForCurrentUser(StorageService storage) async {
    for (final key in libraryKeys) {
      await read(storage, key);
    }
  }

  /// Drops unscoped catalogs when nobody is signed in so the next login cannot
  /// inherit another account's generated-file list.
  static Future<void> discardUnscopedIfUnsigned(StorageService storage) async {
    if (currentUserId(storage) != null) return;
    for (final key in libraryKeys) {
      await storage.remove(key);
    }
  }
}
