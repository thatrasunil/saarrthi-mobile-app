import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/darshan.dart';
import '../core/constants.dart';

class SupabaseRepository {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      _initialized = true;
    } catch (_) {
      // Offline mode fallback
    }
  }

  Future<DarshanStatus> getLiveDarshanStatus() async {
    if (!_initialized) return DarshanStatus.sample();

    try {
      final response = await Supabase.instance.client
          .from('live_status')
          .select()
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return DarshanStatus.fromJson(response);
      }
    } catch (_) {
      // Fallback to sample status if offline or error
    }

    return DarshanStatus.sample();
  }

  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    if (!_initialized) return [];

    try {
      final response = await Supabase.instance.client
          .from('alerts')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }
}
