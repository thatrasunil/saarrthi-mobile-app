import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
import '../../data/local_repository.dart';
import '../../main.dart';
import '../widgets/saarthi_logo.dart';

class OnboardingScreen extends StatefulWidget {
  final LocalRepository localRepo;

  const OnboardingScreen({super.key, required this.localRepo});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AppState _appState = AppState.instance;
  final TextEditingController _nameController = TextEditingController();
  int _currentStep = 1; // 1: Language, 2: Welcome, 3: Name, 4: Location

  @override
  void initState() {
    super.initState();
    _nameController.text = _appState.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else if (_currentStep == 3) {
      if (_nameController.text.trim().isNotEmpty) {
        _appState.setUserName(_nameController.text.trim());
      }
      setState(() => _currentStep = 4);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _finishOnboarding() async {
    await _appState.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainNavigationScaffold(localRepo: widget.localRepo),
      ),
    );
  }

  Future<void> _handleAllowLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (_) {}
    _finishOnboarding();
  }

  void _showHubPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final hubs = [
          {'name': 'Tirupati', 'sub': 'Railway Station & Bus Stand (Plains)'},
          {'name': 'Tirumala', 'sub': 'Srivari Temple & Hill Precinct'},
          {'name': 'Alipiri', 'sub': 'Steps Footpath Entrance'},
          {'name': 'Srivari Mettu', 'sub': 'Chandragiri Footpath Entrance'},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Starting Hub',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...hubs.map((hub) {
                  final isSelected = _appState.selectedLocation == hub['name'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.emeraldLight : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: isSelected ? AppTheme.emerald : AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      hub['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppTheme.emerald : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(hub['sub']!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.emerald) : null,
                    onTap: () {
                      _appState.setLocation(hub['name']!);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 4) {
      return _buildLocationScreen();
    }

    final isTelugu = _appState.isTelugu;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 1)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppTheme.textPrimary),
                      ),
                      onPressed: _prevStep,
                    )
                  else
                    const SizedBox(width: 44),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      isTelugu ? 'దాటవేయి' : 'Skip',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F5132),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Linear Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _currentStep / 3.0,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F5132)),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildCurrentStepView(),
                ),
              ),
            ),

            // Bottom Continue Button & Page Dots
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5132),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 3
                                ? (isTelugu ? 'ప్రారంభిద్దాం!' : "Let's Go!")
                                : (isTelugu ? 'కొనసాగండి' : 'Continue'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentStep == 3 ? Icons.auto_awesome_rounded : Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = (index + 1) == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? const Color(0xFF0F5132) : const Color(0xFFCBD5E1),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildLanguageStep();
      case 2:
        return _buildWelcomeStep();
      case 3:
        return _buildNameStep();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Choose Your Language
  Widget _buildLanguageStep() {
    final isTelugu = _appState.isTelugu;

    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Center Pin Logo Icon
        const SaarthiLogo(
          size: 72,
          showShadow: true,
          borderRadius: 16,
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.language_rounded, color: Color(0xFF0F5132), size: 22),
            SizedBox(width: 8),
            Text(
              'Choose Your Language',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'మీ భాషను ఎంచుకోండి',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 28),

        // Option 1: English
        _buildLanguageOptionCard(
          flag: 'IN',
          title: 'English',
          subtext: 'Continue in English →',
          isSelected: !isTelugu,
          onTap: () => setState(() => _appState.setLanguage('en')),
        ),
        const SizedBox(height: 12),

        // Option 2: Telugu
        _buildLanguageOptionCard(
          flag: 'IN',
          title: 'తెలుగు',
          subtext: 'తెలుగులో కొనసాగండి',
          isSelected: isTelugu,
          onTap: () => setState(() => _appState.setLanguage('te')),
        ),
      ],
    );
  }

  Widget _buildLanguageOptionCard({
    required String flag,
    required String title,
    required String subtext,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F5132) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                flag,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF0F5132) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF0F5132) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F5132) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Welcome to Saarthi
  Widget _buildWelcomeStep() {
    final isTelugu = _appState.isTelugu;

    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Watercolor Temple Image Banner
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              'assets/onboarding-tirumala.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.temple_hindu_rounded, size: 64, color: AppTheme.saffron),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Saarthi Badge Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SaarthiLogo(size: 16),
              SizedBox(width: 6),
              Text(
                'Saarthi',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F5132),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Text(
          isTelugu ? 'సారథికి స్వాగతం' : 'Welcome to Saarthi',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          isTelugu
              ? 'తిరుపతి యాత్రను సులభంగా, ఆధ్యాత్మికంగా అనుభవించేందుకు మీ విశ్వసనీయ సహచరి.'
              : 'Your trusted companion for a smooth & meaningful journey in Tirupati.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Step 3: What should we call you?
  Widget _buildNameStep() {
    final isTelugu = _appState.isTelugu;

    return Column(
      key: const ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar Badge
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFDE68A), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.person_outline_rounded, color: Color(0xFFC89B3C), size: 36),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          isTelugu ? 'మిమ్మల్ని ఏమని పిలవాలి?' : 'What should we call you?',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isTelugu
              ? 'మీ తిరుమల యాత్ర వివరాలను మీ కోసం ప్రత్యేకంగా తీర్చిదిద్దుతాం.'
              : "We'll personalize your dashboard & recommendations.",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),

        // Name input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF0F5132), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: isTelugu ? 'మీ పేరు నమోదు చేయండి' : 'Enter your name',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isTelugu ? 'ఉదా: మధురిమ, సునీల్, శ్రీజ' : 'e.g. Madhurima, Sunil, Sreeja',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),

        // Privacy Guarantee Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, color: Color(0xFF0F5132), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTelugu
                      ? 'మీ గోప్యత మా బాధ్యత. మీ వివరాలు సురక్షితంగా కేవలం మీ ఫోన్‌లోనే ఉంటాయి.'
                      : 'Your privacy is our priority. We never share your details; they are stored strictly on this device.',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F5132), fontWeight: FontWeight.w600, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 4: Enable Location Modal/Sheet
  Widget _buildLocationScreen() {
    final isTelugu = _appState.isTelugu;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: Stack(
        children: [
          // Background stylized radar map
          Positioned.fill(
            child: CustomPaint(
              painter: _MapBackgroundPainter(),
            ),
          ),

          // Center Animated Pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SaarthiLogo(
                  size: 84,
                  showShadow: true,
                  borderRadius: 18,
                ),
                SizedBox(height: 120),
              ],
            ),
          ),

          // Bottom Sheet Card (Image 4)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isTelugu ? 'లొకేషన్ ఆన్ చేయండి' : 'Enable Location',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTelugu
                          ? 'సమీప క్షేత్రాలు, ఖచ్చితమైన దూరం మరియు సరైన మార్గాల కోసం లొకేషన్ అనుమతించండి.'
                          : 'Allow location to find nearby places, show accurate distance and the best routes.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Button: Allow Location (Orange fill)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _handleAllowLocation,
                        icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                        label: Text(
                          isTelugu ? 'లొకేషన్ అనుమతించండి' : 'Allow Location',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9801D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Secondary Button: Select Starting City / Hub
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _showHubPicker,
                        icon: const Icon(Icons.location_city_rounded, color: Color(0xFFB45309), size: 18),
                        label: Text(
                          isTelugu ? 'ప్రారంభ నగరం / కేంద్రం ఎంచుకోండి' : 'Select Starting City / Hub',
                          style: const TextStyle(color: Color(0xFF92400E), fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFBEB),
                          side: const BorderSide(color: Color(0xFFFDE68A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Not Now Button
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        isTelugu ? 'ఇప్పుడు కాదు' : 'Not Now',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);

    // Radar Rings
    final ringPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, 70, ringPaint);
    canvas.drawCircle(center, 120, ringPaint);
    canvas.drawCircle(center, 180, ringPaint);

    // Cross Lines / Roads
    final roadPaint = Paint()
      ..color = const Color(0xFFF1ECE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.3, size.width, size.height * 0.22);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.3, size.height * 0.6);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
