import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
import '../../data/local_repository.dart';
import '../../data/supabase_repository.dart';
import '../../data/admin_repository.dart';
import '../../main.dart';
import '../widgets/saarthi_logo.dart';
import 'onboarding_screen.dart';

/// High-Fidelity Pilgrim Splash Screen
/// Plays the sacred logo animation, pre-loads offline repositories in parallel,
/// and smoothly transitions into the main app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isInitFinished = false;
  bool _hasNavigated = false;
  final LocalRepository _localRepo = LocalRepository();

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // 1. Initialize video playback
    try {
      _controller = VideoPlayerController.asset('assets/banner/splash-screen-logo.mp4');
      await _controller.initialize();
      _controller.setLooping(false);
      _controller.setVolume(0.0);
      await _controller.play();

      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }

      // Listen for video completion
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration && !_hasNavigated) {
          _tryNavigate();
        }
      });
    } catch (_) {
      // Fallback if video player encounters codec issue
      if (mounted) {
        setState(() => _isVideoInitialized = false);
      }
    }

    // 2. Pre-load offline databases, Supabase client, AppState, and Admin connection
    await Future.wait([
      _localRepo.initialize(),
      SupabaseRepository.init(),
      AppState.instance.load(),
      AdminRepository.instance.init(),
    ]);

    _isInitFinished = true;

    // Safety fallback timer: auto-advance after 3.5s maximum even if video is still playing
    Timer(const Duration(milliseconds: 3500), () {
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    if (_hasNavigated || !_isInitFinished || !mounted) return;
    _hasNavigated = true;

    final targetScreen = AppState.instance.hasSeenOnboarding
        ? MainNavigationScaffold(localRepo: _localRepo)
        : OnboardingScreen(localRepo: _localRepo);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Sacred Divine Cream background
      body: GestureDetector(
        onTap: _tryNavigate, // Tap to skip for frequent pilgrims
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Splash Video or Poster Fallback
            Center(
              child: _isVideoInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Image.asset(
                      'assets/banner/splash_poster.webp',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SaarthiLogo(
                            size: 110,
                            showShadow: true,
                            borderRadius: 24,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'SAARTHI',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: AppTheme.emerald,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tirupati & Tirumala Divine Companion',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // 2. Skip hint at bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap anywhere to enter',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
