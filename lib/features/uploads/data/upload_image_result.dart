import 'package:equatable/equatable.dart';
import 'package:t_app/core/network/backend_url_normalizer.dart';

enum UploadImageType {
  post('post'),
  reply('reply'),
  profileAvatar('profile_avatar');

  const UploadImageType(this.value);

  factory UploadImageType.fromValue(String value) {
    return UploadImageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw FormatException('Unsupported upload type: $value'),
    );
  }

  final String value;
}

class UploadImageResult extends Equatable {
  const UploadImageResult({
    required this.secureUrl,
    required this.publicId,
    required this.type,
  });

  factory UploadImageResult.fromJson(Map<String, dynamic> json) {
    final secureUrl = json['secureUrl'] as String? ?? json['url'] as String?;
    final publicId = json['publicId'] as String?;
    final typeValue = json['type'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw const FormatException('Upload image response missing url.');
    }
    if (publicId == null || publicId.isEmpty) {
      throw const FormatException('Upload image response missing publicId.');
    }
    if (typeValue == null || typeValue.isEmpty) {
      throw const FormatException('Upload image response missing type.');
    }

    return UploadImageResult(
      secureUrl: BackendUrlNormalizer.normalize(secureUrl),
      publicId: publicId,
      type: UploadImageType.fromValue(typeValue),
    );
  }

  final String secureUrl;
  final String publicId;
  final UploadImageType type;

  @override
  List<Object?> get props => [secureUrl, publicId, type];
}
