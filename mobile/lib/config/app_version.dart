/// Application version. Keep in sync with the `version` field in pubspec.yaml.
abstract final class AppVersion {
  static const String version = '0.1.1';
  static const String buildNumber = '2';

  static String get label => 'Version $version ($buildNumber)';
}
