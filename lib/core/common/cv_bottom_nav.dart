import 'package:cv_bank/core/constants/app_assets.dart';
import 'package:cv_bank/core/routes/routes.dart';
import 'package:cv_bank/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CvBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  const CvBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const tabs = [
    AppRoutes.dashboard,
    AppRoutes.people,
    AppRoutes.categories,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final routeName = entry.value;
          final isSelected = currentIndex == index;

          return _BottomNavItem(
            label: _getLabel(routeName),
            iconPath: _getIconPath(routeName),
            isSelected: isSelected,
            onTap: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.people:
        return 'People';
      case AppRoutes.categories:
        return 'Categories';
      case AppRoutes.profile:
        return 'Profile';
      default:
        return '';
    }
  }

  String _getIconPath(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return AppAssets.TAB_DASHBOARD;
      case AppRoutes.people:
        return AppAssets.TAB_PEOPLE;
      case AppRoutes.categories:
        return AppAssets.TAB_CATEGORIES;
      case AppRoutes.profile:
        return AppAssets.TAB_PROFILE;
      default:
        return AppAssets.TAB_DASHBOARD;
    }
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary500 : AppColors.subText2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
