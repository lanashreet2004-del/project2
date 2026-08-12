import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/image_pick_source.dart';
import '../models/recent_upload_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/image_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Controller for home screen presentation logic.
class HomeController extends BaseController {
  HomeController({
    required AuthRepository authRepository,
    required ImageRepository imageRepository,
  })  : _authRepository = authRepository,
        _imageRepository = imageRepository;

  final AuthRepository _authRepository;
  final ImageRepository _imageRepository;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final RxString username = 'Ahmad'.obs;
  final RxString greeting = ''.obs;
  final RxList<RecentUploadModel> recentUploads = <RecentUploadModel>[].obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _setGreeting();
    _loadDummyRecentUploads();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Good morning 👋';
    } else if (hour < 17) {
      greeting.value = 'Good afternoon 👋';
    } else {
      greeting.value = 'Good evening 👋';
    }
  }

  Future<void> loadData() async {
    await runAsync(() async {
      if (_authRepository.isLoggedIn) {
        // Future: load username from auth session
      }
      _loadDummyRecentUploads();
    });
  }

  void _loadDummyRecentUploads() {
    recentUploads.assignAll(const [
      RecentUploadModel(
        id: '1',
        fileName: 'Photo1.Jpg',
        uploadedAgo: '2 days ago',
        thumbnailAsset: 'assets/images/splash/splash1.png',
      ),
      RecentUploadModel(
        id: '2',
        fileName: 'Photo2.Jpg',
        uploadedAgo: '2 days ago',
        thumbnailAsset: 'assets/images/splash/splash2.png',
      ),
      RecentUploadModel(
        id: '3',
        fileName: 'Photo3.Jpg',
        uploadedAgo: '2 days ago',
        thumbnailAsset: 'assets/images/splash/splash3.png',
      ),
    ]);
  }

  void _openImageEditor(String path, ImagePickSource source) {
    Get.toNamed(
      AppRoutes.imageEditor,
      arguments: {
        'filePath': path,
        'source': source.routeValue,
      },
    );
  }

  Future<void> pickFromGallery() async {
    final path = await runAsync(() => _imageRepository.pickFromGallery());
    if (path != null) {
      _openImageEditor(path, ImagePickSource.gallery);
    } else if (hasError) {
      _showPickError('Gallery');
    }
  }

  Future<void> pickFromCamera() async {
    final path = await runAsync(() => _imageRepository.pickFromCamera());
    if (path != null) {
      _openImageEditor(path, ImagePickSource.camera);
    } else if (hasError) {
      _showPickError('Camera');
    }
  }

  void _showPickError(String source) {
    Get.snackbar(
      source,
      errorMessage.value ?? 'Could not pick image',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  void openMenu() => scaffoldKey.currentState?.openDrawer();

  void _closeDrawer() => scaffoldKey.currentState?.closeDrawer();

  void navigateHome() {
    _closeDrawer();
    if (Get.currentRoute != AppRoutes.home) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void openMyDocuments() {
    _closeDrawer();
    Get.toNamed(AppRoutes.documents);
  }

  void openSettings() {
    _closeDrawer();
    Get.toNamed(AppRoutes.settings);
  }

  void openProfile() {
    // Future: navigate to profile page
  }

  void onSearch(String query) {
    // Future: search functionality
  }

  void openUploadDetails(RecentUploadModel item) {
    Get.toNamed(AppRoutes.result, arguments: {'resultId': item.id});
  }

  void openSeeAll() => Get.toNamed(AppRoutes.documents);

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
