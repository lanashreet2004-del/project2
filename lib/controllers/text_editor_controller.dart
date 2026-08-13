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
  final RxBool hasChanges = false.obs;

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
    hasChanges.value = textController.text != _ocrResult.extractedText;
  }

  Future<void> onCancel() async {
    if (!hasChanges.value) {
      Get.back();
      return;
    }

    final discard = await Get.dialog<bool>(
      AlertDialog(
        title: Text('textEditor.unsavedTitle'.tr),
        content: Text('textEditor.unsavedBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('textEditor.keepEditing'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('textEditor.discard'.tr),
          ),
        ],
      ),
    );

    if (discard == true) {
      Get.back();
    }
  }

  void onDone() {
    final text = textController.text;
    if (text.trim().isEmpty) {
      Get.snackbar(
        'textEditor.emptyTitle'.tr,
        'textEditor.emptyBody'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final updated = _repository.applyTextEdit(_ocrResult, text);
    Get.back(result: updated);
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.onClose();
  }
}
