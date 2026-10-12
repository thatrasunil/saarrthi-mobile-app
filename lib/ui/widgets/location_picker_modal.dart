import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/app_state.dart';

class LocationPickerModal extends StatefulWidget {
  final VoidCallback? onClose;

  const LocationPickerModal({super.key, this.onClose});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LocationPickerModal(),
    );
  }

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  final AppState _appState = AppState.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeTab = 'all'; // 'all', 'local', 'city'
  String _searchQuery = '';
  bool _isLocating = false;

  final List<Map<String, String>> _locations = [
    {
      'id': 'tirupati',
      'name': 'Tirupati (City & Foothills)',
      'shortName': 'Tirupati',
      'sub': 'Alipiri, Railway Station, Central RTC Bus Stand',
      'category': 'local',
    },
    {
      'id': 'tirumala',
      'name': 'Tirumala (Hill Top & Temple)',
      'shortName': 'Tirumala',
      'sub': 'Venkateswara Temple, CRO, Balaji Nagar, Mada Streets',
      'category': 'local',
    },
    {
      'id': 'renigunta',
      'name': 'Renigunta (Airport & Rail Hub)',
      'shortName': 'Renigunta',
      'sub': 'Tirupati Airport (TIR) & Major Rail Junction',
      'category': 'local',
    },
    {
      'id': 'chandragiri',
      'name': 'Chandragiri (Fort & Heritage)',
      'shortName': 'Chandragiri',
      'sub': 'Historic Fort, Sound & Light Show, Raja Mahal',
      'category': 'local',
    },
    {
      'id': 'srikalahasti',
      'name': 'Srikalahasti (Vayu Lingam)',
      'shortName': 'Srikalahasti',
      'sub': 'Rahu-Ketu Kshethram (~38 km from Tirupati)',
      'category': 'local',
    },
    {
      'id': 'kanipakam',
      'name': 'Kanipakam (Varasiddhi Vinayaka)',
      'shortName': 'Kanipakam',
      'sub': 'Swayambhu Vinayaka Temple (~70 km from Tirupati)',
      'category': 'local',
    },
    {
      'id': 'bengaluru',
      'name': 'Bengaluru (Planning Trip)',
      'shortName': 'Bengaluru',
      'sub': 'Majestic / Kempegowda Intl Airport (~250 km)',
      'category': 'city',
    },
    {
      'id': 'chennai',
      'name': 'Chennai (Planning Trip)',
      'shortName': 'Chennai',
      'sub': 'Central Station / Koyambedu / Airport (~135 km)',
      'category': 'city',
    },
    {
      'id': 'hyderabad',
      'name': 'Hyderabad (Planning Trip)',
      'shortName': 'Hyderabad',
      'sub': 'Secunderabad / MGBS / Airport (~550 km)',
      'category': 'city',
    },
    {
      'id': 'vijayawada',
      'name': 'Vijayawada (Planning Trip)',
      'shortName': 'Vijayawada',
      'sub': 'Railway Station / RTC Bus Complex (~380 km)',
      'category': 'city',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGps() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4),
        );
        final isHill = pos.latitude > 13.655 && pos.latitude < 13.735 && pos.longitude > 79.30 && pos.longitude < 79.385;
        final name = isHill ? 'Tirumala' : 'Tirupati';
        _appState.setLocationWithCoordinates(name, lat: pos.latitude, lng: pos.longitude);
      } else {
        _appState.setLocation('Tirupati');
      }
    } catch (_) {
      _appState.setLocation('Tirupati');
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
        Navigator.pop(context);
      }
    }
  }

  List<Map<String, String>> get _filteredLocations {
    return _locations.where((loc) {
      if (_activeTab == 'local' && loc['category'] != 'local') return false;
      if (_activeTab == 'city' && loc['category'] != 'city') return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final name = loc['name']!.toLowerCase();
      final sub = loc['sub']!.toLowerCase();
      return name.contains(q) || sub.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = _appState.isTelugu;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Center(
                    child: Icon(Icons.location_on_rounded, color: Color(0xFFD97706), size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'మీ ప్రారంభ ప్రాంతాన్ని ఎంచుకోండి' : 'Choose Your Starting Location',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTelugu ? 'ఖచ్చితమైన సమయాలు & సిఫార్సుల కోసం' : 'For accurate route times & recommendations',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (widget.onClose != null) widget.onClose!();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // Live GPS Location Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isLocating ? null : _handleGps,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F5132),
                      side: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: const Color(0xFFF0FDF4),
                    ),
                    child: _isLocating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F5132)),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.near_me_rounded, size: 18, color: Color(0xFF0F5132)),
                              const SizedBox(width: 8),
                              Text(
                                isTelugu ? 'ప్రస్తుత లైవ్ జీపీఎస్ ఉపయోగించండి' : 'Use Current Live GPS Location',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F5132),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Info Advice Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTelugu
                              ? 'ప్రస్తుతం తిరుపతిలో లేరా? ప్రయాణ సమయాలు లెక్కించడానికి మీ ప్రారంభ నగరాన్ని ఎంచుకోండి.'
                              : 'Not in Tirupati right now? Pick your starting city to calculate exact highway travel times and trip itineraries.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF92400E),
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: isTelugu ? 'నగరం, స్టేషన్ లేదా ఆలయాన్ని వెతకండి...' : 'Search city, station, or temple...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3 Filter Pill Tabs
                Row(
                  children: [
                    _buildTabPill('all', isTelugu ? 'అన్ని ప్రాంతాలు' : 'All Places'),
                    const SizedBox(width: 8),
                    _buildTabPill('local', isTelugu ? 'తిరుపతి & కొండలు' : 'Tirupati & Hills'),
                    const SizedBox(width: 8),
                    _buildTabPill('city', isTelugu ? 'ఇతర నగరాల నుండి' : 'From Other Cities'),
                  ],
                ),
                const SizedBox(height: 14),

                // Locations List
                ..._filteredLocations.map((loc) {
                  final isSelected = _appState.selectedLocation == loc['shortName'] ||
                      _appState.selectedLocation == loc['name'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        _appState.setLocation(loc['shortName']!);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc['name']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc['sub']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF16A34A),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String tabKey, String label) {
    final isActive = _activeTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
            color: isActive ? const Color(0xFF92400E) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
