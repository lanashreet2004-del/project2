import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/storage_keys.dart';
import '../models/history_model.dart';
import 'base_repository.dart';

/// Handles document history persistence via local storage.
/// Ready for migration to Dio API or a local database.
class HistoryRepository extends BaseRepository {
  HistoryRepository({
    required super.apiService,
    required super.storageService,
  });

  static const _imagesFolder = 'DocumentImages';

  /// Saves metadata after copying the image into durable app storage.
  ///
  /// Image copy happens only here (explicit save), never during list loads
  /// or camera/gallery picking. Missing text or a missing image is not saved.
  Future<HistoryModel> saveDocument(HistoryModel item) async {
    if (item.extractedText.trim().isEmpty) {
      throw Exception('Cannot save document without extracted text');
    }

    final persisted = await _persistImage(item);
    final imagesDir = await _imagesDirectory();
    if (imagesDir == null ||
        !_isUnderDirectory(persisted.imagePath, imagesDir.path) ||
        !File(persisted.imagePath).existsSync()) {
      throw Exception('Cannot save document without a persisted image');
    }

    final documents = await _readAll();
    documents.removeWhere((doc) => doc.id == persisted.id);
    documents.insert(0, persisted);
    await _writeAll(documents);
    return persisted;
  }

  /// Copies a still-valid temp/cache image into durable storage in place.
  /// Does not reorder history. Safe to call when opening an existing document.
  Future<HistoryModel> ensurePersistedImage(HistoryModel item) async {
    try {
      final persisted = await _persistImage(item);
      if (persisted.imagePath == item.imagePath) return item;

      final documents = await _readAll();
      final index = documents.indexWhere((doc) => doc.id == persisted.id);
      if (index >= 0) {
        documents[index] = persisted;
        await _writeAll(documents);
      }
      return persisted;
    } catch (e, st) {
      debugPrint('HistoryRepository.ensurePersistedImage failed: $e\n$st');
      return item;
    }
  }

  Future<List<HistoryModel>> getDocuments() async {
    final documents = await _readAll();
    documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return documents;
  }

  Future<void> deleteDocument(String id) async {
    final documents = await _readAll();
    HistoryModel? removed;
    documents.removeWhere((doc) {
      if (doc.id == id) {
        removed = doc;
        return true;
      }
      return false;
    });
    await _writeAll(documents);
    await _deletePersistedImage(removed);
  }

  Future<void> clearAll() async {
    final documents = await _readAll();
    await storageService.write(
      StorageKeys.documentHistory,
      <Map<String, dynamic>>[],
    );
    for (final doc in documents) {
      await _deletePersistedImage(doc);
    }
  }

  /// Copies a capture/edit temp file into application documents.
  /// Never deletes the source. Never throws.
  Future<HistoryModel> _persistImage(HistoryModel item) async {
    try {
      final sourcePath = item.imagePath.trim();
      if (sourcePath.isEmpty) return item;

      final imagesDir = await _imagesDirectory();
      if (imagesDir == null) return item;
      if (_isUnderDirectory(sourcePath, imagesDir.path)) {
        return item;
      }

      final source = File(sourcePath);
      if (!await source.exists()) return item;

      final dest = File(
        '${imagesDir.path}${Platform.pathSeparator}${item.id}${_fileExtension(sourcePath)}',
      );

      if (source.path == dest.path) return item;

      await source.copy(dest.path);
      return item.copyWith(imagePath: dest.path);
    } catch (e, st) {
      debugPrint('HistoryRepository._persistImage failed: $e\n$st');
      return item;
    }
  }

  Future<void> _deletePersistedImage(HistoryModel? item) async {
    try {
      final path = item?.imagePath.trim() ?? '';
      if (path.isEmpty) return;

      final imagesDir = await _imagesDirectory();
      if (imagesDir == null) return;
      if (!_isUnderDirectory(path, imagesDir.path)) return;

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, st) {
      debugPrint('HistoryRepository._deletePersistedImage failed: $e\n$st');
    }
  }

  Future<Directory?> _imagesDirectory() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(
        '${docs.path}${Platform.pathSeparator}$_imagesFolder',
      );
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (e, st) {
      debugPrint('HistoryRepository._imagesDirectory failed: $e\n$st');
      return null;
    }
  }

  bool _isUnderDirectory(String filePath, String directoryPath) {
    var file = filePath.replaceAll('\\', '/');
    var dir = directoryPath.replaceAll('\\', '/');
    if (Platform.isWindows) {
      file = file.toLowerCase();
      dir = dir.toLowerCase();
    }
    final normalizedDir = dir.endsWith('/') ? dir : '$dir/';
    return file.startsWith(normalizedDir);
  }

  String _fileExtension(String path) {
    final name = path.split(RegExp(r'[\\/]')).last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return '.jpg';
    final ext = name.substring(dot).toLowerCase();
    if (ext.length > 5) return '.jpg';
    return ext;
  }

  Future<List<HistoryModel>> _readAll() async {
    final raw = storageService.read<List<dynamic>>(StorageKeys.documentHistory);
    if (raw == null || raw.isEmpty) return [];

    return raw
        .map(
          (entry) => HistoryModel.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  Future<void> _writeAll(List<HistoryModel> documents) async {
    await storageService.write(
      StorageKeys.documentHistory,
      documents.map((doc) => doc.toJson()).toList(),
    );
  }
}
