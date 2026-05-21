import 'package:t_app/core/config/app_config.dart';

class BackendUrlNormalizer {
  const BackendUrlNormalizer._();

  static Uri? get _baseUri => Uri.tryParse(AppConfig.apiBaseUrl);

  static String? normalizeNullable(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) {
      return rawUrl;
    }
    return normalize(rawUrl);
  }

  static String normalize(String rawUrl) {
    final input = Uri.tryParse(rawUrl);
    final base = _baseUri;
    if (input == null || base == null) {
      return rawUrl;
    }

    if (!input.hasScheme && rawUrl.startsWith('/')) {
      return base.resolveUri(input).toString();
    }

    final host = input.host.toLowerCase();
    if (host != 'localhost' && host != '127.0.0.1') {
      return rawUrl;
    }

    return input.replace(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    ).toString();
  }
}
