import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  GoTrueClient? _auth;

  bool _initialized = false;

  SupabaseClient get client {
    if (_client == null) throw Exception('Supabase not initialized');
    return _client!;
  }

  GoTrueClient get auth {
    if (_auth == null) throw Exception('Supabase not initialized');
    return _auth!;
  }

  bool get isInitialized => _initialized;

  bool get isLoggedIn => _auth?.currentUser != null;

  String? get userId => _auth?.currentUser?.id;

  String? get userEmail => _auth?.currentUser?.email;

  User? get currentUser => _auth?.currentUser;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final url = dotenv.env['SUPABASE_URL'] ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      if (url.isEmpty || anonKey.isEmpty) return;
      await Supabase.initialize(url: url, anonKey: anonKey);
      _client = Supabase.instance.client;
      _auth = _client!.auth;
      _initialized = true;
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Stream<AuthState> get onAuthStateChange => auth.onAuthStateChange;
}
