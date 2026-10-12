import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saarthi_mobile/core/app_state.dart';
import 'package:saarthi_mobile/data/local_repository.dart';
import 'package:saarthi_mobile/models/place.dart';
import 'package:saarthi_mobile/models/alert_item.dart';
import 'package:saarthi_mobile/ui/screens/onboarding_screen.dart';
import 'package:saarthi_mobile/ui/screens/essentials_screen.dart';
import 'package:saarthi_mobile/ui/screens/facility_detail_screen.dart';
import 'package:saarthi_mobile/ui/screens/explore_screen.dart';
import 'package:saarthi_mobile/ui/screens/notifications_screen.dart';
import 'package:saarthi_mobile/ui/widgets/floating_bottom_nav.dart';
import 'package:saarthi_mobile/ui/widgets/japa_mala_modal.dart';
import 'package:saarthi_mobile/ui/widgets/location_picker_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppState localization and toggle test', () async {
    final appState = AppState.instance;
    expect(appState.language, 'en');
    expect(appState.isTelugu, false);

    appState.toggleLanguage();
    expect(appState.language, 'te');
    expect(appState.isTelugu, true);

    // Switch back to English
    appState.setLanguage('en');
    expect(appState.language, 'en');

    // Test Japa counter increment
    expect(appState.japaCount, 1);
    await appState.incrementJapa();
    expect(appState.japaCount, 2);
  });

  testWidgets('OnboardingScreen Step 1 renders correctly', (tester) async {
    final repo = LocalRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(localRepo: repo),
      ),
    );

    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('తెలుగు'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('FloatingBottomNav renders all 3 tabs with Essentials FAB', (tester) async {
    int selectedTab = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingBottomNav(
            currentIndex: 0,
            onTap: (index) => selectedTab = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Essentials'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.byIcon(Icons.layers_rounded), findsOneWidget);
  });

  testWidgets('JapaMalaModal renders bead track and chanting view', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JapaMalaModal(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SRIVARI 108 SACRED JAPA MALA'), findsOneWidget);
    expect(find.text('Sacred Devotional Chanting Sadhana'), findsOneWidget);
    expect(find.text('DIVINE BLESSING & GRACE:'), findsOneWidget);
    expect(find.text('Tap, Swipe, or Press Spacebar to Chant'), findsOneWidget);
  });

  testWidgets('LocationPickerModal renders search, tabs, and locations', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LocationPickerModal(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Starting Location'), findsOneWidget);
    expect(find.text('Use Current Live GPS Location'), findsOneWidget);
    expect(find.text('All Places'), findsOneWidget);
    expect(find.text('Tirupati (City & Foothills)'), findsOneWidget);
    expect(find.text('Tirumala (Hill Top & Temple)'), findsOneWidget);
  });

  test('AppState dynamic distance and saved places test', () async {
    final appState = AppState.instance;

    // Default to Tirupati
    await appState.setLocation('Tirupati');
    expect(appState.selectedLocation, 'Tirupati');
    expect(appState.currentLat, 13.6288);

    // Distance to Tirumala Srivari Temple from Tirupati (Plains to Hill)
    // Srivari Temple coordinates: lat 13.6833, lng 79.3473
    final templeCoords = PlaceCoordinates(lat: 13.6833, lng: 79.3473);
    final distFromTirupati = appState.getDistanceTo(templeCoords, true);
    expect(distFromTirupati, greaterThan(18.0)); // Includes 18.5 km ghat road

    // Change starting location to Tirumala (Hill to Hill)
    await appState.setLocation('Tirumala');
    expect(appState.selectedLocation, 'Tirumala');
    final distFromTirumala = appState.getDistanceTo(templeCoords, true);
    expect(distFromTirumala, lessThan(2.0)); // Local on plateau!

    // Test saved places
    expect(appState.isPlaceSaved('tirumala-main-temple'), false);
    await appState.toggleSavePlace('tirumala-main-temple');
    expect(appState.isPlaceSaved('tirumala-main-temple'), true);
    await appState.toggleSavePlace('tirumala-main-temple');
    expect(appState.isPlaceSaved('tirumala-main-temple'), false);
  });

  testWidgets('EssentialsScreen renders search, notice, facility cards, and emergency banner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EssentialsScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Pilgrim Essentials'), findsOneWidget);
    expect(find.text('Everything you need before your visit'), findsOneWidget);
    expect(find.text('HIGH CROWD WARNING: Ghat road traffic slow. Exercise caution.'), findsOneWidget);
    expect(find.text('What You Need Right Now'), findsOneWidget);
    expect(find.text('Free Lockers & Mobile Deposit'), findsOneWidget);

    // Scroll down to reveal Support Services, FAQs, and Emergency Help
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pump();

    expect(find.text('Call 108'), findsOneWidget);
    expect(find.text('Official Shopping'), findsOneWidget);
  });

  testWidgets('FacilityDetailScreen renders explainable rationale, highlights and guidance', (tester) async {
    final facilityData = {
      'id': 'secure-belongings',
      'titleEn': 'Secure My Belongings',
      'titleTe': 'ఉచిత లాకర్లు & మొబైల్ డిపాజిట్',
      'subEn': 'Free luggage lockers, mobile phone deposit, and electronics storage.',
      'subTe': 'క్యూలోకి వెళ్లేముందు ఫోన్లు, స్మార్ట్ వాచీలు & లగేజీని భద్రపరచండి',
      'statusEn': 'Open Now',
      'statusTe': 'ఓపెన్',
      'icon': Icons.lock_outline_rounded,
      'locationEn': '6 Nearby Counters (Madhava Nilayam, PAC-1 to PAC-5, VQC Entrance)',
      'locationTe': 'మాధవ నిలయం, పీఏసీ 1-5, వీక్యూసీ ప్రవేశం వద్ద 6 కౌంటర్లు',
      'descEn': 'Store your heavy bags, mobile phones, cameras safely before entering VQC.',
      'descTe': 'క్యూ కాంప్లెక్స్ లోకి వెళ్లేముందు లగేజీ, మొబైల్ ఫోన్లు భద్రపరచండి.',
      'whyItMattersEn': 'Mobiles and bags are strictly prohibited inside the main temple.',
      'whyItMattersTe': 'ఆలయం లోపలికి మొబైల్స్ ఖచ్చితంగా నిషిద్ధం.',
      'lat': 13.6823,
      'lng': 79.3514,
      'isTirumala': true,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: FacilityDetailScreen(facility: facilityData),
      ),
    );
    await tester.pump();

    expect(find.text('Secure My Belongings'), findsAtLeastNWidgets(1));
    expect(find.text('WHY THIS IS REQUIRED BEFORE QUEUE ENTRY'), findsOneWidget);
    expect(find.text('SAARTHI GUIDANCE'), findsOneWidget);
    expect(find.text('Get Driving Directions'), findsOneWidget);
  });

  testWidgets('ExploreScreen renders filter chips and search bar', (tester) async {
    final repo = LocalRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: ExploreScreen(localRepo: repo),
      ),
    );
    await tester.pump();

    expect(find.text('Explore Sacred Sites'), findsOneWidget);
    expect(find.textContaining('All'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Nearby'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Saved'), findsAtLeastNWidgets(1));
  });

  test('AppState alert methods test', () {
    final appState = AppState.instance;
    expect(appState.alerts.isNotEmpty, true);

    final initialCount = appState.activeAlertsCount;
    expect(initialCount, greaterThan(0));

    // Mark all as read
    appState.markAllAlertsAsRead();
    expect(appState.activeAlertsCount, 0);

    // Add a simulated alert
    final testAlert = AlertItem(
      id: 'unit-test-alert',
      titleEn: 'Test Alert',
      titleTe: 'పరీక్ష అలర్ట్',
      descEn: 'Test Description',
      descTe: 'పరీక్ష వివరణ',
      category: 'High Priority',
      severity: 'High',
      cta: 'Open Queue',
      timeAgo: 'Just now',
      timeAgoTe: 'ఇప్పుడే',
      isRead: false,
    );
    appState.addSimulatedAlert(testAlert);
    expect(appState.activeAlertsCount, 1);

    // Mark single alert as read
    appState.markAlertAsRead('unit-test-alert');
    expect(appState.activeAlertsCount, 0);

    // Dismiss alert
    appState.dismissAlert('unit-test-alert');
    expect(appState.alerts.any((a) => a.id == 'unit-test-alert'), false);
  });

  testWidgets('NotificationsScreen renders categories, notices and handles simulation', (tester) async {
    final appState = AppState.instance;
    // Reset to default
    appState.setLanguage('en');

    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
    await tester.pump();

    // Verify Title & Subtitle
    expect(find.text('Alerts & Notices'), findsOneWidget);
    expect(find.text('Simulate'), findsOneWidget);

    // Tap Simulate Live Alert
    await tester.tap(find.text('Simulate'));
    await tester.pump();

    // Verify simulated notice appears
    expect(find.text('Live Advisory: Additional Laddu Counters Opened'), findsOneWidget);

    // Tap Mark all read if button is present
    if (find.text('Mark all read').evaluate().isNotEmpty) {
      await tester.tap(find.text('Mark all read'));
      await tester.pump();
      expect(appState.activeAlertsCount, 0);
    }
  });
}
