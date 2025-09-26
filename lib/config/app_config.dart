import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();
  bool _isLoaded = false;

  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    try {
      await dotenv.load(fileName: 'assets/config/.env');
    } catch (_) {
      await dotenv.load(fileName: 'assets/config/.env.example');
    }
    _isLoaded = true;
  }

  String get _baseUrl => _read('API_BASE_URL', 'http://localhost:1337/api');
  String get _assetsBaseUrl => _read('API_ASSETS_BASE_URL', _baseUrl.replaceAll('/api', ''));

  Uri buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalized = _normalizePath(path);
    return Uri.parse(_baseUrl).replace(
      path: _concatenatePaths(Uri.parse(_baseUrl).path, normalized),
      queryParameters: queryParameters?.map((key, value) => MapEntry(key, '$value')),
    );
  }

  Uri buildAssetUri(String? path) {
    if (path == null || path.isEmpty) {
      return Uri.parse(_assetsBaseUrl);
    }
    if (path.startsWith('http')) {
      return Uri.parse(path);
    }
    return Uri.parse(_assetsBaseUrl).replace(
      path: _concatenatePaths(Uri.parse(_assetsBaseUrl).path, path),
    );
  }

  String get medicalCardsPath => _read('MEDICAL_CARDS_PATH', '/medical-cards');
  String get medicalCardsPopulate => _read('MEDICAL_CARDS_POPULATE', '');
  String get categoriesPath => _read('CATEGORIES_PATH', '/categories');
  String get paymentCheckoutPath => _read('PAYMENT_CHECKOUT_PATH', '/payments/checkout');
  String get aiChatPath => _read('AI_CHAT_PATH', '/ai/chat');
  String get adminCreateCardPath => _read('ADMIN_CREATE_CARD_PATH', '/admin/manual-cards');
  String get adminGenerateCardPath => _read('ADMIN_GENERATE_CARD_PATH', '/admin/ai/generate');
  String get adminCategoryRefreshPath => _read('ADMIN_CATEGORY_REFRESH_PATH', '/admin/categories/sync');

  Duration get requestTimeout => Duration(
        milliseconds: int.tryParse(_read('REQUEST_TIMEOUT_MS', '15000')) ?? 15000,
      );

  bool get useMockData {
    final value = _read('USE_MOCK_DATA', kReleaseMode ? 'false' : 'true');
    return value.toLowerCase() == 'true';
  }

  String _read(String key, String fallback) {
    final value = dotenv.maybeGet(key);
    if (value == null) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _normalizePath(String path) {
    if (path.isEmpty) return '';
    return path.startsWith('/') ? path : '/$path';
  }

  String _concatenatePaths(String a, String b) {
    final first = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final second = b.startsWith('/') ? b : '/$b';
    return '$first$second';
  }
}
