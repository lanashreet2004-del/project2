import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/storage_keys.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/core/utils/user_scoped_library.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late StorageService storage;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('user_scoped_library_test');
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  setUp(() async {
    storage = StorageService(box: GetStorage('user_scoped_library_test'));
    await GetStorage('user_scoped_library_test').erase();
  });

  test('read and write are scoped to the signed-in user', () async {
    await storage.write(StorageKeys.userId, 'alice');
    await UserScopedLibrary.write(
      storage,
      StorageKeys.excelFilesLibrary,
      [
        {'id': 'a1', 'fileName': 'a.xlsx'},
      ],
    );

    await storage.write(StorageKeys.userId, 'bob');
    expect(
      await UserScopedLibrary.read(storage, StorageKeys.excelFilesLibrary),
      isEmpty,
    );

    await storage.write(StorageKeys.userId, 'alice');
    final alice = await UserScopedLibrary.read(
      storage,
      StorageKeys.excelFilesLibrary,
    );
    expect(alice, isNotEmpty);
    expect(alice.first['id'], 'a1');
  });

  test('legacy unscoped catalog migrates to the signed-in user only', () async {
    await storage.write(StorageKeys.excelFilesLibrary, [
      {'id': 'legacy', 'fileName': 'old.xlsx'},
    ]);
    await storage.write(StorageKeys.userId, 'alice');

    final migrated = await UserScopedLibrary.read(
      storage,
      StorageKeys.excelFilesLibrary,
    );
    expect(migrated.first['id'], 'legacy');
    expect(storage.read<List<dynamic>>(StorageKeys.excelFilesLibrary), isNull);

    await storage.write(StorageKeys.userId, 'bob');
    expect(
      await UserScopedLibrary.read(storage, StorageKeys.excelFilesLibrary),
      isEmpty,
    );
  });

  test('unsigned session discards leftover unscoped catalogs', () async {
    await storage.write(StorageKeys.pdfFilesLibrary, [
      {'id': 'leak', 'fileName': 'a.pdf'},
    ]);

    await UserScopedLibrary.discardUnscopedIfUnsigned(storage);
    expect(storage.read<List<dynamic>>(StorageKeys.pdfFilesLibrary), isNull);

    await storage.write(StorageKeys.userId, 'bob');
    expect(
      await UserScopedLibrary.read(storage, StorageKeys.pdfFilesLibrary),
      isEmpty,
    );
  });
}
