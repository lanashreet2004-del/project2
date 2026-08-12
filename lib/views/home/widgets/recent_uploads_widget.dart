import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/recent_upload_model.dart';
import 'recent_upload_item.dart';

/// Recent uploads section with header and list.
class RecentUploadsWidget extends StatelessWidget {
  const RecentUploadsWidget({
    super.key,
    required this.uploads,
    required this.onSeeAll,
    required this.onItemTap,
  });

  final List<RecentUploadModel> uploads;
  final VoidCallback onSeeAll;
  final ValueChanged<RecentUploadModel> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Uploads',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.nameHighlight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See All',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...uploads.map(
          (upload) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RecentUploadItem(
              upload: upload,
              onTap: () => onItemTap(upload),
            ),
          ),
        ),
      ],
    );
  }
}
