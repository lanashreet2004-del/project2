import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme_context.dart';
import 'maktub_header_waves.dart';

/// Deep-green layered wavy AppBar used across Maktub screens.
///
/// Drop-in replacement for [AppBar] that preserves leading/title/actions.
class WavyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WavyAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.leadingWidth,
    this.toolbarHeight = kToolbarHeight,
    this.waveHeight = 28,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? leadingWidth;
  final double toolbarHeight;
  final double waveHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight + waveHeight);

  @override
  Widget build(BuildContext context) {
    final onBar = context.appColors.onAppBar;

    final effectiveTitle = title == null
        ? null
        : DefaultTextStyle(
            style: (context.texts.titleMedium ?? const TextStyle()).copyWith(
              color: onBar,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            child: title!,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: const MaktubHeaderWaveClipper(),
              child: CustomPaint(
                painter: MaktubHeaderBackgroundPainter.fromTheme(
                  isDark: context.isDark,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: toolbarHeight,
                child: Builder(
                  builder: (context) {
                    final leadingWidget = _buildLeading(context, onBar);
                    return NavigationToolbar(
                      middleSpacing: 8,
                      centerMiddle: centerTitle,
                      leading: leadingWidget == null
                          ? null
                          : SizedBox(
                              width: leadingWidth ?? 56,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: leadingWidget,
                              ),
                            ),
                      middle: effectiveTitle,
                      trailing: actions == null || actions!.isEmpty
                          ? null
                          : IconTheme(
                              data: IconThemeData(color: onBar, size: 24),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: actions!,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color onBar) {
    if (leading != null) {
      return IconTheme(
        data: IconThemeData(color: onBar, size: 24),
        child: leading!,
      );
    }

    if (!automaticallyImplyLeading) return null;

    final parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;
    final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;

    if (hasDrawer && !canPop) {
      return IconButton(
        icon: Icon(Icons.menu_rounded, color: onBar),
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        onPressed: () => Scaffold.of(context).openDrawer(),
      );
    }

    if (canPop) {
      return IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: onBar),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.maybePop(context),
      );
    }

    return null;
  }
}
