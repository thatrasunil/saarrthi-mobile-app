class SpiritualInfo {
  final String? deity;
  final String? knownFor;
  final String? mantra;
  final List<String> devoteeTips;

  SpiritualInfo({
    this.deity,
    this.knownFor,
    this.mantra,
    this.devoteeTips = const [],
  });

  factory SpiritualInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SpiritualInfo();
    return SpiritualInfo(
      deity: (json['deity'] ?? json['god']) as String?,
      knownFor: json['knownFor'] as String?,
      mantra: json['mantra'] as String?,
      devoteeTips: (json['devoteeTips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class PlaceCoordinates {
  final double lat;
  final double lng;

  PlaceCoordinates({required this.lat, required this.lng});

  factory PlaceCoordinates.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PlaceCoordinates(lat: 13.6288, lng: 79.4192);
    return PlaceCoordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 13.6288,
      lng: (json['lng'] as num?)?.toDouble() ?? 79.4192,
    );
  }
}

class Place {
  final String id;
  final String name;
  final String? nameTe;
  final String category;
  final String location;
  final String? precinct;
  final double rating;
  final int reviewCount;
  final double distanceKms;
  final String? approxDuration;
  final String? shortIntro;
  final String? description;
  final String? descriptionTe;
  final String? history;
  final String? historyTe;
  final String? whyVisit;
  final String? openingTime;
  final String? closingTime;
  final String? bestTime;
  final String? dressCode;
  final String? image;
  final List<String> images;
  final bool isTirumala;
  final PlaceCoordinates coordinates;
  final SpiritualInfo? spiritualInfo;

  // Enriched fields from saarthiguide.in
  final String? entryFee;
  final String? duration;
  final Map<String, dynamic>? detailedFacilities;
  final Map<String, dynamic>? practicalInfo;
  final Map<String, dynamic>? significance;
  final Map<String, dynamic>? visitorTips;
  final Map<String, dynamic>? saarthiIntelligence;
  final Map<String, dynamic>? contentCreator;
  final Map<String, dynamic>? rituals;
  final String? travelByRTC;
  final String? travelByCar;
  final String? travelByBike;
  final String? approxRTCFare;
  final String? approxCarCost;
  final String? approxBikeCost;
  final List<String> tags;
  final List<String> nearbyIds;
  final List<String> recommendationReasons;

  Place({
    required this.id,
    required this.name,
    this.nameTe,
    required this.category,
    required this.location,
    this.precinct,
    this.rating = 4.8,
    this.reviewCount = 500,
    this.distanceKms = 0.0,
    this.approxDuration,
    this.shortIntro,
    this.description,
    this.descriptionTe,
    this.history,
    this.historyTe,
    this.whyVisit,
    this.openingTime,
    this.closingTime,
    this.bestTime,
    this.dressCode,
    this.image,
    this.images = const [],
    this.isTirumala = false,
    required this.coordinates,
    this.spiritualInfo,
    this.entryFee,
    this.duration,
    this.detailedFacilities,
    this.practicalInfo,
    this.significance,
    this.visitorTips,
    this.saarthiIntelligence,
    this.contentCreator,
    this.rituals,
    this.travelByRTC,
    this.travelByCar,
    this.travelByBike,
    this.approxRTCFare,
    this.approxCarCost,
    this.approxBikeCost,
    this.tags = const [],
    this.nearbyIds = const [],
    this.recommendationReasons = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final loc = (json['location'] as String? ?? json['precinct'] as String? ?? '').toLowerCase();
    final cat = (json['category'] as String? ?? '').toLowerCase();
    final id = json['id'] as String? ?? json['slug'] as String? ?? '';
    final isTirumalaPlace = loc.contains('tirumala') ||
        cat.contains('tirumala') ||
        id == 'venkateswara' ||
        id == 'bhu-varaha' ||
        id == 'swami-pushkarini' ||
        id == 'silathoranam' ||
        id == 'srivari-padalu-spot';

    // Parse image list
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imageList = rawImages.map((e) {
      final s = e.toString();
      return s.startsWith('/') ? 'https://www.saarthiguide.in$s' : s;
    }).toList();

    String? primaryImage = json['image'] as String?;
    if (primaryImage != null && primaryImage.startsWith('/')) {
      primaryImage = 'https://www.saarthiguide.in$primaryImage';
    } else if ((primaryImage == null || primaryImage.isEmpty) && imageList.isNotEmpty) {
      primaryImage = imageList.first;
    }

    // Extract nearby IDs from relationships
    final relationships = json['relationships'] as Map<String, dynamic>?;
    final nearbyRaw = relationships?['nearby'] as List<dynamic>? ?? [];

    // Extract recommendation reasons
    final recCtx = json['recommendationContext'] as Map<String, dynamic>?;
    final reasons = (recCtx?['recommendationReasons'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    final rawTags = json['tags'] as List<dynamic>? ?? [];
    final tagList = rawTags.map((e) => e.toString()).toList();

    return Place(
      id: id,
      name: json['name'] as String? ?? 'Sacred Temple',
      nameTe: (json['nameTe'] ?? json['teluguName']) as String?,
      category: json['category'] as String? ?? 'Spiritual',
      location: json['location'] as String? ?? json['precinct'] as String? ?? 'Tirupati',
      precinct: json['precinct'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 500,
      distanceKms: (json['distanceKms'] as num?)?.toDouble() ?? 0.0,
      approxDuration: (json['duration'] ?? json['approxDuration']) as String?,
      shortIntro: json['shortIntro'] as String? ??
          (json['contentCreator'] != null ? json['contentCreator']['summary30'] : null) ??
          json['description'] as String?,
      description: json['description'] as String?,
      descriptionTe: json['descriptionTe'] as String?,
      history: json['history'] as String?,
      historyTe: json['historyTe'] as String?,
      whyVisit: json['whyVisit'] as String?,
      openingTime: json['openingTime'] as String? ?? '6:00 AM',
      closingTime: json['closingTime'] as String? ?? '9:00 PM',
      bestTime: json['bestTime'] as String? ?? 'Early Morning & Evening',
      dressCode: (json['visitorTips'] != null ? json['visitorTips']['dressCode'] : null) ??
          json['dressCode'] as String? ??
          'Traditional Indian Attire',
      image: primaryImage,
      images: imageList,
      isTirumala: isTirumalaPlace,
      coordinates: PlaceCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>?),
      spiritualInfo: SpiritualInfo.fromJson(json['spiritualInfo'] as Map<String, dynamic>?),
      entryFee: json['entryFee'] as String?,
      duration: json['duration'] as String?,
      detailedFacilities: json['detailedFacilities'] as Map<String, dynamic>?,
      practicalInfo: json['practicalInfo'] as Map<String, dynamic>?,
      significance: json['significance'] as Map<String, dynamic>?,
      visitorTips: json['visitorTips'] as Map<String, dynamic>?,
      saarthiIntelligence: json['saarthiIntelligence'] as Map<String, dynamic>?,
      contentCreator: json['contentCreator'] as Map<String, dynamic>?,
      rituals: json['rituals'] as Map<String, dynamic>?,
      travelByRTC: json['travelByRTC'] as String?,
      travelByCar: json['travelByCar'] as String?,
      travelByBike: json['travelByBike'] as String?,
      approxRTCFare: json['approxRTCFare'] as String?,
      approxCarCost: json['approxCarCost'] as String?,
      approxBikeCost: json['approxBikeCost'] as String?,
      tags: tagList,
      nearbyIds: nearbyRaw.map((e) => e.toString()).toList(),
      recommendationReasons: reasons,
    );
  }
}
