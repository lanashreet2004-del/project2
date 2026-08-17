import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/api_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/core/utils/api_exception.dart';
import 'package:p2/models/ocr_result_model.dart';
import 'package:p2/repositories/text_edit_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

class _RecordingAdapter implements HttpClientAdapter {
  String? lastPath;
  String? lastMethod;
  String? lastBody;
  bool called = false;
  int callCount = 0;

  int statusCode = 200;
  Map<String, dynamic> responseJson = const {};
  Duration delay = Duration.zero;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    called = true;
    callCount++;
    lastPath = options.path;
    lastMethod = options.method;
    if (requestStream != null) {
      final bytes = <int>[];
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
      lastBody = utf8.decode(bytes);
    }
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

OcrResultModel _result({required String id, String text = 'النص القديم'}) {
  return OcrResultModel(
    id: id,
    extractedText: text,
    processedAt: DateTime(2026, 6, 12, 14, 30),
    imagePath: '/tmp/ocr.jpg',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late _RecordingAdapter adapter;
  late ApiService apiService;
  late TextEditRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('text_edit_patch_test');
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
    repository = TextEditRepository(
      apiService: apiService,
      storageService: StorageService(box: GetStorage('text_edit_patch_test')),
    );
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('valid id 12 PATCHes /api/ocr-status/12/ with extracted_text only',
      () async {
    adapter.responseJson = {
      'id': 12,
      'ocr_record': 12,
      'extracted_text': 'النص المعدل',
      'edited_text': 'النص المعدل',
      'status': 'COMPLETED',
      'message': 'Text updated and saved for training.',
    };

    final updated = await repository.syncToBackend(
      original: _result(id: '12'),
      editedText: 'النص المعدل',
    );

    expect(adapter.called, isTrue);
    expect(adapter.lastMethod, 'PATCH');
    expect(adapter.lastPath, '/api/ocr-status/12/');
    expect(jsonDecode(adapter.lastBody!), {
      'extracted_text': 'النص المعدل',
    });
    expect(updated.extractedText, 'النص المعدل');
    expect(updated.id, '12');
    expect(
      apiService.client.options.headers['Authorization'],
      'Bearer test-access-token',
    );
  });

  test('invalid local id doc_123 does not send HTTP request', () async {
    await expectLater(
      () => repository.syncToBackend(
        original: _result(id: 'doc_123'),
        editedText: 'edited text',
      ),
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

  test('backend 400 surfaces message and status', () async {
    adapter.statusCode = 400;
    adapter.responseJson = {
      'message': 'OCR record is not completed yet.',
      'status': 'PENDING',
    };

    await expectLater(
      () => repository.syncToBackend(
        original: _result(id: '12'),
        editedText: 'edited text',
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('OCR record is not completed yet.'),
            contains('PENDING'),
          ),
        ),
      ),
    );
  });

  test('backend 500 surfaces backend message', () async {
    adapter.statusCode = 500;
    adapter.responseJson = {
      'message': 'Failed to save edited OCR text.',
    };

    await expectLater(
      () => repository.syncToBackend(
        original: _result(id: '12'),
        editedText: 'edited text',
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Failed to save edited OCR text.'),
        ),
      ),
    );
  });
}
