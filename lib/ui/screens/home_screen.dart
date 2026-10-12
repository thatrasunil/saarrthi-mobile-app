import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../core/app_state.dart';
import '../../data/local_repository.dart';
import '../../data/supabase_repository.dart';
import '../../models/place.dart';
import '../../models/gita_shloka.dart';
import '../../data/admin_repository.dart';
import 'place_detail_screen.dart';
import 'darshan_screen.dart';
import 'notifications_screen.dart';
import '../widgets/japa_mala_modal.dart';
import '../widgets/location_picker_modal.dart';
import '../widgets/saarthi_image.dart';
import '../widgets/hero_banner_video.dart';
import '../widgets/skeleton_shimmer.dart';
import '../widgets/saarthi_logo.dart';

class HomeScreen extends StatefulWidget {
  final LocalRepository localRepo;
  final SupabaseRepository supabaseRepo;
  final Function(int) onTabChange;

  const HomeScreen({
    super.key,
    required this.localRepo,
    required this.supabaseRepo,
    required this.onTabChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GitaShloka _dailyShloka;
  bool _isLoading = true;
  bool _isLoreExpanded = false;
  final AppState _appState = AppState.instance;

  @override
  void initState() {
    super.initState();
    _dailyShloka = widget.localRepo.getDailyShloka();
    _loadLiveStatus();
  }

  Future<void> _loadLiveStatus() async {
    try {
      final adminData = await AdminRepository.instance.fetchLiveStatus();
      if (adminData != null) {
        _appState.updateFromAdminLiveStatus(adminData);
      }
    } catch (_) {}

    await widget.supabaseRepo.getLiveDarshanStatus();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showHubPicker() {
    LocationPickerModal.show(context);
  }

  void _openDarshanScreen() {
    Navigator.push(
      context,
      AppTransitions.smoothSlideRoute(
        DarshanScreen(supabaseRepo: widget.supabaseRepo),
      ),
    );
  }

  void _showShareSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _appState.isTelugu
              ? 'దర్శనం స్టేటస్ వివరాలు క్లిప్‌బోర్డ్‌కు కాపీ చేయబడ్డాయి'
              : 'Darshan live status summary copied to share with family!',
        ),
        backgroundColor: AppTheme.emerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = _appState.isTelugu;
    final allPlaces = widget.localRepo.places;
    final sortedPlaces = List<Place>.from(allPlaces);
    sortedPlaces.sort((a, b) {
      final distA = _appState.getDistanceTo(a.coordinates, a.isTirumala);
      final distB = _appState.getDistanceTo(b.coordinates, b.isTirumala);
      return distA.compareTo(distB);
    });
    final nearbyPlaces = sortedPlaces.take(6).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const HomeScreenSkeleton()
            : RefreshIndicator(
                onRefresh: _loadLiveStatus,
                color: AppTheme.emerald,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
            children: [
              // 1. SACRED MODERN HEADER (Image 5)
              _buildSacredHeader(isTelugu),
              const SizedBox(height: 10),

              // 2. TIRUMALA LIVE STATUS PULSE CARD (Psychology: Answer wait anxiety first)
              _buildLiveStatusPulseCard(isTelugu),
              const SizedBox(height: 12),

              // 3. 4 FAST-INTENT PILGRIM SHORTCUTS (Hick's Law)
              _buildQuickIntentsRow(isTelugu),
              const SizedBox(height: 14),

              // 4. DEVOTIONAL INVOCATION & 108 JAPA MALA BAR
              _buildDevotionalBar(isTelugu),
              const SizedBox(height: 12),

              // 5. HERO BANNER: Closer to what matters
              _buildHeroBanner(),
              const SizedBox(height: 14),

              // 5b. EXPLAINABLE SAARTHI GUIDANCE CARD (Decision Psychology)
              _buildSaarthiGuidanceCard(isTelugu),
              const SizedBox(height: 14),

              // 6. SSD TOKEN STATUS & COLLECTION CENTRES (Image 1 & 2)
              _buildSsdTokenStatusCard(isTelugu),
              const SizedBox(height: 14),

              // 7. YATRA ESSENTIALS CHECKLIST (Image 2)
              _buildYatraEssentialsCard(isTelugu),
              const SizedBox(height: 16),

              // 7. WHAT YOU NEED RIGHT NOW (Horizontal Photo Carousel) (Image 2 & 3)
              _buildWhatYouNeedRightNow(isTelugu),
              const SizedBox(height: 18),

              // 8. EXPLORE AROUND YOU (Photo-First Horizontal Scroll) (Image 3)
              _buildExploreSection(isTelugu, nearbyPlaces),
              const SizedBox(height: 18),

              // 9. SACRED LORE, CHANTS & TRADITIONS (Collapsible) (Image 3)
              _buildSacredLoreCard(isTelugu),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Sacred Header (Matching Image 5)
  Widget _buildSacredHeader(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Saarthi Logo & Brand Serif Typography
          Row(
            children: const [
              SaarthiLogo(size: 34),
              SizedBox(width: 8),
              Text(
                'Saarthi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F5132),
                  letterSpacing: -0.5,
                  fontFamily: 'Georgia',
                ),
              ),
            ],
          ),

          // Right: Location Pill, Language Switcher & Notification Bell
          Row(
            children: [
              // Location Pill
              InkWell(
                onTap: _showHubPicker,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF0F5132)),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text(
                          _appState.selectedLocation,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F5132),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF0F5132)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Language Toggle Pill
              InkWell(
                onTap: () => _appState.toggleLanguage(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.translate_rounded, size: 13, color: Color(0xFF0F5132)),
                      const SizedBox(width: 4),
                      Text(
                        isTelugu ? 'EN' : 'తెలుగు',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F5132),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Notification Bell with dynamic badge from AppState
              InkWell(
                key: const Key('notification_bell_button'),
                borderRadius: BorderRadius.circular(17),
                onTap: () {
                  Navigator.push(
                    context,
                    AppTransitions.smoothSlideRoute(
                      NotificationsScreen(
                        localRepo: widget.localRepo,
                        supabaseRepo: widget.supabaseRepo,
                        onTabChange: widget.onTabChange,
                      ),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Icon(Icons.notifications_none_rounded, size: 19, color: Color(0xFF0F5132)),
                      ),
                    ),
                    if (_appState.activeAlertsCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                          child: Center(
                            child: Text(
                              '${_appState.activeAlertsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4 Fast-Intent Pilgrim Shortcuts (Psychology & Hick's Law: 4 core needs upfront)
  Widget _buildQuickIntentsRow(bool isTelugu) {
    return Row(
      children: [
        _buildIntentPill(
          icon: Icons.access_time_filled_rounded,
          label: isTelugu ? 'క్యూ సమయం' : 'Queue Time',
          color: AppTheme.emerald,
          bgColor: AppTheme.emeraldLight,
          onTap: _openDarshanScreen,
        ),
        const SizedBox(width: 8),
        _buildIntentPill(
          icon: Icons.content_cut_rounded,
          label: isTelugu ? 'తలనీలాలు' : 'Tonsure',
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          onTap: () {
            _appState.setEssentialsCategory('Kalyana Katta');
            widget.onTabChange(2);
          },
        ),
        const SizedBox(width: 8),
        _buildIntentPill(
          icon: Icons.lock_outline_rounded,
          label: isTelugu ? 'లాకర్లు' : 'Lockers',
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
          onTap: () {
            _appState.setEssentialsCategory('Lockers');
            widget.onTabChange(2);
          },
        ),
        const SizedBox(width: 8),
        _buildIntentPill(
          icon: Icons.checkroom_rounded,
          label: isTelugu ? 'నిబంధనలు' : 'Dress Code',
          color: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
          onTap: () {
            _appState.setEssentialsCategory('Rules');
            widget.onTabChange(2);
          },
        ),
      ],
    );
  }

  Widget _buildIntentPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Devotional Invocation Bar & Japa Mala Button (Image 5)
  Widget _buildDevotionalBar(bool isTelugu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Date & Live Weather Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: const [
              Text(
                'Wed, 23 Sept',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
              ),
              SizedBox(width: 4),
              Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
              SizedBox(width: 4),
              Icon(Icons.wb_sunny_rounded, size: 13, color: Color(0xFFD97706)),
              SizedBox(width: 4),
              Text(
                '27°C',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),

        // Right: 108 Japa Mala Button with Counter Badge
        InkWell(
          onTap: () => JapaMalaModal.show(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFDF7), Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD97706), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFFD97706)),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTelugu ? 'ఓం నమో వేంకటేశాయ' : 'Om Namo Venkatesaya',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
                    ),
                    Text(
                      isTelugu ? 'జప మాల - నొక్కండి' : 'Japa Mala - Tap to Chant',
                      style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_appState.japaCount}/108',
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFFEF3C7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Sacred Hero Video Banner (Image 5)
  Widget _buildHeroBanner() {
    return const HeroBannerVideo();
  }

  // 4. Tirumala Live Status Pulse Card with 3 Columns (Image 5)
  Widget _buildLiveStatusPulseCard(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Beacon dot, Title, and Refresh Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTelugu ? 'తిరుమల లైవ్ స్టేటస్' : 'Tirumala Live Status',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() => _isLoading = true);
                  _loadLiveStatus();
                },
                child: Row(
                  children: [
                    const Text(
                      '12h ago',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Side-by-Side Queue Cards (Sarva, ₹300, SSD)
          Row(
            children: [
              // Column 1: Sarva Darshan (Free Entry)
              Expanded(
                child: _buildQueueColumnCard(
                  icon: Icons.apartment_rounded,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFDCFCE7),
                  sublabel: isTelugu ? 'ఉచిత ప్రవేశం' : 'FREE ENTRY',
                  title: isTelugu ? 'సర్వదర్శనం' : 'Sarva Darshan',
                  wait: _appState.sarvaDarshanWait,
                  waitBg: const Color(0xFFDCFCE7),
                  waitColor: const Color(0xFF166534),
                  borderColor: const Color(0xFFBBF7D0),
                  onTap: _openDarshanScreen,
                ),
              ),
              const SizedBox(width: 8),

              // Column 2: ₹300 Special Entry Darshan
              Expanded(
                child: _buildQueueColumnCard(
                  icon: Icons.confirmation_number_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  sublabel: isTelugu ? 'ప్రత్యేక ప్రవేశం' : 'SPECIAL ENTRY',
                  title: isTelugu ? '₹300 దర్శనం' : '₹300 Darshan',
                  wait: _appState.specialEntryWait,
                  waitBg: const Color(0xFFFEF3C7),
                  waitColor: const Color(0xFF92400E),
                  borderColor: const Color(0xFFFDE68A),
                  onTap: _openDarshanScreen,
                ),
              ),
              const SizedBox(width: 8),

              // Column 3: SSD Tokens (Timed Slot)
              Expanded(
                child: _buildQueueColumnCard(
                  icon: Icons.confirmation_num_outlined,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFDCFCE7),
                  sublabel: isTelugu ? 'టైమ్డ్ స్లాట్' : 'TIMED SLOT',
                  title: isTelugu ? 'SSD టోకెన్లు' : 'SSD Tokens',
                  wait: _appState.ssdTokenStatus,
                  waitBg: const Color(0xFFDCFCE7),
                  waitColor: const Color(0xFF166534),
                  borderColor: const Color(0xFFBBF7D0),
                  onTap: _openDarshanScreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: const Color(0xFF0F172A).withValues(alpha: 0.08)),
          const SizedBox(height: 10),

          // Travel & Weather Pill + Share to Family button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0F172A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, size: 13, color: Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text('${_appState.temperatureCelsius}°C', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                  ],
                ),
              ),
              InkWell(
                onTap: _showShareSnack,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF16A34A), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.share_rounded, size: 12, color: Color(0xFF166534)),
                      const SizedBox(width: 4),
                      Text(
                        isTelugu ? 'కుటుంబానికి షేర్ చేయండి' : 'Share to Family',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sub-card: SAARTHI GUIDANCE (Matching Image 1)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF0F5132)),
                        SizedBox(width: 6),
                        Text(
                          'SAARTHI GUIDANCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F5132),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isTelugu ? '"ప్రశాంత భక్తితో స్వామిని చేరండి"' : '"In calm faith, seek Srivari"',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  _appState.liveNotice,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // 3 Highlights in a row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.local_fire_department_rounded, size: 12, color: Color(0xFFD97706)),
                                SizedBox(width: 3),
                                Text(
                                  'Sacred Shrine',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'ISKCON Lotus',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF78350F)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF2563EB)),
                                SizedBox(width: 3),
                                Text(
                                  'Best Route',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Local Shrines',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF16A34A)),
                                SizedBox(width: 3),
                                Text(
                                  'Optimal Time',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Early Morning',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF14532D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      isTelugu ? 'ప్రత్యక్ష క్యూ డేటా ఆధారంగా • ఇటీవల ధృవీకరించబడింది' : 'Based on live queue data • Verified recently',
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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

  Widget _buildQueueColumnCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String sublabel,
    required String title,
    required String wait,
    required Color waitBg,
    required Color waitColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 5),
            Text(
              sublabel,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: waitBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  wait,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: waitColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // 5. Explainable Saarthi Guidance Card (Mandated by rules)
  Widget _buildSaarthiGuidanceCard(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC89B3C).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 12, color: Color(0xFF92400E)),
                    const SizedBox(width: 4),
                    Text(
                      isTelugu ? 'సారథి సూచన' : 'SAARTHI RECOMMENDS',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            isTelugu
                ? 'ప్రశాంతమైన దర్శన సమయం అందుబాటులో ఉంది. మీ ప్రయాణం ఇప్పుడే ప్రారంభించండి.'
                : 'A serene darshan window is open. Start your journey now.',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Explainable Reasons Section
          Text(
            isTelugu ? 'ఎందుకు సిఫార్సు చేయబడింది:' : 'RECOMMENDED BECAUSE',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          _buildBulletPoint(isTelugu
              ? 'మధ్యాహ్న సమయాల్లో దర్శన క్యూ వేగంగా కదులుతుంది.'
              : "Queue wait times clear significantly during afternoon slot."),
          _buildBulletPoint(isTelugu
              ? 'ఘాట్ రోడ్డుపై ప్రస్తుత ట్రాఫిక్ సాధారణంగా ఉంది.'
              : 'Ghat road traffic and weather conditions are clear and safe.'),
          const SizedBox(height: 10),

          // Benefit Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF059669)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isTelugu ? 'ఇప్పుడే బయలుదేరితే సుమారు 3 గంటల సమయం ఆదా అవుతుంది' : 'Save approx. 3 hours of wait time by leaving now',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.3)),
          ),
        ],
      ),
    );
  }

  // 5. SSD Token Status & Collection Centres (Images 1 & 2)
  Widget _buildSsdTokenStatusCard(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.confirmation_num_outlined, color: Color(0xFF16A34A), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isTelugu ? 'SSD టోకెన్ స్టేటస్' : 'SSD Token Status',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      _appState.ssdTokenStatus,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Important Advisory Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'ముఖ్యమైన హెచ్చరిక' : 'IMPORTANT ADVISORY',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _appState.ssdNotice,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF991B1B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Collection Centres
          Text(
            isTelugu ? 'టోకెన్ జారీ కేంద్రాలు' : 'COLLECTION CENTRES',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildCentreCard(
                  icon: Icons.train_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFDBEAFE),
                  title: isTelugu ? 'విష్ణు నివాసం' : 'Vishnu Nivasam',
                  sub: isTelugu ? 'రైల్వే ఎదురుగా' : 'Opp. Railway',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCentreCard(
                  icon: Icons.directions_bus_rounded,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFDCFCE7),
                  title: isTelugu ? 'శ్రీనివాసం' : 'Srinivasam',
                  sub: isTelugu ? 'బస్టాండ్ ఎదురుగా' : 'Opp. Bus Stand',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCentreCard(
                  icon: Icons.temple_hindu_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  title: isTelugu ? 'భూదేవి కాంప్లెక్స్' : 'Bhudevi Complex',
                  sub: isTelugu ? 'అలిపిరి వద్ద' : 'Near Alipiri',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCentreCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // 6. Yatra Essentials Checklist (Image 2)
  Widget _buildYatraEssentialsCard(bool isTelugu) {
    final checkedCount = _appState.checkedEssentials.length;
    final items = [
      {'id': 'id_card', 'label': isTelugu ? 'ఆధార్ ID' : 'ID Card', 'icon': Icons.badge_outlined},
      {'id': 'dress_code', 'label': isTelugu ? 'వస్త్రధారణ' : 'Dress Code', 'icon': Icons.dry_cleaning_outlined},
      {'id': 'cash_coins', 'label': isTelugu ? 'నగదు & నాణాలు' : 'Cash & Coins', 'icon': Icons.payments_outlined},
      {'id': 'meds_water', 'label': isTelugu ? 'మందులు & నీరు' : 'Meds & Water', 'icon': Icons.medication_outlined},
      {'id': 'phone_power', 'label': isTelugu ? 'ఫోన్ & పవర్' : 'Phone & Power', 'icon': Icons.smartphone_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: Color(0xFFD97706), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isTelugu ? 'యాత్రా ముఖ్య అంశాలు' : 'Yatra Essentials',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$checkedCount/5',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 5 checklist tiles
          Row(
            children: items.map((item) {
              final id = item['id'] as String;
              final isChecked = _appState.checkedEssentials.contains(id);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _appState.toggleEssential(id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      decoration: BoxDecoration(
                        color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isChecked ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                          width: isChecked ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 18,
                            color: isChecked ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: isChecked ? const Color(0xFF16A34A) : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 7. What You Need Right Now (Horizontal Photo Carousel) (Images 2 & 3)
  Widget _buildWhatYouNeedRightNow(bool isTelugu) {
    final services = [
      {
        'category': 'Lockers',
        'title': isTelugu ? 'లాకర్లు & లగేజీ' : 'Lockers & Luggage',
        'sub': isTelugu ? 'ఫోన్లు & బ్యాగులు భద్రపరచండి' : 'Deposit phones & bags before queue',
        'status': isTelugu ? '6 కేంద్రాలు ఓపెన్' : '6 LOCATIONS OPEN',
        'isGreen': true,
        'icon': Icons.lock_outline_rounded,
        'image': 'https://res.cloudinary.com/kniegqlj/image/upload/v1786968161/IMG_6992_cq6gls.jpg',
      },
      {
        'category': 'Rooms & PAC',
        'title': isTelugu ? 'పిఏసి సముదాయం & విడిది' : 'PAC Halls & Rooms',
        'sub': isTelugu ? 'ఉచిత హాల్స్ & కౌంటర్లు' : 'Free rest halls & CRO registration',
        'status': isTelugu ? '24/7 అందుబాటులో' : 'OPEN ROUND-THE-CLOCK',
        'isGreen': true,
        'icon': Icons.night_shelter_rounded,
        'image': 'https://res.cloudinary.com/kniegqlj/image/upload/v1786968353/painted-sign-board-of-kalyanakatta-balaji-temple-tirupati-andhra-pradesh-F5M0J1_p7hkr5.jpg',
      },
      {
        'category': 'Kalyana Katta',
        'title': isTelugu ? 'కళ్యాణకట్ట (తలనీలాలు)' : 'Kalyana Katta (Tonsure)',
        'sub': isTelugu ? 'దర్శనానికి ముందు తలనీలాలు' : 'Sacred hair offering before darshan',
        'status': isTelugu ? '24/7 ఓపెన్' : 'OPEN 24/7',
        'isGreen': true,
        'icon': Icons.content_cut_rounded,
        'image': 'https://res.cloudinary.com/kniegqlj/image/upload/v1786968353/painted-sign-board-of-kalyanakatta-balaji-temple-tirupati-andhra-pradesh-F5M0J1_p7hkr5.jpg',
      },

    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTelugu ? 'ముఖ్యమైన యాత్రా సదుపాయాలు' : 'What You Need Right Now',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                Text(
                  isTelugu ? 'దర్శనానికి అవసరమైన కేంద్రాలు' : 'Essential pilgrim facilities',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                _appState.setEssentialsCategory('All');
                widget.onTabChange(1);
              },
              child: Text(
                isTelugu ? 'అన్నీ చూడండి →' : 'See all →',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Carousel
        SizedBox(
          height: 215,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, idx) {
              final item = services[idx];
              final isGreen = item['isGreen'] as bool;
              return InkWell(
                onTap: () {
                  _appState.setEssentialsCategory(item['category'] as String);
                  widget.onTabChange(1);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 185,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo with circular icon
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 95,
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              SaarthiImage(
                                url: item['image'] as String?,
                                fit: BoxFit.cover,
                                fallbackIcon: item['icon'] as IconData,
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(item['icon'] as IconData, size: 16, color: const Color(0xFF0F5132)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isGreen ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item['status'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: isGreen ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['sub'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isTelugu ? 'దారి చూడండి →' : 'Navigate →',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 7. Explore Around You (Photo-First Horizontal Carousel)
  Widget _buildExploreSection(bool isTelugu, List<Place> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isTelugu ? 'మీ చుట్టూ ఉన్న ప్రదేశాలు' : 'Explore Around You',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            InkWell(
              onTap: () => widget.onTabChange(2),
              child: Text(
                isTelugu ? 'అన్నీ చూడండి →' : 'See all →',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 195,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, idx) {
              final place = places[idx];
              final reason = place.whyVisit ?? 'Sacred regional landmark of deep spiritual importance.';
              final dynamicDist = _appState.getDistanceTo(place.coordinates, place.isTirumala);
              final travelTime = _appState.formatTravelTime(dynamicDist, place.isTirumala);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    AppTransitions.smoothSlideRoute(
                      PlaceDetailScreen(place: place, localRepo: widget.localRepo),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 185,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Banner with Category Pill
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 95,
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              SaarthiImage(
                                url: place.image,
                                fit: BoxFit.cover,
                                fallbackIcon: place.isTirumala ? Icons.temple_hindu_rounded : Icons.account_balance_rounded,
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    place.category,
                                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF64748B)),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${dynamicDist.toStringAsFixed(1)} km • $travelTime',
                                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Title & Explainable Reason
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              reason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.25),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isTelugu ? 'వివరాలు →' : 'Explore →',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 9. Sacred Lore, Chants & Traditions (Collapsible) (Image 3)
  Widget _buildSacredLoreCard(bool isTelugu) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isLoreExpanded = !_isLoreExpanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, color: Color(0xFFD97706), size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'పవిత్ర చరిత్ర & శ్లోకాలు' : 'Sacred Lore, Chants & Traditions',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTelugu ? 'రోజువారీ గీతా శ్లోకం, సుప్రభాతం & తిరుమల విశేషాలు' : 'Daily Shloka, Suprabhatam & Tirumala lore',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF78350F), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _isLoreExpanded ? (isTelugu ? 'దాచు' : 'Hide') : (isTelugu ? 'చూడండి' : 'View'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                    ),
                    Icon(
                      _isLoreExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: const Color(0xFF92400E),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isLoreExpanded) ...[
          const SizedBox(height: 10),
          _buildDailyGitaCard(),
        ],
      ],
    );
  }

  // Daily Gita Shloka Card
  Widget _buildDailyGitaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 18, color: AppTheme.gold),
              const SizedBox(width: 6),
              Text(
                _dailyShloka.referenceEn,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF78350F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _dailyShloka.shlokaTelugu.isNotEmpty ? _dailyShloka.shlokaTelugu : _dailyShloka.shlokaSanskrit,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _dailyShloka.meaningEn,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.self_improvement_rounded, size: 16, color: AppTheme.emerald),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _dailyShloka.pilgrimReflectionEn,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
