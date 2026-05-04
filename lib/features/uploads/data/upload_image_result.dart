import 'package:equatable/equatable.dart';

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
    return UploadImageResult(
      secureUrl: json['secureUrl'] as String,
      publicId: json['publicId'] as String,
      type: UploadImageType.fromValue(json['type'] as String),
    );
  }

  final String secureUrl;
  final String publicId;
  final UploadImageType type;

  @override
  List<Object?> get props => [secureUrl, publicId, type];
}
