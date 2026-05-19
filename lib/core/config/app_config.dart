class AppConfig {
  const AppConfig._();

  // Temporary UI preview mode: bypass backend calls so the app can be explored
  // before API/environment setup is ready.
  static const uiPreviewMode = true;

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
