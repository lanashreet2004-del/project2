import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/controllers/result_controller.dart';
import 'package:p2/controllers/upload_controller.dart';
import 'package:p2/core/constants/api_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/ocr_result_model.dart';
import 'package:p2/repositories/excel_export_repository.dart';
import 'package:p2/repositories/excel_files_repository.dart';
import 'package:p2/repositories/history_repository.dart';
import 'package:p2/repositories/image_repository.dart';
import 'package:p2/repositories/pdf_export_repository.dart';
import 'package:p2/repositories/pdf_files_repository.dart';
import 'package:p2/repositories/result_repository.dart';
import 'package:p2/repositories/upload_repository.dart';
import 'package:p2/repositories/word_export_repository.dart';
import 'package:p2/repositories/word_files_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

class _EmptyAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late ResultController controller;
  late UploadController uploadController;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('result_apply_edit_test');
  });

  setUp(() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dio.httpClientAdapter = _EmptyAdapter();
    final apiService = ApiService(dio: dio);
    final storage = StorageService(box: GetStorage('result_apply_edit_test'));

    uploadController = UploadController(
      repository: UploadRepository(
        apiService: apiService,
        storageService: storage,
      ),
      imageRepository: ImageRepository(
        apiService: apiService,
        storageService: storage,
      ),
    );

    controller = ResultController(
      repository: ResultRepository(
        apiService: apiService,
        storageService: storage,
      ),
      historyRepository: HistoryRepository(
        apiService: apiService,
        storageService: storage,
      ),
      uploadController: uploadController,
      pdfExportRepository: PdfExportRepository(
        apiService: apiService,
        storageService: storage,
      ),
      pdfFilesRepository: PdfFilesRepository(
        apiService: apiService,
        storageService: storage,
      ),
      wordExportRepository: WordExportRepository(
        apiService: apiService,
        storageService: storage,
      ),
      wordFilesRepository: WordFilesRepository(
        apiService: apiService,
        storageService: storage,
      ),
      excelExportRepository: ExcelExportRepository(
        apiService: apiService,
        storageService: storage,
      ),
      excelFilesRepository: ExcelFilesRepository(
        apiService: apiService,
        storageService: storage,
      ),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('applyEditedResult replaces extracted text and keeps backend id 29', () {
    const processedAt = '2026-08-19T10:00:00.000Z';
    controller.result.value = OcrResultModel(
      id: '29',
      extractedText: 'Old text',
      processedAt: DateTime.parse(processedAt),
      imagePath: '/tmp/ocr.jpg',
    );

    controller.applyEditedResult(
      OcrResultModel(
        id: '29',
        extractedText: 'New text',
        processedAt: DateTime.parse(processedAt),
        imagePath: '/tmp/ocr.jpg',
      ),
    );

    expect(controller.result.value!.extractedText, 'New text');
    expect(controller.result.value!.id, '29');
    expect(controller.result.value!.imagePath, '/tmp/ocr.jpg');
    expect(uploadController.ocrResult.value!['id'], '29');
    expect(uploadController.ocrResult.value!['text'], 'New text');
  });
}
