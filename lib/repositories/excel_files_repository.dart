import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/export_constants.dart';
import '../core/constants/storage_keys.dart';
import '../models/excel_file_model.dart';
import '../models/history_model.dart';
import 'base_repository.dart';

/// Local library of exported Excel files (metadata in GetStorage, files on disk).
class ExcelFilesRepository extends BaseRepository {
  ExcelFilesRepository({
    required super.apiService,
    required super.storageService,
  });

  static const _xlsxMime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// Registers a successfully exported Excel file into the local library.
  Future<ExcelFileModel> registerExportedExcel({
    required File file,
    required HistoryModel document,
    required String documentTitle,
  }) async {
    final size = await file.exists() ? await file.length() : 0;
    final entry = ExcelFileModel(
      id: 'excel_${DateTime.now().millisecondsSinceEpoch}',
      fileName: file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : file.path.split(Platform.pathSeparator).last,
      filePath: file.path,
      documentId: document.id,
      documentTitle: documentTitle.trim().isEmpty
          ? 'Untitled Document'
          : documentTitle.trim(),
      exportedAt: DateTime.now(),
      fileSizeBytes: size,
    );

    final items = await _readAll();
    items.removeWhere(
      (item) =>
          item.filePath == entry.filePath || item.documentId == entry.documentId,
    );
    items.insert(0, entry);
    await _writeAll(items);
    return entry;
  }

  Future<List<ExcelFileModel>> getExcelFiles() async {
    final items = await _readAll();
    items.sort((a, b) => b.exportedAt.compareTo(a.exportedAt));
    return items;
  }

  Future<bool> fileExists(ExcelFileModel item) async {
    if (item.filePath.isEmpty) return false;
    return File(item.filePath).exists();
  }

  Future<void> deleteExcel(String id) async {
    final items = await _readAll();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final item = items[index];
    final file = File(item.filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {
        // Continue removing metadata even if file delete fails.
      }
    }

    items.removeAt(index);
    await _writeAll(items);
  }

  Future<void> removeStaleEntry(String id) async {
    final items = await _readAll();
    items.removeWhere((item) => item.id == id);
    await _writeAll(items);
  }

  Future<void> openExcel(ExcelFileModel item) async {
    final file = File(item.filePath);
    if (!await file.exists()) {
      throw StateError('Excel file not found on device.');
    }

    await OpenFilex.open(file.path, type: _xlsxMime);
  }

  Future<void> shareExcel(ExcelFileModel item) async {
    final file = File(item.filePath);
    if (!await file.exists()) {
      throw StateError('Excel file not found on device.');
    }

    await Share.shareXFiles(
      [XFile(file.path, mimeType: _xlsxMime)],
      subject: item.fileName,
      text: 'Shared from ${ExportConstants.appExportTitle}',
    );
  }

  Future<List<ExcelFileModel>> _readAll() async {
    final raw =
        storageService.read<List<dynamic>>(StorageKeys.excelFilesLibrary);
    if (raw == null || raw.isEmpty) return [];

    return raw
        .map(
          (entry) => ExcelFileModel.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<void> _writeAll(List<ExcelFileModel> items) async {
    await storageService.write(
      StorageKeys.excelFilesLibrary,
      items.map((item) => item.toJson()).toList(),
    );
  }
}
