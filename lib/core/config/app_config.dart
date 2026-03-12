class AppConfig {
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'NexusPoint POS',
  );

  static const String appOrigin = String.fromEnvironment(
    'APP_ORIGIN',
    defaultValue: 'https://nexuslab.asia',
  );

  static const String googleCloudProject = String.fromEnvironment(
    'GOOGLE_CLOUD_PROJECT',
    defaultValue: 'nexuspoint-prod',
  );

  static const String gaMeasurementId = String.fromEnvironment(
    'GA_MEASUREMENT_ID',
    defaultValue: '',
  );

  static const String apiOrigin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'https://nexuslab.asia/api/',
  );

  static bool get isLocal => appName.contains('(Local)');
}
