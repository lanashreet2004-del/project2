import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/history_model.dart';
import '../repositories/history_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'home_controller.dart';

/// Local document search presentation logic.
class DocumentSearchController extends BaseController {
  DocumentSearchController({required HistoryRepository historyRepository})
      : _historyRepository = historyRepository;

  final HistoryRepository _historyRepository;

  final TextEditingController searchFieldController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final RxList<HistoryModel> allDocuments = <HistoryModel>[].obs;
  final RxList<HistoryModel> searchResults = <HistoryModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasQuery = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  @override
  void onReady() {
    super.onReady();
    searchFocusNode.requestFocus();
  }

  Future<void> loadDocuments() async {
    final data = await runAsync(() => _historyRepository.getDocuments());
    if (data == null) return;
    allDocuments.assignAll(data);
    _applySearch(searchQuery.value);
  }

  void onSearch(String query) {
    searchQuery.value = query;
    hasQuery.value = query.trim().isNotEmpty;
    _applySearch(query);
  }

  void clearSearch() {
    searchFieldController.clear();
    searchQuery.value = '';
    hasQuery.value = false;
    searchResults.clear();
    searchFocusNode.requestFocus();
  }

  void _applySearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      searchResults.clear();
      return;
    }

    final matches = allDocuments.where((doc) {
      final title = HomeController.documentTitle(doc).toLowerCase();
      final text = doc.extractedText.toLowerCase();
      final id = doc.id.toLowerCase();
      return title.contains(normalized) ||
          text.contains(normalized) ||
          id.contains(normalized);
    }).toList();

    searchResults.assignAll(matches);
  }

  Future<void> openDocument(HistoryModel document) async {
    await Get.toNamed(AppRoutes.documentDetails, arguments: document);
    await loadDocuments();
  }

  @override
  void onClose() {
    searchFieldController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}
