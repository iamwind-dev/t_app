import 'package:t_app/core/config/app_config.dart';

class BackendUrlNormalizer {
  const BackendUrlNormalizer._();

  static const _cloudinaryPlaybackVideoTransform = 'f_mp4,vc_h264,ac_aac';

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

    final cloudinaryPlayerUrl = _cloudinaryPlayerToVideoUrl(uri);
    if (cloudinaryPlayerUrl != null) {
      return cloudinaryPlayerUrl;
    }

    if (uri.host.toLowerCase() != 'res.cloudinary.com') {
      return normalizedUrl;
    }

    final segments = uri.pathSegments.toList(growable: true);
    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex < 0 || uploadIndex == 0) {
      return normalizedUrl;
    }

    final transformedSegments = <String>[
      ...segments.take(uploadIndex + 1),
      _cloudinaryPlaybackVideoTransform,
    ];

    final nextIndex = uploadIndex + 1;
    final hasExistingTransform =
        nextIndex < segments.length && !segments[nextIndex].startsWith('v');
    final remainingStartIndex = hasExistingTransform ? nextIndex + 1 : nextIndex;
    transformedSegments.addAll(segments.skip(remainingStartIndex));

    final lastIndex = transformedSegments.length - 1;
    if (lastIndex >= 0) {
      final fileName = transformedSegments[lastIndex];
      final dotIndex = fileName.lastIndexOf('.');
      final baseName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
      transformedSegments[lastIndex] = '$baseName.mp4';
    }

    return uri
        .replace(
          pathSegments: transformedSegments,
          queryParameters: null,
        )
        .toString();
  }

  static List<String> videoPlaybackCandidates(String rawUrl) {
    final normalized = normalize(rawUrl);
    final playback = normalizeVideoPlayback(rawUrl);
    final source = normalizeCloudinarySourceVideo(rawUrl);
    final sourceWithoutExtension = normalizeCloudinarySourceVideo(
      rawUrl,
      removeExtension: true,
    );
    final candidates = <String>[
      playback,
      source,
      sourceWithoutExtension,
      normalized,
      rawUrl,
    ];

    return candidates
        .where((candidate) => candidate.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  static String normalizeCloudinarySourceVideo(
    String rawUrl, {
    bool removeExtension = false,
  }) {
    final normalizedUrl = normalize(rawUrl);
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null || uri.host.toLowerCase() != 'res.cloudinary.com') {
      return normalizedUrl;
    }

    final segments = uri.pathSegments.toList(growable: true);
    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex < 0 || uploadIndex == 0) {
      return normalizedUrl;
    }

    final nextIndex = uploadIndex + 1;
    final hasExistingTransform =
        nextIndex < segments.length && !segments[nextIndex].startsWith('v');
    final sourceSegments = <String>[
      ...segments.take(uploadIndex + 1),
      ...segments.skip(hasExistingTransform ? nextIndex + 1 : nextIndex),
    ];

    if (removeExtension && sourceSegments.isNotEmpty) {
      final lastIndex = sourceSegments.length - 1;
      final fileName = sourceSegments[lastIndex];
      final dotIndex = fileName.lastIndexOf('.');
      if (dotIndex > 0) {
        sourceSegments[lastIndex] = fileName.substring(0, dotIndex);
      }
    }

    return uri.replace(
      pathSegments: sourceSegments,
      queryParameters: null,
    ).toString();
  }

  static String? _cloudinaryPlayerToVideoUrl(Uri uri) {
    if (uri.host.toLowerCase() != 'player.cloudinary.com') {
      return null;
    }

    final cloudName = uri.queryParameters['cloud_name']?.trim();
    final publicId = uri.queryParameters['public_id']?.trim();
    if (cloudName == null ||
        cloudName.isEmpty ||
        publicId == null ||
        publicId.isEmpty) {
      return null;
    }

    final normalizedPublicId = publicId.replaceAll('%2F', '/');
    return Uri.https(
      'res.cloudinary.com',
      '/$cloudName/video/upload/$_cloudinaryPlaybackVideoTransform/$normalizedPublicId.mp4',
    ).toString();
  }
}
