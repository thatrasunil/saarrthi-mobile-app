import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../core/app_state.dart';
import '../../data/local_repository.dart';
import '../../models/place.dart';
import '../widgets/location_picker_modal.dart';
import '../widgets/saarthi_image.dart';
import 'place_detail_screen.dart';
import 'notifications_screen.dart';
import '../widgets/skeleton_shimmer.dart';
import '../widgets/saarthi_logo.dart';

class ExploreScreen extends StatefulWidget {
  final LocalRepository localRepo;

  const ExploreScreen({super.key, required this.localRepo});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _refreshPlaces() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isTelugu = appState.isTelugu;
        final allPlaces = widget.localRepo.places;
        final unreadAlerts = appState.activeAlertsCount;

        // Categories with translations and dynamic counts
        final filterDefs = [
          {'key': 'All', 'labelEn': 'All', 'labelTe': 'అన్నీ'},
          {'key': 'Nearby', 'labelEn': 'Nearby', 'labelTe': 'సమీపంలో'},
          {'key': 'Saved', 'labelEn': 'Saved', 'labelTe': 'దాచినవి'},
          {'key': 'Spiritual', 'labelEn': 'Spiritual', 'labelTe': 'ఆధ్యాత్మికం'},
          {'key': 'Nature', 'labelEn': 'Nature', 'labelTe': 'ప్రకృతి'},
          {'key': 'Theertham', 'labelEn': 'Theerthams', 'labelTe': 'తీర్థాలు'},
          {'key': 'Heritage', 'labelEn': 'Heritage', 'labelTe': 'చారిత్రకం'},
          {'key': 'Hidden', 'labelEn': 'Hidden Gems', 'labelTe': 'దాగి ఉన్నవి'},
        ];

        // Calculate counts
        bool matchesCategory(Place p, String key) {
          final cat = p.category.toLowerCase();
          if (key == 'All' || key == 'Nearby') return true;
          if (key == 'Saved') return appState.isPlaceSaved(p.id);
          if (key == 'Spiritual') {
            return cat.contains('temple') || cat.contains('spot') || cat.contains('kshethram') || cat.contains('spiritual');
          }
          if (key == 'Nature') {
            return cat.contains('nature') || cat.contains('water') || cat.contains('falls');
          }
          if (key == 'Theertham') {
            return cat.contains('theertham') || p.name.toLowerCase().contains('theertham') || p.name.toLowerCase().contains('pushkarini');
          }
          if (key == 'Heritage') {
            return cat.contains('historic') || cat.contains('heritage');
          }
          if (key == 'Culture') {
            return cat.contains('culture') || cat.contains('leisure') || cat.contains('park');
          }
          if (key == 'Hidden') {
            return cat.contains('theertham') || cat.contains('hidden') || p.tags.any((t) => t.toLowerCase().contains('hidden')) || (p.whyVisit?.toLowerCase().contains('peaceful') ?? false);
          }
          return cat.contains(key.toLowerCase());
        }

        int countFor(String key) {
          if (key == 'All') return allPlaces.length;
          if (key == 'Saved') return appState.savedPlaceIds.length;
          if (key == 'Nearby') {
            return allPlaces.where((p) => appState.getDistanceTo(p.coordinates, p.isTirumala) <= 15.0).length;
          }
          return allPlaces.where((p) => matchesCategory(p, key)).length;
        }

        // Filtering logic
        final isAlternative = _searchQuery.toLowerCase().contains('alternative') || _searchQuery.toLowerCase().contains('crowd');
        final isTirupatiFilter = _searchQuery.toLowerCase() == 'tirupati';

        var filtered = allPlaces.where((place) {
          if (isAlternative && place.id == 'venkateswara') return false;
          if (isTirupatiFilter && place.isTirumala) return false;

          final q = _searchQuery.toLowerCase().trim();
          final matchesSearch = q.isEmpty ||
              place.name.toLowerCase().contains(q) ||
              place.location.toLowerCase().contains(q) ||
              place.category.toLowerCase().contains(q) ||
              (place.spiritualInfo?.deity?.toLowerCase().contains(q) ?? false) ||
              (place.whyVisit?.toLowerCase().contains(q) ?? false);

          if (!matchesSearch) return false;
          return matchesCategory(place, _selectedCategory);
        }).toList();

        // Sort by computed distance
        filtered.sort((a, b) {
          final distA = appState.getDistanceTo(a.coordinates, a.isTirumala);
          final distB = appState.getDistanceTo(b.coordinates, b.isTirumala);
          return distA.compareTo(distB);
        });

