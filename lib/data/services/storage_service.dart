import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  StorageService._internal();

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token management (secure storage)
  static const String _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // User data management (shared preferences for non-sensitive data)
  static const String _userKey = 'user_data';

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await init();
    await _prefs?.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUser() async {
    await init();
    final userJson = _prefs?.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUser() async {
    await init();
    await _prefs?.remove(_userKey);
  }

  // Onboarding status
  static const String _onboardingKey = 'onboarding_completed';

  Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await _prefs?.setBool(_onboardingKey, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    await init();
    return _prefs?.getBool(_onboardingKey) ?? false;
  }

  // Theme preference
  static const String _themeKey = 'theme_mode';

  Future<void> saveThemeMode(String mode) async {
    await init();
    await _prefs?.setString(_themeKey, mode);
  }

  Future<String?> getThemeMode() async {
    await init();
    return _prefs?.getString(_themeKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
    await init();
    await _prefs?.clear();
  }
}
