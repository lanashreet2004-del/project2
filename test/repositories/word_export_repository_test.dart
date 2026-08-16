import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/api_constants.dart';
import 'package:p2/core/constants/export_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/core/utils/api_exception.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/word_export_repository.dart';
import 'package:p2/repositories/word_files_repository.dart';
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
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
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

List<int> _minimalDocxBytes() {
  // ZIP / DOCX local file header magic (PK..)
  return [0x50, 0x4B, 0x03, 0x04, 0x00, 0x00, 0x00, 0x00];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late _RecordingAdapter adapter;
  late ApiService apiService;
  late StorageService storageService;
  late WordExportRepository repository;
  late WordFilesRepository wordFilesRepository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('word_export_test');
  });

  setUp(() {
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
    storageService = StorageService(box: GetStorage('word_export_test'));
    repository = WordExportRepository(
      apiService: apiService,
      storageService: storageService,
    );
    wordFilesRepository = WordFilesRepository(
      apiService: apiService,
      storageService: storageService,
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

  test('backend id 29 calls /api/export-ocr/29/docx/ with ResponseType.bytes',
      () async {
    adapter.body = _minimalDocxBytes();
    adapter.responseHeaders = {
      'content-disposition': ['attachment; filename="ocr_export_29.docx"'],
    };

    final file = await repository.exportDocumentToWord(_doc(id: '29'));

    expect(adapter.called, isTrue);
    expect(adapter.lastPath, '/api/export-ocr/29/docx/');
    expect(adapter.lastResponseType, ResponseType.bytes);
    expect(file, isNotNull);
    expect(file!.path.toLowerCase().endsWith('.docx'), isTrue);
    expect(file.path.contains('DocumentsExports'), isTrue);
    expect(file.path.contains('word'), isTrue);
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), _minimalDocxBytes());
  });

  test('successful binary response registers in WordFilesRepository', () async {
    adapter.body = _minimalDocxBytes();
    adapter.responseHeaders = {
      'content-disposition': ['attachment; filename="ocr_export_29.docx"'],
    };

    final document = _doc(id: '29');
    final file = await repository.exportDocumentToWord(document);
    expect(file, isNotNull);

    final entry = await wordFilesRepository.registerExportedWord(
      file: file!,
      document: document,
      documentTitle: repository.documentTitleOf(document),
    );

    final files = await wordFilesRepository.getWordFiles();
    expect(files.any((item) => item.id == entry.id), isTrue);
    expect(entry.fileName.toLowerCase().endsWith('.docx'), isTrue);
    expect(entry.documentId, '29');
  });

  test('local-only id ocr_123 does not send HTTP request', () async {
    await expectLater(
      () => repository.exportDocumentToWord(_doc(id: 'ocr_123')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('cannot be exported'),
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
      () => repository.exportDocumentToWord(_doc(id: '29')),
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
        'message': 'Arabic shaping libraries are missing. Install arabic-reshaper and python-bidi.',
      }),
    );

    await expectLater(
      () => repository.exportDocumentToWord(_doc(id: '29')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Arabic shaping libraries are missing'),
        ),
      ),
    );
  });

  test('empty binary response fails safely', () async {
    adapter.body = const [];

    await expectLater(
      () => repository.exportDocumentToWord(_doc(id: '29')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Empty DOCX'),
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
