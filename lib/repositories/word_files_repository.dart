import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/export_constants.dart';
import '../core/constants/storage_keys.dart';
import '../models/history_model.dart';
import '../models/word_file_model.dart';
import 'base_repository.dart';

/// Local library of exported Word files (metadata in GetStorage, files on disk).
class WordFilesRepository extends BaseRepository {
  WordFilesRepository({
    required super.apiService,
    required super.storageService,
  });

  static const _docxMime =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  /// Registers a successfully exported Word file into the local library.
  ///
  /// Existing export naming may overwrite the same path for a document;
  /// prior library entries for that path are replaced to avoid stale duplicates.
  Future<WordFileModel> registerExportedWord({
    required File file,
    required HistoryModel document,
    required String documentTitle,
  }) async {
    final size = await file.exists() ? await file.length() : 0;
    final entry = WordFileModel(
      id: 'word_${DateTime.now().millisecondsSinceEpoch}',
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

  Future<List<WordFileModel>> getWordFiles() async {
    final items = await _readAll();
    items.sort((a, b) => b.exportedAt.compareTo(a.exportedAt));
    return items;
  }

  Future<bool> fileExists(WordFileModel item) async {
    if (item.filePath.isEmpty) return false;
    return File(item.filePath).exists();
  }

  Future<void> deleteWord(String id) async {
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

  Future<void> openWord(WordFileModel item) async {
    final file = File(item.filePath);
    if (!await file.exists()) {
      throw StateError('Word file not found on device.');
    }

    await OpenFilex.open(file.path, type: _docxMime);
  }

  Future<void> shareWord(WordFileModel item) async {
    final file = File(item.filePath);
    if (!await file.exists()) {
      throw StateError('Word file not found on device.');
    }

    await Share.shareXFiles(
      [XFile(file.path, mimeType: _docxMime)],
      subject: item.fileName,
      text: 'Shared from ${ExportConstants.appExportTitle}',
    );
  }

  Future<List<WordFileModel>> _readAll() async {
    final raw = storageService.read<List<dynamic>>(StorageKeys.wordFilesLibrary);
    if (raw == null || raw.isEmpty) return [];

    return raw
        .map(
          (entry) => WordFileModel.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<void> _writeAll(List<WordFileModel> items) async {
    await storageService.write(
      StorageKeys.wordFilesLibrary,
      items.map((item) => item.toJson()).toList(),
    );
  }
}
