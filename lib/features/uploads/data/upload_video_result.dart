import 'package:equatable/equatable.dart';
import 'package:t_app/features/uploads/data/upload_moderation.dart';

class UploadVideoResult extends Equatable {
  const UploadVideoResult({
    required this.url,
    required this.publicId,
    this.durationSeconds,
    this.moderation = UploadModeration.none,
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
      durationSeconds: json['durationSeconds'] as int?,
      moderation: _parseModeration(json['moderation']),
    );
  }

  final String url;
  final String publicId;
  final int? durationSeconds;
  final UploadModeration moderation;

  @override
  List<Object?> get props => [url, publicId, durationSeconds, moderation];

  static UploadModeration _parseModeration(Object? value) {
    if (value is Map<String, dynamic>) {
      return UploadModeration.fromJson(value);
    }

    return UploadModeration.none;
  }
}
