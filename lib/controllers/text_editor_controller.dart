import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/ocr_result_model.dart';
import '../repositories/text_edit_repository.dart';
import 'base_controller.dart';

/// Presentation logic for OCR text editing.
class TextEditorController extends BaseController {
  TextEditorController({
    required TextEditRepository repository,
    required OcrResultModel ocrResult,
  })  : _repository = repository,
        _ocrResult = ocrResult;

  final TextEditRepository _repository;
  final OcrResultModel _ocrResult;

  late final TextEditingController textController;
  final RxInt characterCount = 0.obs;

  OcrResultModel get ocrResult => _ocrResult;

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController(text: _ocrResult.extractedText);
    characterCount.value = textController.text.length;
    textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    characterCount.value = textController.text.length;
  }

  void onCancel() => Get.back();

  void onDone() {
    final updated = _repository.applyTextEdit(
      _ocrResult,
      textController.text,
    );
    Get.back(result: updated);
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.onClose();
  }
}
