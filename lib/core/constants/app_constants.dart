class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Medigram';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Medical Information Sharing Platform';

  // Pagination
  static const int defaultPageSize = 25;
  static const int maxPageSize = 100;

  // Timeouts
  static const int apiTimeout = 15000; // milliseconds
  static const int imageLoadTimeout = 10000;

  // Image Sizes
  static const double avatarSize = 40.0;
  static const double avatarSizeLarge = 80.0;
  static const double cardImageHeight = 400.0;
  static const double thumbnailSize = 120.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Text Limits
  static const int maxTitleLength = 200;
  static const int maxContentLength = 10000;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 500;

  // Card Swipe Threshold
  static const double swipeThreshold = 0.3;
  static const double swipeVelocityThreshold = 300.0;

  // Cache
  static const int maxCacheSize = 100; // MB
  static const Duration cacheExpiration = Duration(days: 7);

  // Categories
  static const List<String> medicalCategories = [
    'Kardiyoloji',
    'Nöroloji',
    'Pediatri',
    'Dahiliye',
    'Cerrahi',
    'Radyoloji',
    'Psikiyatri',
    'Onkoloji',
    'Ortopedi',
    'Göz Hastalıkları',
    'KBB',
    'Diğer',
  ];

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  // Reading Time Colors (minutes)
  static const Map<String, dynamic> readingTimeRanges = {
    'quick': {'max': 3, 'label': 'Hızlı Okuma'},
    'normal': {'max': 10, 'label': 'Normal'},
    'long': {'max': 999, 'label': 'Detaylı'},
  };

  // Error Messages
  static const String errorGeneric = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork = 'İnternet bağlantınızı kontrol edin.';
  static const String errorAuth = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
  static const String errorNotFound = 'Aradığınız içerik bulunamadı.';

  // Success Messages
  static const String successLogin = 'Giriş başarılı!';
  static const String successRegister = 'Kayıt başarılı!';
  static const String successLike = 'Beğenildi!';
  static const String successUnlike = 'Beğeni kaldırıldı.';
  static const String successShare = 'Paylaşıldı!';

  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const String emailRegex = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';

  // Premium Features
  static const String premiumSubscriptionId = 'medigram_premium_monthly';
  static const double premiumPrice = 29.99;
  static const String premiumCurrency = 'TRY';

  // Social Share
  static const String shareText = 'Medigram\'da bu ilginç medikal içeriği gördüm: ';
  static const String appStoreUrl = 'https://apps.apple.com/app/medigram';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.medigram.app';
}
