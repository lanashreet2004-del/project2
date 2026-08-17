import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/utils/api_exception.dart';
import '../models/ocr_result_model.dart';
import 'base_repository.dart';
import 'history_repository.dart';

/// Text editing layer for OCR extracted text.
class TextEditRepository extends BaseRepository {
  TextEditRepository({
    required super.apiService,
    required super.storageService,
  });

  OcrResultModel applyTextEdit(OcrResultModel original, String newText) {
    return original.copyWith(extractedText: newText);
  }

  Future<void> saveToHistory(OcrResultModel result) async {
    // Placeholder — persist edited OCR result to local history
  }

  Future<String> exportToJson(OcrResultModel result) async {
    // Placeholder — JSON export of edited text
    return result.toJson().toString();
  }

  Future<String> exportToPdf(OcrResultModel result) async {
    // Placeholder — PDF export of edited text
    return '';
  }

  /// PATCH `/api/ocr-status/{id}/` with `{ "extracted_text": ... }`.
  Future<OcrResultModel> syncToBackend({
    required OcrResultModel original,
    required String editedText,
  }) async {
    final backendId = HistoryRepository.parseBackendId(original.id);
    if (backendId == null) {
      throw ApiException(
        'This document does not have a valid backend OCR ID.',
      );
    }

    try {
      final response = await apiService.patch<dynamic>(
        ApiConstants.ocrStatus(backendId),
        data: {
          'extracted_text': editedText,
        },
      );

      final extracted = _extractedTextFromResponse(response.data);
      return original.copyWith(
        extractedText: extracted ?? editedText,
      );
    } on DioException catch (e) {
      throw _exceptionFromPatchDio(e);
    }
  }

  String? _extractedTextFromResponse(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final extracted = map['extracted_text'];
    if (extracted is String) return extracted;
    return null;
  }

  ApiException _exceptionFromPatchDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    Map<String, dynamic>? map;
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
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
}
