import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/history_repository.dart';
import 'package:p2/repositories/ocr_repository.dart';
import 'package:p2/repositories/result_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late Directory sourceDir;
  late StorageService storage;
  late HistoryRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    sourceDir = Directory(
      '${docsDir.parent.path}${Platform.pathSeparator}source',
    );
    await sourceDir.create(recursive: true);
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('history_repository_test');
  });

  setUp(() async {
    storage = StorageService(box: GetStorage('history_repository_test'));
    await storage.clear();
    repository = HistoryRepository(
      apiService: ApiService(),
      storageService: storage,
    );
  });

  tearDown(() async {
    await storage.clear();
    final images = Directory(
      '${docsDir.path}${Platform.pathSeparator}DocumentImages',
    );
    if (await images.exists()) {
      await images.delete(recursive: true);
    }
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  Future<HistoryModel> saveSample({
    required String id,
    required String imagePath,
    String text = 'extracted sample text',
    DateTime? createdAt,
  }) {
    return repository.saveDocument(
      HistoryModel(
        id: id,
        imagePath: imagePath,
        extractedText: text,
        createdAt: createdAt ?? DateTime.utc(2026, 8, 14, 12),
      ),
    );
  }

  String documentImagesPath(String id, {String ext = '.jpg'}) {
    return '${docsDir.path}${Platform.pathSeparator}DocumentImages'
        '${Platform.pathSeparator}$id$ext';
  }

  group('image persistence', () {
    test('copies a temporary image into DocumentImages on save', () async {
      final source = await writeTestImage(sourceDir, name: 'capture.jpg');
      expect(await source.exists(), isTrue);

      final saved = await saveSample(
        id: 'doc_persist',
        imagePath: source.path,
        text: 'مرحباً بكم',
      );

      final permanentPath = documentImagesPath('doc_persist');
      expect(saved.imagePath, permanentPath);
      expect(File(saved.imagePath).existsSync(), isTrue);
      expect(saved.extractedText, 'مرحباً بكم');
      expect(await source.exists(), isTrue);

      final loaded = await repository.getDocuments();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'doc_persist');
      expect(loaded.first.imagePath, permanentPath);
      expect(File(loaded.first.imagePath).existsSync(), isTrue);
      expectNoConfidenceFields(loaded.first.toJson());
    });
  });

  group('missing image protection', () {
    test('does not save when imagePath is empty', () async {
      await expectLater(
        saveSample(id: 'doc_empty_path', imagePath: ''),
        throwsA(isA<Exception>()),
      );

      expect(await repository.getDocuments(), isEmpty);
      expect(File(documentImagesPath('doc_empty_path')).existsSync(), isFalse);
    });

    test('does not save when imagePath points to a missing file', () async {
      final missing = File(
        '${sourceDir.path}${Platform.pathSeparator}missing.jpg',
      );

      await expectLater(
        saveSample(id: 'doc_missing_file', imagePath: missing.path),
        throwsA(isA<Exception>()),
      );

      expect(await repository.getDocuments(), isEmpty);
      expect(
        File(documentImagesPath('doc_missing_file')).existsSync(),
        isFalse,
      );
    });
  });

  group('missing OCR protection', () {
    test('does not save when extracted text is empty', () async {
      final source = await writeTestImage(sourceDir, name: 'empty_text.jpg');

      await expectLater(
        saveSample(
          id: 'doc_empty_text',
          imagePath: source.path,
          text: '   ',
        ),
        throwsA(isA<Exception>()),
      );

      expect(await repository.getDocuments(), isEmpty);
      expect(File(documentImagesPath('doc_empty_text')).existsSync(), isFalse);
    });
  });

  group('valid OCR save', () {
    test('saves extracted text and a durable image that can be loaded later',
        () async {
      final source = await writeTestImage(sourceDir, name: 'valid.jpg');
      const text = 'هذا نص تجريبي مستخرج من الصورة.';

      final saved = await saveSample(
        id: 'doc_valid',
        imagePath: source.path,
        text: text,
      );

      expect(saved.extractedText, text);
      expect(File(saved.imagePath).existsSync(), isTrue);
      expect(saved.imagePath, contains('DocumentImages'));

      final loaded = await repository.getDocuments();
      expect(loaded.single.id, 'doc_valid');
      expect(loaded.single.extractedText, text);
      expect(loaded.single.imagePath, saved.imagePath);
      expect(File(loaded.single.imagePath).existsSync(), isTrue);
    });

    test('mock OCR result can be saved and loaded as a document', () async {
      final source = await writeTestImage(sourceDir, name: 'ocr_save.jpg');
      final ocrRepository = OcrRepository(
        apiService: ApiService(),
        storageService: storage,
      );
      final resultRepository = ResultRepository(
        apiService: ApiService(),
        storageService: storage,
      );

      final ocrData = await ocrRepository.processImage(imagePath: source.path);
      final ocrResult = await resultRepository.getResult(
        id: ocrData['id'] as String,
        ocrData: ocrData,
        imagePath: source.path,
      );

      expect(ocrResult.extractedText.trim(), isNotEmpty);
      expectNoConfidenceFields(ocrResult.toJson());

      final saved = await repository.saveDocument(
        HistoryModel(
          id: 'doc_from_ocr',
          imagePath: ocrResult.imagePath,
          extractedText: ocrResult.extractedText,
          createdAt: ocrResult.processedAt,
        ),
      );

      expect(saved.extractedText, ocrResult.extractedText);
      expect(File(saved.imagePath).existsSync(), isTrue);
      expect(saved.imagePath, contains('DocumentImages'));

      final loaded = await repository.getDocuments();
      expect(loaded.single.id, 'doc_from_ocr');
      expect(loaded.single.extractedText, ocrResult.extractedText);
      expect(File(loaded.single.imagePath).existsSync(), isTrue);
    });
  });

  group('document lifecycle', () {
    test('create, save, load, update text, load again, delete', () async {
      final sourceA = await writeTestImage(sourceDir, name: 'life_a.jpg');
      final sourceB = await writeTestImage(sourceDir, name: 'life_b.png');

      final first = await saveSample(
        id: 'doc_life_a',
        imagePath: sourceA.path,
        text: 'original text',
        createdAt: DateTime.utc(2026, 8, 1),
      );
      final second = await saveSample(
        id: 'doc_life_b',
        imagePath: sourceB.path,
        text: 'keep this document',
        createdAt: DateTime.utc(2026, 8, 2),
      );

      var loaded = await repository.getDocuments();
      expect(loaded.map((doc) => doc.id), ['doc_life_b', 'doc_life_a']);

      final updated = await repository.saveDocument(
        first.copyWith(extractedText: 'edited text'),
      );
      expect(updated.extractedText, 'edited text');
      expect(updated.imagePath, first.imagePath);
      expect(File(updated.imagePath).existsSync(), isTrue);

      loaded = await repository.getDocuments();
      final reloadedA = loaded.firstWhere((doc) => doc.id == 'doc_life_a');
      expect(reloadedA.extractedText, 'edited text');
      expect(File(reloadedA.imagePath).existsSync(), isTrue);

      await repository.deleteDocument('doc_life_a');

      loaded = await repository.getDocuments();
      expect(loaded, hasLength(1));
      expect(loaded.single.id, 'doc_life_b');
      expect(loaded.single.extractedText, 'keep this document');
      expect(File(first.imagePath).existsSync(), isFalse);
      expect(File(second.imagePath).existsSync(), isTrue);
    });
  });
}
