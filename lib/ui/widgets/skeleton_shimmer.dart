import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Lightweight, 60fps hardware-accelerated Shimmer Effect built purely with Flutter
/// framework primitives (ShaderMask, LinearGradient, AnimatedBuilder).
/// Adheres to Ponytail minimalism: 0 third-party packages, minimal code, maximum performance.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFEBE6DF),
    this.highlightColor = const Color(0xFFFAF7F2),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width;
            final progress = _controller.value;
            // Slide gradient smoothly from left (-width) to right (+2*width)
            final dx = (progress * 3.0 - 1.0) * width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: dx / width),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Atomic rectangular skeleton element
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFEBE6DF),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Atomic text line skeleton element
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
    );
  }
}

/// Atomic circular skeleton element (for avatars, badges, icons)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEBE6DF),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ============================================================================
// COMPOSITE SCREEN SKELETONS
// ============================================================================

/// Full-page skeleton mirror for HomeScreen
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Hub Header / Location Switcher Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(width: 80, height: 12),
                  SizedBox(height: 6),
                  SkeletonText(width: 140, height: 20),
                ],
              ),
              SkeletonBox(
                width: 100,
                height: 36,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Hero Banner Skeleton
          const SkeletonBox(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(height: 16),

          // 3. Live Darshan Status Card Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 160, height: 16),
                    SkeletonBox(
                      width: 70,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    SkeletonCircle(size: 48),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 120, height: 22),
                        SizedBox(height: 6),
                        SkeletonText(width: 180, height: 12),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14),
                SkeletonBox(
                  width: double.infinity,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Daily Gita Shloka Card Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 130, height: 14),
                SizedBox(height: 10),
                SkeletonText(width: double.infinity, height: 14),
                SizedBox(height: 6),
                SkeletonText(width: 240, height: 14),
                SizedBox(height: 12),
                SkeletonText(width: 180, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Section Title Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText(width: 140, height: 18),
              SkeletonText(width: 60, height: 14),
            ],
          ),
          const SizedBox(height: 12),

          // 6. Places Horizontal Carousel Skeleton
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, __) => Container(
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: 180,
                      height: 110,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonText(width: 120, height: 14),
                          SizedBox(height: 6),
                          SkeletonText(width: 80, height: 12),
                          SizedBox(height: 10),
                          SkeletonText(width: 90, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Full-page skeleton mirror for ExploreScreen
class ExploreScreenSkeleton extends StatelessWidget {
  const ExploreScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Search Bar Skeleton
          const SkeletonBox(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          const SizedBox(height: 14),

          // Category Chips Bar Skeleton
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => SkeletonBox(
                width: 70.0 + (i % 3) * 20,
                height: 36,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Place Cards Vertical List
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Row(
                  children: [
                    SkeletonBox(
                      width: 110,
                      height: 110,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: 160, height: 16),
                            SizedBox(height: 8),
                            SkeletonText(width: 110, height: 12),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonText(width: 70, height: 12),
                                SkeletonBox(
                                  width: 60,
                                  height: 22,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-page skeleton mirror for DarshanScreen
class DarshanScreenSkeleton extends StatelessWidget {
  const DarshanScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Live Wait Time Card Skeleton
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 170, height: 16),
                    SkeletonBox(
                      width: 80,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    SkeletonCircle(size: 52),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 100, height: 26),
                        SizedBox(height: 6),
                        SkeletonText(width: 140, height: 12),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonBox(
                  width: double.infinity,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Queue Details / Compartment Grid Skeleton
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 70, height: 12),
                      SizedBox(height: 8),
                      SkeletonText(width: 110, height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 70, height: 12),
                      SizedBox(height: 8),
                      SkeletonText(width: 110, height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Darshan Types / Information Card Skeleton
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonText(width: 150, height: 16),
                const SizedBox(height: 14),
                ...List.generate(
                  3,
                  (i) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonText(width: 130, height: 14),
                        SkeletonText(width: 60, height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Practical Pilgrim Tips Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 140, height: 14),
                SizedBox(height: 10),
                SkeletonText(width: double.infinity, height: 12),
                SizedBox(height: 6),
                SkeletonText(width: 260, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-page skeleton mirror for EssentialsScreen
class EssentialsScreenSkeleton extends StatelessWidget {
  const EssentialsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Emergency Helpline Banner Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Row(
              children: [
                SkeletonCircle(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 140, height: 14),
                      SizedBox(height: 6),
                      SkeletonText(width: 180, height: 12),
                    ],
                  ),
                ),
                SkeletonBox(
                  width: 70,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Category Chips Bar Skeleton
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => SkeletonBox(
                width: 65.0 + (i % 3) * 15,
                height: 36,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Facilities List Skeleton
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonCircle(size: 38),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonText(width: 150, height: 16),
                              SizedBox(height: 6),
                              SkeletonText(width: 110, height: 12),
                            ],
                          ),
                        ),
                        SkeletonBox(
                          width: 50,
                          height: 22,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SkeletonText(width: double.infinity, height: 12),
                    SizedBox(height: 6),
                    SkeletonText(width: 220, height: 12),
                    SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonText(width: 120, height: 12),
                        SkeletonBox(
                          width: 80,
                          height: 32,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-page skeleton mirror for NotificationsScreen
class NotificationsScreenSkeleton extends StatelessWidget {
  const NotificationsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Filter Tabs Skeleton
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => SkeletonBox(
                width: 75.0 + (i % 2) * 20,
                height: 36,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Alert Cards List Skeleton
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(
                          width: 70,
                          height: 22,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        SkeletonText(width: 60, height: 11),
                      ],
                    ),
                    SizedBox(height: 10),
                    SkeletonText(width: 200, height: 15),
                    SizedBox(height: 8),
                    SkeletonText(width: double.infinity, height: 12),
                    SizedBox(height: 4),
                    SkeletonText(width: 240, height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-page skeleton mirror for PlaceDetailScreen
class PlaceDetailSkeleton extends StatelessWidget {
  const PlaceDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // Hero Image Header Skeleton
          const SkeletonBox(
            width: double.infinity,
            height: 260,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Tags
                const SkeletonText(width: 220, height: 24),
                const SizedBox(height: 8),
                const SkeletonText(width: 140, height: 14),
                const SizedBox(height: 16),

                // Quick Action Bar Skeleton
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Overview Text Skeleton
                const SkeletonText(width: 120, height: 18),
                const SizedBox(height: 12),
                const SkeletonText(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const SkeletonText(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const SkeletonText(width: 280, height: 14),
                const SizedBox(height: 24),

                // Highlights / Information Grid Skeleton
                const SkeletonText(width: 150, height: 18),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-page skeleton mirror for FacilityDetailScreen
class FacilityDetailSkeleton extends StatelessWidget {
  const FacilityDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: [
          // Header Card Skeleton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonCircle(size: 48),
                    SkeletonBox(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonText(width: 200, height: 22),
                SizedBox(height: 8),
                SkeletonText(width: 130, height: 14),
                SizedBox(height: 16),
                SkeletonText(width: double.infinity, height: 14),
                SizedBox(height: 8),
                SkeletonText(width: 250, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Location & Timing Card Skeleton
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 140, height: 16),
                SizedBox(height: 12),
                SkeletonText(width: double.infinity, height: 12),
                SizedBox(height: 14),
                SkeletonBox(
                  width: double.infinity,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
