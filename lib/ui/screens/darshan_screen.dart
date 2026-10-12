import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
import '../../data/admin_repository.dart';
import '../../data/supabase_repository.dart';
import '../../models/darshan.dart';
import '../widgets/skeleton_shimmer.dart';

class DarshanScreen extends StatefulWidget {
  final SupabaseRepository supabaseRepo;

  const DarshanScreen({super.key, required this.supabaseRepo});

  @override
  State<DarshanScreen> createState() => _DarshanScreenState();
}

class _DarshanScreenState extends State<DarshanScreen> {
  final _appState = AppState.instance;
  late DarshanStatus _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _status = DarshanStatus.sample();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final adminData = await AdminRepository.instance.fetchLiveStatus();
      if (adminData != null) _appState.updateFromAdminLiveStatus(adminData);
    } catch (_) {}

    final s = await widget.supabaseRepo.getLiveDarshanStatus();
    if (mounted) {
      setState(() {
        _status = s;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = _appState.isTelugu;

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        title: Text(
          isTelugu ? 'దర్శనం & క్యూ సమయాలు' : 'Darshan & Queue Timings',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: isTelugu ? 'రిఫ్రెష్ చేయండి' : 'Refresh Live Status',
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.emerald),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchStatus();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const DarshanScreenSkeleton()
          : RefreshIndicator(
              onRefresh: _fetchStatus,
              color: AppTheme.emerald,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. REASSURING ANXIETY-REDUCING RULE BANNER (SAVES PILGRIMS FROM TURNAWAYS)
                  _buildCrucialRulesBanner(isTelugu),
                  const SizedBox(height: 14),

                  // 2. LIVE WAIT TIME HERO CARD (INSTANT SITUATIONAL AWARENESS)
                  _buildLiveStatusHeroCard(isTelugu),
                  const SizedBox(height: 16),

                  // 3. PROGRESSIVE 3-STAGE QUEUE JOURNEY TRACKER
                  _buildQueueStagesTracker(isTelugu),
                  const SizedBox(height: 20),

                  // 4. DARSHAN TYPES MATRIX (SARVA, SPECIAL ENTRY, DIVYA)
                  _buildDarshanTypesMatrix(isTelugu),
                  const SizedBox(height: 20),

                  // 5. FREE SSD TOKEN COUNTERS (WITH DIRECTIONS & REQUIREMENTS)
                  _buildSsdCountersSection(isTelugu),
                  const SizedBox(height: 20),

                  // 6. GHAT ROAD TRAVEL TIMINGS & SPEED LIMITS
                  _buildGhatRoadCard(isTelugu),
                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }

  // 1. Crucial Rule Reminder Banner (Psychology: Prevents devastating turnaways after 4h wait)
  Widget _buildCrucialRulesBanner(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.no_photography_rounded, color: Color(0xFFDC2626), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTelugu ? 'ముఖ్య గమనిక: ఎలక్ట్రానిక్స్ & మొబైల్స్ నిషేధం' : 'Crucial: Mobiles & Electronics Barred',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTelugu
                      ? 'వైకుంఠం క్యూ కాంప్లెక్స్ లోపలికి మొబైల్స్, ఇయర్‌ఫోన్లు, కెమెరాలు అనుమతించబడవు. క్యూ ప్రవేశానికి ముందే ఉచిత టీటీడీ లగేజీ కౌంటర్లలో డిపాజిట్ చేయండి.'
                      : 'Mobiles, smartwatches, and cameras are strictly banned in queue lines. Deposit them at free TTD counters outside before queue entry.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF7F1D1D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Live Status Hero Card
  Widget _buildLiveStatusHeroCard(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTelugu ? 'సర్వ దర్శనం (ఉచిత SSD)' : 'Sarva Darshan (Free SSD)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusGreenBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.statusGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _appState.crowdStatus,
                      style: const TextStyle(
                        color: AppTheme.statusGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _appState.sarvaDarshanWait,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.emerald,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'అంచనా నిరీక్షణ' : 'Estimated Wait',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.meeting_room_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      isTelugu
                          ? 'కంపార్ట్‌మెంట్లు: ${_status.compartmentsFull} / 31'
                          : 'Compartments: ${_status.compartmentsFull} / 31 full',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                Text(
                  isTelugu ? 'నిరంతరం కదులుతోంది' : 'Active Movement',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.emerald),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _status.recommendation,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF78350F),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Progressive 3-Stage Queue Journey (Psychology: Eliminates black-box wait anxiety)
  Widget _buildQueueStagesTracker(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.linear_scale_rounded, color: AppTheme.emerald, size: 20),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'క్యూ ప్రయాణం & వసతులు' : 'Queue Journey & Comforts',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStageItem(
            step: '1',
            title: isTelugu ? 'టోకెన్ & సెక్యూరిటీ తనిఖీ' : 'Token & Security Check',
            desc: isTelugu
                ? 'అసలు ఆధార్ కార్డు చూపించాలి. పురుషులు పంచె/కుర్తా, స్త్రీలు చీర/చురీదార్ ధరించాలి.'
                : 'Aadhaar ID scan + mandatory traditional dress code check.',
            badge: isTelugu ? 'ప్రవేశం' : 'Entry',
            isFirst: true,
          ),
          _buildStageItem(
            step: '2',
            title: isTelugu ? 'వైకుంఠం కంపార్ట్‌మెంట్లు' : 'Vaikuntam Waiting Halls',
            desc: isTelugu
                ? 'ఉచిత వేడి పాలు, సాంబార్ అన్నం, తాగునీరు నిరంతరం టీటీడీ సేవకులు అందిస్తారు.'
                : 'Continuous free hot milk for babies, meals & RO water provided.',
            badge: isTelugu ? 'విశ్రాంతి & ఆహారం' : 'Free Meals & Milk',
          ),
          _buildStageItem(
            step: '3',
            title: isTelugu ? 'ఆనంద నిలయం దివ్య దర్శనం' : 'Ananda Nilayam Sanctum',
            desc: isTelugu
                ? 'మహాద్వారం ద్వారా గర్భగుడి దర్శనం, లడ్డూ ప్రసాదం స్వీకరణ.'
                : 'Golden Vimana darshan, sanctum entry & free laddu collection.',
            badge: isTelugu ? 'మహా దర్శనం' : 'Sanctum',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem({
    required String step,
    required String title,
    required String desc,
    required String badge,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppTheme.emeraldLight,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(color: AppTheme.emerald, width: 1.5)),
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.emerald),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: const Color(0xFFCBD5E1),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. Darshan Types Matrix
  Widget _buildDarshanTypesMatrix(bool isTelugu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTelugu ? 'దర్శన రకాలు & వేళలు' : 'Darshan Channels & Timings',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChannelCard(
                title: isTelugu ? 'ప్రత్యేక ప్రవేశం' : 'Special Entry (SED)',
                price: '₹300',
                wait: _appState.specialEntryWait,
                tag: isTelugu ? 'ముందస్తు బుకింగ్' : 'Advance Online',
                icon: Icons.confirmation_number_rounded,
                isHighlight: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChannelCard(
                title: isTelugu ? 'దివ్య దర్శనం' : 'Divya Darshan (Footpath)',
                price: isTelugu ? 'ఉచితం' : 'FREE',
                wait: _appState.divyaDarshanWait,
                tag: isTelugu ? 'అలిపిరి / మెట్టు' : 'Alipiri / Mettu',
                icon: Icons.hiking_rounded,
                isHighlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelCard({
    required String title,
    required String price,
    required String wait,
    required String tag,
    required IconData icon,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isHighlight ? AppTheme.emerald.withValues(alpha: 0.3) : AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: isHighlight ? AppTheme.emerald : AppTheme.saffron),
              Text(
                price,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isHighlight ? AppTheme.emerald : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            wait,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  // 5. SSD Token Counters Section
  Widget _buildSsdCountersSection(bool isTelugu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTelugu ? 'తిరుపతిలో ఉచిత SSD టోకెన్ కేంద్రాలు' : 'Free SSD Token Counters (Tirupati)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _buildSsdCounterCard(
          name: isTelugu ? 'భూదేవి కాంప్లెక్స్' : 'Bhudevi Complex',
          location: isTelugu ? 'అలిపిరి పాదాల చెంత (మెట్ల మార్గం)' : 'Alipiri Footpath Entrance, Tirupati',
          timing: isTelugu ? 'ఉదయం 4:00 నుండి (ఆధార్ కార్డు తప్పనిసరి)' : 'Opens 4:00 AM (Aadhaar mandatory)',
          icon: Icons.confirmation_number_rounded,
        ),
        _buildSsdCounterCard(
          name: isTelugu ? 'శ్రీనివాసం కాంప్లెక్స్' : 'Srinivasam Complex',
          location: isTelugu ? 'తిరుపతి సెంట్రల్ బస్ స్టాండ్ ఎదురుగా' : 'Opposite Tirupati Central Bus Station',
          timing: isTelugu ? 'ఉదయం 4:00 నుండి కోటా ముగిసే వరకు' : 'Opens 4:00 AM daily until quota exhausts',
          icon: Icons.directions_bus_rounded,
        ),
        _buildSsdCounterCard(
          name: isTelugu ? 'గోవిందరాజ సత్రాలు (విష్ణు నివాసం)' : 'Vishnu Nivasam (Railway Station)',
          location: isTelugu ? 'తిరుపతి రైల్వే స్టేషన్ ఎదురుగా' : 'Directly opposite Tirupati Railway Station',
          timing: isTelugu ? 'ఉదయం 4:00 నుండి నిరంతరం' : 'Opens 4:00 AM daily until quota exhausts',
          icon: Icons.train_rounded,
        ),
      ],
    );
  }

  Widget _buildSsdCounterCard({
    required String name,
    required String location,
    required String timing,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.emeraldLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.emerald, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  timing,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF78350F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Ghat Road Rules Card
  Widget _buildGhatRoadCard(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.saffronLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.saffron.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: AppTheme.saffron, size: 20),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'తిరుమల ఘాట్ రోడ్ వేగ పరిమితులు' : 'Tirumala Ghat Road Speed Rules',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF78350F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isTelugu
                ? '• ఘాట్ ఎక్కే సమయం: అలిపిరి టోల్ గేట్ నుండి తిరుమల చేరడానికి కనీసం 28 నిమిషాలు పట్టాలి.\n'
                  '• ఘాట్ దిగే సమయం: బ్రేక్ హీట్ నివారణకు కనీసం 40 నిమిషాలు పట్టాలి.\n'
                  '• వేగ పరిమితి: మలుపులలో గరిష్టంగా 30 కిమీ/గం. నిబంధనల ఉల్లంఘనకు టీటీడీ ఆటోమేటిక్ జరిమానా విధిస్తుంది.'
                : '• Uphill Ascent: Minimum travel time is 28 minutes from Alipiri Toll Gate to Tirumala.\n'
                  '• Downhill Descent: Minimum travel time is 40 minutes to prevent brake overheating.\n'
                  '• Max Speed Limit: 30 km/h on curves. Heavy automated fines are levied for early arrivals.',
            style: const TextStyle(fontSize: 12.5, height: 1.45, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
