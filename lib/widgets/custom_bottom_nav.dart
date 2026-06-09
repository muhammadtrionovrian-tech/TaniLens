import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Custom premium colors matching the figma palette
    const backgroundColor = AppColors.accent;      // Soft light sage pastel
    const selectedColor = AppColors.primary;        // Darker Olive Sage
    const unselectedColor = AppColors.primaryLight; // Olive Sage

    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'HOME',
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.center_focus_weak_outlined,
                selectedIcon: Icons.center_focus_strong,
                label: 'PINDAI',
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                label: 'RIWAYAT',
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final isSelected = currentIndex == index;
    final activeColor = isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.4) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: activeColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: activeColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
