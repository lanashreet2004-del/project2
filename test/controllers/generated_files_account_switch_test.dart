import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:p2/controllers/excel_files_controller.dart';
import 'package:p2/controllers/json_files_controller.dart';
import 'package:p2/controllers/pdf_files_controller.dart';
import 'package:p2/controllers/word_files_controller.dart';
import 'package:p2/core/constants/storage_keys.dart';
import 'package:p2/core/services/api_service.dart';
import 'package:p2/core/services/storage_service.dart';
import 'package:p2/core/utils/generated_files_session.dart';
import 'package:p2/core/utils/user_scoped_library.dart';
import 'package:p2/models/excel_file_model.dart';
import 'package:p2/models/history_model.dart';
import 'package:p2/repositories/excel_files_repository.dart';
import 'package:p2/repositories/json_files_repository.dart';
import 'package:p2/repositories/pdf_files_repository.dart';
import 'package:p2/repositories/word_files_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/offline_test_support.dart';

HistoryModel _doc(String id) {
  return HistoryModel(
    id: id,
    imagePath: '',
    extractedText: 'مرحباً',
    createdAt: DateTime(2026, 6, 12, 14, 30),
  );
}

class _DelayedExcelFilesRepository extends ExcelFilesRepository {
  _DelayedExcelFilesRepository({
    required super.apiService,
    required super.storageService,
  });

  Completer<List<ExcelFileModel>>? pending;

  @override
  Future<List<ExcelFileModel>> getExcelFiles() {
    final gate = pending;
    if (gate != null) return gate.future;
    return super.getExcelFiles();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late StorageService storage;
  late PdfFilesRepository pdfRepo;
  late WordFilesRepository wordRepo;
  late ExcelFilesRepository excelRepo;
  late JsonFilesRepository jsonRepo;

  setUpAll(() async {
    docsDir = await createTestDocumentsDir();
    PathProviderPlatform.instance = FakePathProvider(docsDir.path);
    await GetStorage.init('generated_files_account_switch_test');
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await GetStorage('generated_files_account_switch_test').erase();
    storage = StorageService(
      box: GetStorage('generated_files_account_switch_test'),
    );
    final api = ApiService();
    pdfRepo = PdfFilesRepository(apiService: api, storageService: storage);
    wordRepo = WordFilesRepository(apiService: api, storageService: storage);
    excelRepo = ExcelFilesRepository(apiService: api, storageService: storage);
    jsonRepo = JsonFilesRepository(apiService: api, storageService: storage);
    await storage.write(StorageKeys.userId, 'user_a');
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  tearDownAll(() async {
    await tryDeleteTestRoot(docsDir);
  });

  Future<File> writeExport(String folder, String name) async {
    final dir = Directory(
      '${docsDir.path}${Platform.pathSeparator}$folder',
    );
    await dir.create(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(const [0x50, 0x4B, 0x03, 0x04]);
    return file;
  }

  test('account switch replaces in-memory lists for all generated file types',
      () async {
    final pdfFile = await writeExport('pdf', 'a.pdf');
    final wordFile = await writeExport('word', 'a.docx');
    final excelFile = await writeExport('excel', 'a.xlsx');
    final jsonFile = await writeExport('json', 'a.json');

    await pdfRepo.registerExportedPdf(
      file: pdfFile,
      document: _doc('1'),
      documentTitle: 'A',
    );
    await wordRepo.registerExportedWord(
      file: wordFile,
      document: _doc('1'),
      documentTitle: 'A',
    );
    await excelRepo.registerExportedExcel(
      file: excelFile,
      document: _doc('1'),
      documentTitle: 'A',
    );
    await jsonRepo.registerExportedJson(
      file: jsonFile,
      document: _doc('1'),
      documentTitle: 'A',
    );

    final pdf = PdfFilesController(repository: pdfRepo);
    final word = WordFilesController(repository: wordRepo);
    final excel = ExcelFilesController(repository: excelRepo);
    final json = JsonFilesController(repository: jsonRepo);

    await pdf.loadPdfFiles();
    await word.loadWordFiles();
    await excel.loadExcelFiles();
    await json.loadJsonFiles();

    expect(pdf.pdfFiles.map((e) => e.fileName), ['a.pdf']);
    expect(word.wordFiles.map((e) => e.fileName), ['a.docx']);
    expect(excel.excelFiles.map((e) => e.fileName), ['a.xlsx']);
    expect(json.jsonFiles.map((e) => e.fileName), ['a.json']);

    await storage.write(StorageKeys.userId, 'user_b');
    pdf.clearFiles();
    word.clearFiles();
    excel.clearFiles();
    json.clearFiles();

    expect(pdf.pdfFiles, isEmpty);
    expect(word.wordFiles, isEmpty);
    expect(excel.excelFiles, isEmpty);
    expect(json.jsonFiles, isEmpty);

    await pdf.loadPdfFiles();
    await word.loadWordFiles();
    await excel.loadExcelFiles();
    await json.loadJsonFiles();

    expect(pdf.pdfFiles, isEmpty);
    expect(word.wordFiles, isEmpty);
    expect(excel.excelFiles, isEmpty);
    expect(json.jsonFiles, isEmpty);

    final bExcel = await writeExport('excel', 'b.xlsx');
    await excelRepo.registerExportedExcel(
      file: bExcel,
      document: _doc('2'),
      documentTitle: 'B',
    );
    await excel.loadExcelFiles();
    expect(excel.excelFiles.map((e) => e.fileName), ['b.xlsx']);

    await storage.write(StorageKeys.userId, 'user_a');
    excel.clearFiles();
    await excel.loadExcelFiles();
    expect(excel.excelFiles.map((e) => e.fileName), ['a.xlsx']);

    expect(
      storage.read<List<dynamic>>(
        UserScopedLibrary.keyFor(StorageKeys.excelFilesLibrary, 'user_a'),
      ),
      isNotEmpty,
    );
    expect(
      storage.read<List<dynamic>>(
        UserScopedLibrary.keyFor(StorageKeys.excelFilesLibrary, 'user_b'),
      ),
      isNotEmpty,
    );
    expect(
      storage.read<List<dynamic>>(StorageKeys.excelFilesLibrary),
      isNull,
    );
  });

  test('GeneratedFilesSession reloads registered controllers after user change',
      () async {
    final excelFile = await writeExport('excel', 'a.xlsx');
    await excelRepo.registerExportedExcel(
      file: excelFile,
      document: _doc('1'),
      documentTitle: 'A',
    );

    final excel = ExcelFilesController(repository: excelRepo);
    await excel.loadExcelFiles();
    Get.put(excel);

    await storage.write(StorageKeys.userId, 'user_b');
    await GeneratedFilesSession.onAuthenticatedUserChanged();

    expect(excel.excelFiles, isEmpty);
  });

  test('in-flight load from the previous user is ignored after clearFiles',
      () async {
    final delayed = _DelayedExcelFilesRepository(
      apiService: ApiService(),
      storageService: storage,
    );
    final controller = ExcelFilesController(repository: delayed);
    delayed.pending = Completer<List<ExcelFileModel>>();

    final load = controller.loadExcelFiles();
    controller.clearFiles();
    delayed.pending!.complete([
      ExcelFileModel(
        id: 'stale',
        fileName: 'a.xlsx',
        filePath: '/tmp/a.xlsx',
        documentId: '1',
        documentTitle: 'A',
        exportedAt: DateTime(2026, 6, 12),
      ),
    ]);
    await load;

    expect(controller.excelFiles, isEmpty);
  });
}
