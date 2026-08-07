import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class PillBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const PillBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Floating Pill Navigation Bar
        Container(
          height: 56,
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C1C),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.pie_chart_rounded,
                isActive: currentIndex == 1,
              ),
              // Add Button centered
              GestureDetector(
                onTap: onAddTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFB8000B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.history_rounded,
                isActive: currentIndex == 2,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                isActive: currentIndex == 3,
                customIcon: _buildAvatarIcon(currentIndex == 3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildAvatarIcon(bool isActive) {
    final avatarUrl = SupabaseService.currentUser?.userMetadata?['avatar_url'];
    if (avatarUrl == null) return null;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: Colors.white, width: 1.5) : null,
        image: DecorationImage(
          image: NetworkImage(avatarUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isActive,
    Widget? customIcon,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(customIcon != null ? 6 : 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFB8000B) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: customIcon ?? Icon(
          icon,
          color: isActive ? Colors.white : Colors.white54,
          size: 22,
        ),
      ),
    );
  }
}