        final nearbyCurated = allPlaces.where((p) => appState.getDistanceTo(p.coordinates, p.isTirumala) <= 25.0).toList()
          ..sort((a, b) => appState.getDistanceTo(a.coordinates, a.isTirumala).compareTo(appState.getDistanceTo(b.coordinates, b.isTirumala)));

        final hiddenGemsCurated = allPlaces.where((p) => p.category.toLowerCase().contains('theertham') || (p.whyVisit?.toLowerCase().contains('peaceful') ?? false) || p.name.contains('Japali')).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          // 1. APP BAR WITH SRIVARI NAMAM & LOCATION PICKER (Web Parity)
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F5132)),
              onPressed: () => Navigator.maybePop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                const SaarthiLogo(size: 26),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isTelugu ? 'దర్శనీయ ప్రదేశాలు' : 'Explore Sacred Sites',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // Notification Bell
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

              // Starting Location Pill
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => LocationPickerModal.show(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF0F5132)),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 75),
                          child: Text(
                            appState.selectedLocation,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 11.5,
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
              ),
            ],
          ),

          // SCROLLABLE BODY
          body: _isLoading
              ? const ExploreScreenSkeleton()
              : RefreshIndicator(
                  onRefresh: _refreshPlaces,
                  color: AppTheme.emerald,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
            children: [
              // 2. SEARCH INPUT BAR (Web Parity)
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
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: isTelugu
                        ? 'ఆలయాలు, జలపాతాలు, ప్రసాదం, చరిత్ర శోధించండి...'
                        : 'Search places, temples, waterfalls, history...',
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

              // 3. HORIZONTAL CATEGORY FILTER CHIPS WITH ITEM COUNTS (Web Parity)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterDefs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final f = filterDefs[idx];
                    final key = f['key']!;
                    final label = isTelugu ? f['labelTe']! : f['labelEn']!;
                    final isSelected = _selectedCategory == key;
                    final count = countFor(key);

                    return ChoiceChip(
                      label: Text('$label ($count)'),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = key),
                      selectedColor: const Color(0xFF0F5132),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF0F5132) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // 4. INTELLIGENCE CROWD WARNING BANNERS (Web Parity)
              if (isAlternative) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTelugu ? 'శ్రీవారి ఆలయం వద్ద అధిక రద్దీ' : 'Heavy Crowds at Srivari Temple',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTelugu
                                  ? 'శ్రీవారి ఆలయంలో ప్రస్తుతం దర్శన సమయం అధికంగా ఉంది. మీ సమయాన్ని సద్వినియోగం చేసుకోవడానికి సమీపంలోని ఈ ప్రశాంత పుణ్యక్షేత్రాలను దర్శించండి.'
                                  : 'Srivari Venkateswara Swamy Temple is currently experiencing high wait times. We recommend exploring these serene alternative shrines first.',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (isTirupatiFilter) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.explore_rounded, size: 16, color: Color(0xFFD97706)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTelugu ? 'తిరుపతి నగరంలోని ఆకర్షణలు' : 'Attractions in Tirupati City',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTelugu
                                  ? 'కొండపైకి వెళ్లేముందు తిరుపతి నగరంలోని ప్రసిద్ధ ఆలయాలు, సంగ్రహాలయాలు మరియు పురాతన క్షేత్రాలను సందర్శించండి.'
                                  : 'Tirupati foothill city offers renowned ancient shrines, sacred pushkarinis, and spiritual museums before heading uphill.',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 5. CURATED HORIZONTAL CAROUSELS (Only shown in 'All' view without active text search)
              if (_selectedCategory == 'All' && _searchQuery.isEmpty) ...[
                // Curated Nearby Carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          isTelugu ? 'సమీపంలోని క్షేత్రాలు' : 'Nearby',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.near_me_rounded, size: 16, color: Color(0xFF0F5132)),
                      ],
                    ),
                    Text(
                      'from ${appState.selectedLocation}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: nearbyCurated.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final place = nearbyCurated[idx];
                      return _buildCompactCarouselCard(place, appState, isTelugu);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Curated Hidden Gems Carousel
                Row(
                  children: [
                    Text(
                      isTelugu ? 'దాగి ఉన్న పవిత్ర క్షేత్రాలు' : 'Hidden Gems',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFD97706)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hiddenGemsCurated.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final place = hiddenGemsCurated[idx];
                      return _buildCompactCarouselCard(place, appState, isTelugu, isHiddenGem: true);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 6. MAIN SECTION HEADER WITH COUNTER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'All'
                        ? (isTelugu ? 'అన్ని దర్శనీయ స్థలాలు' : 'All Experiences')
                        : (isTelugu ? 'ఫలితాలు' : '$_selectedCategory Places'),
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filtered.length} ${filtered.length == 1 ? (isTelugu ? 'ప్రదేశం' : 'place') : (isTelugu ? 'ప్రదేశాలు' : 'places')}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 7. PLACE CARDS LIST
              if (filtered.isEmpty)
                _buildEmptyState(isTelugu)
              else
                ...filtered.map((place) => _buildExploreCard(place, appState, isTelugu)),
            ],
          ),
        ),
      );
      },
    );
  }

  // Compact Card for Horizontal Carousels (Web Parity)
  Widget _buildCompactCarouselCard(Place place, AppState appState, bool isTelugu, {bool isHiddenGem = false}) {
    final dist = appState.getDistanceTo(place.coordinates, place.isTirumala);
    final travelTime = appState.formatTravelTime(dist, place.isTirumala);
    final reason = place.whyVisit ?? place.shortIntro ?? place.description ?? '';

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
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
            // Image with Category / Hidden Gem tag and distance badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 95,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SaarthiImage(
                      url: place.image,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.temple_hindu_rounded,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isHiddenGem ? const Color(0xFF4F46E5) : const Color(0xFF0F172A).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isHiddenGem ? 'HIDDEN GEM' : place.category.toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 9, color: Color(0xFF0F5132)),
                            const SizedBox(width: 2),
                            Text(
                              '${dist.toStringAsFixed(1)} km • $travelTime',
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        isTelugu ? 'వివరాలు →' : 'Explore →',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isHiddenGem ? const Color(0xFF4F46E5) : const Color(0xFF0F5132),
                        ),
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

  // Full-width Explore Card (Web Parity)
  Widget _buildExploreCard(Place place, AppState appState, bool isTelugu) {
    final reason = place.whyVisit ?? place.shortIntro ?? place.description ?? '';
    final dynamicDist = appState.getDistanceTo(place.coordinates, place.isTirumala);
    final travelTime = appState.formatTravelTime(dynamicDist, place.isTirumala);
    final isSaved = appState.isPlaceSaved(place.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              AppTransitions.smoothSlideRoute(
                PlaceDetailScreen(place: place, localRepo: widget.localRepo),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with Dual Floating Badges
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SaarthiImage(
                      url: place.image,
                      fit: BoxFit.cover,
                      fallbackIcon: place.isTirumala ? Icons.temple_hindu_rounded : Icons.account_balance_rounded,
                    ),

                    // Top-Left Dual Badges: Precinct (Hill vs Foot) + Category
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: place.isTirumala ? const Color(0xFF0F5132) : const Color(0xFFE9801D),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              place.isTirumala
                                  ? (isTelugu ? 'తిరుమల కొండ' : 'Tirumala Hill')
                                  : (isTelugu ? 'తిరుపతి' : 'Tirupati'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              place.category.toUpperCase(),
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top-Right Bookmark / Heart Button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () => appState.toggleSavePlace(place.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 18,
                            color: isSaved ? const Color(0xFFD97706) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),

                    // Bottom-Left Proximity Pill
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF0F5132)),
                            const SizedBox(width: 3),
                            Text(
                              '${dynamicDist.toStringAsFixed(1)} km • $travelTime',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F5132),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 3),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.location,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),

                    // Explainable Rationale Callout
                    if (reason.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                reason,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF854D0E),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (place.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: place.tags.take(3).map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        )).toList(),
                      ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            place.category,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isTelugu ? 'పూర్తి వివరాలు' : 'Explore Details',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F5132),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF0F5132)),
                          ],
                        ),
                      ],
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

  Widget _buildEmptyState(bool isTelugu) {
    if (_selectedCategory == 'Saved') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_border_rounded, size: 28, color: Color(0xFFD97706)),
              ),
              const SizedBox(height: 14),
              Text(
                isTelugu ? 'ఇంకా ఏ క్షేత్రాలు దాచలేదు' : 'No Saved Places Yet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                isTelugu
                    ? 'ఏదైనా ఆలయం కార్డుపై బుక్‌మార్క్ చిహ్నాన్ని నొక్కితే ఇక్కడ కనిపిస్తుంది.'
                    : 'Tap the bookmark icon on any temple to save it here for quick offline access.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              isTelugu ? 'ఫలితాలు కనిపించలేదు' : 'No places found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              isTelugu ? 'దయచేసి వేరే పదాలతో శోధించండి.' : 'Try adjusting your search query or category filter.',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
