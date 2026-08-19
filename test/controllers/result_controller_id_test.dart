import 'package:flutter_test/flutter_test.dart';
import 'package:p2/controllers/result_controller.dart';
import 'package:p2/repositories/history_repository.dart';

void main() {
  test('preserves numeric backend OCR IDs for Save Document', () {
    expect(ResultController.persistableHistoryId('29'), '29');
    expect(ResultController.persistableHistoryId(' 42 '), '42');
    expect(HistoryRepository.parseBackendId('29'), 29);
  });

  test('does not send local or placeholder IDs as backend PKs', () {
    expect(HistoryRepository.parseBackendId('doc_123456'), isNull);
    expect(HistoryRepository.parseBackendId('ocr_unknown'), isNull);
    expect(HistoryRepository.parseBackendId('default'), isNull);

    expect(
      ResultController.persistableHistoryId('doc_123456'),
      'doc_123456',
    );
    expect(
      ResultController.persistableHistoryId('ocr_unknown'),
      startsWith('doc_'),
    );
    expect(
      ResultController.persistableHistoryId('default'),
      startsWith('doc_'),
    );
  });
}
