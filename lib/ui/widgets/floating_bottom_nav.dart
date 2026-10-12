import 'package:flutter/material.dart';
import '../../core/app_state.dart';

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTelugu = AppState.instance.isTelugu;
    final homeLabel = isTelugu ? 'హోమ్' : 'Home';
    final essentialsLabel = isTelugu ? 'అవసరాలు' : 'Essentials';
    final exploreLabel = isTelugu ? 'అన్వేషించు' : 'Explore';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5132).withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Home Tab (Index 0)
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: homeLabel,
                ),
              ),

              // Placeholder spacing for center elevated Essentials FAB
              const SizedBox(width: 72),

              // 3. Explore Tab (Index 2)
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: exploreLabel,
                ),
              ),
            ],
          ),

          // 2. Center Elevated Essentials FAB (Index 1)
          Positioned(
            top: -16,
            child: _buildCenterFab(
              label: essentialsLabel,
              isActive: currentIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Center(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 16 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF083822)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F5132).withValues(alpha: 0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? Colors.white : const Color(0xFF475569),
                size: 22,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF475569),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                      letterSpacing: -0.2,
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

  Widget _buildCenterFab({
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulsing Aura Ring
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.32),
                    width: 2,
                  ),
                ),
              ),

              // Gradient FAB Circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.38),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive ? const Color(0xFF0F5132) : const Color(0xFFB45309),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
