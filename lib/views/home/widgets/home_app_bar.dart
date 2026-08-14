import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';
import '../../../core/widgets/maktub_header_waves.dart';
import 'search_bar_widget.dart';

/// Home branded header — layered green waves, curved bottom, floating search.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.onMenuTap,
    required this.onProfileTap,
    required this.searchController,
    required this.onSearchTap,
    this.profileImageUrl,
    this.searchHintText,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final TextEditingController searchController;
  final VoidCallback onSearchTap;
  final String? profileImageUrl;
  final String? searchHintText;

  static const double _toolbarHeight = kToolbarHeight;
  static const double _searchHeight = 52;
  static const double _waveExtra = 44;

  @override
  Widget build(BuildContext context) {
    final onBar = context.appColors.onAppBar;
    final top = MediaQuery.paddingOf(context).top;
    final headerBodyHeight = _toolbarHeight + 10 + _searchHeight + _waveExtra;
    final totalHeight = top + headerBodyHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: const MaktubHeaderWaveClipper(),
                child: CustomPaint(
                  painter: MaktubHeaderBackgroundPainter.fromTheme(
                    isDark: context.isDark,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: _toolbarHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: onMenuTap,
                              tooltip: 'home.menu'.tr,
                              icon: Icon(
                                Icons.menu_rounded,
                                size: 26,
                                color: onBar,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'app.name'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.texts.titleMedium?.copyWith(
                                  color: onBar,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onProfileTap,
                              tooltip: 'home.account'.tr,
                              icon: Icon(
                                Icons.person_outline_rounded,
                                size: 26,
                                color: onBar,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Transform.translate(
                      offset: const Offset(0, 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SearchBarWidget(
                          controller: searchController,
                          readOnly: true,
                          onTap: onSearchTap,
                          hintText: searchHintText ?? 'home.searchHint'.tr,
                          glassStyle: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
