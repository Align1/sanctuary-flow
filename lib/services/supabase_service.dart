import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rooted/config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  /// User authentication
  Future<AuthResponse> signInAnonymously() async {
    return await client.auth.signInAnonymously();
  }

  Future<AuthResponse> signUp({required String email, required String password, required String name}) async {
    // If the user is currently anonymous, updating their email/password 
    // will "convert" the anonymous account to a permanent one.
    if (currentUser?.isAnonymous ?? false) {
      final response = await client.auth.updateUser(
        UserAttributes(email: email, password: password, data: {'full_name': name}),
      );
      try {
        await upsertProfile({'full_name': name});
      } catch (e) {
        debugPrint('Silent error: Failed to upsert profile during conversion: $e');
      }
      return AuthResponse(session: client.auth.currentSession, user: response.user);
    } else {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (response.user != null) {
        try {
          await upsertProfile({'full_name': name});
        } catch (e) {
          debugPrint('Silent error: Failed to upsert profile during signup: $e');
        }
      }
      return response;
    }
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;
  bool get isGuest => currentUser?.isAnonymous ?? true;
  bool get isAuthenticated => currentUser != null;

  /// Database operations
  Future<void> upsertProfile(Map<String, dynamic> profile) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('profiles').upsert({
      'id': userId,
      ...profile,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveBibleReading(Map<String, dynamic> reading) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('bible_readings').insert({
      'user_id': userId,
      ...reading,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> savePrayer(Map<String, dynamic> prayer) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('prayers').insert({
      'user_id': userId,
      ...prayer,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveAchievement(Map<String, dynamic> achievement) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('achievements').upsert({
      'user_id': userId,
      'achievement_id': achievement['id'],
      ...achievement,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveMessage(Map<String, dynamic> message) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('messages').upsert({
      'user_id': userId,
      'message_id': message['id'],
      ...message,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveBook(Map<String, dynamic> book) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('books').upsert({
      'user_id': userId,
      'book_id': book['id'],
      ...book,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveGoal(Map<String, dynamic> goal) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await client.from('goals').upsert({
      'user_id': userId,
      'goal_id': goal['id'],
      ...goal,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Fetch all user data for synchronization
  Future<Map<String, List<Map<String, dynamic>>>> fetchUserData() async {
    final userId = currentUser?.id;
    if (userId == null) return {};

    final profile = await client.from('profiles').select().eq('id', userId).maybeSingle();
    final bibleReadings = await client.from('bible_readings').select().eq('user_id', userId);
    final prayers = await client.from('prayers').select().eq('user_id', userId);
    final achievements = await client.from('achievements').select().eq('user_id', userId);
    final messages = await client.from('messages').select().eq('user_id', userId);
    final books = await client.from('books').select().eq('user_id', userId);
    final goals = await client.from('goals').select().eq('user_id', userId);

    return {
      'profile': profile != null ? [profile] : [],
      'bible_readings': List<Map<String, dynamic>>.from(bibleReadings),
      'prayers': List<Map<String, dynamic>>.from(prayers),
      'achievements': List<Map<String, dynamic>>.from(achievements),
      'messages': List<Map<String, dynamic>>.from(messages),
      'books': List<Map<String, dynamic>>.from(books),
      'goals': List<Map<String, dynamic>>.from(goals),
    };
  }

  /// Daily Verse operations
  Future<Map<String, dynamic>?> getDailyVerse(int dayOfYear) async {
    try {
      final response = await client
          .from('daily_verses')
          .select()
          .eq('day_of_year', dayOfYear)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching daily verse: $e');
      return null;
    }
  }

  /// Test the connection to Supabase
  Future<bool> testConnection() async {
    try {
      // Try to fetch one row from profiles to test connectivity
      await client.from('profiles').select().limit(1).maybeSingle();
      return true;
    } catch (e) {
      debugPrint('Supabase connection test failed: $e');
      return false;
    }
  }
}
