import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/repositories/ocr_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late OcrRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('ocr_repository_test');
  });

  setUp(() {
    repository = OcrRepository(
      apiService: ApiService(),
      storageService: StorageService(box: GetStorage('ocr_repository_test')),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('mock OCR returns extracted text without confidence', () async {
    final source = await writeTestImage(docsDir, name: 'ocr_input.jpg');
    expect(await source.exists(), isTrue);

    final result = await repository.processImage(imagePath: source.path);

    expect(result['text'], isA<String>());
    expect((result['text'] as String).trim(), isNotEmpty);
    expect(result['id'], isNotEmpty);
    expect(result['language'], 'ar');
    expect(result['processed_at'], isNotEmpty);
    expectNoConfidenceFields(result);
    expect(source.path, isNotEmpty);
  });
}
