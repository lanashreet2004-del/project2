import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/bindings/initial_binding.dart';
import 'package:p2/core/constants/app_constants.dart';
import 'package:p2/core/localization/app_translations.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/models/ocr_result_model.dart';
import 'package:p2/repositories/history_repository.dart';
import 'package:p2/repositories/ocr_repository.dart';
import 'package:p2/routes/app_pages.dart';
import 'package:p2/routes/app_routes.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init();
    await GetStorage.init('app_smoke_test');
  });

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  test('core app structure initializes without crashing', () {
    expect(AppConstants.appName, isNotEmpty);
    expect(AppPages.initial, AppRoutes.splash);
    expect(AppPages.routes, isNotEmpty);

    final routeNames = AppPages.routes.map((page) => page.name).toSet();
    expect(
      routeNames,
      containsAll([
        AppRoutes.splash,
        AppRoutes.home,
        AppRoutes.imageEditor,
        AppRoutes.processing,
        AppRoutes.result,
        AppRoutes.documents,
        AppRoutes.documentDetails,
      ]),
    );

    final translations = AppTranslations();
    expect(translations.keys['en'], isNotEmpty);
    expect(translations.keys['ar'], isNotEmpty);
    expect(translations.keys['en']?['result.confidence'], isNull);
    expect(translations.keys['ar']?['details.confidence'], isNull);

    InitialBinding().dependencies();

    expect(Get.isRegistered<ApiService>(), isTrue);
    expect(Get.isRegistered<StorageService>(), isTrue);
    expect(Get.isRegistered<OcrRepository>(), isTrue);
    expect(Get.isRegistered<HistoryRepository>(), isTrue);

    final ocr = OcrResultModel(
      id: 'ocr_smoke',
      extractedText: 'smoke',
      processedAt: DateTime.utc(2026, 8, 14),
      imagePath: '/tmp/smoke.jpg',
    );
    final history = HistoryModel(
      id: 'doc_smoke',
      imagePath: '/tmp/smoke.jpg',
      extractedText: 'smoke',
      createdAt: DateTime.utc(2026, 8, 14),
    );

    expect(ocr.id, 'ocr_smoke');
    expect(history.id, 'doc_smoke');
    expect(ocr.toJson().containsKey('confidence'), isFalse);
    expect(history.toJson().containsKey('confidence'), isFalse);
  });
}
