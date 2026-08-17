import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/controllers/document_details_controller.dart';
import 'package:p2/core/constants/api_constants.dart';
import 'package:p2/core/localization/app_translations.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/excel_export_repository.dart';
import 'package:p2/repositories/excel_files_repository.dart';
import 'package:p2/repositories/history_repository.dart';
import 'package:p2/repositories/pdf_export_repository.dart';
import 'package:p2/repositories/pdf_files_repository.dart';
import 'package:p2/repositories/word_export_repository.dart';
import 'package:p2/repositories/word_files_repository.dart';
import 'package:p2/views/document_details/document_details_view.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

class _RecordingAdapter implements HttpClientAdapter {
  String? lastPath;
  ResponseType? lastResponseType;
  bool called = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    called = true;
    lastPath = options.path;
    lastResponseType = options.responseType;
    return ResponseBody.fromBytes(
      const [0x50, 0x4B, 0x03, 0x04],
      200,
      headers: {
        Headers.contentTypeHeader: [
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ],
        'content-disposition': ['attachment; filename="ocr_export_42.xlsx"'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late _RecordingAdapter adapter;
  late DocumentDetailsController controller;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('document_details_excel_test');
  });

  setUp(() {
    Get.testMode = true;
    Get.reset();

    adapter = _RecordingAdapter();
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    dio.httpClientAdapter = adapter;
    final apiService = ApiService(dio: dio);
    apiService.setAuthToken('test-access-token');
    final storageService =
        StorageService(box: GetStorage('document_details_excel_test'));

    controller = DocumentDetailsController(
      repository: HistoryRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      pdfExportRepository: PdfExportRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      pdfFilesRepository: PdfFilesRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      wordExportRepository: WordExportRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      wordFilesRepository: WordFilesRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      excelExportRepository: ExcelExportRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      excelFilesRepository: ExcelFilesRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      document: HistoryModel(
        id: '42',
        imagePath: '',
        extractedText: 'تطبيقنا سطر للرقمنة العربية',
        createdAt: DateTime(2026, 6, 12, 14, 30),
      ),
    );
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  Future<void> pumpDetails(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const DocumentDetailsView(),
      ),
    );
    await tester.pump();
  }

  testWidgets('quick actions replace Edit Text with Export Excel',
      (tester) async {
    await pumpDetails(tester);

    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Export Excel'), findsOneWidget);
    expect(find.text('Export Word'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Edit Text'), findsNothing);
    expect(find.byKey(const Key('extracted_text_edit')), findsOneWidget);
  });

  test('exportPdf, exportWord, and openTextEditor remain available', () {
    expect(controller.exportPdf, isA<Future<void> Function()>());
    expect(controller.exportWord, isA<Future<void> Function()>());
    expect(controller.exportExcel, isA<Future<void> Function()>());
    expect(controller.openTextEditor, isA<Future<void> Function()>());
  });
}
