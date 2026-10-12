import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme.dart';

/// High-Fidelity Animated Hero Banner with WebP Poster Fallback
/// Replicates the web app's ambient looping temple video banner with battery-conscious lifecycle.
class HeroBannerVideo extends StatefulWidget {
  final String videoAsset;
  final String posterAsset;

  const HeroBannerVideo({
    super.key,
    this.videoAsset = 'assets/banner/homescreen-banner.mp4',
    this.posterAsset = 'assets/banner/banner_poster.webp',
  });

  @override
  State<HeroBannerVideo> createState() => _HeroBannerVideoState();
}

class _HeroBannerVideoState extends State<HeroBannerVideo> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset(widget.videoAsset);
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0); // Muted for ambient autoplay
      await controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('HeroBannerVideo error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_isInitialized) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _controller?.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Instant WebP Poster (zero layout shift while video warms up)
              Image.asset(
                widget.posterAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.canvasBg,
                  child: const Center(
                    child: Icon(Icons.temple_hindu_rounded, size: 48, color: AppTheme.gold),
                  ),
                ),
              ),

              // 2. Cross-fading Loop Video
              if (_isInitialized && !_hasError && _controller != null)
                AnimatedOpacity(
                  opacity: _isInitialized ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: (_controller!.value.size.width > 0)
                            ? _controller!.value.size.width
                            : 16,
                        height: (_controller!.value.size.height > 0)
                            ? _controller!.value.size.height
                            : 9,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                ),

              // 3. Subtle bottom gradient overlay for divine contrast
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Ambient Live Badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'TIRUMALA HILLS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
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
