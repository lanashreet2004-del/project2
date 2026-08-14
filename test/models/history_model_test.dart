import 'package:flutter_test/flutter_test.dart';
import 'package:p2/models/history_model.dart';

import '../helpers/offline_test_support.dart';

void main() {
  final createdAt = DateTime.utc(2026, 6, 12, 14, 30);

  HistoryModel sample() => HistoryModel(
        id: 'doc_100',
        imagePath: '/app/DocumentImages/doc_100.jpg',
        extractedText: 'هذا نص مستخرج.',
        createdAt: createdAt,
      );

  test('round-trips through toJson and fromJson', () {
    final original = sample();
    final json = original.toJson();

    expect(json['id'], original.id);
    expect(json['image_path'], original.imagePath);
    expect(json['extracted_text'], original.extractedText);
    expect(json['created_at'], createdAt.toIso8601String());
    expectNoConfidenceFields(json);

    final restored = HistoryModel.fromJson(json);

    expect(restored.id, original.id);
    expect(restored.imagePath, original.imagePath);
    expect(restored.extractedText, original.extractedText);
    expect(restored.createdAt, original.createdAt);
    expectNoConfidenceFields(restored.toJson());
  });

  test('serialized history JSON does not include confidence keys', () {
    expectNoConfidenceFields(sample().toJson());
  });

  test('fromJson ignores leftover confidence keys from old storage', () {
    final json = sample().toJson();
    json['confidence'] = 0.92;
    json['ocrConfidence'] = 0.1;

    final restored = HistoryModel.fromJson(json);
    final roundTrip = restored.toJson();

    expect(restored.extractedText, sample().extractedText);
    expect(roundTrip.containsKey('confidence'), isFalse);
    expectNoConfidenceFields(roundTrip);
  });
}
