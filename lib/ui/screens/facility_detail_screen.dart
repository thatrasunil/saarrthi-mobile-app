import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_state.dart';
import '../../models/place.dart';
import '../widgets/srivari_namam_icon.dart';

class FacilityDetailScreen extends StatelessWidget {
  final Map<String, dynamic> facility;

  const FacilityDetailScreen({
    super.key,
    required this.facility,
  });

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareFacility(BuildContext context, bool isTelugu) {
    final title = isTelugu ? (facility['titleTe'] ?? facility['titleEn']) : facility['titleEn'];
    final location = isTelugu ? (facility['locationTe'] ?? facility['locationEn']) : facility['locationEn'];
    Clipboard.setData(ClipboardData(text: '$title\nLocation: $location\nVerified on TTD Saarthi Mobile App.'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isTelugu ? 'వివరాలు క్లిప్‌బోర్డ్‌కు కాపీ చేయబడ్డాయి!' : 'Facility details copied to clipboard!'),
        backgroundColor: const Color(0xFF0F5132),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isTelugu = appState.isTelugu;
        final title = isTelugu ? (facility['titleTe'] ?? facility['titleEn']) as String : facility['titleEn'] as String;
        final sub = isTelugu ? (facility['subTe'] ?? facility['subEn']) as String : facility['subEn'] as String;
        final desc = isTelugu ? (facility['descTe'] ?? facility['descEn']) as String : facility['descEn'] as String;
        final location = isTelugu ? (facility['locationTe'] ?? facility['locationEn']) as String : facility['locationEn'] as String;
        final whyItMatters = isTelugu
            ? (facility['whyItMattersTe'] ?? facility['whyItMattersEn'] ?? '') as String
            : (facility['whyItMattersEn'] ?? '') as String;
        final status = isTelugu ? (facility['statusTe'] ?? facility['statusEn']) as String : facility['statusEn'] as String;
        final tag = facility['tag'] as String? ?? 'FREE';
        final icon = facility['icon'] as IconData? ?? Icons.business_rounded;
        final lat = facility['lat'] as double? ?? 13.6823;
        final lng = facility['lng'] as double? ?? 79.3514;
        final isTirumala = facility['isTirumala'] as bool? ?? true;

        final distKm = appState.getDistanceTo(PlaceCoordinates(lat: lat, lng: lng), isTirumala);
        final walkMins = (distKm * 12).round().clamp(2, 60);

        final List<Map<String, dynamic>> highlights = (facility['highlights'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [
          {
            'title': isTelugu ? '100% ఉచిత సేవ' : '100% Free TTD',
            'sub': isTelugu ? 'ఎలాంటి రుసుము లేదు' : 'Zero fee for lockers & deposit',
            'icon': Icons.verified_user_rounded,
          },
          {
            'title': isTelugu ? 'ఆధార్ తప్పనిసరి' : 'Aadhaar Required',
            'sub': isTelugu ? 'అసలు ఐడీ కార్డు వెంట ఉండాలి' : 'Mandatory original ID for receipt',
            'icon': Icons.badge_outlined,
          },
          {
            'title': isTelugu ? '24/7 భద్రత' : '24/7 Security',
            'sub': isTelugu ? 'టీటీడీ విజిలెన్స్ పర్యవేక్షణ' : 'Armed TTD vigilance & CCTV coverage',
            'icon': Icons.security_rounded,
          },
          {
            'title': isTelugu ? 'కంప్యూటరీకృత టోకెన్' : 'Electronic Token',
            'sub': isTelugu ? 'సురక్షిత బార్‌కోడ్ రశీదు' : 'Computerized barcode receipt',
            'icon': Icons.qr_code_rounded,
          },
        ];

        final List<Map<String, dynamic>> subLocations = (facility['subLocations'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [
          {'name': 'PAC-1 (Madhava Nilayam)', 'walk': '4 min walk', 'status': 'Open Now', 'lat': 13.6828, 'lng': 79.3508},
          {'name': 'PAC-2 (Nandakam Rest Hall)', 'walk': '5 min walk', 'status': 'Open Now', 'lat': 13.6815, 'lng': 79.3522},
          {'name': 'PAC-5 (Central Amenities)', 'walk': '7 min walk', 'status': 'Open Now', 'lat': 13.6840, 'lng': 79.3490},
          {'name': 'CRO Room Reservation Complex', 'walk': '3 min walk', 'status': 'Open Now', 'lat': 13.6830, 'lng': 79.3530},
          {'name': 'VQC-II Entry Pouch Counter', 'walk': '2 min walk', 'status': 'Open Now', 'lat': 13.6838, 'lng': 79.3478},
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F5132)),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F5132),
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFF0F5132), size: 20),
                onPressed: () => _shareFacility(context, isTelugu),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO BANNER CARD (Image 5)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFFBEB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subtle watermark in background
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Opacity(
                          opacity: 0.12,
                          child: SrivariNamamIcon(size: 80, whiteColor: Colors.amber.shade200),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Center(
                                  child: Icon(icon, color: const Color(0xFFD97706), size: 26),
                                ),
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
                                            title,
                                            style: const TextStyle(
                                              fontFamily: 'Georgia',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const SrivariNamamIcon(size: 16),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            location,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${distKm.toStringAsFixed(1)} km • ${walkMins}m walk',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Description
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Badges Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildPillBadge(status, const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                              _buildPillBadge(
                                isTelugu ? 'ఈరోజే ధ్రువీకరించబడింది' : 'Verified Today',
                                const Color(0xFFE0F2FE),
                                const Color(0xFF0369A1),
                              ),
                              _buildPillBadge(tag, const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                              _buildPillBadge(
                                isTelugu ? 'ఆధార్ కార్డు తప్పనిసరి' : 'Aadhaar Card Required',
                                const Color(0xFFFEE2E2),
                                const Color(0xFF991B1B),
                                icon: Icons.description_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. EXPLAINABLE RATIONALE CALLOUT (Image 5)
                if (whyItMatters.isNotEmpty) ...[
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
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isTelugu
                                    ? 'క్యూ ప్రవేశానికి ముందు ఇది ఎందుకు తప్పనిసరి'
                                    : 'WHY THIS IS REQUIRED BEFORE QUEUE ENTRY',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          whyItMatters,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF78350F),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 3. SAARTHI DEVOTIONAL GUIDANCE (Image 5)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF15803D)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTelugu ? 'సారథి ఆధ్యాత్మిక మార్గదర్శనం' : 'SAARTHI GUIDANCE',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF15803D),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isTelugu
                                  ? '"లౌకిక లగేజీ మరియు డిజిటల్ పరధ్యానాలను పక్కన పెట్టి, సంపూర్ణ శరణాగతితో శ్రీవారిని దర్శించుకోండి."'
                                  : '"In calm faith, seek Srivari. Relieve yourself of worldly luggage and digital distractions to embrace pure devotion."',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF166534),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. KEY FACILITIES & FEATURES (4 Pillars)
                Text(
                  isTelugu ? 'ముఖ్య సదుపాయాలు & విశిష్టతలు' : 'Key Facilities & Features',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: highlights.map((h) {
                    final hIcon = h['icon'] as IconData? ?? Icons.check_circle_outline_rounded;
                    final hTitle = h['title'] as String;
                    final hSub = h['sub'] as String;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(hIcon, size: 20, color: const Color(0xFF0F5132)),
                          const SizedBox(height: 6),
                          Text(
                            hTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            hSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 5. TRANSIT COUNTERS & SUB-LOCATIONS
                Text(
                  isTelugu ? 'సమీప కౌంటర్లు & కేంద్రాలు' : 'Nearby Service Counters & Locations',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                ...subLocations.map((loc) {
                  final name = loc['name'] as String;
                  final walk = loc['walk'] as String;
                  final locStatus = loc['status'] as String;
                  final subLat = loc['lat'] as double? ?? lat;
                  final subLng = loc['lng'] as double? ?? lng;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, size: 18, color: Color(0xFF0F5132)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                              Row(
                                children: [
                                  Text(walk, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      locStatus,
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _launchMaps(subLat, subLng),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.navigation_rounded, size: 12, color: Color(0xFF0F5132)),
                                const SizedBox(width: 4),
                                Text(
                                  isTelugu ? 'దారి' : 'Directions',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F5132)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // 6. MAIN CTA NAVIGATION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchMaps(lat, lng),
                    icon: const Icon(Icons.directions_rounded, color: Colors.white, size: 18),
                    label: Text(
                      isTelugu ? 'గూగుల్ మ్యాప్స్‌లో దారి చూడండి' : 'Get Driving Directions',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5132),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPillBadge(String label, Color bg, Color text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
