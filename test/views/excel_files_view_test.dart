import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/controllers/excel_files_controller.dart';
import 'package:p2/core/localization/app_translations.dart';
import 'package:p2/core/localization/locale_controller.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/excel_files_repository.dart';
import 'package:p2/routes/app_pages.dart';
import 'package:p2/routes/app_routes.dart';
import 'package:p2/views/home/widgets/app_drawer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('excel_files_ui_test');
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

  test('AppPages registers the Excel Files named route', () {
    final routeNames = AppPages.routes.map((page) => page.name).toSet();
    expect(routeNames, contains(AppRoutes.excelFiles));
    expect(AppRoutes.excelFiles, '/excel-files');
  });

  test('registered XLSX appears in ExcelFilesController list', () async {
    await GetStorage('excel_files_ui_test').erase();
    final storageService =
        StorageService(box: GetStorage('excel_files_ui_test'));
    final repository = ExcelFilesRepository(
      apiService: ApiService(),
      storageService: storageService,
    );

    final excelDir = Directory(
      '${docsDir.path}${Platform.pathSeparator}DocumentsExports${Platform.pathSeparator}excel',
    );
    await excelDir.create(recursive: true);
    final file = File(
      '${excelDir.path}${Platform.pathSeparator}ocr_export_42.xlsx',
    );
    await file.writeAsBytes(const [0x50, 0x4B, 0x03, 0x04]);

    await repository.registerExportedExcel(
      file: file,
      document: HistoryModel(
        id: '42',
        imagePath: '',
        extractedText: 'مرحباً',
        createdAt: DateTime(2026, 6, 12, 14, 30),
      ),
      documentTitle: 'مرحباً',
    );

    final controller = ExcelFilesController(repository: repository);
    await controller.loadExcelFiles();

    expect(controller.excelFiles, isNotEmpty);
    expect(controller.excelFiles.first.fileName, 'ocr_export_42.xlsx');
    expect(controller.excelFiles.first.documentId, '42');
  });

  testWidgets('drawer Excel Files item invokes navigation callback',
      (tester) async {
    final storageService =
        StorageService(box: GetStorage('excel_files_ui_test'));
    Get.put(LocaleController(storageService: storageService));

    var excelTapped = false;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: Scaffold(
          body: AppDrawer(
            displayName: 'Guest',
            email: null,
            isLoggedIn: false,
            isDarkMode: false,
            selectedDestination: null,
            onDocumentsTap: () {},
            onPdfFilesTap: () {},
            onWordFilesTap: () {},
            onExcelFilesTap: () => excelTapped = true,
            onJsonFilesTap: () {},
            onSettingsTap: () {},
            onDarkModeChanged: (_) {},
            onSignInTap: () {},
            onSignOutTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Excel Files'), findsOneWidget);
    expect(find.text('PDF Files'), findsOneWidget);
    expect(find.text('Word Files'), findsOneWidget);
    expect(find.text('JSON Files'), findsOneWidget);

    await tester.tap(find.text('Excel Files'));
    await tester.pump();

    expect(excelTapped, isTrue);
  });
}
