import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/controllers/text_editor_controller.dart';
import 'package:p2/core/constants/api_constants.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
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
  late TextEditRepository repository;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('text_editor_controller_test');
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
    repository = TextEditRepository(
      apiService: apiService,
      storageService:
          StorageService(box: GetStorage('text_editor_controller_test')),
    );
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  TextEditorController controller({
    required String id,
    bool persistToBackend = true,
    String text = 'النص القديم',
  }) {
    final c = TextEditorController(
      repository: repository,
      ocrResult: _result(id: id, text: text),
      persistToBackend: persistToBackend,
    );
    c.onInit();
    return c;
  }

  Future<void> runDone(TextEditorController c) {
    final done = Completer<void>();
    runZonedGuarded(
      () {
        Future(() async {
          try {
            await c.onDone();
          } catch (_) {
            // Get.snackbar / Get.back require a navigator overlay.
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }).whenComplete(() {
          if (!done.isCompleted) done.complete();
        });
      },
      (error, stack) {
        // Swallow GetX overlay errors scheduled after onDone returns.
      },
    );
    return done.future;
  }

  test('empty text does not send HTTP and keeps the editor open', () async {
    final c = controller(id: '12');
    c.textController.text = '   ';

    await runDone(c);

    expect(adapter.called, isFalse);
    expect(c.textController.text, '   ');
    expect(c.isSaving.value, isFalse);
  });

  test('invalid id doc_123 does not send HTTP and keeps edited text', () async {
    final c = controller(id: 'doc_123');
    c.textController.text = 'النص الجديد';

    await runDone(c);

    expect(adapter.called, isFalse);
    expect(c.textController.text, 'النص الجديد');
    expect(c.isSaving.value, isFalse);
  });

  test('Document Details path does not PATCH', () async {
    final c = controller(id: '12', persistToBackend: false);
    c.textController.text = 'local edit';

    await runDone(c);

    expect(adapter.called, isFalse);
  });

  test('successful PATCH uses backend extracted_text', () async {
    adapter.responseJson = {
      'id': 12,
      'extracted_text': 'النص المعدل',
      'status': 'COMPLETED',
    };
    final c = controller(id: '12');
    c.textController.text = 'النص الجديد';

    await runDone(c);

    expect(adapter.called, isTrue);
    expect(adapter.lastMethod, 'PATCH');
    expect(adapter.lastPath, '/api/ocr-status/12/');
    expect(jsonDecode(adapter.lastBody!), {'extracted_text': 'النص الجديد'});
    expect(c.isSaving.value, isFalse);
  });

  test('failed PATCH keeps editor text and resets saving', () async {
    adapter.statusCode = 400;
    adapter.responseJson = {
      'message': 'OCR record is not completed yet.',
      'status': 'PENDING',
    };
    final c = controller(id: '12');
    c.textController.text = 'النص الجديد';

    await runDone(c);

    expect(adapter.called, isTrue);
    expect(c.textController.text, 'النص الجديد');
    expect(c.isSaving.value, isFalse);
  });

  test('duplicate Done while saving sends only one PATCH', () async {
    adapter.delay = const Duration(milliseconds: 80);
    adapter.responseJson = {
      'id': 12,
      'extracted_text': 'edited text',
    };
    final c = controller(id: '12', text: 'old');
    c.textController.text = 'edited text';

    final first = runDone(c);
    await Future<void>.delayed(Duration.zero);
    expect(c.isSaving.value, isTrue);
    await runDone(c);
    await first;

    expect(adapter.callCount, 1);
    expect(c.isSaving.value, isFalse);
  });
}
