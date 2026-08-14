import 'dart:convert';
import 'dart:io';

import 'package:open_file_manager/open_file_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/export_constants.dart';
import '../models/history_model.dart';
import '../models/json_export_validation_result.dart';
import 'base_repository.dart';

/// Handles JSON export, sharing, validation, and export folder access.
/// Ready for backend upload, cloud sync, and remote download.
class JsonExportRepository extends BaseRepository {
  JsonExportRepository({
    required super.apiService,
    required super.storageService,
  });

  static const String schemaVersion = '1.0';

  Map<String, dynamic> buildExportPayload({
    required HistoryModel document,
    required String status,
    required String sourceType,
    required int wordCount,
    required int characterCount,
    required int lineCount,
  }) {
    return {
      'documentInfo': {
        'id': document.id,
        'createdAt': document.createdAt.toIso8601String(),
        'status': status,
      },
      'ocrResult': {
        'text': document.extractedText,
        'wordCount': wordCount,
        'characterCount': characterCount,
        'lineCount': lineCount,
      },
      'source': {
        'imagePath': document.imagePath,
        'sourceType': sourceType,
      },
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': AppConstants.appVersion,
        'schemaVersion': schemaVersion,
      },
    };
  }

  JsonExportValidationResult validateExportPayload(Map<String, dynamic> payload) {
    final errors = <String>[];

    final documentInfo = payload['documentInfo'] as Map<String, dynamic>?;
    final id = documentInfo?['id'] as String?;
    if (id == null || id.trim().isEmpty) {
      errors.add('Document ID is missing.');
    }

    final ocrResult = payload['ocrResult'] as Map<String, dynamic>?;
    final text = ocrResult?['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      errors.add('Extracted text is empty.');
    }

    return JsonExportValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  String formatPrettyJson(Map<String, dynamic> payload) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  Future<File?> exportDocumentToJson({
    required HistoryModel document,
    required String status,
    required String sourceType,
    required int wordCount,
    required int characterCount,
    required int lineCount,
  }) async {
    try {
      final payload = buildExportPayload(
        document: document,
        status: status,
        sourceType: sourceType,
        wordCount: wordCount,
        characterCount: characterCount,
        lineCount: lineCount,
      );

      final validation = validateExportPayload(payload);
      if (!validation.isValid) return null;

      final directory = await _ensureExportsDirectory();
      final fileName =
          '${ExportConstants.jsonFilePrefix}${_sanitizeId(document.id)}${ExportConstants.jsonFileExtension}';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(formatPrettyJson(payload));
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<void> shareJsonPayload(Map<String, dynamic> payload) async {
    await Share.share(
      formatPrettyJson(payload),
      subject: '${ExportConstants.appExportTitle} JSON Export',
    );
  }

  Future<Directory> getExportsDirectory() => _ensureExportsDirectory();

  Future<void> shareExportedFile(File file) async {
    if (!await file.exists()) return;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'OCR Document Export',
      text: 'Exported OCR document JSON',
    );
  }

  Future<void> openExportFolder({File? highlightFile}) async {
    final directory = await _ensureExportsDirectory();

    if (Platform.isIOS) {
      await openFileManager(
        iosConfig: IosConfig(subFolderPath: ExportConstants.exportsFolderName),
      );
      return;
    }

    if (Platform.isAndroid) {
      if (highlightFile != null && await highlightFile.exists()) {
        await OpenFilex.open(
          highlightFile.path,
          type: 'application/json',
        );
      }
      return;
    }

    if (Platform.isWindows) {
      await Process.run('explorer', [directory.path]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.run('open', [directory.path]);
      return;
    }

    if (Platform.isLinux) {
      await Process.run('xdg-open', [directory.path]);
    }
  }

  Future<void> uploadToBackend(File file) async {
    // Placeholder — Dio multipart upload when backend is ready
  }

  Future<void> syncToCloud(File file) async {
    // Placeholder — cloud sync integration
  }

  Future<File?> downloadGeneratedJson(String remoteUrl) async {
    // Placeholder — download JSON from backend
    return null;
  }

  Future<Directory> _ensureExportsDirectory() async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final exportsDirectory = Directory(
      '${baseDirectory.path}/${ExportConstants.exportsFolderName}',
    );

    if (!await exportsDirectory.exists()) {
      await exportsDirectory.create(recursive: true);
    }

    return exportsDirectory;
  }

  String _sanitizeId(String id) {
    final sanitized = id.replaceAll(RegExp(r'[^\w\-]'), '_');
    return sanitized.isEmpty ? 'unknown' : sanitized;
  }
}
