import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/export_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/pdf_export_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late PdfExportRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('pdf_export_test');
  });

  setUp(() {
    repository = PdfExportRepository(
      apiService: ApiService(),
      storageService: StorageService(box: GetStorage('pdf_export_test')),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('loads bundled Arabic fonts from assets without network', () async {
    final regular = await rootBundle.load(
      ExportConstants.arabicRegularFontAsset,
    );
    final bold = await rootBundle.load(
      ExportConstants.arabicBoldFontAsset,
    );

    expect(regular.lengthInBytes, greaterThan(100000));
    expect(bold.lengthInBytes, greaterThan(100000));
  });

  test('generates PDF bytes containing Arabic text offline', () async {
    const arabicText =
        'مرحباً بكم في تطبيق مكتوب.\n\n'
        'هذا نص تجريبي مستخرج من الصورة.';

    final document = HistoryModel(
      id: 'test_arabic_pdf',
      imagePath: '',
      extractedText: arabicText,
      createdAt: DateTime(2026, 6, 12, 14, 30),
    );
    expectNoConfidenceFields(document.toJson());

    final bytes = await repository.generatePdfBytes(
      document,
      status: 'Processed, Edited',
    );

    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!.take(4)), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });

  test('generateArabicTestReport produces valid offline PDF bytes path', () async {
    const arabicText =
        'مرحباً بكم في تطبيق مكتوب.\n\n'
        'هذا نص تجريبي مستخرج من الصورة.';

    final document = HistoryModel(
      id: 'arabic_pdf_test',
      imagePath: '',
      extractedText: arabicText,
      createdAt: DateTime(2026, 6, 12, 14, 30),
    );

    final bytes = await repository.generatePdfBytes(
      document,
      status: 'تمت المعالجة، تم التحرير',
    );

    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!.take(4)), '%PDF');
    expect(bytes.length, greaterThan(1000));

    final artifactDir = Directory('test/artifacts');
    if (!await artifactDir.exists()) {
      await artifactDir.create(recursive: true);
    }
    final artifact = File(
      '${artifactDir.path}/${ExportConstants.arabicTestReportFileName}',
    );
    await artifact.writeAsBytes(bytes);
    expect(await artifact.exists(), isTrue);
  });
}
