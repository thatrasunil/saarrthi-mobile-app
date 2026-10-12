import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/app_state.dart';
import 'data/local_repository.dart';
import 'data/supabase_repository.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/explore_screen.dart';
import 'ui/screens/essentials_screen.dart';
import 'ui/widgets/floating_bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar matching pilgrim canvas
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.canvasBg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SaarthiApp());
}

class SaarthiApp extends StatelessWidget {
  const SaarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final LocalRepository localRepo;

  const MainNavigationScaffold({super.key, required this.localRepo});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  final _supabaseRepo = SupabaseRepository();

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // 3 Tabs matching web app: 0: Home, 1: Essentials, 2: Explore
    final screens = [
      HomeScreen(
        localRepo: widget.localRepo,
        supabaseRepo: _supabaseRepo,
        onTabChange: _onTabChanged,
      ),
      const EssentialsScreen(),
      ExploreScreen(localRepo: widget.localRepo),
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
