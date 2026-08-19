import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/core/constants/storage_keys.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/excel_files_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

HistoryModel _doc({required String id}) {
  return HistoryModel(
    id: id,
    imagePath: '',
    extractedText: 'مرحباً بكم',
    createdAt: DateTime(2026, 6, 12, 14, 30),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late ExcelFilesRepository repository;
  late Directory excelDir;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('excel_files_library_test');
  });

  setUp(() async {
    repository = ExcelFilesRepository(
      apiService: ApiService(),
      storageService: StorageService(box: GetStorage('excel_files_library_test')),
    );
    excelDir = Directory(
      '${docsDir.path}${Platform.pathSeparator}DocumentsExports${Platform.pathSeparator}excel',
    );
    await excelDir.create(recursive: true);
    await GetStorage('excel_files_library_test').erase();
    await repository.storageService.write(StorageKeys.userId, 'user_a');
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  Future<File> writeXlsx({String name = 'ocr_export_42.xlsx'}) async {
    final file = File('${excelDir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(const [0x50, 0x4B, 0x03, 0x04]);
    return file;
  }

  test('registered Excel file appears in the library list', () async {
    final file = await writeXlsx();
    final document = _doc(id: '42');

    final entry = await repository.registerExportedExcel(
      file: file,
      document: document,
      documentTitle: 'مرحباً بكم',
    );

    final files = await repository.getExcelFiles();
    expect(files, isNotEmpty);
    expect(files.first.id, entry.id);
    expect(files.first.fileName, 'ocr_export_42.xlsx');
    expect(files.first.documentId, '42');
    expect(await repository.fileExists(entry), isTrue);
  });

  test('deleteExcel removes the physical file and metadata', () async {
    final file = await writeXlsx();
    final entry = await repository.registerExportedExcel(
      file: file,
      document: _doc(id: '42'),
      documentTitle: 'title',
    );

    await repository.deleteExcel(entry.id);

    expect(await file.exists(), isFalse);
    expect(await repository.getExcelFiles(), isEmpty);
    expect(await repository.fileExists(entry), isFalse);
  });

  test('removeStaleEntry drops metadata when the file is already gone', () async {
    final file = await writeXlsx(name: 'ocr_export_stale.xlsx');
    final entry = await repository.registerExportedExcel(
      file: file,
      document: _doc(id: '7'),
      documentTitle: 'stale',
    );
    await file.delete();

    await repository.removeStaleEntry(entry.id);

    expect(await repository.getExcelFiles(), isEmpty);
  });

  test('openExcel throws when the physical file is missing', () async {
    final missing = File(
      '${excelDir.path}${Platform.pathSeparator}missing.xlsx',
    );
    final entry = await repository.registerExportedExcel(
      file: missing,
      document: _doc(id: '9'),
      documentTitle: 'missing',
    );

    await expectLater(
      () => repository.openExcel(entry),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Excel file not found'),
        ),
      ),
    );
  });

  test('shareExcel throws when the physical file is missing', () async {
    final missing = File(
      '${excelDir.path}${Platform.pathSeparator}missing_share.xlsx',
    );
    final entry = await repository.registerExportedExcel(
      file: missing,
      document: _doc(id: '10'),
      documentTitle: 'missing',
    );

    await expectLater(
      () => repository.shareExcel(entry),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Excel file not found'),
        ),
      ),
    );
  });

  test('registered file is available to open and share', () async {
    final file = await writeXlsx(name: 'ocr_export_open.xlsx');
    final entry = await repository.registerExportedExcel(
      file: file,
      document: _doc(id: '11'),
      documentTitle: 'open',
    );

    expect(await repository.fileExists(entry), isTrue);
    expect(entry.fileName.toLowerCase().endsWith('.xlsx'), isTrue);
    expect(File(entry.filePath).existsSync(), isTrue);
  });

  test('generated files are isolated by signed-in user', () async {
    final file = await writeXlsx(name: 'ocr_export_user_a.xlsx');
    await repository.registerExportedExcel(
      file: file,
      document: _doc(id: '7'),
      documentTitle: 'user a',
    );

    expect(await repository.getExcelFiles(), isNotEmpty);

    await repository.storageService.write(StorageKeys.userId, 'user_b');
    expect(await repository.getExcelFiles(), isEmpty);

    await repository.storageService.write(StorageKeys.userId, 'user_a');
    final restored = await repository.getExcelFiles();
    expect(restored, isNotEmpty);
    expect(restored.first.fileName, 'ocr_export_user_a.xlsx');
  });

  test('unsigned session cannot read or write the generated-files catalog',
      () async {
    await repository.storageService.remove(StorageKeys.userId);
    final file = await writeXlsx(name: 'ocr_export_unsigned.xlsx');
    await repository.registerExportedExcel(
      file: file,
      document: _doc(id: '8'),
      documentTitle: 'unsigned',
    );

    expect(await repository.getExcelFiles(), isEmpty);
    expect(
      repository.storageService.read<List<dynamic>>(StorageKeys.excelFilesLibrary),
      isNull,
    );
  });
}
