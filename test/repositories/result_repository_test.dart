import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/repositories/result_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late ResultRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('result_repository_test');
  });

  setUp(() {
    repository = ResultRepository(
      apiService: ApiService(),
      storageService: StorageService(box: GetStorage('result_repository_test')),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  final ocrData = {
    'id': 'ocr_1',
    'text': 'extracted text',
    'language': 'ar',
    'processed_at': DateTime.utc(2026, 8, 14).toIso8601String(),
  };

  test('throws when OCR data is missing', () async {
    await expectLater(
      repository.getResult(
        id: 'ocr_1',
        ocrData: null,
        imagePath: '/tmp/image.jpg',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('throws when imagePath is missing or empty', () async {
    await expectLater(
      repository.getResult(id: 'ocr_1', ocrData: ocrData),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      repository.getResult(
        id: 'ocr_1',
        ocrData: ocrData,
        imagePath: '   ',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('maps a valid OCR payload without confidence', () async {
    final result = await repository.getResult(
      id: 'ocr_1',
      ocrData: ocrData,
      imagePath: '/tmp/image.jpg',
    );

    expect(result.id, 'ocr_1');
    expect(result.extractedText, 'extracted text');
    expect(result.imagePath, '/tmp/image.jpg');
    expect(result.extractedText, isNotEmpty);
    expectNoConfidenceFields(result.toJson());
  });
}
