enum AppFlavor {
  dev,
  prod;

  static AppFlavor fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppFlavor.dev;
      case 'prod':
      case 'production':
      default:
        return AppFlavor.prod;
    }
  }
}

class AppEnvironment {
  AppEnvironment._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableVerboseLogs,
  });

  static AppEnvironment? _current;

  static AppEnvironment get current => _current ??= _fromFlavor(
    AppFlavor.fromString(
      const String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod'),
    ),
  );

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String appName;
  final bool enableVerboseLogs;

  static const String _defaultDevApiBaseUrl = 'http://10.0.2.2:5000/api';
  static const String _defaultProdApiBaseUrl =
      'https://backend-r9e6.onrender.com/api';

  static const String _defaultDevAppName = 'Travel Diary Dev';
  static const String _defaultProdAppName = 'Travel Diary';

  static void initialize(AppFlavor flavor) {
    _current = AppEnvironment._fromFlavor(flavor);
  }

  static AppEnvironment _fromFlavor(AppFlavor flavor) {
    final apiBaseUrlOverride = const String.fromEnvironment('API_BASE_URL');
    final appNameOverride = const String.fromEnvironment('APP_NAME');
    final verboseLogs = const bool.fromEnvironment(
      'ENABLE_VERBOSE_LOGS',
      defaultValue: false,
    );

    final defaultApiBaseUrl = switch (flavor) {
      AppFlavor.dev => _defaultDevApiBaseUrl,
      AppFlavor.prod => _defaultProdApiBaseUrl,
    };

    final defaultAppName = switch (flavor) {
      AppFlavor.dev => _defaultDevAppName,
      AppFlavor.prod => _defaultProdAppName,
    };

    return AppEnvironment._(
      flavor: flavor,
      apiBaseUrl: apiBaseUrlOverride.isNotEmpty
          ? apiBaseUrlOverride
          : defaultApiBaseUrl,
      appName: appNameOverride.isNotEmpty ? appNameOverride : defaultAppName,
      enableVerboseLogs: verboseLogs || flavor == AppFlavor.dev,
    );
  }
}
