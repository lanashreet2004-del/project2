import 'package:flutter_test/flutter_test.dart';
import 'package:p2/models/ocr_process_response.dart';
import 'package:p2/models/ocr_status_model.dart';

void main() {
  test('OcrProcessResponse parses 202 body', () {
    final response = OcrProcessResponse.fromJson({
      'id': 123,
      'status': 'PENDING',
      'message': 'OCR task accepted. Poll the status endpoint for updates.',
    });

    expect(response.id, 123);
    expect(response.status, 'PENDING');
  });

  test('OcrStatusModel maps COMPLETED text for result UI', () {
    final status = OcrStatusModel.fromJson({
      'id': 15,
      'status': 'COMPLETED',
      'extracted_text': 'Hello OCR',
      'error_message': null,
      'document': {
        'paragraphs': ['Hello OCR'],
      },
      'result': {
        'status': 'COMPLETED',
        'completed_at': '2026-08-15T14:31:20+00:00',
      },
    });

    expect(status.isCompleted, isTrue);
    expect(status.toOcrResultMap()['text'], 'Hello OCR');
    expect(status.toOcrResultMap()['id'], '15');
  });

  test('OcrStatusModel FAILED exposes error_message', () {
    final status = OcrStatusModel.fromJson({
      'id': 9,
      'status': 'FAILED',
      'extracted_text': null,
      'error_message': 'Could not read image',
      'document': {'paragraphs': []},
    });

    expect(status.isFailed, isTrue);
    expect(status.errorMessage, 'Could not read image');
  });
}
