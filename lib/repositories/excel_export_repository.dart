import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/export_constants.dart';
import '../core/utils/api_exception.dart';
import '../models/history_model.dart';
import 'base_repository.dart';
import 'history_repository.dart';

/// Downloads backend-generated Excel (.xlsx) exports and saves them locally.
class ExcelExportRepository extends BaseRepository {
  ExcelExportRepository({
    required super.apiService,
    required super.storageService,
  });

  static const _xlsxMime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// Downloads a backend-generated XLSX for the OCR record and saves it locally.
  Future<File?> exportDocumentToExcel(HistoryModel document) async {
    final backendId = HistoryRepository.parseBackendId(document.id);
    if (backendId == null) {
      throw ApiException(
        'This document does not have a valid backend OCR ID.',
      );
    }

    try {
      final response = await apiService.get<List<int>>(
        ApiConstants.ocrExportXlsx(backendId),
        options: Options(responseType: ResponseType.bytes),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw ApiException('Empty XLSX response from server.');
      }

      final bytes = Uint8List.fromList(data);
      if (!_looksLikeXlsx(bytes)) {
        throw ApiException('Server did not return a valid Excel file.');
      }

      final preferredName = _fileNameFromHeaders(
        response.headers,
        backendId,
      );
      return _writeXlsxBytes(bytes, preferredName);
    } on DioException catch (e) {
      throw _exceptionFromExportDio(e);
    }
  }

  /// Human-readable title derived from OCR text.
  String documentTitleOf(HistoryModel document) {
    return _documentTitle(document.extractedText);
  }

  Future<void> shareExportedFile(File file) async {
    if (!await file.exists()) return;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: _xlsxMime)],
      subject: '${ExportConstants.appExportTitle} Report',
      text: 'Exported OCR document Excel file',
    );
  }

  Future<void> openExportedFile(File file) async {
    if (!await file.exists()) return;

    await OpenFilex.open(file.path, type: _xlsxMime);
  }

  Future<Directory> _ensureExportsDirectory() async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final exportsDirectory = Directory(
      '${baseDirectory.path}/${ExportConstants.exportsFolderName}/${ExportConstants.excelExportsSubfolder}',
    );

    if (!await exportsDirectory.exists()) {
      await exportsDirectory.create(recursive: true);
    }

    return exportsDirectory;
  }

  Future<File> _writeXlsxBytes(Uint8List bytes, String preferredName) async {
    final directory = await _ensureExportsDirectory();
    var fileName = _sanitizeFileName(
      preferredName.toLowerCase().endsWith('.xlsx')
          ? preferredName.substring(0, preferredName.length - 5)
          : preferredName,
    );
    if (fileName.isEmpty) fileName = 'ocr_export';
    fileName = '$fileName${ExportConstants.excelFileExtension}';

    var file = File('${directory.path}${Platform.pathSeparator}$fileName');
    if (await file.exists()) {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final base = fileName.substring(
        0,
        fileName.length - ExportConstants.excelFileExtension.length,
      );
      fileName = '${base}_$stamp${ExportConstants.excelFileExtension}';
      file = File('${directory.path}${Platform.pathSeparator}$fileName');
    }

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _fileNameFromHeaders(Headers headers, int id) {
    final cd = headers.value('content-disposition');
    if (cd != null && cd.isNotEmpty) {
      final quoted = RegExp(
        r'filename="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(cd);
      if (quoted != null) {
        final name = quoted.group(1)?.trim() ?? '';
        if (name.toLowerCase().endsWith('.xlsx') && name.isNotEmpty) {
          return name;
        }
      }
      final plain = RegExp(
        r'filename=([^;\s]+)',
        caseSensitive: false,
      ).firstMatch(cd);
      if (plain != null) {
        final name = plain.group(1)?.replaceAll('"', '').trim() ?? '';
        if (name.toLowerCase().endsWith('.xlsx') && name.isNotEmpty) {
          return name;
        }
      }
    }
    return 'ocr_export_$id.xlsx';
  }

  bool _looksLikeXlsx(Uint8List bytes) {
    if (bytes.length < 2) return false;
    // XLSX is a ZIP package (PK..)
    return bytes[0] == 0x50 && bytes[1] == 0x4B;
  }

  /// Same binary-error decoding used by PDF/Word export.
  ApiException _exceptionFromExportDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    Map<String, dynamic>? map;
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    } else if (data is List<int>) {
      try {
        final text = utf8.decode(data, allowMalformed: true).trim();
        if (text.isNotEmpty) {
          final decoded = jsonDecode(text);
          if (decoded is Map) {
            map = Map<String, dynamic>.from(decoded);
          } else if (text.isNotEmpty) {
            return ApiException(text, statusCode: status);
          }
        }
      } catch (_) {
        // Fall through to ApiException.fromDio.
      }
    } else if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          map = Map<String, dynamic>.from(decoded);
        } else {
          return ApiException(data.trim(), statusCode: status);
        }
      } catch (_) {
        return ApiException(data.trim(), statusCode: status);
      }
    }

    if (map != null) {
      final message = map['message'];
      if (message is String && message.trim().isNotEmpty) {
        final statusLabel = map['status'];
        if (statusLabel is String && statusLabel.trim().isNotEmpty) {
          return ApiException(
            '${message.trim()} (${statusLabel.trim()})',
            statusCode: status,
          );
        }
        return ApiException(message.trim(), statusCode: status);
      }
    }

    return ApiException.fromDio(error);
  }

  String _sanitizeFileName(String input) {
    var name = input.trim();
    if (name.isEmpty) name = 'document';

    name = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.endsWith('.')) {
      name = name.substring(0, name.length - 1).trim();
    }

    const maxLength = 60;
    if (name.length > maxLength) {
      name = name.substring(0, maxLength).trim();
    }

    return name.isEmpty ? 'document' : name;
  }

  String _documentTitle(String extractedText) {
    final trimmed = extractedText.trim();
    if (trimmed.isEmpty) return 'Untitled Document';

    final firstLine = trimmed.split('\n').first.trim();
    if (firstLine.isEmpty) return 'Untitled Document';

    const maxLength = 80;
    if (firstLine.length <= maxLength) return firstLine;
    return '${firstLine.substring(0, maxLength)}...';
  }
}
