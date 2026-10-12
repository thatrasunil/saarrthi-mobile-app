import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_repository.dart';
import '../models/place.dart';
import '../models/alert_item.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal();

  String _language = 'en'; // 'en' or 'te'
  String _userName = '';
  String _selectedLocation = 'Tirupati';
  double _currentLat = 13.6288;
  double _currentLng = 79.4192;
  bool _hasSeenOnboarding = false;
  int _japaCount = 1;
  String _essentialsCategory = 'All';
  final Set<String> _savedPlaceIds = {};
  final Set<String> _checkedEssentials = {};
  List<AlertItem> _alerts = List.from(defaultAlerts);

  // Live Admin-Controlled Metrics
  String _sarvaDarshanWait = '2-3 Hours';
  String _specialEntryWait = '2-4 Hours';
  String _divyaDarshanWait = '1-1.5 Hours';
  String _crowdStatus = 'Moderate';
  int _crowdWaitMinutes = 45;
  String _ssdTokenStatus = 'Closed for Day';
  String _ssdNotice = 'SSD & DD Tokens are issuing directly in queue line';
  String _liveNotice = 'Wednesday: Visit ISKCON Lotus Temple first — morning rush clears after 1 PM.';
  int _temperatureCelsius = 27;
  String _weatherCondition = 'Pleasant';
  DateTime _lastSyncTime = DateTime.now();

  String get language => _language;
  bool get isTelugu => _language == 'te';
  String get userName => _userName;
  String get selectedLocation => _selectedLocation;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  int get japaCount => _japaCount;
  int get activeAlertsCount => _alerts.where((a) => !a.isRead).length;
  List<AlertItem> get alerts => _alerts;
  String get essentialsCategory => _essentialsCategory;
  Set<String> get savedPlaceIds => _savedPlaceIds;
  Set<String> get checkedEssentials => _checkedEssentials;

  // Live Admin Getters
  String get sarvaDarshanWait => _sarvaDarshanWait;
  String get specialEntryWait => _specialEntryWait;
  String get divyaDarshanWait => _divyaDarshanWait;
  String get crowdStatus => _crowdStatus;
  int get crowdWaitMinutes => _crowdWaitMinutes;
  String get ssdTokenStatus => _ssdTokenStatus;
  String get ssdNotice => _ssdNotice;
  String get liveNotice => _liveNotice;
  int get temperatureCelsius => _temperatureCelsius;
  String get weatherCondition => _weatherCondition;
  DateTime get lastSyncTime => _lastSyncTime;

  /// Updates state dynamically from Admin API payload (Web Admin Panel reflection)
  void updateFromAdminLiveStatus(Map<String, dynamic> data) {
    // 1. Crowd / Darshan Times
    if (data['crowd'] is Map) {
      final crowd = data['crowd'] as Map<String, dynamic>;
      if (crowd['sarvaDarshan'] != null) _sarvaDarshanWait = crowd['sarvaDarshan'].toString();
      if (crowd['specialEntry'] != null) _specialEntryWait = crowd['specialEntry'].toString();
      if (crowd['divyaDarshan'] != null) _divyaDarshanWait = crowd['divyaDarshan'].toString();
      if (crowd['status'] != null) _crowdStatus = crowd['status'].toString();
      if (crowd['waitMinutes'] is num) _crowdWaitMinutes = (crowd['waitMinutes'] as num).toInt();
      if (crowd['ssdTokens'] != null) _ssdTokenStatus = crowd['ssdTokens'].toString();
    }

    // Direct StatusDb schema mapping
    if (data['darshans'] is List) {
      final list = data['darshans'] as List;
      for (final item in list) {
        if (item is Map) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final wait = (item['waitTime'] ?? '').toString();
          if (wait.isNotEmpty) {
            if (name.contains('sarva')) _sarvaDarshanWait = wait;
            else if (name.contains('300') || name.contains('special')) _specialEntryWait = wait;
            else if (name.contains('divya') || name.contains('footpath')) _divyaDarshanWait = wait;
          }
        }
      }
    }

    if (data['crowdLevel'] != null) _crowdStatus = data['crowdLevel'].toString();
    if (data['ssdTokenStatus'] != null) _ssdTokenStatus = data['ssdTokenStatus'].toString();
    if (data['ssdNotice'] != null && data['ssdNotice'].toString().isNotEmpty) {
      _ssdNotice = data['ssdNotice'].toString();
    }
    if (data['notice'] != null && data['notice'].toString().isNotEmpty) {
      _liveNotice = data['notice'].toString();
    }

    // 2. Weather
    if (data['weather'] is Map) {
      final weather = data['weather'] as Map<String, dynamic>;
      if (weather['temperatureCelsius'] is num) {
        _temperatureCelsius = (weather['temperatureCelsius'] as num).toInt();
      }
      if (weather['condition'] != null) {
        _weatherCondition = weather['condition'].toString();
      }
    } else if (data['weather'] is String) {
      final weatherStr = data['weather'].toString();
      final match = RegExp(r'(\d+)°?C').firstMatch(weatherStr);
      if (match != null) {
        _temperatureCelsius = int.tryParse(match.group(1) ?? '27') ?? 27;
      }
      _weatherCondition = weatherStr;
    }

    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  static final List<AlertItem> defaultAlerts = [
    AlertItem(
      id: 'tirumala-darshan-advisory',
      titleEn: 'Tirumala Live Darshan & SSD Token Advisory',
      titleTe: 'తిరుమల లైవ్ దర్శనం & SSD టోకెన్ సమాచారం',
      descEn: 'Sarva Darshan queue moving at normal pace (2-3 hrs). Slotted SSD offline counters at Vishnu Nivasam & Srinivasam open daily at 05:00 AM. Original Aadhaar is mandatory.',
      descTe: 'సర్వదర్శనం సాధారణ వేగంతో (2-3 గంటలు) సాగుతోంది. విష్ణు నివాసం & శ్రీనివాసం వద్ద రోజూ ఉదయం 5 గంటలకు ఆఫ్ లైన్ SSD టోకెన్లు జారీ చేస్తారు. అసలు ఆధార్ కార్డు తప్పనిసరి.',
      category: 'High Priority',
      severity: 'Medium',
      cta: 'Open Queue',
      timeAgo: '15m ago',
      timeAgoTe: '15 నిమిషాల క్రితం',
      isRead: false,
    ),
    AlertItem(
      id: 'ghat-road-safety-rules',
      titleEn: 'Ghat Road Timings & Speed Monitoring',
      titleTe: 'ఘాట్ రోడ్డు వేళలు & ప్రయాణ నిబంధనలు',
      descEn: 'Up-Ghat road open 03:00 AM to 11:00 PM. Down-Ghat road closes at 12:00 midnight. Minimum journey time of 28 minutes is strictly enforced at toll gates to ensure safety.',
      descTe: 'పైకి వెళ్లే ఘాట్ రోడ్డు ఉదయం 3:00 నుండి రాత్రి 11:00 వరకు తెరిచి ఉంటుంది. టోల్ గేట్ల వద్ద కనీస ప్రయాణ సమయం 28 నిమిషాలు ఖచ్చితంగా పాటించాలి.',
      category: 'Advisory',
      severity: 'Low',
      cta: 'Open Maps',
      timeAgo: '1h ago',
      timeAgoTe: '1 గంట క్రితం',
      isRead: false,
    ),
    AlertItem(
      id: 'annaprasadam-amenities-alert',
      titleEn: 'Free Annaprasadam Complex Operating Continuously',
      titleTe: 'నిత్య అన్నప్రసాదం భవనం నిరంతర సేవలు',
      descEn: 'Tarigonda Vengamamba Complex serves hot sacred vegetarian meals continuously until 11:00 PM without token requirement. Free luggage lockers available at PAC-1, 2 & 5.',
      descTe: 'తరిగొండ వెంగమాంబ అన్నప్రసాద భవనంలో రాత్రి 11:00 వరకు టోకెన్ లేకుండా ఉచితంగా భోజన ప్రసాదం లభిస్తుంది. పీఏసీ 1, 2, 5 ల వద్ద ఉచిత లాకర్లు అందుబాటులో ఉన్నాయి.',
      category: 'Information',
      severity: 'Low',
      cta: 'Open Essentials',
      timeAgo: '3h ago',
      timeAgoTe: '3 గంటల క్రితం',
      isRead: true,
    ),
  ];

  static final Map<String, List<double>> hubCoordinates = {
    'Tirupati': [13.6288, 79.4192],
    'Tirumala': [13.6833, 79.3473],
    'Renigunta': [13.6522, 79.5160],
    'Chandragiri': [13.5855, 79.3175],
    'Srikalahasti': [13.7498, 79.6984],
    'Kanipakam': [13.2796, 79.0371],
    'Bengaluru': [12.9716, 77.5946],
    'Chennai': [13.0827, 80.2707],
    'Hyderabad': [17.3850, 78.4867],
    'Vijayawada': [16.5062, 80.6480],
  };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString('saarthi_language') ?? 'en';
      _userName = prefs.getString('saarthi_user_name') ?? '';
      _selectedLocation = prefs.getString('saarthi_location') ?? 'Tirupati';
      _currentLat = prefs.getDouble('saarthi_lat') ?? 13.6288;
      _currentLng = prefs.getDouble('saarthi_lng') ?? 79.4192;
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      _japaCount = prefs.getInt('saarthi_japa_count') ?? 1;
      final savedList = prefs.getStringList('saarthi_saved_places') ?? [];
      _savedPlaceIds.addAll(savedList);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saarthi_language', lang);
    } catch (_) {}
  }

  void toggleLanguage() {
    setLanguage(_language == 'en' ? 'te' : 'en');
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saarthi_user_name', _userName);
    } catch (_) {}
  }

  Future<void> setLocation(String loc) async {
    await setLocationWithCoordinates(loc);
  }

  Future<void> setLocationWithCoordinates(String loc, {double? lat, double? lng}) async {
    _selectedLocation = loc;
    if (lat != null && lng != null) {
      _currentLat = lat;
      _currentLng = lng;
    } else if (hubCoordinates.containsKey(loc)) {
      _currentLat = hubCoordinates[loc]![0];
      _currentLng = hubCoordinates[loc]![1];
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saarthi_location', loc);
      await prefs.setDouble('saarthi_lat', _currentLat);
      await prefs.setDouble('saarthi_lng', _currentLng);
    } catch (_) {}
  }

  double getDistanceTo(PlaceCoordinates dest, bool isTirumala) {
    return LocalRepository.calculateDrivingDistance(
      _currentLat,
      _currentLng,
      dest.lat,
      dest.lng,
      isTirumalaDestination: isTirumala,
    );
  }

  String formatTravelTime(double distanceKm, bool isTirumala) {
    if (distanceKm <= 0.1) return '1 min';
    final isHillOrigin = LocalRepository.isCoordinateOnTirumalaHill(_currentLat, _currentLng);
    final crossGhat = isHillOrigin != isTirumala;
    final avgSpeedKmH = crossGhat ? 26.0 : (isTirumala ? 20.0 : 35.0);
    final hours = distanceKm / avgSpeedKmH;
    final totalMins = (hours * 60).round();
    if (totalMins < 60) return '$totalMins mins';
    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    return m == 0 ? '$h hr' : '$h hr $m mins';
  }

  bool isPlaceSaved(String id) => _savedPlaceIds.contains(id);

  Future<void> toggleSavePlace(String id) async {
    if (_savedPlaceIds.contains(id)) {
      _savedPlaceIds.remove(id);
    } else {
      _savedPlaceIds.add(id);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saarthi_saved_places', _savedPlaceIds.toList());
    } catch (_) {}
  }

  void setEssentialsCategory(String cat) {
    _essentialsCategory = cat;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
    } catch (_) {}
  }

  Future<void> incrementJapa() async {
    if (_japaCount >= 108) {
      _japaCount = 1;
    } else {
      _japaCount++;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saarthi_japa_count', _japaCount);
    } catch (_) {}
  }

  Future<void> setJapaCount(int count) async {
    _japaCount = count.clamp(1, 108);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saarthi_japa_count', _japaCount);
    } catch (_) {}
  }

  void toggleEssential(String id) {
    if (_checkedEssentials.contains(id)) {
      _checkedEssentials.remove(id);
    } else {
      _checkedEssentials.add(id);
    }
    notifyListeners();
  }

  void markAlertAsRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1 && !_alerts[index].isRead) {
      _alerts[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAlertsAsRead() {
    bool changed = false;
    for (final a in _alerts) {
      if (!a.isRead) {
        a.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void dismissAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void addSimulatedAlert(AlertItem alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  // Common UI Localization strings
  String t(String key) {
    final strings = _localizedStrings[_language] ?? _localizedStrings['en']!;
    return strings[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'skip': 'Skip',
      'continue': 'Continue',
      'lets_go': "Let's Go!",
      'choose_language': 'Choose Your Language',
      'choose_language_sub': 'మీ భాషను ఎంచుకోండి',
      'welcome_title': 'Welcome to Saarthi',
      'welcome_sub': 'Your trusted companion for a smooth & meaningful journey in Tirupati.',
      'name_title': 'What should we call you?',
      'name_sub': "We'll personalize your dashboard & recommendations.",
      'name_hint': 'Enter your name',
      'name_example': 'e.g. Madhurima, Sunil, Sreeja',
      'privacy_note': 'Your privacy is our priority. We never share your details; they are stored strictly on this device.',
      'enable_location': 'Enable Location',
      'enable_location_sub': 'Allow location to find nearby places, show accurate distance and the best routes.',
      'allow_location': 'Allow Location',
      'select_city_hub': 'Select Starting City / Hub',
      'not_now': 'Not Now',
      'home': 'Home',
      'essentials': 'Essentials',
      'explore': 'Explore',
      'live_status': 'Tirumala Live Status',
      'free_entry': 'FREE ENTRY',
      'sarva_darshan': 'Sarva Darshan',
      'special_entry': 'SPECIAL ENTRY',
      'special_entry_darshan': '₹300 Darshan',
      'timed_slot': 'TIMED SLOT',
      'ssd_tokens': 'SSD Tokens',
      'hours': 'Hours',
      'closed_today': 'Cancelled',
      'saarthi_recommends': 'SAARTHI RECOMMENDS',
      'why_visit': 'Why visit',
      'notifications': 'Alerts & Notices',
      'no_notifications': 'No active notices at this moment',
      'mark_all_read': 'Mark all read',
      'simulate_alert': 'Simulate Live Alert',
      'filter_all': 'All',
      'filter_high': 'High Priority',
      'filter_advisory': 'Advisory',
      'filter_info': 'Information',
    },
    'te': {
      'skip': 'దాటవేయి',
      'continue': 'కొనసాగండి',
      'lets_go': 'ప్రారంభిద్దాం!',
      'choose_language': 'మీ భాషను ఎంచుకోండి',
      'choose_language_sub': 'Choose Your Language',
      'welcome_title': 'సారథికి స్వాగతం',
      'welcome_sub': 'తిరుపతి యాత్రను సులభంగా, ఆధ్యాత్మికంగా అనుభవించేందుకు మీ విశ్వసనీయ సహచరి.',
      'name_title': 'మిమ్మల్ని ఏమని పిలవాలి?',
      'name_sub': 'మీ తిరుమల యాత్ర వివరాలను మీ కోసం ప్రత్యేకంగా తీర్చిదిద్దుతాం.',
      'name_hint': 'మీ పేరు నమోదు చేయండి',
      'name_example': 'ఉదా: మధురిమ, సునీల్, శ్రీజ',
      'privacy_note': 'మీ గోప్యత మా బాధ్యత. మీ వివరాలు సురక్షితంగా కేవలం మీ ఫోన్‌లోనే ఉంటాయి.',
      'enable_location': 'లొకేషన్ ఆన్ చేయండి',
      'enable_location_sub': 'సమీప క్షేత్రాలు, ఖచ్చితమైన దూరం మరియు సరైన మార్గాల కోసం లొకేషన్ అనుమతించండి.',
      'allow_location': 'లొకేషన్ అనుమతించండి',
      'select_city_hub': 'ప్రారంభ నగరం / కేంద్రం ఎంచుకోండి',
      'not_now': 'ఇప్పుడు కాదు',
      'home': 'హోమ్',
      'essentials': 'అవసరాలు',
      'explore': 'అన్వేషించు',
      'live_status': 'తిరుమల లైవ్ స్టేటస్',
      'free_entry': 'ఉచిత ప్రవేశం',
      'sarva_darshan': 'సర్వదర్శనం',
      'special_entry': 'ప్రత్యేక ప్రవేశం',
      'special_entry_darshan': '₹300 దర్శనం',
      'timed_slot': 'టైమ్డ్ స్లాట్',
      'ssd_tokens': 'SSD టోకెన్లు',
      'hours': 'గంటలు',
      'closed_today': 'రద్దు చేయబడింది',
      'saarthi_recommends': 'సారథి సూచన',
      'why_visit': 'దర్శన విశిష్టత',
      'notifications': 'హెచ్చరికలు & సమాచారం',
      'no_notifications': 'ప్రస్తుతం ఎలాంటి నోటీసులు లేవు',
      'mark_all_read': 'అన్నీ చదివినట్లుగా మార్చు',
      'simulate_alert': 'లైవ్ హెచ్చరిక అనుకరణ',
      'filter_all': 'అన్నీ',
      'filter_high': 'ముఖ్యమైనవి',
      'filter_advisory': 'సూచనలు',
      'filter_info': 'సమాచారం',
    },
  };
}
