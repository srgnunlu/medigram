enum EnvironmentType {
  development,
  staging,
  production,
}

class Environment {
  static EnvironmentType _currentEnvironment = EnvironmentType.development;

  static EnvironmentType get currentEnvironment => _currentEnvironment;

  static void setEnvironment(EnvironmentType env) {
    _currentEnvironment = env;
  }

  // API Configuration
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case EnvironmentType.development:
        return 'http://localhost:1337/api';
      case EnvironmentType.staging:
        return 'https://staging-api.medigram.com/api';
      case EnvironmentType.production:
        return 'https://api.medigram.com/api';
    }
  }

  static String get webSocketUrl {
    switch (_currentEnvironment) {
      case EnvironmentType.development:
        return 'ws://localhost:1337';
      case EnvironmentType.staging:
        return 'wss://staging-api.medigram.com';
      case EnvironmentType.production:
        return 'wss://api.medigram.com';
    }
  }

  // Feature Flags
  static bool get enableAnalytics {
    return _currentEnvironment == EnvironmentType.production ||
        _currentEnvironment == EnvironmentType.staging;
  }

  static bool get enableCrashReporting {
    return _currentEnvironment == EnvironmentType.production ||
        _currentEnvironment == EnvironmentType.staging;
  }

  static bool get enableLogging {
    return _currentEnvironment == EnvironmentType.development;
  }

  static bool get enableDebugMode {
    return _currentEnvironment == EnvironmentType.development;
  }

  // App Configuration
  static String get appName {
    switch (_currentEnvironment) {
      case EnvironmentType.development:
        return 'Medigram Dev';
      case EnvironmentType.staging:
        return 'Medigram Staging';
      case EnvironmentType.production:
        return 'Medigram';
    }
  }

  static String get appVersion => '1.0.0';
  static String get buildNumber => '1';

  // Cache Configuration
  static Duration get apiCacheDuration {
    return const Duration(minutes: 5);
  }

  static Duration get imageCacheDuration {
    return const Duration(days: 7);
  }

  // Timeout Configuration
  static Duration get connectTimeout {
    return const Duration(seconds: 30);
  }

  static Duration get receiveTimeout {
    return const Duration(seconds: 30);
  }

  // Pagination
  static int get defaultPageSize => 20;
  static int get maxPageSize => 100;

  // Media Upload
  static int get maxImageSizeMB => 10;
  static int get maxVideoSizeMB => 50;

  // Rate Limiting (client-side)
  static int get maxRequestsPerMinute => 60;

  // Error Reporting
  static bool get shouldReportError {
    return _currentEnvironment != EnvironmentType.development;
  }

  // Debug Info
  static Map<String, dynamic> get environmentInfo => {
        'environment': _currentEnvironment.name,
        'apiBaseUrl': apiBaseUrl,
        'appName': appName,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'enableAnalytics': enableAnalytics,
        'enableCrashReporting': enableCrashReporting,
        'enableLogging': enableLogging,
      };
}
