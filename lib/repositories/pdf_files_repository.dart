import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/export_constants.dart';
import '../core/constants/storage_keys.dart';
import '../models/history_model.dart';
import '../models/pdf_file_model.dart';
import 'base_repository.dart';

/// Local library of exported PDF files (metadata in GetStorage, files on disk).
class PdfFilesRepository extends BaseRepository {
  PdfFilesRepository({
    required super.apiService,
    required super.storageService,
  });

  /// Registers a successfully exported PDF into the local library.
  Future<PdfFileModel> registerExportedPdf({
    required File file,
    required HistoryModel document,
    required String documentTitle,
  }) async {
    final size = await file.exists() ? await file.length() : 0;
    final entry = PdfFileModel(
      id: 'pdf_${DateTime.now().millisecondsSinceEpoch}',
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
    items.insert(0, entry);
    await _writeAll(items);
    return entry;
  }

  Future<List<PdfFileModel>> getPdfFiles() async {
    final items = await _readAll();
    items.sort((a, b) => b.exportedAt.compareTo(a.exportedAt));
    return items;
  }

  Future<PdfFileModel?> getById(String id) async {
    final items = await _readAll();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<bool> fileExists(PdfFileModel item) async {
    if (item.filePath.isEmpty) return false;
    return File(item.filePath).exists();
  }

  Future<void> deletePdf(String id) async {
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

  /// Removes metadata when the physical file is missing.
  Future<void> removeStaleEntry(String id) async {
    final items = await _readAll();
    items.removeWhere((item) => item.id == id);
    await _writeAll(items);
  }

  Future<void> openPdf(PdfFileModel item) async {
    final file = File(item.filePath);
    if (!await file.exists()) {
      throw StateError('PDF file not found on device.');
    }

    await OpenFilex.open(
      file.path,
      type: 'application/pdf',
    );
  }

  Future<void> sharePdf(PdfFileModel item) async {
    final file = File(item.filePath);
    if (!await file.exists()) {
      throw StateError('PDF file not found on device.');
    }

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: item.fileName,
      text: 'Shared from ${ExportConstants.appExportTitle}',
    );
  }

  Future<List<PdfFileModel>> _readAll() async {
    final raw = storageService.read<List<dynamic>>(StorageKeys.pdfFilesLibrary);
    if (raw == null || raw.isEmpty) return [];

    return raw
        .map(
          (entry) => PdfFileModel.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<void> _writeAll(List<PdfFileModel> items) async {
    await storageService.write(
      StorageKeys.pdfFilesLibrary,
      items.map((item) => item.toJson()).toList(),
    );
  }
}
