import 'package:t_app/core/config/app_config.dart';

class BackendUrlNormalizer {
  const BackendUrlNormalizer._();

  static const _cloudinaryAndroidVideoTransform = 'f_mp4,vc_h264,ac_aac,fl_progressive,q_auto';

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

  static String normalizeVideoPlayback(String rawUrl) {
    final normalizedUrl = normalize(rawUrl);
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      return normalizedUrl;
    }

    if (uri.host.toLowerCase() != 'res.cloudinary.com') {
      return normalizedUrl;
    }

    final segments = uri.pathSegments.toList(growable: true);
    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex < 0 || uploadIndex == 0) {
      return normalizedUrl;
    }

    final transformedSegments = List<String>.from(segments);
    final nextIndex = uploadIndex + 1;
    final hasExistingTransform =
        nextIndex < transformedSegments.length &&
        !transformedSegments[nextIndex].startsWith('v');

    if (hasExistingTransform) {
      if (!transformedSegments[nextIndex].contains('f_mp4')) {
        transformedSegments[nextIndex] =
            '${transformedSegments[nextIndex]},$_cloudinaryAndroidVideoTransform';
      }
    } else {
      transformedSegments.insert(nextIndex, _cloudinaryAndroidVideoTransform);
    }

    final lastIndex = transformedSegments.length - 1;
    if (lastIndex >= 0) {
      final fileName = transformedSegments[lastIndex];
      final dotIndex = fileName.lastIndexOf('.');
      final baseName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
      transformedSegments[lastIndex] = '$baseName.mp4';
    }

    return uri.replace(pathSegments: transformedSegments).toString();
  }
}
