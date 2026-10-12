import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/app_state.dart';
import '../../core/transitions.dart';
import '../../data/local_repository.dart';
import '../../models/place.dart';
import '../widgets/offline_precinct_map.dart';
import '../widgets/saarthi_image.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;
  final LocalRepository localRepo;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.localRepo,
  });

  Future<void> _launchNavigation() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.coordinates.lat},${place.coordinates.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = localRepo.getTempleLayout(place.id);
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isTelugu = appState.isTelugu;
        final isSaved = appState.isPlaceSaved(place.id);
        final dynamicDist = appState.getDistanceTo(place.coordinates, place.isTirumala);
        final travelTime = appState.formatTravelTime(dynamicDist, place.isTirumala);

        // Resolve nearby places
        final nearbyPlaces = place.nearbyIds
            .map((id) => localRepo.getPlaceById(id))
            .where((p) => p != null)
            .cast<Place>()
            .toList();

        // If nearbyIds is empty, find geographically close places
        final displayNearby = nearbyPlaces.isNotEmpty
            ? nearbyPlaces
            : localRepo.places
                .where((p) => p.id != place.id)
                .where((p) => appState.getDistanceTo(p.coordinates, p.isTirumala) <= 10.0)
                .toList()
              ..sort((a, b) {
                final dA = LocalRepository.calculateHaversineDistance(
                    place.coordinates.lat, place.coordinates.lng, a.coordinates.lat, a.coordinates.lng);
                final dB = LocalRepository.calculateHaversineDistance(
                    place.coordinates.lat, place.coordinates.lng, b.coordinates.lat, b.coordinates.lng);
                return dA.compareTo(dB);
              });

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              // 1. Hero Image with Overlaid Controls
              _buildHeroSliver(context, isSaved, appState, isTelugu),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 2. Title & Location
                      _buildTitleSection(dynamicDist, appState, isTelugu),
                      const SizedBox(height: 14),

                      // 2.1 Sacred Mantra Card
                      _buildMantraCard(isTelugu),
                      const SizedBox(height: 14),

                      // 3. Quick Info Cards (Distance, Drive, Status, Entry)
                      _buildQuickInfoRow(dynamicDist, travelTime, isTelugu),
                      const SizedBox(height: 20),

                      // 4. Before You Go — Timings & Practical Info
                      _buildBeforeYouGo(isTelugu),
                      const SizedBox(height: 16),

                      // 4.1 Sacred Significance & Pilgrim Actions (saarthiguide.in parity)
                      if (place.significance != null && place.significance!.isNotEmpty) ...[
                        _buildSacredSignificance(isTelugu),
                        const SizedBox(height: 16),
                      ],

                      // 4.2 Visitor Rules & Guidelines (Dress, Phones, Footwear, Tickets)
                      if (place.visitorTips != null && place.visitorTips!.isNotEmpty) ...[
                        _buildVisitorRules(isTelugu),
                        const SizedBox(height: 16),
                      ],

                      // 4.3 Multi-Image Gallery
                      if (place.images.length > 1) ...[
                        _buildGallery(context),
                        const SizedBox(height: 16),
                      ],

                      // 4.4 Complete Transport & Commute Guide (Bus, Car, Bike)
                      if (place.travelByRTC != null || place.travelByCar != null || place.travelByBike != null) ...[
                        _buildTransportDetails(isTelugu),
                        const SizedBox(height: 16),
                      ],

                      // 4.5 Annual Festivals & Rituals Calendar (2026 dates)
                      if (place.rituals != null && (place.rituals!['annual'] as List<dynamic>?) != null && (place.rituals!['annual'] as List<dynamic>).isNotEmpty) ...[
                        _buildAnnualRituals(isTelugu),
                        const SizedBox(height: 16),
                      ],

                      // 5. Essential Facilities Grid
                      if (place.detailedFacilities != null && place.detailedFacilities!.isNotEmpty) ...[
                        _buildFacilitiesGrid(),
                        const SizedBox(height: 16),
                      ],

                      // 6. Offline Precinct Map
                      if (layout != null) ...[
                        OfflinePrecinctMap(layoutData: layout),
                        const SizedBox(height: 20),
                      ],

                      // 7. About This Place
                      if (place.description != null && place.description!.isNotEmpty) ...[
                        _buildSection(
                          title: isTelugu ? 'ఆలయ విశేషాలు' : 'About This Temple',
                          icon: Icons.info_outline_rounded,
                          content: (isTelugu && place.descriptionTe != null && place.descriptionTe!.isNotEmpty)
                              ? place.descriptionTe!
                              : place.description!,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 8. Why Visit (Explainable recommendation)
                      if (place.whyVisit != null && place.whyVisit!.isNotEmpty) ...[
                        _buildSection(
                          title: isTelugu ? 'దర్శన ప్రాశస్త్యం' : 'Why Visit This Sacred Site',
                          icon: Icons.auto_awesome_rounded,
                          content: place.whyVisit!,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 9. Devotee Tips
                      if (place.spiritualInfo != null && place.spiritualInfo!.devoteeTips.isNotEmpty) ...[
                        _buildDevoteeTips(),
                        const SizedBox(height: 16),
                      ],

                      // 10. Nearby Sacred Temples
                      if (displayNearby.isNotEmpty) ...[
                        _buildNearbySection(context, displayNearby.take(4).toList(), appState),
                        const SizedBox(height: 16),
                      ],

                      // 11. More Details & Heritage
                      if (place.history != null && place.history!.isNotEmpty) ...[
                        _buildExpandableSection(
                          title: isTelugu ? 'స్థల పురాణం & పవిత్ర గాథ' : 'Sthala Puranam & Sacred Legend',
                          icon: Icons.history_edu_rounded,
                          content: (isTelugu && place.historyTe != null && place.historyTe!.isNotEmpty)
                              ? place.historyTe!
                              : place.history!,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 12. Website link
                      _buildWebsiteLink(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _launchNavigation,
                    icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                    label: Text(
                      '${isTelugu ? 'దారి ప్రారంభించండి' : 'Start Navigation'}  $travelTime',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emerald,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildBottomAction(Icons.home_work_rounded, () {}),
                _buildBottomAction(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  () => appState.toggleSavePlace(place.id),
                  color: isSaved ? Colors.red : null,
                ),
                _buildBottomAction(Icons.share_rounded, () {}),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction(IconData icon, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        icon: Icon(icon, size: 22, color: color ?? const Color(0xFF64748B)),
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5F9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // 1. HERO IMAGE SLIVER
  Widget _buildHeroSliver(BuildContext context, bool isSaved, AppState appState, bool isTelugu) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: Icon(
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isSaved ? Colors.red : Colors.white,
              size: 20,
            ),
            onPressed: () => appState.toggleSavePlace(place.id),
          ),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (place.image != null && place.image!.isNotEmpty)
              SaarthiImage(url: place.image, fit: BoxFit.cover)
            else
              Container(
                color: place.isTirumala ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                child: Icon(
                  place.isTirumala ? Icons.temple_hindu_rounded : Icons.account_balance_rounded,
                  size: 80,
                  color: place.isTirumala ? AppTheme.saffron : AppTheme.emerald,
                ),
              ),
            // Bottom gradient for readability
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: SizedBox(height: 80),
              ),
            ),
            // Rating & badges (Precinct clarity)
            Positioned(
              bottom: 12, left: 16,
              child: Row(
                children: [
                  _buildBadge('★ ${place.rating}', const Color(0xFFFEF3C7), AppTheme.saffron),
                  if (place.category.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(place.category, Colors.white, AppTheme.emerald),
                  ],
                  const SizedBox(width: 6),
                  _buildBadge(
                    place.isTirumala
                        ? (isTelugu ? 'కొండపై (తిరుమల 3,200 అ.)' : 'Tirumala Hill (3,200 ft)')
                        : (isTelugu ? 'కొండ కింద (తిరుపతి)' : 'Tirupati Foot'),
                    place.isTirumala ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                    place.isTirumala ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  Widget _buildMantraCard(bool isTelugu) {
    final mantra = place.spiritualInfo?.mantra ?? (place.isTirumala ? 'Om Namo Venkateshaya' : '');
    final god = place.spiritualInfo?.deity ?? (place.isTirumala ? 'Lord Venkateswara' : '');
    if (mantra.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
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
              color: const Color(0xFFD97706),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.25),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🕉️',
                style: TextStyle(fontSize: 20),
              ),
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
                        isTelugu ? 'దివ్య మంత్రం & స్మరణ' : 'SACRED CHANTING MANTRA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (god.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• $god',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  mantra,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. TITLE & LOCATION
  Widget _buildTitleSection(double dist, AppState appState, bool isTelugu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'place-title-${place.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              place.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              place.isTirumala ? Icons.terrain_rounded : Icons.location_on_rounded,
              size: 14,
              color: place.isTirumala ? const Color(0xFFB45309) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${place.location} • ~${dist.toStringAsFixed(1)} km ${isTelugu ? 'దూరంలో' : 'from you'}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. QUICK INFO ROW
  Widget _buildQuickInfoRow(double dist, String travelTime, bool isTelugu) {
    final entryLabel = place.entryFee ?? (isTelugu ? 'ఉచితం' : 'Free');
    final shortEntry = entryLabel.length > 12 ? (isTelugu ? 'ఉచితం' : 'Free') : entryLabel;

    return Row(
      children: [
        _buildQuickCard(Icons.straighten_rounded, isTelugu ? 'దూరం' : 'DISTANCE', '${dist.toStringAsFixed(1)} km'),
        const SizedBox(width: 6),
        _buildQuickCard(Icons.directions_car_rounded, isTelugu ? 'ప్రయాణం' : 'DRIVE', travelTime, highlight: true),
        const SizedBox(width: 6),
        _buildQuickCard(Icons.circle, isTelugu ? 'స్థితి' : 'STATUS', isTelugu ? 'తెరిచి ఉంది' : 'Open', statusColor: AppTheme.emerald),
        const SizedBox(width: 6),
        _buildQuickCard(Icons.confirmation_number_outlined, isTelugu ? 'ప్రవేశం' : 'ENTRY', shortEntry),
      ],
    );
  }

  Widget _buildQuickCard(IconData icon, String label, String value, {bool highlight = false, Color? statusColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlight ? AppTheme.emerald.withValues(alpha: 0.3) : AppTheme.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: statusColor ?? (highlight ? AppTheme.emerald : const Color(0xFF64748B))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: highlight ? AppTheme.emerald : AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 4. BEFORE YOU GO
  Widget _buildBeforeYouGo(bool isTelugu) {
    final dressLabel = place.practicalInfo?['dressCode'] as String? ?? place.dressCode ?? (isTelugu ? 'సాంప్రదాయ దుస్తులు' : 'Traditional');
    final parkingLabel = place.practicalInfo?['parking'] as String? ?? (isTelugu ? 'అందుబాటులో ఉంది' : 'Available');
    final phonesLabel = place.practicalInfo?['phones'] as String? ?? (isTelugu ? 'వెలుపల అనుమతి' : 'Allowed Outside');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isTelugu ? 'దర్శనానికి వెళ్లే ముందు ముఖ్య సూచనలు' : 'Before you go',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderSubtle),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isTelugu ? 'నిబంధనలు' : 'Guidelines',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Crucial Pilgrim Advisory Banner for Hilltop / Sacred Precinct
        if (place.isTirumala) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFFB45309), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'ముఖ్య గమనిక: టీటీడీ నిబంధనలు' : 'Crucial: Official TTD Temple Guidelines',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isTelugu
                            ? '• భద్రతా గేట్లు/క్యూ లైన్లలోకి మొబైల్స్ & కెమెరాలు నిషేధం (పీఏసీ ఉచిత లాకర్లలో భద్రపరచండి).\n• పురుషులకు ధోవతి/కుర్తా, మహిళలకు చీర/చుడీదార్ తప్పనిసరి.\n• మాడ వీధుల్లోకి చెప్పులు అనుమతించబడవు (ఉచిత చెప్పుల కౌంటర్లు వాడండి).'
                            : '• Strictly no phones/cameras beyond security. Deposit at free PAC lockers.\n• Mandatory traditional dress code for sanctum entry.\n• Footwear not allowed on mada streets (free counters available).',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Timings card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.emerald),
                  const SizedBox(width: 6),
                  Text(
                    isTelugu ? 'సమయాలు & ప్రవేశ వేళలు' : 'TIMINGS & SCHEDULE',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.emerald, letterSpacing: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${place.openingTime} – ${place.closingTime}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Practical info chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildInfoChip(Icons.checkroom_rounded, isTelugu ? 'వస్త్రధారణ' : 'Dress Code', dressLabel),
            _buildInfoChip(Icons.local_parking_rounded, isTelugu ? 'పార్కింగ్' : 'Parking', parkingLabel),
            _buildInfoChip(Icons.phone_android_rounded, isTelugu ? 'మొబైల్స్' : 'Phones', phonesLabel),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppTheme.emerald),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // 5. FACILITIES GRID
  Widget _buildFacilitiesGrid() {
    final facilities = place.detailedFacilities!;
    final items = <MapEntry<String, Map<String, dynamic>>>[];

    for (final entry in facilities.entries) {
      if (entry.value is Map<String, dynamic>) {
        final val = entry.value as Map<String, dynamic>;
        if (val['available'] == true) {
          items.add(MapEntry(entry.key, val));
        }
      }
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Essential Facilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((e) => _buildFacilityItem(e.key, e.value)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String key, Map<String, dynamic> data) {
    final icons = {
      'parking': Icons.local_parking_rounded,
      'washrooms': Icons.wc_rounded,
      'drinkingWater': Icons.water_drop_rounded,
      'footwearCounter': Icons.do_not_step_rounded,
      'prasadam': Icons.restaurant_rounded,
      'lockers': Icons.lock_outline_rounded,
    };
    final labels = {
      'parking': 'Parking',
      'washrooms': 'Restrooms',
      'drinkingWater': 'RO Water',
      'footwearCounter': 'Footwear',
      'prasadam': 'Prasadam',
      'lockers': 'Lockers',
    };
    final subLabel = data['distance'] as String? ?? data['cost'] as String? ?? '';

    return SizedBox(
      width: 85,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icons[key] ?? Icons.check_circle_outline_rounded, size: 22, color: AppTheme.emerald),
          ),
          const SizedBox(height: 4),
          Text(
            labels[key] ?? _formatKey(key),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (subLabel.isNotEmpty)
            Text(
              subLabel,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}').trim();
  }

  // 9. DEVOTEE TIPS
  Widget _buildDevoteeTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: AppTheme.emerald, size: 18),
              SizedBox(width: 8),
              Text('Devotee Tips & Guidance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ...place.spiritualInfo!.devoteeTips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 10. NEARBY SACRED TEMPLES
  Widget _buildNearbySection(BuildContext context, List<Place> nearby, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nearby Sacred Temples', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text('View All →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.emerald)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: nearby.map((p) => _buildNearbyCard(context, p, appState)).toList(),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(BuildContext context, Place nearbyPlace, AppState appState) {
    final dist = LocalRepository.calculateHaversineDistance(
      place.coordinates.lat, place.coordinates.lng,
      nearbyPlace.coordinates.lat, nearbyPlace.coordinates.lng,
    );
    final distStr = dist < 1.0 ? '${(dist * 1000).toInt()} m' : '${dist.toStringAsFixed(1)} km';
    final driveMin = (dist / 0.5).ceil(); // ~30km/h avg

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppTransitions.smoothSlideRoute(
          PlaceDetailScreen(place: nearbyPlace, localRepo: localRepo),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox.expand(
                      child: SaarthiImage(
                        url: nearbyPlace.image,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.temple_hindu_rounded,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$driveMin mins',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nearbyPlace.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF64748B)),
                      const SizedBox(width: 2),
                      Text(
                        '$distStr away',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 11. EXPANDABLE SECTION
  Widget _buildExpandableSection({required String title, required IconData icon, required String content}) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      leading: Icon(icon, color: AppTheme.emerald, size: 18),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      children: [
        Text(content, style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textPrimary)),
      ],
    );
  }

  // 12. WEBSITE LINK
  Widget _buildWebsiteLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          final uri = Uri.parse('https://www.saarthiguide.in/place/${place.id}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.open_in_new_rounded, size: 14),
        label: const Text('View on saarthiguide.in', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // GENERIC SECTION CARD
  Widget _buildSection({required String title, required IconData icon, required String content}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.emerald, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  // 4.1 SACRED SIGNIFICANCE & PILGRIM ACTIONS
  Widget _buildSacredSignificance(bool isTelugu) {
    final sig = place.significance!;
    final whyVisit = (isTelugu ? sig['whyVisitTe'] : sig['whyVisitEn']) as String? ?? place.whyVisit ?? '';
    final actions = ((isTelugu ? sig['actionsTe'] : sig['actionsEn']) as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final culturalMeaning = (isTelugu ? sig['culturalMeaningTe'] : sig['culturalMeaningEn']) as String? ?? '';
    final saarthiTip = (isTelugu ? sig['saarthiTipTe'] : sig['saarthiTipEn']) as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.temple_hindu_rounded, size: 18, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTelugu ? 'పవిత్ర ప్రాముఖ్యత & భక్తుల నియమావళి' : 'Sacred Significance & Rituals',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          if (whyVisit.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              whyVisit,
              style: const TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
            ),
          ],

          // Ritual Actions Checklist
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              isTelugu ? 'ఆలయ సందర్శనలో ఆచరించాల్సిన విధులు:' : 'Mandated Pilgrim Rituals:',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
            ),
            const SizedBox(height: 8),
            ...actions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Cultural Meaning
          if (culturalMeaning.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        isTelugu ? 'పురాణ నేపథ్యం' : 'Puranic & Cultural Lore',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    culturalMeaning,
                    style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ],

          // Saarthi Devotional Tip
          if (saarthiTip.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTelugu ? 'సారథి సూచన' : 'Saarthi Pilgrim Tip',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          saarthiTip,
                          style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4.2 VISITOR RULES & GUIDELINES (Visual Scannable Badges)
  Widget _buildVisitorRules(bool isTelugu) {
    final tips = place.visitorTips!;
    final dressCode = tips['dressCode'] as String? ?? place.dressCode;
    final footwearRule = tips['footwearRule'] as String?;
    final photoRule = tips['photoRule'] as String?;
    final entryRule = tips['entryRule'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              const Icon(Icons.policy_rounded, size: 18, color: Color(0xFF0F5132)),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'దర్శన నిబంధనలు (ఒక్క చూపులో)' : 'Visitor Rules (At a Glance)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Visual Rule Badges Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (photoRule != null)
                _buildVisualRuleBadge(Icons.no_cell_rounded, isTelugu ? 'ఫోన్లు నిషేధం' : 'No Mobiles', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
              if (dressCode != null)
                _buildVisualRuleBadge(Icons.checkroom_rounded, isTelugu ? 'సంప్రదాయ వస్త్రధారణ' : 'Traditional Wear', const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
              if (footwearRule != null)
                _buildVisualRuleBadge(Icons.do_not_step_rounded, isTelugu ? 'ఉచిత చెప్పుల కౌంటర్' : 'Free Footwear Stand', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
              if (entryRule != null)
                _buildVisualRuleBadge(Icons.badge_rounded, isTelugu ? 'అసలు ID తప్పనిసరి' : 'Original ID Proof', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
            ],
          ),
          const SizedBox(height: 12),

          // Brief text details
          if (dressCode != null && dressCode.isNotEmpty)
            _buildRuleRow(Icons.checkroom_rounded, isTelugu ? 'వస్త్రధారణ నియమావళి' : 'Dress Code Policy', dressCode, const Color(0xFF7C3AED)),
          if (photoRule != null && photoRule.isNotEmpty)
            _buildRuleRow(Icons.no_photography_rounded, isTelugu ? 'మొబైల్స్ & కెమెరాలు' : 'Phones & Smartwatches', photoRule, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _buildVisualRuleBadge(IconData icon, String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String title, String desc, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: iconColor)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF475569))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4.3 MULTI-IMAGE GALLERY
  Widget _buildGallery(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Temple Photo Gallery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: place.images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final imgUrl = place.images[idx];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 150,
                  child: SaarthiImage(
                    url: imgUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.image_rounded,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4.4 COMPLETE TRANSPORT & COMMUTE GUIDE
  Widget _buildTransportDetails(bool isTelugu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_transit_filled_rounded, size: 18, color: Color(0xFF0F5132)),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'రవాణా సౌకర్యాలు & ఛార్జీలు' : 'How To Reach & Commute Guide',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (place.travelByRTC != null && place.travelByRTC!.isNotEmpty)
            _buildTransportItem(
              icon: Icons.directions_bus_rounded,
              title: isTelugu ? 'APSRTC బస్సు సర్వీస్' : 'APSRTC Bus Service',
              desc: place.travelByRTC!,
              fare: place.approxRTCFare,
              color: const Color(0xFF0F5132),
            ),
          if (place.travelByCar != null && place.travelByCar!.isNotEmpty)
            _buildTransportItem(
              icon: Icons.directions_car_rounded,
              title: isTelugu ? 'కారు / టాక్సీ' : 'Car & Local Taxi',
              desc: place.travelByCar!,
              fare: place.approxCarCost,
              color: const Color(0xFF2563EB),
            ),
          if (place.travelByBike != null && place.travelByBike!.isNotEmpty)
            _buildTransportItem(
              icon: Icons.two_wheeler_rounded,
              title: isTelugu ? 'ద్విచక్ర వాహనం' : 'Two-Wheeler / Bike',
              desc: place.travelByBike!,
              fare: place.approxBikeCost,
              color: const Color(0xFFD97706),
            ),
        ],
      ),
    );
  }

  Widget _buildTransportItem({
    required IconData icon,
    required String title,
    required String desc,
    String? fare,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
                    if (fare != null && fare.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          fare,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF475569))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4.5 ANNUAL FESTIVALS & RITUALS (2026 CALENDAR)
  Widget _buildAnnualRituals(bool isTelugu) {
    final list = (place.rituals!['annual'] as List<dynamic>).map((e) => e.toString()).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'వార్షిక ఉత్సవాలు & పర్వదినాలు (2026)' : 'Annual Festivals & Rituals (2026)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...list.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

