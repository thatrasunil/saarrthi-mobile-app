import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../models/place.dart';
import '../models/festival.dart';
import '../models/gita_shloka.dart';

class LocalRepository {
  List<Place> _places = [];
  List<Festival> _festivals = [];
  List<GitaShloka> _shlokas = [];
  Map<String, dynamic> _layouts = {};
  Map<String, dynamic> _liveStatus = {};
  Map<String, dynamic> _dailyCompanion = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<Place> get places => _places;
  List<Festival> get festivals => _festivals;
  List<GitaShloka> get shlokas => _shlokas;
  Map<String, dynamic> get liveStatus => _liveStatus;
  Map<String, dynamic> get dailyCompanion => _dailyCompanion;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Load Places
      final placesStr = await rootBundle.loadString('assets/data/places.json');
      final List<dynamic> placesJson = json.decode(placesStr);
      _places = placesJson.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();

      // 2. Load Festivals
      try {
        final festivalsStr = await rootBundle.loadString('assets/data/festivals.json');
        final List<dynamic> festivalsJson = json.decode(festivalsStr);
        _festivals = festivalsJson.map((e) => Festival.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}

      // 3. Load Shlokas
      try {
        final shlokasStr = await rootBundle.loadString('assets/data/gita_shlokas.json');
        final List<dynamic> shlokasJson = json.decode(shlokasStr);
        _shlokas = shlokasJson.map((e) => GitaShloka.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}

      // 4. Load Temple Layouts
      try {
        final layoutsStr = await rootBundle.loadString('assets/data/temple_layouts.json');
        _layouts = json.decode(layoutsStr) as Map<String, dynamic>;
      } catch (_) {}

      // 5. Load Live Status
      try {
        final statusStr = await rootBundle.loadString('assets/data/live_status.json');
        _liveStatus = json.decode(statusStr) as Map<String, dynamic>;
      } catch (_) {}

      // 6. Load Daily Companion
      try {
        final dailyStr = await rootBundle.loadString('assets/data/daily_companion.json');
        _dailyCompanion = json.decode(dailyStr) as Map<String, dynamic>;
      } catch (_) {}

      _isInitialized = true;
    } catch (e) {
      // Graceful fallback if asset loading encountered issue in tests
      _isInitialized = true;
    }
  }

  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Place> getTirumalaPlaces() {
    return _places.where((p) => p.isTirumala).toList();
  }

  List<Place> getTirupatiPlaces() {
    return _places.where((p) => !p.isTirumala).toList();
  }

  List<Place> getHiddenGems() {
    return _places.where((p) =>
      p.category.toLowerCase().contains('hidden') ||
      p.tags.any((t) => t.toLowerCase().contains('hidden') || t.toLowerCase().contains('gem'))
    ).toList();
  }

  List<Place> getNearbyPlaces(double userLat, double userLng, {int limit = 10}) {
    final listWithDist = _places.map((p) {
      final d = calculateDrivingDistance(userLat, userLng, p.coordinates.lat, p.coordinates.lng, isTirumalaDestination: p.isTirumala);
      return MapEntry(p, d);
    }).toList();

    listWithDist.sort((a, b) => a.value.compareTo(b.value));
    return listWithDist.take(limit).map((e) => e.key).toList();
  }

  GitaShloka getDailyShloka() {
    if (_shlokas.isEmpty) {
      return GitaShloka(
        id: 'gita-2-47',
        chapter: 2,
        verse: 47,
        referenceEn: 'Bhagavad Gita • Chapter 2, Verse 47',
        referenceTe: 'శ్రీమద్భగవద్గీత • సాంఖ్య యోగం (2.47)',
        themeEn: 'Selfless Action & Peace',
        themeTe: 'నిష్కామ కర్మ',
        shlokaSanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन |',
        shlokaTelugu: 'కర్మణ్యేవాధికారస్తే మా ఫలేషు కదాచన |',
        meaningEn: 'You have a right to perform duty, not to the fruits.',
        meaningTe: 'కర్మలను ఆచరించుట యందే నీకు అధికారము కలదు.',
        pilgrimReflectionEn: 'Focus on your sacred darshan with peaceful surrender.',
        pilgrimReflectionTe: 'దర్శన క్యూలో సహనంతో, ప్రశాంత మనస్సుతో స్వామిని స్మరించండి.',
      );
    }
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _shlokas[dayOfYear % _shlokas.length];
  }

