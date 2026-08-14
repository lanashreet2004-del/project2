import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/app_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/json_export_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late JsonExportRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('json_export_repository_test');
  });

  setUp(() {
    repository = JsonExportRepository(
      apiService: ApiService(),
      storageService: StorageService(
        box: GetStorage('json_export_repository_test'),
      ),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  HistoryModel sampleDocument() => HistoryModel(
        id: 'doc_json_1',
        imagePath: '${docsDir.path}${Platform.pathSeparator}DocumentImages'
            '${Platform.pathSeparator}doc_json_1.jpg',
        extractedText: 'مرحباً بكم في تطبيق مكتوب.',
        createdAt: DateTime.utc(2026, 6, 12, 14, 30),
      );

  test('builds parseable JSON with document data and no confidence', () {
    final document = sampleDocument();
    final payload = repository.buildExportPayload(
      document: document,
      status: 'Processed',
      sourceType: 'gallery',
      wordCount: 5,
      characterCount: document.extractedText.length,
      lineCount: 1,
    );

    expectNoConfidenceFields(payload);
    expect(payload['documentInfo']['id'], 'doc_json_1');
    expect(payload['ocrResult']['text'], document.extractedText);
    expect(payload['source']['imagePath'], document.imagePath);
    expect(payload['metadata']['appVersion'], AppConstants.appVersion);

    final pretty = repository.formatPrettyJson(payload);
    final parsed = jsonDecode(pretty) as Map<String, dynamic>;
    expect(parsed['ocrResult']['text'], document.extractedText);
    expectNoConfidenceFields(parsed);

    final validation = repository.validateExportPayload(payload);
    expect(validation.isValid, isTrue);
  });

  test('rejects a payload with empty extracted text', () {
    final payload = repository.buildExportPayload(
      document: HistoryModel(
        id: 'doc_json_empty',
        imagePath: '/tmp/a.jpg',
        extractedText: '   ',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      status: 'Processed',
      sourceType: 'camera',
      wordCount: 0,
      characterCount: 0,
      lineCount: 0,
    );

    final validation = repository.validateExportPayload(payload);
    expect(validation.isValid, isFalse);
  });

  test('writes a JSON export file for a valid document', () async {
    final document = sampleDocument();
    final file = await repository.exportDocumentToJson(
      document: document,
      status: 'Processed',
      sourceType: 'gallery',
      wordCount: 5,
      characterCount: document.extractedText.length,
      lineCount: 1,
    );

    expect(file, isNotNull);
    expect(await file!.exists(), isTrue);

    final parsed = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(parsed['ocrResult']['text'], document.extractedText);
    expect(parsed['source']['imagePath'], document.imagePath);
    expectNoConfidenceFields(parsed);
  });
}
