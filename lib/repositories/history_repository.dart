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

  Future<void> saveDocument(HistoryModel item) async {
    final documents = await _readAll();
    documents.removeWhere((doc) => doc.id == item.id);
    documents.insert(0, item);
    await _writeAll(documents);
  }

  Future<List<HistoryModel>> getDocuments() async {
    final documents = await _readAll();
    documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return documents;
  }

  Future<void> deleteDocument(String id) async {
    final documents = await _readAll();
    documents.removeWhere((doc) => doc.id == id);
    await _writeAll(documents);
  }

  Future<void> clearAll() async {
    await storageService.write(StorageKeys.documentHistory, <Map<String, dynamic>>[]);
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
