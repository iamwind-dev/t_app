import 'package:equatable/equatable.dart';

enum UploadModerationAction {
  allow('allow'),
  blurAllowOpen('blur_allow_open'),
  blurNoOpen('blur_no_open'),
  block('block');

  const UploadModerationAction(this.value);

  factory UploadModerationAction.fromValue(String? value) {
    return UploadModerationAction.values.firstWhere(
      (item) => item.value == value,
      orElse: () => UploadModerationAction.allow,
    );
  }

  final String value;
}

class UploadModeration extends Equatable {
  const UploadModeration({
    required this.originalLabel,
    required this.mappedCategory,
    required this.confidence,
    required this.mediaType,
    required this.action,
    required this.canOpen,
    required this.shouldBlur,
    required this.reason,
  });

  factory UploadModeration.fromJson(Map<String, dynamic> json) {
    return UploadModeration(
      originalLabel: json['original_label'] as String? ?? '',
      mappedCategory: json['mapped_category'] as String? ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      mediaType: json['media_type'] as String? ?? 'image',
      action: UploadModerationAction.fromValue(json['action'] as String?),
      canOpen: json['can_open'] as bool? ?? false,
      shouldBlur: json['should_blur'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
    );
  }

  static const UploadModeration none = UploadModeration(
    originalLabel: '',
    mappedCategory: 'unknown',
    confidence: 0,
    mediaType: 'image',
    action: UploadModerationAction.allow,
    canOpen: true,
    shouldBlur: false,
    reason: '',
  );

  final String originalLabel;
  final String mappedCategory;
  final double confidence;
  final String mediaType;
  final UploadModerationAction action;
  final bool canOpen;
  final bool shouldBlur;
  final String reason;

  String warningMessage() {
    switch (mappedCategory) {
      case 'suggestive':
        return 'Nội dung nhạy cảm.';
      case 'blood_gore':
        return 'Nội dung kinh dị, có thể gây ám ảnh.';
      case 'sexual_explicit':
      case 'explicit_anime':
        return 'Nội dung nhạy cảm cao.';
      default:
        return 'Nội dung nhạy cảm.';
    }
  }

  @override
  List<Object?> get props => [
    originalLabel,
    mappedCategory,
    confidence,
    mediaType,
    action,
    canOpen,
    shouldBlur,
    reason,
  ];
}

