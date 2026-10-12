import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Service connecting the Flutter application to the Saarthi Admin backend.
/// Follows Ponytail First Principles: uses native dart:io HttpClient with zero new dependencies.
class AdminRepository {
  static final AdminRepository instance = AdminRepository._internal();
  AdminRepository._internal();

  static const String defaultBaseUrl = 'https://www.saarthiguide.in';
  static const String defaultAdminToken = 'saarthi_admin_token_2026';

  String _baseUrl = defaultBaseUrl;
  String _adminToken = defaultAdminToken;
  bool _isAdminLoggedIn = false;

  String get baseUrl => _baseUrl;
  String get adminToken => _adminToken;
  bool get isAdminLoggedIn => _isAdminLoggedIn;

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('saarthi_admin_base_url') ?? defaultBaseUrl;
      _adminToken = prefs.getString('saarthi_admin_token') ?? defaultAdminToken;
      _isAdminLoggedIn = prefs.getBool('saarthi_is_admin') ?? false;
    } catch (_) {}
  }

  Future<bool> login(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) return false;

    // Check if token matches standard admin secret
    if (cleanToken == 'saarthi_admin_token_2026' || cleanToken == 'admin2026' || cleanToken == 'jeevapath_admin_2024') {
      _adminToken = cleanToken;
      _isAdminLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saarthi_admin_token', _adminToken);
      await prefs.setBool('saarthi_is_admin', true);
      return true;
    }

    // Also attempt remote verification against admin login API
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/admin/login');
      final request = await _client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode({'email': 'admin@saarthiguide.in', 'password': cleanToken}));
      final response = await request.close();
      if (response.statusCode == 200) {
        _adminToken = cleanToken;
        _isAdminLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saarthi_admin_token', _adminToken);
        await prefs.setBool('saarthi_is_admin', true);
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<void> logout() async {
    _isAdminLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saarthi_is_admin', false);
  }

  /// Fetches live Darshan and crowd status from the central backend.
  Future<Map<String, dynamic>?> fetchLiveStatus() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/live-status');
      final request = await _client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Offline fallback
    }
    return null;
  }

  /// Updates Live Darshan & Crowd Wait Times (Admin authorized).
  Future<bool> updateLiveMetrics({
    required int crowdWaitMinutes,
    required String crowdLevel,
    required String sarvaDarshanWait,
    required String specialEntryWait,
    required String divyaDarshanWait,
    required String srivaniWait,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/admin/live');
      final request = await _client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_adminToken');
      request.write(jsonEncode({
        'crowd_wait_minutes': crowdWaitMinutes,
        'crowd_level': crowdLevel,
        'sarva_darshan_wait': sarvaDarshanWait,
        'special_entry_wait': specialEntryWait,
        'divya_darshan_wait': divyaDarshanWait,
        'srivani_darshan_wait': srivaniWait,
      }));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Updates SSD Token status, issuing locations, and advisories (Admin authorized).
  Future<bool> updateSsdTokenStatus({
    required String status,
    required String notice,
    String? nextTokenTime,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/admin/ssd-tokens');
      final request = await _client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_adminToken');
      request.write(jsonEncode({
        'ssdTokenStatus': status,
        'ssdNotice': notice,
        if (nextTokenTime != null) 'ssdNextTokenTime': nextTokenTime,
      }));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Broadcasts a live emergency or crowd advisory to all devotees (Admin authorized).
  Future<bool> broadcastAlert({
    required String titleEn,
    required String titleTe,
    required String descEn,
    required String descTe,
    required String category,
    required String severity,
    required String cta,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/admin/status');
      final request = await _client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_adminToken');
      request.write(jsonEncode({
        'notice': descEn,
        'noticeTe': descTe,
      }));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
