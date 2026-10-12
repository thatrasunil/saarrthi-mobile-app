import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'skeleton_shimmer.dart';

/// Offline-first intelligent image widget.
/// Resolves canonical website asset URLs to bundled local assets for 0ms instant loading,
/// and provides smooth loading and error fallbacks for network URLs.
class SaarthiImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const SaarthiImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIcon = Icons.temple_hindu_rounded,
    this.fallbackColor,
  });

  static String? getLocalAssetPath(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('assets/')) return imageUrl;
    if (imageUrl.startsWith('/assets/')) return imageUrl.substring(1);
    
    // Check if it's a domain URL pointing to /assets/
    const domainPrefix = 'https://www.saarthiguide.in/assets/';
    if (imageUrl.startsWith(domainPrefix)) {
      return 'assets/${imageUrl.substring(domainPrefix.length)}';
    }
    const domainHttpPrefix = 'http://www.saarthiguide.in/assets/';
    if (imageUrl.startsWith(domainHttpPrefix)) {
      return 'assets/${imageUrl.substring(domainHttpPrefix.length)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localPath = getLocalAssetPath(url);

    if (localPath != null) {
      return Image.asset(
        localPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    if (url == null || url!.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Shimmer(
          child: SkeletonBox(
            width: width,
            height: height,
            borderRadius: BorderRadius.zero,
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor ?? const Color(0xFFFEF3C7),
      child: Center(
        child: Icon(fallbackIcon, color: AppTheme.saffron, size: 28),
      ),
    );
  }
}
