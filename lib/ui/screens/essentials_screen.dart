import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
import '../../core/transitions.dart';
import '../widgets/saarthi_image.dart';
import 'facility_detail_screen.dart';
import 'notifications_screen.dart';
import '../widgets/skeleton_shimmer.dart';
import '../widgets/saarthi_logo.dart';

class EssentialsScreen extends StatefulWidget {
  const EssentialsScreen({super.key});

  @override
  State<EssentialsScreen> createState() => _EssentialsScreenState();
}

class _EssentialsScreenState extends State<EssentialsScreen> {
  final AppState _appState = AppState.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _expandedFaqId;
  bool _dismissedNotice = false;
  bool _showChecklist = false;
  bool _isLoading = false;

  Future<void> _refreshEssentials() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    if (_appState.essentialsCategory.isNotEmpty && _appState.essentialsCategory != 'All') {
      _selectedCategory = _appState.essentialsCategory;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openFacilityDetail(Map<String, dynamic> facility) {
    Navigator.push(
      context,
      AppTransitions.smoothSlideRoute(
        FacilityDetailScreen(facility: facility),
      ),
    );
  }

  final List<Map<String, dynamic>> _facilities = [
    {
      'id': 'secure-belongings',
      'category': 'Lockers',
      'titleEn': 'Free Lockers & Mobile Deposit',
      'titleTe': 'ఉచిత లాకర్లు & మొబైల్ డిపాజిట్',
      'subEn': 'Secure phones, smart watches & luggage before entering VQC queue',
      'subTe': 'క్యూలోకి వెళ్లేముందు ఫోన్లు, స్మార్ట్ వాచీలు & లగేజీని భద్రపరచండి',
      'statusEn': '6 Locations Open',
      'statusTe': '6 కేంద్రాలు ఓపెన్',
      'icon': Icons.lock_outline_rounded,
      'image': 'https://res.cloudinary.com/kniegqlj/image/upload/v1786968161/IMG_6992_cq6gls.jpg',
      'locationEn': '6 Nearby Counters (Madhava Nilayam, PAC-1 to PAC-5, VQC Entrance)',
      'locationTe': 'మాధవ నిలయం, పీఏసీ 1-5, వీక్యూసీ ప్రవేశం వద్ద 6 కౌంటర్లు',
      'descEn': 'Store your heavy bags, mobile phones, cameras, and leather items safely before entering the Vaikuntam Queue Complex. Free TTD counters are available at 6 major transit points.',
      'descTe': 'క్యూ కాంప్లెక్స్ లోకి వెళ్లేముందు లగేజీ, మొబైల్ ఫోన్లు, కెమెరాలు, లెదర్ వస్తువులను భద్రపరచండి. 6 ప్రధాన కేంద్రాల్లో ఉచిత కౌంటర్లు అందుబాటులో ఉన్నాయి.',
      'whyItMattersEn': 'Mobiles, smartwatches, cameras, and heavy bags are strictly prohibited inside the main temple. Depositing them at authorized TTD counters before queue entry avoids being turned back by security checkpoints at VQC-II gates.',
      'whyItMattersTe': 'ఆలయం లోపలికి మొబైల్స్, స్మార్ట్ వాచీలు, బ్యాగులు ఖచ్చితంగా నిషిద్ధం. క్యూ ప్రవేశానికి ముందే డిపాజిట్ చేయడం వల్ల తనిఖీ కేంద్రాల వద్ద ఇబ్బందులు తప్పుతాయి.',
      'tag': 'FREE',
      'lat': 13.6823,
      'lng': 79.3514,
      'isTirumala': true,
      'subLocations': [
        {'name': 'PAC-1 (Madhava Nilayam Counter)', 'walk': '4 min walk', 'status': 'Open Now', 'lat': 13.6828, 'lng': 79.3508},
        {'name': 'PAC-2 (Nandakam Rest Hall)', 'walk': '5 min walk', 'status': 'Open Now', 'lat': 13.6815, 'lng': 79.3522},
        {'name': 'PAC-5 (Central Lockers)', 'walk': '7 min walk', 'status': 'Open Now', 'lat': 13.6840, 'lng': 79.3490},
        {'name': 'CRO Reception Office Counter', 'walk': '3 min walk', 'status': 'Open Now', 'lat': 13.6830, 'lng': 79.3530},
        {'name': 'VQC-II Entry Pouch Counter', 'walk': '2 min walk', 'status': 'Open Now', 'lat': 13.6838, 'lng': 79.3478},
      ],
    },
    {
      'id': 'free-meals',
      'category': 'Annaprasadam',
      'titleEn': 'Free Annaprasadam Meals',
      'titleTe': 'ఉచిత నిత్య అన్నప్రసాదం',
      'subEn': 'Continuous hot, sacred vegetarian meals at Tarigonda Vengamamba Complex',
      'subTe': 'తరిగొండ వెంగమాంబ అన్నప్రసాద భవనంలో నిరంతర వేడి భోజన ప్రసాదం',
      'statusEn': 'Serving Continuously',
      'statusTe': 'నిరంతరం లభిస్తుంది',
      'icon': Icons.restaurant_rounded,
      'image': 'https://res.cloudinary.com/kniegqlj/image/upload/v1786968272/Annaprasadam-4-copy_lyo86v.jpg',
      'locationEn': 'Tarigonda Vengamamba Complex, West Mada Street',
      'locationTe': 'తరిగొండ వెంగమాంబ కాంప్లెక్స్, పశ్చిమ మాడ వీధి',
      'descEn': 'Continuous sacred vegetarian meals including rice, sambar, rasam, curry, curd, and sweet pongal. Open from 9:00 AM to 11:00 PM without token requirement. 4 huge dining halls serve 4,000+ devotees per sitting.',
      'descTe': 'వేడి అన్నం, సాంబారు, రసం, కూర, పెరుగు మరియు తీపి పొంగలితో నిరంతర భోజనం. ఉదయం 9:00 నుండి రాత్రి 11:00 వరకు టోకెన్ లేకుండా ఉచితంగా అందిస్తారు.',
      'whyItMattersEn': 'Having sacred Annaprasadam satisfies both physical nourishment and spiritual sanctity before or after arduous hill climbs and long queue waits.',
      'whyItMattersTe': 'శ్రీవారి అన్నప్రసాదం స్వీకరించడం వల్ల క్యూలో నిల్చోవడానికి అవసరమైన శక్తి మరియు ఆత్మశాంతి లభిస్తాయి.',
      'tag': 'FREE',
      'lat': 13.6835,
      'lng': 79.3458,
      'isTirumala': true,
      'subLocations': [
        {'name': 'Dining Hall 1 (Ground Floor)', 'walk': '2 min walk', 'status': 'Serving', 'lat': 13.6835, 'lng': 79.3458},
        {'name': 'Dining Hall 2 (First Floor)', 'walk': '2 min walk', 'status': 'Serving', 'lat': 13.6835, 'lng': 79.3458},
        {'name': 'Food Distribution PAC-2', 'walk': '5 min walk', 'status': 'Open Now', 'lat': 13.6815, 'lng': 79.3522},
      ],
    },
    {
      'id': 'hair-offering',
      'category': 'Kalyana Katta',
      'titleEn': 'Kalyana Katta (Hair Offering)',
      'titleTe': 'కళ్యాణకట్ట (తలనీలాలు)',
      'subEn': 'Token-free sacred tonsure service open 24/7 with sanitized blades',
      'subTe': 'సానిటైజ్ చేసిన బ్లేడ్లతో 24/7 ఉచిత తలనీలాల సేవలు',
      'statusEn': 'Open 24/7',
      'statusTe': '24/7 అందుబాటులో ఉంది',
      'icon': Icons.content_cut_rounded,
      'image': 'https://res.cloudinary.com/kniegqlj/image/upload/v1786968353/painted-sign-board-of-kalyanakatta-balaji-temple-tirupati-andhra-pradesh-F5M0J1_p7hkr5.jpg',
      'locationEn': 'Main Central Hall near Rambagicha & Mini Kalyana Kattas at PAC 1-4',
      'locationTe': 'రాంబగీచా వద్ద ప్రధాన భవనం & పీఏసీ 1-4 ల వద్ద మినీ కేంద్రాలు',
      'descEn': 'Sacred head tonsure offering (Kalyana Katta). Token-free services open 24/7 at the 4-storey central building near Rambagicha and 4 mini Kalyana Kattas at PAC-1 to PAC-4. Hot water baths available adjacent.',
      'descTe': 'శ్రీవారికి తలనీలాలు సమర్పించే పవిత్ర కేంద్రం. 24 గంటలూ ఉచితంగా సేవలు అందుతాయి. పక్కనే వేడినీటి స్నానపు సదుపాయాలు ఉన్నాయి.',
      'whyItMattersEn': 'Offering hair symbolizes complete surrender of ego and pride before having the sacred darshan of Lord Venkateswara.',
      'whyItMattersTe': 'శ్రీవారి దర్శనానికి ముందు అహంకారాన్ని వీడి సంపూర్ణ శరణాగతితో తలనీలాలు సమర్పించడం అత్యంత పుణ్యప్రదం.',
      'tag': 'FREE',
      'lat': 13.6852,
      'lng': 79.3488,
      'isTirumala': true,
      'subLocations': [
        {'name': 'Main Central Kalyana Katta', 'walk': '4 min walk', 'status': 'Open 24/7', 'lat': 13.6852, 'lng': 79.3488},
        {'name': 'Mini Kalyana Katta PAC-1', 'walk': '3 min walk', 'status': 'Open Now', 'lat': 13.6828, 'lng': 79.3508},
        {'name': 'Mini Kalyana Katta PAC-3', 'walk': '6 min walk', 'status': 'Open Now', 'lat': 13.6832, 'lng': 79.3515},
      ],
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'id': 'faq-phone',
      'qEn': 'Can I carry a mobile phone inside the Tirumala temple?',
      'qTe': 'తిరుమల ఆలయం లోపలికి మొబైల్ ఫోన్ తీసుకెళ్లవచ్చా?',
      'aEn': 'No. Mobile phones, smartwatches, earphones, laptops, and cameras are strictly prohibited inside the Vaikuntam Queue Complex and the main temple. You must deposit them at free TTD electronic counters before entering.',
      'aTe': 'లేదు. ఆలయం మరియు క్యూ కాంప్లెక్స్ లోపలికి మొబైల్ ఫోన్లు, స్మార్ట్ వాచీలు, ఎలక్ట్రానిక్స్ తీసుకెళ్లడం ఖచ్చితంగా నిషిద్ధం. క్యూ ప్రవేశానికి ముందే ఉచిత కౌంటర్లలో డిపాజిట్ చేయాలి.',
    },
    {
      'id': 'faq-dress',
      'qEn': 'What is the mandatory dress code for Darshan?',
      'qTe': 'దర్శనానికి అధికారిక వస్త్రధారణ నిబంధనలు ఏమిటి?',
      'aEn': 'For Men: White Dhoti with Uttareeyam (Angavastram) or Kurta-Pyjama. Jeans, T-shirts, shorts, and trousers are barred. For Women: Saree, Half-Saree, or Churidar/Salwar with Dupatta (worn properly across chest).',
      'aTe': 'పురుషులకు: తెల్లటి ధోతి లేదా కుర్తా-పైజామా (ఉత్తరీయంతో). జీన్స్, టీషర్టులు నిషిద్ధం. మహిళలకు: చీర, లంగా వోణి లేదా చున్నీతో కూడిన పంజాబీ డ్రెస్/చురీదార్.',
    },
    {
      'id': 'faq-lockers',
      'qEn': 'Are luggage lockers in Tirumala free to use?',
      'qTe': 'తిరుమలలో లగేజీ లాకర్లు ఉచితంగా లభిస్తాయా?',
      'aEn': 'Yes. TTD provides 100% free luggage lockers across PAC-1, PAC-2, PAC-3, PAC-4, PAC-5, and near CRO. Original Aadhaar or Govt ID card is required to receive the computerized token receipt.',
      'aTe': 'అవును. పీఏసీ 1, 2, 3, 4, 5 మరియు సీఆర్వో వద్ద టీటీడీ 100% ఉచితంగా లాకర్లను అందిస్తుంది. రశీదు కోసం అసలు ఆధార్ కార్డు చూపించాలి.',
    },
    {
      'id': 'faq-meals',
      'qEn': 'Where can I get free meals in Tirumala?',
      'qTe': 'తిరుమలలో ఉచిత అన్నప్రసాదం ఎక్కడ లభిస్తుంది?',
      'aEn': 'Free hot vegetarian Annaprasadam meals are served continuously from 9:00 AM to 11:00 PM at the Matrusri Tarigonda Vengamamba Annaprasadam Complex on West Mada Street without tokens.',
      'aTe': 'పశ్చిమ మాడ వీధిలోని మాతృశ్రీ తరిగొండ వెంగమాంబ అన్నప్రసాద భవనంలో ఉదయం 9:00 నుండి రాత్రి 11:00 వరకు టోకెన్ లేకుండా ఉచితంగా భోజన ప్రసాదం అందిస్తారు.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        final isTelugu = _appState.isTelugu;
        final unreadAlerts = _appState.activeAlertsCount;
        final checkedCount = _appState.checkedEssentials.length;

        // Filter facilities based on search query
        final filteredFacilities = _facilities.where((f) {
          if (_selectedCategory != 'All' && f['category'] != _selectedCategory) {
            return false;
          }
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase().trim();
          final titleEn = (f['titleEn'] as String).toLowerCase();
          final titleTe = (f['titleTe'] as String).toLowerCase();
          final descEn = (f['descEn'] as String).toLowerCase();
          final descTe = (f['descTe'] as String).toLowerCase();
          final subEn = (f['subEn'] as String).toLowerCase();
          final subTe = (f['subTe'] as String).toLowerCase();
          return titleEn.contains(q) || titleTe.contains(q) || descEn.contains(q) || descTe.contains(q) || subEn.contains(q) || subTe.contains(q);
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          // 1. STICKY TOP APP BAR (Image 1)
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF0F172A)),
                  ),
                ),
              ),
            ),
            titleSpacing: 8,
            title: Row(
              children: [
                const SaarthiLogo(size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isTelugu ? 'యాత్రా అవసరాలు' : 'Pilgrim Essentials',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isTelugu ? 'దర్శనానికి ముందు మీకు కావాల్సినవి' : 'Everything you need before your visit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Notification Bell with Badge
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    AppTransitions.smoothSlideRoute(const NotificationsScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF0F172A)),
                    ),
                    if (unreadAlerts > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Checklist Toggle Button
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showChecklist = !_showChecklist;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _showChecklist ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
                        width: _showChecklist ? 1.5 : 1.0,
                      ),
                      color: _showChecklist ? const Color(0xFFFFFBEB) : Colors.white,
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 19,
                      color: _showChecklist ? const Color(0xFFD97706) : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // SCROLLABLE BODY WITH 160px BOTTOM PADDING (PREVENTS FLOATING NAV OVERLAP)
          body: _isLoading
              ? const EssentialsScreenSkeleton()
              : RefreshIndicator(
                  onRefresh: _refreshEssentials,
                  color: AppTheme.emerald,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
            children: [
              // 2. SEARCH INPUT BAR (Image 1)
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: isTelugu
                        ? 'లాకర్లు, గదులు, కళ్యాణకట్ట శోధించండి...'
                        : 'Search lockers, rooms, tonsure...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. TODAY'S NOTICE CARD (Image 1)
              if (!_dismissedNotice) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                              const SizedBox(width: 6),
                              Text(
                                isTelugu ? 'ఈరోజు తాజా నోటీసు' : "TODAY'S NOTICE",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => setState(() => _dismissedNotice = true),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.close_rounded, size: 16, color: Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTelugu
                            ? 'అధిక రద్దీ హెచ్చరిక: ఘాట్ రోడ్డులో వాహనాల రాకపోకలు నెమ్మదిగా సాగుతున్నాయి. జాగ్రత్తగా ప్రయాణించండి.'
                            : 'HIGH CROWD WARNING: Ghat road traffic slow. Exercise caution.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF78350F),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTelugu ? '14 గంటల క్రితం నవీకరించబడింది' : 'Updated 14 hrs ago',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 4. PRE-DARSHAN READINESS CHECKLIST (Toggled by Checklist Icon)
              if (_showChecklist) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFD97706), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isTelugu ? 'దర్శన ముందస్తు సిద్ధత' : 'Pre-Darshan Readiness',
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: checkedCount == 5 ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$checkedCount / 5',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: checkedCount == 5 ? const Color(0xFF15803D) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: checkedCount / 5.0,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildChecklistTile('id_card', isTelugu ? 'అసలు ఆధార్ / ప్రభుత్వం జారీ చేసిన గుర్తింపు కార్డు' : 'Original Aadhaar / Govt Photo ID Card'),
                      _buildChecklistTile('dress_code', isTelugu ? 'అధికారిక సంప్రదాయ వస్త్రధారణ' : 'Official TTD Traditional Dress Code'),
                      _buildChecklistTile('cash_coins', isTelugu ? 'తగినంత నగదు & నాణాలు' : 'Sufficient Cash & Coins for lockers/prasad'),
                      _buildChecklistTile('meds_water', isTelugu ? 'అవసరమైన మందులు & తాగునీటి బాటిల్' : 'Prescribed Medicines & Water (Permitted in queue)'),
                      _buildChecklistTile('phone_power', isTelugu ? 'మొబైల్ డిపాజిట్ పూర్తయింది' : 'Mobile Phone deposited at PAC lockers'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Quick Emergency Direct-Dial Bar (Psychology: Instant crisis relief)
              _buildTopEmergencyBar(isTelugu),
              const SizedBox(height: 14),

              // 5. "WHAT YOU NEED RIGHT NOW" SECTION (Image 1 & 2)
              Text(
                isTelugu ? 'ప్రస్తుతం మీకు కావాల్సిన ముఖ్య సదుపాయాలు' : 'What You Need Right Now',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isTelugu ? 'దర్శనానికి ముందు అత్యవసర కేంద్రాలు' : 'Essential facilities before your darshan',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              // 6. FACILITY CARDS WITH IMAGE, BADGES & "Navigate →" (Image 1, 2, 3)
              ...filteredFacilities.map((f) => _buildWebStyleFacilityCard(f, isTelugu)),

              const SizedBox(height: 8),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 4),

              // 7. SUPPORT & EMERGENCY SERVICES (2-Column Grid matching Image 3)
              Text(
                isTelugu ? 'మద్దతు & అత్యవసర సేవలు' : 'Support & Emergency Services',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Card 1: Official Shopping
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _openFacilityDetail({
                          'id': 'official-shopping',
                          'category': 'Shopping',
                          'titleEn': 'Official Shopping',
                          'titleTe': 'టీటీడీ అధికారిక విక్రయశాలలు',
                          'subEn': 'TTD Books, Laddus, Photos & Puja articles',
                          'subTe': 'శ్రీవారి లడ్డూలు, చిత్రపటాలు, పూజా సామగ్రి',
                          'descEn': 'Authentic TTD publications, copper coins, sacred calendars, agarbattis, and authorized extra laddu counters.',
                          'descTe': 'టీటీడీ ప్రచురణలు, శ్రీవారి క్యాలెండర్లు, రాగి నాణాలు, అగర్‌బత్తీలు మరియు అధికారిక లడ్డూ కౌంటర్లు.',
                          'whyItMattersEn': 'Purchasing only from official TTD sales counters ensures authentic sanctified prasadam and avoids overpaying unauthorized street vendors.',
                          'whyItMattersTe': 'కేవలం అధికారిక కౌంటర్లలో మాత్రమే కొనుగోలు చేయడం ద్వారా స్వచ్ఛమైన ప్రసాదం సరసమైన ధరకు లభిస్తుంది.',
                          'statusEn': 'Open 8 AM - 9 PM',
                          'statusTe': 'ఉదయం 8 నుండి రాత్రి 9 వరకు',
                          'icon': Icons.shopping_bag_outlined,
                          'locationEn': 'Opposite Lepakshi & SV Temple Museum, Tirumala',
                          'locationTe': 'లేపాక్షి ఎదురుగా & ఎస్వీ మ్యూజియం, తిరుమల',
                          'tag': 'OFFICIAL TTD',
                          'lat': 13.6845,
                          'lng': 79.3465,
                          'isTirumala': true,
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF166534), size: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isTelugu ? 'అధికారిక టీటీడీ' : 'OFFICIAL TTD',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF166534),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTelugu ? 'షాపింగ్ కేంద్రాలు' : 'Official Shopping',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTelugu ? 'పుస్తకాలు & లడ్డూలు' : 'TTD Books & Laddus',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Card 2: Emergency Help
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _openFacilityDetail({
                          'id': 'emergency-help',
                          'category': 'Emergency',
                          'titleEn': 'Emergency Help',
                          'titleTe': 'అత్యవసర సహాయ కేంద్రాలు',
                          'subEn': 'Police, Medical 24/7 & Lost & Found',
                          'subTe': 'పోలీస్, వైద్యం 24/7 & తప్పిపోయిన వారి సమాచార కేంద్రం',
                          'descEn': 'Round-the-clock free emergency medical treatment at Aswini Hospital, first-aid posts at PACs, police assistance booths, and child wristband tracking.',
                          'descTe': 'అశ్విని ఆసుపత్రిలో 24 గంటల ఉచిత వైద్యం, పీఏసీల వద్ద ప్రథమ చికిత్స కేంద్రాలు మరియు పోలీస్ బూతులు.',
                          'whyItMattersEn': 'Quick access to medical and security assistance in peak crowd situations ensures safety for elders and children.',
                          'whyItMattersTe': 'రద్దీ సమయాల్లో వృద్ధులు మరియు పిల్లల భద్రతకు తక్షణ సహాయం అందుబాటులో ఉండటం చాలా ముఖ్యం.',
                          'statusEn': 'Active 24/7',
                          'statusTe': '24/7 అందుబాటులో ఉంది',
                          'icon': Icons.shield_outlined,
                          'locationEn': 'Aswini Hospital & Central Security Office, Tirumala',
                          'locationTe': 'అశ్విని ఆసుపత్రి & సెక్యూరిటీ ఆఫీస్, తిరుమల',
                          'tag': 'EMERGENCY',
                          'lat': 13.6812,
                          'lng': 79.3498,
                          'isTirumala': true,
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFDA4AF)),
                              ),
                              child: const Icon(Icons.shield_outlined, color: Color(0xFFE11D48), size: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isTelugu ? 'అత్యవసరం 24/7' : 'EMERGENCY 24/7',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE11D48),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTelugu ? 'అత్యవసర సహాయం' : 'Emergency Help',
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTelugu ? 'పోలీస్ & వైద్యం 24/7' : 'Police & Medical 24/7',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 8. FREQUENTLY ASKED QUESTIONS (Image 3 & 4)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFFD97706)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTelugu ? 'తరచుగా అడిగే ప్రశ్నలు (FAQ)' : 'Frequently Asked Questions',
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._faqs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final faq = entry.value;
                      final id = faq['id'] as String;
                      final isExpanded = _expandedFaqId == id;
                      final isLast = idx == _faqs.length - 1;

                      return Column(
                        children: [
                          Container(height: 1, color: const Color(0xFFF1F5F9)),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expandedFaqId = isExpanded ? null : id;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isTelugu ? faq['qTe'] as String : faq['qEn'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded)
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isTelugu ? faq['aTe'] as String : faq['aEn'] as String,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          if (isLast) const SizedBox(height: 4),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 9. EMERGENCY CALLOUT RED BANNER (Image 4)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF881337), // Deep maroon
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF881337).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTelugu ? 'అత్యవసర సహాయం' : 'Emergency Help',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isTelugu ? 'పోలీస్ • వైద్యం • తప్పిపోయిన వారి సమాచారం' : 'Police • Medical • Lost & Found',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _callNumber('108'),
                      icon: const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF881337)),
                      label: const Text(
                        'Call 108',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF881337),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF881337),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  // Quick Emergency Helpline Bar (Psychology: Instant crisis relief)
  Widget _buildTopEmergencyBar(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isTelugu ? '24/7 అత్యవసర హెల్ప్‌లైన్' : '24/7 Tirumala Emergency',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isTelugu ? 'ఉచితం' : 'TOLL FREE',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isTelugu ? 'వైద్య, పోలీసు, అగ్నిమాపక & సహాయ కేంద్రం' : 'Medical, Police, Fire & Pilgrim Helpdesk',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7F1D1D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _callNumber('08772277777'),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
            label: Text(
              isTelugu ? 'కాల్' : 'Call',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // Pre-Darshan Checklist Tile
  Widget _buildChecklistTile(String id, String title) {
    final isChecked = _appState.checkedEssentials.contains(id);
    return InkWell(
      onTap: () => _appState.toggleEssential(id),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                  width: 1.5,
                ),
                color: isChecked ? const Color(0xFFD97706) : Colors.transparent,
              ),
              child: isChecked
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Facility Card with Web-App Design Tokens (Images 1, 2, 3)
  Widget _buildWebStyleFacilityCard(Map<String, dynamic> f, bool isTelugu) {
    final title = isTelugu ? f['titleTe'] as String : f['titleEn'] as String;
    final sub = isTelugu ? f['subTe'] as String : f['subEn'] as String;
    final status = isTelugu ? f['statusTe'] as String : f['statusEn'] as String;
    final icon = f['icon'] as IconData;
    final imageUrl = f['image'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openFacilityDetail(f),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with Dual Floating Badges (Image 1 & 2)
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SaarthiImage(
                      url: imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: icon,
                    ),

                    // Top-Left Floating Badge: White Box with Category Icon
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
                        ),
                      ),
                    ),

                    // Top-Right Floating Badge: Dark Pill with Live Green Dot
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E), // Live bright green dot
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Wide Dark-Green "Navigate →" Button (Image 2)
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => _openFacilityDetail(f),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isTelugu ? 'వివరాలు & దారి →' : 'Navigate →',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
