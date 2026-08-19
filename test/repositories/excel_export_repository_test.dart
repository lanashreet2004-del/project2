import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/api_constants.dart';
import 'package:p2/core/constants/storage_keys.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/core/utils/api_exception.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/excel_export_repository.dart';
import 'package:p2/repositories/excel_files_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

class _RecordingAdapter implements HttpClientAdapter {
  String? lastPath;
  ResponseType? lastResponseType;
  bool called = false;

  int statusCode = 200;
  List<int> body = const [];
  Map<String, List<String>> responseHeaders = const {};

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
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ],
        ...responseHeaders,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

HistoryModel _doc({required String id}) {
  return HistoryModel(
    id: id,
    imagePath: '',
    extractedText: 'مرحباً بكم',
    createdAt: DateTime(2026, 6, 12, 14, 30),
  );
}

List<int> _minimalXlsxBytes() {
  // ZIP / XLSX local file header magic (PK..)
  return [0x50, 0x4B, 0x03, 0x04, 0x00, 0x00, 0x00, 0x00];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late _RecordingAdapter adapter;
  late ApiService apiService;
  late StorageService storageService;
  late ExcelExportRepository repository;
  late ExcelFilesRepository excelFilesRepository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('excel_export_test');
  });

  setUp(() async {
    adapter = _RecordingAdapter();
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    dio.httpClientAdapter = adapter;
    apiService = ApiService(dio: dio);
    apiService.setAuthToken('test-access-token');
    storageService = StorageService(box: GetStorage('excel_export_test'));
    await storageService.write(StorageKeys.userId, 'user_a');
    repository = ExcelExportRepository(
      apiService: apiService,
      storageService: storageService,
    );
    excelFilesRepository = ExcelFilesRepository(
      apiService: apiService,
      storageService: storageService,
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('backend id 42 calls /api/export-ocr/42/xlsx/ with ResponseType.bytes',
      () async {
    adapter.body = _minimalXlsxBytes();
    adapter.responseHeaders = {
      'content-disposition': ['attachment; filename="ocr_export_42.xlsx"'],
    };

    final file = await repository.exportDocumentToExcel(_doc(id: '42'));

    expect(adapter.called, isTrue);
    expect(adapter.lastPath, '/api/export-ocr/42/xlsx/');
    expect(adapter.lastResponseType, ResponseType.bytes);
    expect(file, isNotNull);
    expect(file!.path.toLowerCase().endsWith('.xlsx'), isTrue);
    expect(file.path.contains('DocumentsExports'), isTrue);
    expect(file.path.contains('excel'), isTrue);
    expect(file.uri.pathSegments.last, 'ocr_export_42.xlsx');
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), _minimalXlsxBytes());
  });

  test('successful binary response registers in ExcelFilesRepository', () async {
    adapter.body = _minimalXlsxBytes();
    adapter.responseHeaders = {
      'content-disposition': ['attachment; filename="ocr_export_42.xlsx"'],
    };

    final document = _doc(id: '42');
    final file = await repository.exportDocumentToExcel(document);
    expect(file, isNotNull);

    final entry = await excelFilesRepository.registerExportedExcel(
      file: file!,
      document: document,
      documentTitle: repository.documentTitleOf(document),
    );

    final files = await excelFilesRepository.getExcelFiles();
    expect(files.any((item) => item.id == entry.id), isTrue);
    expect(entry.fileName.toLowerCase().endsWith('.xlsx'), isTrue);
    expect(entry.documentId, '42');
  });

  test('local-only id ocr_123 does not send HTTP request', () async {
    await expectLater(
      () => repository.exportDocumentToExcel(_doc(id: 'ocr_123')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('valid backend OCR ID'),
        ),
      ),
    );
    expect(adapter.called, isFalse);
  });

  test('backend 400 JSON bytes surfaces message and status', () async {
    adapter.statusCode = 400;
    adapter.body = utf8.encode(
      jsonEncode({
        'message': 'OCR record is not completed yet.',
        'status': 'PROCESSING',
      }),
    );

    await expectLater(
      () => repository.exportDocumentToExcel(_doc(id: '42')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('OCR record is not completed yet.'),
            contains('PROCESSING'),
          ),
        ),
      ),
    );
  });

  test('backend 500 JSON bytes surfaces backend message', () async {
    adapter.statusCode = 500;
    adapter.body = utf8.encode(
      jsonEncode({
        'message': 'Failed to generate Excel export.',
      }),
    );

    await expectLater(
      () => repository.exportDocumentToExcel(_doc(id: '42')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Failed to generate Excel export.'),
        ),
      ),
    );
  });

  test('backend 401 surfaces authentication error', () async {
    adapter.statusCode = 401;
    adapter.body = utf8.encode(
      jsonEncode({'message': 'Authentication credentials were not provided.'}),
    );

    await expectLater(
      () => repository.exportDocumentToExcel(_doc(id: '42')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Authentication credentials were not provided.'),
        ),
      ),
    );
  });

  test('backend 404 surfaces backend message when available', () async {
    adapter.statusCode = 404;
    adapter.body = utf8.encode(
      jsonEncode({'message': 'OCR record not found.'}),
    );

    await expectLater(
      () => repository.exportDocumentToExcel(_doc(id: '42')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('OCR record not found.'),
        ),
      ),
    );
  });

  test('empty binary response fails safely', () async {
    adapter.body = const [];

    await expectLater(
      () => repository.exportDocumentToExcel(_doc(id: '42')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Empty XLSX'),
        ),
      ),
    );
  });

  test('existing ApiService auth header remains available for export request',
      () {
    expect(
      apiService.client.options.headers['Authorization'],
      'Bearer test-access-token',
    );
  });
}
