import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_context.dart';

class MaktubBottomNavItem {
  const MaktubBottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Floating bottom navigation — green bar, white icons; same index/onTap contract.
class MaktubBottomNavBar extends StatelessWidget {
  const MaktubBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<MaktubBottomNavItem> items;

  static const Duration _animationDuration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barGreen = context.appColors.appBarBackground;
    final onBar = context.appColors.onAppBar;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          bottomInset > 0 ? bottomInset + 6 : 14,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: barGreen,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppShadows.bar(context, isDark: context.isDark),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItemButton(
                      item: items[i],
                      selected: currentIndex == i,
                      onBar: onBar,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.item,
    required this.selected,
    required this.onBar,
    required this.onTap,
  });

  final MaktubBottomNavItem item;
  final bool selected;
  final Color onBar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? onBar : onBar.withValues(alpha: 0.72);
    final pillColor =
        selected ? onBar.withValues(alpha: 0.20) : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: onBar.withValues(alpha: 0.22),
        highlightColor: onBar.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.06 : 1.0,
                duration: MaktubBottomNavBar._animationDuration,
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: MaktubBottomNavBar._animationDuration,
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? 14 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: 24,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSlide(
                offset: selected ? Offset.zero : const Offset(0, 0.15),
                duration: MaktubBottomNavBar._animationDuration,
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0.78,
                  duration: MaktubBottomNavBar._animationDuration,
                  curve: Curves.easeInOut,
                  child: AnimatedDefaultTextStyle(
                    duration: MaktubBottomNavBar._animationDuration,
                    curve: Curves.easeInOut,
                    style:
                        (context.texts.labelSmall ?? const TextStyle()).copyWith(
                      color: fg,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                      height: 1.1,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
