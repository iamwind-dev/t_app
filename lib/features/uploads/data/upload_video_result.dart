import 'package:equatable/equatable.dart';

class UploadVideoResult extends Equatable {
  const UploadVideoResult({
    required this.url,
    required this.publicId,
    this.durationSeconds,
  });

  factory UploadVideoResult.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    final publicId = json['publicId'] as String?;
    if (url == null || url.isEmpty) {
      throw const FormatException('Upload video response missing url.');
    }
    if (publicId == null || publicId.isEmpty) {
      throw const FormatException('Upload video response missing publicId.');
    }

    return UploadVideoResult(
      url: url,
      publicId: publicId,
      durationSeconds: (json['durationSeconds'] as num?)?.round(),
    );
  }

  final String url;
  final String publicId;
  final int? durationSeconds;

  @override
  List<Object?> get props => [url, publicId, durationSeconds];
}
