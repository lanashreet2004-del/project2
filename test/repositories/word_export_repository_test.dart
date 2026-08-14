import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/export_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/word_export_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late WordExportRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('word_export_test');
  });

  setUp(() {
    repository = WordExportRepository(
      apiService: ApiService(),
      storageService: StorageService(box: GetStorage('word_export_test')),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('loads bundled fonts for Word export', () async {
    final regular = await rootBundle.load(
      ExportConstants.arabicRegularFontAsset,
    );
    final bold = await rootBundle.load(
      ExportConstants.arabicBoldFontAsset,
    );

    expect(regular.lengthInBytes, greaterThan(100000));
    expect(bold.lengthInBytes, greaterThan(100000));
  });

  test('generates DOCX bytes containing Arabic text offline', () async {
    const arabicText =
        'مرحباً بكم في تطبيق مكتوب.\n\n'
        'هذا نص تجريبي مستخرج من الصورة.';

    final document = HistoryModel(
      id: 'test_arabic_word',
      imagePath: '',
      extractedText: arabicText,
      createdAt: DateTime(2026, 6, 12, 14, 30),
    );
    expectNoConfidenceFields(document.toJson());

    final bytes = await repository.generateDocxBytes(document);

    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(1000));
    expect(bytes[0], equals(0x50));
    expect(bytes[1], equals(0x4B));
  });
}
