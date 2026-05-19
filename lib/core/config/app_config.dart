class AppConfig {
  const AppConfig._();

  // Keep backend mode on by default now that API repositories are wired.
  static const uiPreviewMode = false;

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
