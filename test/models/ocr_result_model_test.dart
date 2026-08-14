import 'package:flutter_test/flutter_test.dart';
import 'package:p2/models/ocr_result_model.dart';

import '../helpers/offline_test_support.dart';

void main() {
  final processedAt = DateTime.utc(2026, 8, 14, 15, 30, 0);

  OcrResultModel sample() => OcrResultModel(
        id: 'ocr_42',
        extractedText: 'مرحباً بكم في تطبيق مكتوب.',
        processedAt: processedAt,
        imagePath: '/tmp/working.jpg',
        language: 'ar',
      );

  test('round-trips through toJson and fromOcrMap', () {
    final original = sample();
    final json = original.toJson();

    expect(json['id'], original.id);
    expect(json['text'], original.extractedText);
    expect(json['processed_at'], processedAt.toIso8601String());
    expect(json['image_path'], original.imagePath);
    expect(json['language'], 'ar');
    expectNoConfidenceFields(json);

    // Production deserializer is fromOcrMap; imagePath is supplied by the local flow.
    final restored = OcrResultModel.fromOcrMap(
      json,
      imagePath: json['image_path'] as String,
    );

    expect(restored.id, original.id);
    expect(restored.extractedText, original.extractedText);
    expect(restored.processedAt, original.processedAt);
    expect(restored.imagePath, original.imagePath);
    expect(restored.language, original.language);
    expectNoConfidenceFields(restored.toJson());
  });

  test('serialized OCR JSON does not include confidence keys', () {
    final json = sample().toJson();
    final ocrMap = sample().toOcrMap();

    expect(json.keys, isNot(contains('confidence')));
    expect(ocrMap.keys, isNot(contains('confidence')));
    expectNoConfidenceFields(json);
    expectNoConfidenceFields(ocrMap);
  });

  test('fromOcrMap ignores leftover confidence keys from old payloads', () {
    final json = sample().toJson();
    json['confidence'] = 0.92;
    json['confidenceScore'] = 0.5;

    final restored = OcrResultModel.fromOcrMap(
      json,
      imagePath: json['image_path'] as String,
    );

    expectNoConfidenceFields(restored.toJson());
    expect(restored.extractedText, sample().extractedText);
  });
}