  Map<String, dynamic>? getTempleLayout(String placeId) {
    return _layouts[placeId] as Map<String, dynamic>?;
  }

  static const double alipiriGateLat = 13.647051;
  static const double alipiriGateLng = 79.405856;
  static const double tirumalaCenterLat = 13.6833;
  static const double tirumalaCenterLng = 79.3473;

  /// Determines if GPS coordinates are situated atop Tirumala hill plateau
  static bool isCoordinateOnTirumalaHill(double lat, double lng) {
    if (lat < 13.655 || lat > 13.735 || lng < 79.300 || lng > 79.385) {
      return false;
    }
    return calculateHaversineDistance(lat, lng, tirumalaCenterLat, tirumalaCenterLng) <= 7.5;
  }

  /// Calculates raw straight-line Haversine distance in kilometers
  static double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Accurate dynamic driving distance calculation
  /// Incorporates 4 topographical travel cases:
  /// 1. Hill to Hill (Local mountain roads)
  /// 2. Plains to Hill (Plains + 18.5 km Up-Ghat road + Local hill)
  /// 3. Hill to Plains (Local hill + 19.5 km Down-Ghat road + Plains)
  /// 4. Plains to Plains (City road grid curvature)
  static double calculateDrivingDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    bool isTirumalaDestination = false,
  }) {
    final rawDist = calculateHaversineDistance(lat1, lon1, lat2, lon2);
    if (rawDist <= 0.01) return 0.0;

    final isOriginOnHill = isCoordinateOnTirumalaHill(lat1, lon1);
    final isDestOnHill = isCoordinateOnTirumalaHill(lat2, lon2) ||
        (isTirumalaDestination && lat2 >= 13.655 && lon2 <= 79.385);

    // CASE 1: Both Origin and Destination on Tirumala Hill
    if (isOriginOnHill && isDestOnHill) {
      final factor = rawDist < 0.5 ? 1.15 : (rawDist < 1.5 ? 1.30 : 1.45);
      final dist = rawDist * factor;
      return double.parse((dist < 1.0 ? math.max(0.1, dist) : dist).toStringAsFixed(1));
    }

    // CASE 2: Origin in Plains -> Destination on Tirumala Hill (Up-Ghat)
    if (!isOriginOnHill && isDestOnHill) {
      final rawAlipiri = calculateHaversineDistance(lat1, lon1, alipiriGateLat, alipiriGateLng);
      final distToAlipiri = rawAlipiri < 0.4 ? 0.0 : rawAlipiri * (rawAlipiri < 5.0 ? 1.25 : 1.15);
      const ghatRoadKm = 18.5; // Up-Ghat road distance
      final localHillRaw = calculateHaversineDistance(tirumalaCenterLat, tirumalaCenterLng, lat2, lon2);
      final localHillDist = localHillRaw > 0.2 ? localHillRaw * (lat2 > 13.685 ? 1.5 : 1.25) : 0.0;
      return double.parse((distToAlipiri + ghatRoadKm + localHillDist).toStringAsFixed(1));
    }

    // CASE 3: Origin on Tirumala Hill -> Destination in Plains (Down-Ghat)
    if (isOriginOnHill && !isDestOnHill) {
      final localHillRaw = calculateHaversineDistance(lat1, lon1, tirumalaCenterLat, tirumalaCenterLng);
      final localHillDist = localHillRaw > 0.2 ? localHillRaw * (lat1 > 13.685 ? 1.5 : 1.25) : 0.0;
      const ghatRoadKm = 19.5; // Down-Ghat road distance
      final rawAlipiri = calculateHaversineDistance(alipiriGateLat, alipiriGateLng, lat2, lon2);
      final distFromAlipiri = rawAlipiri < 0.4 ? 0.0 : rawAlipiri * (rawAlipiri < 5.0 ? 1.25 : 1.15);
      return double.parse((localHillDist + ghatRoadKm + distFromAlipiri).toStringAsFixed(1));
    }

    // CASE 4: Both Origin and Destination in Plains
    final factor = rawDist < 0.5 ? 1.15 : (rawDist < 3.0 ? 1.25 : 1.15);
    return double.parse((rawDist * factor).toStringAsFixed(1));
  }
}
