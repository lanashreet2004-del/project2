import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/recent_upload_model.dart';

/// Single recent upload list item.
class RecentUploadItem extends StatelessWidget {
  const RecentUploadItem({
    super.key,
    required this.upload,
    required this.onTap,
  });

  final RecentUploadModel upload;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  upload.thumbnailAsset,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  cacheWidth: 112,
                  cacheHeight: 112,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.iconBgPurple,
                    child: const Icon(Icons.description_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upload.fileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      upload.uploadedAgo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
